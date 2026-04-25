USE DataWarehouse;

--Creating Dimension Tables

CREATE VIEW gold.dim_vessels AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY Vessel_Id) AS vessel_sk,
    vessel_id,
    ISNULL(Vessel_Name, 'Unknown Vessel') AS vessel_name,
    shipping_line_id,
    arrival_atb,
    departure_atd,
    terminal_id,
    -- BUSINESS LOGIC: Calculate stay duration in hours
    CAST(DATEDIFF(MINUTE, Arrival_atb, Departure_atd) / 60.0 AS DECIMAL(10,2)) AS port_stay_duration_hours,
    -- BUSINESS LOGIC: Categorize Vessel Size (Example logic)
    CASE 
        WHEN vessel_id IN ('VESS_001', 'VESS_002', 'VESS_014', 'VESS_017', 'VESS_021', 'VESS_025', 'VESS_032', 'VESS_036', 'VESS_044', 'VESS_049',  'VESS_036', 'VESS_044', 'VESS_049',  'VESS_055', 'VESS_056', 'VESS_061',  'VESS_069', 'VESS_073', 'VESS_079', 'VESS_085', 'VESS_090', 'VESS_091', 'VESS_096') THEN 'Post-Panamax'
        ELSE 'Feeder'
    END AS vessel_class,
    -- BUSINESS LOGIC: Current Status based on ATD
    CASE 
        WHEN Departure_atd IS NULL THEN 'At Berth'
        WHEN Departure_atd > GETDATE() THEN 'In Port'
        ELSE 'Departed'
    END AS vessel_status
FROM silver.tos_vessel_schedule;




CREATE VIEW gold.dim_shipping_lines AS
SELECT 
    -- Generate Surrogate Key
    ROW_NUMBER() OVER (ORDER BY shipping_line_id) AS shipping_line_sk,
    
    -- Natural Key & Details
    shipping_line_id,
    ISNULL(company_name, 'Generic Carrier') AS company_name,
    ISNULL(parent_company, 'Independent') AS parent_company,
    contract_start_date,
    
    -- BUSINESS LOGIC: Partnerships and Tiers
    DATEDIFF(YEAR, contract_start_date, GETDATE()) AS partnership_years,
    CASE 
        WHEN UPPER(TRIM(Priority_level)) = 'PLATINUM' THEN 'Tier 1'
        WHEN UPPER(TRIM(Priority_level)) = 'GOLD'     THEN 'Tier 2'
        WHEN UPPER(TRIM(Priority_level)) = 'SILVER'   THEN 'Tier 3'
        WHEN UPPER(TRIM(Priority_level)) = 'BRONZE'   THEN 'Tier 4'
        ELSE 'Tier 5 - Uncategorized'
    END AS sla_category
FROM silver.crm_shipping_lines;




CREATE VIEW gold.dim_equipment AS
WITH UniqueEquipment AS (
    SELECT DISTINCT
        crane_id,
        equipment_type
    FROM silver.erp_equipment_logs
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY crane_id) AS equipment_sk,
    crane_id,
    ISNULL(equipment_type, 'General Equipment') AS equipment_type,
    
    -- BUSINESS LOGIC: Energy Source Mapping
    -- QCs are usually electric (KWh), RTGs can be Diesel (Litres)
    CASE 
        WHEN equipment_type LIKE '%Quay%' THEN 'Electric'
        WHEN equipment_type LIKE '%Gantry%' THEN 'Diesel/Hybrid'
        ELSE 'Internal Combustion'
    END AS energy_source,

    -- BUSINESS LOGIC: Asset Criticality
    -- Quay Cranes are 'Ship-to-Shore' and higher priority than Yard Cranes
    CASE 
        WHEN equipment_type LIKE '%Quay%' THEN 'High (S-S)'
        ELSE 'Medium (Yard)'
    END AS asset_priority_level
FROM UniqueEquipment;



CREATE VIEW gold.dim_locations AS
SELECT 
    -- Generate Surrogate Key
    ROW_NUMBER() OVER (ORDER BY location_id) AS location_sk,
    
    -- Natural Keys
    location_id,
    location_name,
    location_type,
    
    -- BUSINESS LOGIC: Operational Capacity
    -- If capacity is 0 (like a Berth), label it as 'Operational Area'
    CASE 
        WHEN max_capacity_teu = 0 THEN 'Non-Storage Operational Area'
        WHEN max_capacity_teu > 500 THEN 'High Capacity Block'
        ELSE 'Standard Block'
    END AS capacity_category,

    -- BUSINESS LOGIC: Dwell Time Targets
    -- Categorize locations by how fast containers should move through them
    CASE 
        WHEN average_dwell_time_target <= 24 THEN 'Fast Track'
        WHEN average_dwell_time_target <= 72 THEN 'Standard Dwell'
        ELSE 'Long Term Storage'
    END AS dwell_priority,

    Is_reefer_eligible,
    zone_priority
