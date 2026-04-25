CREATE PROCEDURE bronze.load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT 'Loading the Bronze Layer';
	
	
		PRINT 'Loading the CRM Tables';

		PRINT '>> Truncating Table: bronze.crm_customer_feedback';
		TRUNCATE TABLE bronze.crm_customer_feedback;

		SET @start_time = GETDATE();
		PRINT '>> Inserting Data into Table: bronze.crm_customer_feedback';
		BULK INSERT bronze.crm_customer_feedback
		FROM 'C:\Data Science Course\Data Warehouse Project\Data Warehouse Project - Ports\source_crm\crm_customer_feedback.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';



		PRINT '>> Truncating Table: bronze.crm_shipping_lines';
		TRUNCATE TABLE bronze.crm_shipping_lines;
	

		SET @start_time = GETDATE();
		PRINT '>> Inserting Data into Table: bronze.crm_shipping_lines';
		BULK INSERT bronze.crm_shipping_lines
		FROM 'C:\Data Science Course\Data Warehouse Project\Data Warehouse Project - Ports\source_crm\crm_shipping_lines.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';





		PRINT 'Loading the ERP Tables';



		PRINT '>> Truncating Table: bronze.erp_billing_rates';
		TRUNCATE TABLE bronze.erp_billing_rates;


		SET @start_time = GETDATE();
		PRINT '>> Inserting Data into Table: bronze.erp_billing_rates';
		BULK INSERT bronze.erp_billing_rates
		FROM 'C:\Data Science Course\Data Warehouse Project\Data Warehouse Project - Ports\source_erp\erp_billing_rates.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';




		PRINT '>> Truncating Table: bronze.erp_equipment_logs';
		TRUNCATE TABLE bronze.erp_equipment_logs;


		SET @start_time = GETDATE();
		PRINT '>> Inserting Data into Table: bronze.erp_equipment_logs';
		BULK INSERT bronze.erp_equipment_logs
		FROM 'C:\Data Science Course\Data Warehouse Project\Data Warehouse Project - Ports\source_erp\erp_equipment_logs.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';



		PRINT 'Loading the TOS Tables';


		PRINT '>> Truncating Table: bronze.tos_container_moves';
		TRUNCATE TABLE bronze.tos_container_moves;


		SET @start_time = GETDATE();
		PRINT '>> Inserting Data into Table: bronze.tos_container_moves';
		BULK INSERT bronze.tos_container_moves
		FROM 'C:\Data Science Course\Data Warehouse Project\Data Warehouse Project - Ports\source_tos\tos_container_moves.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';


		
		PRINT '>> Truncating Table: bronze.tos_vessel_schedule';
		TRUNCATE TABLE bronze.tos_vessel_schedule;


		SET @start_time = GETDATE();
		PRINT '>> Inserting Data into Table: bronze.tos_vessel_schedule';
		BULK INSERT bronze.tos_vessel_schedule
		FROM 'C:\Data Science Course\Data Warehouse Project\Data Warehouse Project - Ports\source_tos\tos_vessel_schedule.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';


		PRINT 'Loading the MD Tables';


		PRINT '>> Truncating Table: bronze.md_reference_locations';
		TRUNCATE TABLE bronze.md_reference_locations;


		SET @start_time = GETDATE();
		PRINT '>> Inserting Data into Table: bronze.md_reference_locations';
		BULK INSERT bronze.md_reference_locations
		FROM 'C:\Data Science Course\Data Warehouse Project\Data Warehouse Project - Ports\source_master_data_locations\md_reference_locations.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';

		SET @batch_end_time = GETDATE();
		PRINT 'BRONZE LAYER LOADING COMPLETED';
		PRINT 'Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
	END TRY

	BEGIN CATCH

	PRINT 'ERROR OCCURRED WHILE LOADING BRONZE LAYER';
	PRINT 'Error Message:' + ERROR_MESSAGE();
	PRINT 'Error Number:' + CAST(ERROR_NUMBER() AS NVARCHAR);

	END CATCH

END