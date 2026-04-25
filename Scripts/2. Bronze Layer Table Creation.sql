USE DataWarehouse


IF OBJECT_ID('bronze.crm_customer_feedback', 'U') IS NOT NULL
	DROP TABLE bronze.crm_customer_feedback;
CREATE TABLE bronze.crm_customer_feedback(
	feedback_id NVARCHAR(50),
	shipping_line_id NVARCHAR(50),
	vessel_id NVARCHAR(50),
	delay_complaint_flag BIT NOT NULL DEFAULT 0,
	satisfaction_score INT
);


IF OBJECT_ID('bronze.crm_shipping_lines', 'U') IS NOT NULL
	DROP TABLE bronze.crm_shipping_lines;
CREATE TABLE bronze.crm_shipping_lines(
	shipping_line_id NVARCHAR(50),
	company_name NVARCHAR(50),
	contract_start_date DATE,
	priority_level NVARCHAR(50)
);


IF OBJECT_ID('bronze.erp_billing_rates', 'U') IS NOT NULL
	DROP TABLE bronze.erp_billing_rates;
CREATE TABLE bronze.erp_billing_rates(
	rate_id INT,
	move_type NVARCHAR(10),
	container_size NVARCHAR(10),
	unit_price_usd INT,
	effective_date DATE
)

IF OBJECT_ID('bronze.erp_equipment_logs', 'U') IS NOT NULL
	DROP TABLE bronze.erp_equipment_logs;
CREATE TABLE bronze.erp_equipment_logs(
	crane_id NVARCHAR(10),
	equipment_type NVARCHAR(50),
	date DATE,
	crane_operation_hours FLOAT,
	fuel_consumption_litres FLOAT,
	fuel_consumption_kWh FLOAT,
	maintenance_status NVARCHAR(50),
	operator_id NVARCHAR(10),
	number_of_moves INT
)


IF OBJECT_ID('bronze.tos_container_moves', 'U') IS NOT NULL
	DROP TABLE bronze.tos_container_moves;
CREATE TABLE bronze.tos_container_moves(
	move_id INT,
	container_id NVARCHAR(50),
	vessel_id NVARCHAR(10),
	crane_id NVARCHAR(10),
	container_size NVARCHAR(10),
	move_type NVARCHAR(50),
	start_time DATETIME,
	end_time DATETIME,
	storage_slot NVARCHAR(50)
)


IF OBJECT_ID('bronze.tos_vessel_schedule', 'U') IS NOT NULL
	DROP TABLE bronze.tos_vessel_schedule;
CREATE TABLE bronze.tos_vessel_schedule(
	vessel_id NVARCHAR(10),
	vessel_name NVARCHAR(50),
	shipping_line_id NVARCHAR(50),
	arrival_atb DATETIME,
	departure_atd DATETIME,
	terminal_id NVARCHAR(50)
)


IF OBJECT_ID('bronze.md_reference_locations', 'U') IS NOT NULL
	DROP TABLE bronze.md_reference_locations;
CREATE TABLE bronze.md_reference_locations(
	location_id NVARCHAR(10),
	location_name NVARCHAR(50),
	location_type NVARCHAR(10),
	country NVARCHAR(50),
	max_capacity_teu INT,
	average_dwell_time_target INT,
	is_reefer_eligible NVARCHAR(10),
	zone_priority NVARCHAR(50)
)