FROM silver.md_reference_locations;





WITH DateSeries AS (
    SELECT CAST('2024-01-01' AS DATE) AS calendar_date
    UNION ALL
    SELECT DATEADD(DAY, 1, calendar_date)
    FROM DateSeries
    WHERE calendar_date < '2030-12-31'
)
INSERT INTO gold.dim_date
SELECT
    CAST(FORMAT(calendar_date, 'yyyyMMdd') AS INT),
    calendar_date,
    YEAR(calendar_date),
    MONTH(calendar_date),
    FORMAT(calendar_date, 'MMMM'),
    FORMAT(calendar_date, 'MMM-yyyy'),
    DAY(calendar_date),
    DATENAME(WEEKDAY, calendar_date),
    DATEPART(WEEKDAY, calendar_date),
    CASE WHEN DATEPART(WEEKDAY, calendar_date) IN (1, 7) THEN 1 ELSE 0 END,
    'Q' + CAST(DATEPART(QUARTER, calendar_date) AS VARCHAR),
    CASE WHEN MONTH(calendar_date) >= 4 THEN YEAR(calendar_date) ELSE YEAR(calendar_date) - 1 END
FROM DateSeries
OPTION (MAXRECURSION 0);



---Creating Fact Tables


CREATE VIEW gold.fact_container_moves AS
SELECT 
    -- 1. SURROGATE KEYS (For Power BI / Tableau Performance)
    d_vess.vessel_sk,
    d_loc.location_sk,
    d_equip.equipment_sk,
    d_line.shipping_line_sk,
    d_date.date_sk,

    -- 2. DEGENERATE DIMENSIONS (Operational IDs for drill-down)
    s_moves.move_id,
    s_moves.container_id,
    s_moves.move_type, -- e.g., Discharge, Loading, Shifting
    s_moves.container_size,

    -- 3. MEASURES (The "Facts" for calculation)
    DATEDIFF(MINUTE, s_moves.start_time, s_moves.end_time) AS move_duration_minutes,
    1 AS move_count, -- Useful for simple SUM(move_count) in BI tools
    
    -- Business Logic: Efficiency Calculation
    CASE 
        WHEN DATEDIFF(SECOND, s_moves.start_time, s_moves.end_time) > 0 
        THEN CAST(3600.0 / DATEDIFF(SECOND, s_moves.start_time, s_moves.end_time) AS DECIMAL(10,2))
        ELSE 0 
    END AS moves_per_hour_equivalent

FROM silver.tos_container_moves s_moves
-- Joining to Dimensions using Natural Keys to "collect" the Surrogate Keys
LEFT JOIN gold.dim_vessels d_vess 
    ON s_moves.vessel_id = d_vess.vessel_id
LEFT JOIN gold.dim_locations d_loc 
    ON s_moves.yard_block_number = d_loc.location_id
LEFT JOIN gold.dim_equipment d_equip 
    ON s_moves.crane_id = d_equip.crane_id
LEFT JOIN gold.dim_shipping_lines d_line 
    ON d_vess.shipping_line_id = d_line.shipping_line_id
LEFT JOIN gold.dim_date d_date 
    ON CAST(s_moves.start_time AS DATE) = d_date.full_date;




    --Creating Fact Table fact_equipment_performance

CREATE VIEW gold.fact_equipment_performance AS
SELECT 
    -- 1. SURROGATE KEYS
    ROW_NUMBER() OVER (ORDER BY s_logs.date) AS record_id,
    d_equip.equipment_sk,
    d_date.date_sk,
    
    -- 2. RAW LOG DATA
    s_logs.crane_id,
    s_logs.crane_operation_hours,
    s_logs.fuel_consumption_litres,
    s_logs.fuel_consumption_kWh,
    s_logs.number_of_moves,
    s_logs.operator_id,
    s_logs.maintenance_status,

    -- 3. MEANINGFUL METRICS (The "Strategic Insights")
    
    -- KPI 1: Move Velocity (Gross Moves Per Hour)
    -- High value: Efficient / Low value: Possible congestion or mechanical lag
    CAST(s_logs.number_of_moves / NULLIF(s_logs.crane_operation_hours, 0) AS DECIMAL(10,2)) AS moves_per_hour,

    -- KPI 2: Energy Intensity (kWh per Move)
    -- This directly supports your "15% fuel efficiency boost" story
    CAST(s_logs.fuel_consumption_kWh / NULLIF(s_logs.number_of_moves, 0) AS DECIMAL(10,2)) AS fuel_per_move,

    -- KPI 3: Utilization Rate (%)
    -- Assuming a standard 24-hour terminal operation
    CAST((s_logs.crane_operation_hours / 24.0) * 100 AS DECIMAL(10,2)) AS daily_utilization_pct

