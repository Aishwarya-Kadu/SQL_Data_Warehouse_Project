

CREATE PROCEDURE bronze.load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT 'Loading the Silver Layer';
	
	
		PRINT 'Loading the CRM Tables';

-- crm_customer_feedback table cleaning and loading
PRINT '>> Truncating Table: silver.crm_customer_feedback';

TRUNCATE TABLE silver.crm_customer_feedback;

SET @start_time = GETDATE();
PRINT '>> Inserting Data into Table: silver.crm_customer_feedback';

		INSERT INTO silver.crm_customer_feedback(
			feedback_id,
			shipping_line_id,
			vessel_id,
			delay_complaint_flag,
			satisfaction_score
			)
		SELECT
		cf.feedback_id,
		cf.shipping_line_id,
		cf.vessel_id,
		cf.delay_complaint_flag,
		cf.satisfaction_score
		FROM bronze.crm_customer_feedback cf
		INNER JOIN bronze.tos_vessel_schedule vs ON cf.vessel_id = vs.vessel_id;

SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';



-- crm_shipping_line table cleaning and loading
PRINT '>> Truncating Table: silver.crm_shipping_lines';
		TRUNCATE TABLE silver.crm_shipping_lines;
	

		SET @start_time = GETDATE();
		PRINT '>> Inserting Data into Table: silver.crm_shipping_lines';

		INSERT INTO silver.crm_shipping_lines(
		shipping_line_id,
		company_name,
		parent_company,
		branch_number,
		contract_start_date,
		priority_level
		)
		SELECT shipping_line_id,
		company_name,
		TRIM(LEFT(company_name,LEN(company_name) - CHARINDEX('-', REVERSE(company_name))-1)) AS parent_company,
		TRIM(RIGHT(company_name,CHARINDEX('-', REVERSE(company_name)) -1)) AS branch_number,
		contract_start_date,
		priority_level
		FROM bronze.crm_shipping_lines;


		SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';





--- erp_billing_rates table cleaning and loading
PRINT 'Loading the ERP Tables';

PRINT '>> Truncating Table: silver.erp_billing_rates';
TRUNCATE TABLE silver.erp_billing_rates;

SET @start_time = GETDATE();
		PRINT '>> Inserting Data into Table: silver.erp_billing_rates';

		INSERT INTO silver.erp_billing_rates(
		rate_id,
		move_type,
		container_size,
		unit_price_usd,
		effective_date)
		SELECT 
				rate_id,
				move_type,
				container_size,
				ABS(unit_price_usd) AS unit_price_usd,
				effective_date
		FROM bronze.erp_billing_rates;

SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';


		


----erp_equipment_logs cleaning and loading

PRINT '>> Truncating Table: silver.erp_equipment_logs';
		TRUNCATE TABLE silver.erp_equipment_logs;

SET @start_time = GETDATE();
		PRINT '>> Inserting Data into Table: silver.erp_equipment_logs';

		INSERT INTO silver.erp_equipment_logs(
			crane_id,
			equipment_type,
			date,
			crane_operation_hours,
			fuel_consumption_litres,
			fuel_consumption_kWh,
			maintenance_status,
			operator_id,
			number_of_moves
			)
		SELECT 
		LEFT( crane_id, LEN(crane_id) -2)+ '-' +RIGHT(crane_id, 2) AS crane_id,
		CASE
			WHEN equipment_type = 'RTG' THEN 'Rubber Tyred Gantry Crane'
			ELSE equipment_type
		END AS equipment_type,
		date,
		COALESCE(
				CASE WHEN crane_operation_hours <= 24 OR crane_operation_hours >= 0 
								THEN crane_operation_hours
								ELSE NULL
								END,
				AVG(crane_operation_hours) OVER (PARTITION BY crane_id)) AS crane_operation_hours,
		fuel_consumption_litres,
		fuel_consumption_kWh,
		maintenance_status,
		operator_id,
		number_of_moves
		FROM bronze.erp_equipment_logs
		ORDER BY [date] ASC;


SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';


---Cleaning and Loading silver.tos_container_moves

PRINT 'Loading the TOS Tables';


PRINT '>> Truncating Table: silver.tos_container_moves';
TRUNCATE TABLE silver.tos_container_moves;

SET @start_time = GETDATE();
		PRINT '>> Inserting Data into Table: silver.tos_container_moves';

		INSERT INTO silver.tos_container_moves(
			move_id,
			container_id,
			vessel_id,
			crane_id,
			container_size,
			move_type,
			start_time,
			end_time,
			storage_slot,
			yard_block_number,
			slot_number)
		SELECT
			move_id,
			container_id,
			vessel_id,
			LEFT( crane_id, LEN(crane_id) -2)+ '-' +RIGHT(crane_id, 2) AS crane_id,
			container_size,
			move_type,
			start_time,
			COALESCE(end_time, DATEADD(MINUTE, 2, start_time)) AS end_time,
			storage_slot,
			LEFT(storage_slot, CHARINDEX('-', storage_slot)-1) AS yard_block_number,
			RIGHT(storage_slot, CHARINDEX('-',storage_slot)-1) AS slot_number
		FROM bronze.tos_container_moves;

SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';


		
PRINT '>> Truncating Table: silver.tos_vessel_schedule';
TRUNCATE TABLE silver.tos_vessel_schedule;





---Cleaning and Loading silver.tos_vessel_schedule
SET @start_time = GETDATE();
PRINT '>> Inserting Data into Table: silver.tos_vessel_schedule';

		INSERT INTO silver.tos_vessel_schedule(
			vessel_id,
			vessel_name,
			shipping_line_id,
			arrival_atb,
			departure_atd,
			terminal_id)
		SELECT
			vessel_id,
			vessel_name,
			shipping_line_id,
			arrival_atb,
			departure_atd,
			terminal_id
		FROM bronze.tos_vessel_schedule;

SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';






---md_reference_location table cleaning and loading
PRINT 'Loading the MD Tables';


PRINT '>> Truncating Table: silver.md_reference_locations';
TRUNCATE TABLE silver.md_reference_locations;


SET @start_time = GETDATE();
PRINT '>> Inserting Data into Table: silver.md_reference_locations';


		INSERT INTO silver.md_reference_locations(
			location_id,
			location_name,
			location_type,
			country,
			max_capacity_teu,
			average_dwell_time_target,
			is_reefer_eligible,
			zone_priority)
		SELECT 
			location_id,
			location_name,
			location_type,
			country,
			max_capacity_teu,
			average_dwell_time_target,
			is_reefer_eligible,
			zone_priority
		FROM bronze.md_reference_locations;


SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';

		SET @batch_end_time = GETDATE();
		PRINT 'SILVER LAYER LOADING COMPLETED';
		PRINT 'Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
	END TRY

	BEGIN CATCH

	PRINT 'ERROR OCCURRED WHILE LOADING SILVER LAYER';
	PRINT 'Error Message:' + ERROR_MESSAGE();
	PRINT 'Error Number:' + CAST(ERROR_NUMBER() AS NVARCHAR);

	END CATCH

END







