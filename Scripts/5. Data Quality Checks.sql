USE DataWarehouse;


--Auditing data errors in crm_customer_feedback table

SELECT feedback_id,
COUNT(*)
FROM bronze.crm_customer_feedback
GROUP BY feedback_id
HAVING COUNT(*)>1 OR feedback_id IS NULL



-- finding null vessel ids
SELECT DISTINCT 
	cf.vessel_id AS Orphaned_Vessel_ID
FROM bronze.crm_customer_feedback cf
LEFT JOIN bronze.tos_vessel_schedule vs ON cf.vessel_id = vs.vessel_id 
WHERE vs.vessel_id IS NULL;


--finding unwanted spaces
SELECT feedback_id,
		shipping_line_id,
		vessel_id
FROM bronze.crm_customer_feedback
WHERE 
		feedback_id <> TRIM(feedback_id) OR
		shipping_line_id <> TRIM(shipping_line_id) OR
		vessel_id <> TRIM(vessel_id);

----------------------------------------------------------------

-- Auditing data errors in crm_shipping_line table

-- Checking duplicate or null entries in Primary Key
SELECT shipping_line_id,
COUNT(*)
FROM bronze.crm_shipping_lines
GROUP BY shipping_line_id
HAVING COUNT(*)>1 OR shipping_line_id IS NULL;


-- Checking unwanted spaces in Shippin_line_id, Company_name, Priority_level
SELECT shipping_line_id,
		company_name,
		priority_level
FROM bronze.crm_shipping_lines
WHERE 
	shipping_line_id <> TRIM(shipping_line_id) OR
	company_name <> TRIM(company_name) OR
	priority_level <> TRIM(priority_level);


-- Checking for lowercase characters in company name
SELECT company_name
FROM bronze.crm_shipping_lines
WHERE company_name <> UPPER(company_name);


--- Checking for unwanted and incorrect values in priority_level
SELECT DISTINCT priority_level
FROM bronze.crm_shipping_lines;



------------------------------------------------------------

--Auditing data errors in erp_billing_rates table

-- Checking duplicate or null entries in Primary Key

SELECT rate_id,
COUNT(*)
FROM bronze.erp_billing_rates
GROUP BY rate_id
HAVING COUNT(*)>1 OR rate_id IS NULL;


-- Checking for unwanted spaces

SELECT 
		move_type,
		container_size
FROM bronze.erp_billing_rates
WHERE
		move_type <> TRIM(move_type) OR
		container_size <> TRIM(container_size);
		


-- Checking if the prices are all positive (pricestats is a cte)

SELECT rate_id,
		move_type,
		container_size,
		unit_price_usd
FROM bronze.erp_billing_rates
WHERE unit_price_usd < 0 OR unit_price_usd IS NULL;




------------------------------------------------------------

--Auditing data errors in erp_equipment_logs table

-- Checking for standardized values in equipment_type

SELECT DISTINCT equipment_type
FROM bronze.erp_equipment_logs;


SELECT crane_id
FROM bronze.erp_equipment_logs
WHERE crane_operation_hours < 0;

SELECT crane_id
FROM bronze.erp_equipment_logs
WHERE crane_operation_hours > 24;

SELECT crane_id
FROM bronze.erp_equipment_logs
WHERE (crane_operation_hours IS NULL OR crane_operation_hours <=0) AND number_of_moves >0;


SELECT
crane_id,
COALESCE(crane_operation_hours,
AVG(crane_operation_hours) OVER (PARTITION BY crane_id), AVG(crane_operation_hours) OVER()
)AS new_crane_hours
FROM  bronze.erp_equipment_logs;


-----Auditing data errors in Md_location table--

---Checking for duplicate and null values in primary key location_id

SELECT location_id,
COUNT (*)
FROM bronze.md_reference_locations
GROUP BY location_id
HAVING COUNT(*) >1 AND location_id IS NULL;


---Checking for positive values greater than zero for max_capacity_teu
SELECT 
location_name,
max_capacity_teu
FROM bronze.md_reference_locations
WHERE location_name = 'Berth' AND max_capacity_teu > 0;

---Checking for unwanted spaces in string values
SELECT
location_name,
location_type,
is_reefer_eligible,
zone_priority
FROM bronze.md_reference_locations
WHERE
	location_name <> TRIM(location_name) OR
	location_type <> TRIM(location_type) OR
	is_reefer_eligible <> TRIM(is_reefer_eligible) OR
	zone_priority <> TRIM(zone_priority);


-----Auditing data errors in container_moves --

--Checking for duplicate and null values in primary key

SELECT 
	move_id,
	COUNT(*)
FROM bronze.tos_container_moves
GROUP BY move_id
HAVING COUNT(*)>1 AND move_id IS NULL;


--Checking that start time should be less than end time--

SELECT
move_id,
start_time,
end_time
FROM bronze.tos_container_moves
WHERE start_time > end_time;


---Checking for null values in start_time and end_time--
SELECT
move_id,
start_time,
end_time
FROM bronze.tos_container_moves
WHERE start_time IS NULL OR end_time IS NULL;


---Auditing data errors in vessel_schedule --

--Checking for duplicate and null values in primary key

SELECT 
	vessel_id,
	COUNT(*)
FROM bronze.tos_vessel_schedule
GROUP BY vessel_id
HAVING COUNT(*)>1 AND vessel_id IS NULL;


--Checking that start time should be less than end time--

SELECT
vessel_id,
arrival_atb,
departure_atd
FROM bronze.tos_vessel_schedule
WHERE arrival_atb > departure_atd;












