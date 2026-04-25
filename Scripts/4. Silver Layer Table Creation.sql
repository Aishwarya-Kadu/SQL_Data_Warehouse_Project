USE DataWarehouse


IF OBJECT_ID('silver.crm_customer_feedback', 'U') IS NOT NULL
	DROP TABLE silver.crm_customer_feedback;
CREATE TABLE silver.crm_customer_feedback(
	feedback_id NVARCHAR(50),
	shipping_line_id NVARCHAR(50),
	vessel_id NVARCHAR(50),
	delay_complaint_flag BIT NOT NULL DEFAULT 0,
	satisfaction_score INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID('silver.crm_shipping_lines', 'U') IS NOT NULL
	DROP TABLE silver.crm_shipping_lines;
CREATE TABLE silver.crm_shipping_lines(
	shipping_line_id NVARCHAR(50),
	company_name NVARCHAR(50),
	parent_company NVARCHAR(50),
	branch_number NVARCHAR(50),
	contract_start_date DATE,
	priority_level NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID('silver.erp_billing_rates', 'U') IS NOT NULL
	DROP TABLE silver.erp_billing_rates;
CREATE TABLE silver.erp_billing_rates(
	rate_id INT,
	move_type NVARCHAR(10),
	container_size NVARCHAR(10),
	unit_price_usd INT,
	effective_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_equipment_logs', 'U') IS NOT NULL
	DROP TABLE silver.erp_equipment_logs;
CREATE TABLE silver.erp_equipment_logs(
	record_id INT IDENTITY(1,1) PRIMARY KEY,
	crane_id NVARCHAR(10),
	equipment_type NVARCHAR(50),
	date DATE,
	crane_operation_hours FLOAT,
	fuel_consumption_litres FLOAT,
	fuel_consumption_kWh FLOAT,
	maintenance_status NVARCHAR(50),
	operator_id NVARCHAR(10),
	number_of_moves INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE());


IF OBJECT_ID('silver.tos_container_moves', 'U') IS NOT NULL
	DROP TABLE silver.tos_container_moves;
CREATE TABLE silver.tos_container_moves(
	move_id INT,
	container_id NVARCHAR(50),
	vessel_id NVARCHAR(10),
	crane_id NVARCHAR(10),
	container_size NVARCHAR(10),
	move_type NVARCHAR(50),
	start_time DATETIME,
	end_time DATETIME,
	storage_slot NVARCHAR(50),
	yard_block_number NVARCHAR(10),
	slot_number NVARCHAR(10),
	dwh_create_date DATETIME2 DEFAULT GETDATE());


IF OBJECT_ID('silver.tos_vessel_schedule', 'U') IS NOT NULL
	DROP TABLE silver.tos_vessel_schedule;
CREATE TABLE silver.tos_vessel_schedule(
	vessel_id NVARCHAR(10),
	vessel_name NVARCHAR(50),
	shipping_line_id NVARCHAR(50),
	arrival_atb DATETIME,
	departure_atd DATETIME,
	terminal_id NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID('silver.md_reference_locations', 'U') IS NOT NULL
	DROP TABLE silver.md_reference_locations;
CREATE TABLE silver.md_reference_locations(
	location_id NVARCHAR(10),
	location_name NVARCHAR(50),
	location_type NVARCHAR(10),
	country NVARCHAR(50),
	max_capacity_teu INT,
	average_dwell_time_target INT,
	is_reefer_eligible NVARCHAR(10),
	zone_priority NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE());