FROM silver.erp_equipment_logs AS s_logs
LEFT JOIN gold.dim_equipment d_equip 
    ON s_logs.crane_id = d_equip.crane_id
LEFT JOIN gold.dim_date d_date 
    ON CAST(s_logs.date AS DATE) = d_date.full_date;




---Creating Fact Table fact.terminal_revenue

CREATE VIEW gold.fact_terminal_revenue AS
WITH latest_billing_rates AS (
    -- Deduplicating rates to ensure we only get the newest price for each move category
    SELECT 
        move_type, 
        container_size, 
        unit_price_usd,
        ROW_NUMBER() OVER (
            PARTITION BY move_type, container_size 
            ORDER BY effective_date DESC
        ) as rate_rank
    FROM silver.erp_billing_rates
)
SELECT 
    -- 1. SURROGATE KEYS (Linking to your existing Dimensions)
    
    ROW_NUMBER() OVER (ORDER BY s_moves.start_time, s_moves.move_id) AS revenue_id,d_date.date_sk,
    d_vess.vessel_sk,
    d_loc.location_sk,
    d_line.shipping_line_sk,

    -- 2. OPERATIONAL DIMENSIONS
    s_moves.container_id,
    s_moves.move_id,
    s_moves.move_type,
    s_moves.container_size,

    -- 3. MEASURES
    -- Handling Revenue: Pulling directly from the billing table
    r.unit_price_usd AS handling_revenue,
    
    -- Storage Revenue: Calculating "Dwell Time" logic
    -- (Example: $50/day if the container sits for more than 3 days)
    CASE 
        WHEN DATEDIFF(DAY, s_moves.start_time, s_moves.end_time) > 3 
        THEN (DATEDIFF(DAY, s_moves.start_time, s_moves.end_time) - 3) * 50.00 
        ELSE 0 
    END AS storage_revenue,

    -- Total Revenue: Handling + Storage
    (ISNULL(r.unit_price_usd, 0) + 
     CASE 
        WHEN DATEDIFF(DAY, s_moves.start_time, s_moves.end_time) > 3 
        THEN (DATEDIFF(DAY, s_moves.start_time, s_moves.end_time) - 3) * 50.00 
        ELSE 0 
     END) AS total_revenue

FROM silver.tos_container_moves s_moves
-- Join to our cleaned billing rates using the new size column
LEFT JOIN latest_billing_rates r 
    ON s_moves.move_type = r.move_type 
    AND s_moves.container_size = r.container_size
    AND r.rate_rank = 1
-- Dimension Joins
LEFT JOIN gold.dim_vessels d_vess ON s_moves.vessel_id = d_vess.vessel_id
LEFT JOIN gold.dim_shipping_lines d_line ON d_vess.shipping_line_id = d_line.shipping_line_id
LEFT JOIN gold.dim_date d_date ON CAST(s_moves.start_time AS DATE) = d_date.full_date
LEFT JOIN gold.dim_locations d_loc ON s_moves.yard_block_number = d_loc.location_id;


--Creating Fact Table customer experience

CREATE VIEW gold.fact_customer_experience AS
SELECT 
    -- 1. KEYS
    f.feedback_id,
    d_line.shipping_line_sk,
    d_vess.vessel_sk,
    
    -- 2. DESCRIPTIVE COLUMNS (For easier reporting)
    d_line.company_name,
    d_vess.vessel_name,
    
    -- 3. QUALITATIVE DATA
    f.satisfaction_score,
    f.delay_complaint_flag,

    -- 4. CALCULATED SENTIMENT
    CASE 
        WHEN f.satisfaction_score >= 9 THEN 'Promoter'
        WHEN f.satisfaction_score >= 7 THEN 'Passive'
        ELSE 'Detractor'
    END AS customer_sentiment

FROM silver.crm_customer_feedback f
LEFT JOIN gold.dim_shipping_lines d_line 
    ON f.shipping_line_id = d_line.shipping_line_id
LEFT JOIN gold.dim_vessels d_vess 
    ON f.vessel_id = d_vess.vessel_id;
