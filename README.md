# SQL Data Warehouse Project - Maritime Logistics
This is an end-to-end Galaxy Schema Data Warehouse that integrates siloed terminal operations, financial billing and asset performance data insto single source of truth for maritime logistics.


## Contents
- [Project Overview](# Project Overview)
- Tools
- Data Overview
- Architecture Framework
- Data Modelling (ERD and Schema Design)
- Gold Layer: Data Dictionary and Business Logic
- Key Strategic Insights (KPIs)
- How to run the project

## Project Overview
This project simulates the development of a professional-grade Data Warehouse for a container terminal, bridging the gap between raw maritime operations and strategic business intelligence. By transforming fragmented logs from **Terminal Operating System (TOS)**, **Enterprise Resource Planning System (ERP)**, **Customer Relationship Management System (CRM)** and **Master Data logs** into a centralized Gaalxy Schema, the project enables real-time tracking of operational efficiency, revenue accuracy and asset health.


### Objective
The objective of this project is to design and implement a scalable Galaxy Schema data warehouse that transforms fragmented maritime operational logs into a centralized, audit-ready source of truth for optimizing port productivity and revenue assurance.


## Tools and Technologies
- Database Engine: Mirosoft SQL Server
- Integrated Development Environment (IDE): SQL Server Management Studio (SSMS)
- Data Modeling: draw.io (Entity-Relationship Diagram)
- Architecture Framework: Medallion Architecture
- Version Control: Git and Github


## Data Overview
This data warehouse is built from seven CSV datasets which are sourced from Terminal Operating System (TOS), Enterprise Resource Planning System (ERP), Customer Relationship Management System (CRM) and Master Data file.

### Table Name: TOS_Vessel_Schedule
|Column Names| Description|
|------------|------------|
|vessel_id| Unique identifier for container ship|
|vessel_name| Name of the container ship|
|shipping_line_id| Links the vessel to its parent company|
|arrival_atb| Actual time of berthing - The time when the vessel physically touched the dock|
|departure_atd| Actual time of departure - The time when the vessel left the port|
|terminal_id| Identifies the specific facility|


### Table Name: TOS_Container_Moves
|Column Names| Description|
|------------|------------|
|move_id| Unique primary key for every physical action|
|container_id| Unique identifier for the box|
|vessel_id|Identifier for container ship|
|crane_id| Identifier for container handling cranes|
|container_size| Size of container whether 20ft or 40ft|
|move_type| Type of move whether Loading or Discharge|
|start_time| Time when the operator lifted the container|
|end_time| Time when the operator placed the container, completing one full action|
|storage_slot| The address of storage location of container|


### Table Name: CRM_Customer_Feedback
|Column Names| Description|
|------------|------------|
|feedback_id| Unique identifier for feedbacks received|
|shipping_line_id| Identifier for shipping line companies|
|vessel_id| Identifier for container ship|
|delay_complaint_flag| Boolean column with values 1, when the vessel departure gets delayed and 0 when vessel departs on time from port|
|satisfaction_score| Satisfaction rating ranging from 0 to 10 given by the shipping line company, with 0 as poor and 10 as best|


### Table Name: CRM_Shipping_Lines
|Column Names| Description|
|------------|------------|
|shipping_line_id|Unique identifier for shipping line companies|
|company_name| Name of the shipping line company|
|contract_start_date| Date when the container terminal entered into partnership with the shipping line company|
|priority_level|Assigned levels to shipping line based on annual volume and SLA agreements. Priority levels are Bronze, Silver, Gold and Platinum|


### Table Name: ERP_Billing_Rates
|Column Names| Description|
|------------|------------|
|rate_id| Unique identifier for a record in the table|
|move_type| Type of container move whether Loading or Discharge|
|container_size| Size of container whether 20ft or 40ft|
|unit_price_usd| Price of handling one container. Currency used is United States Dollar|
|effective_date| The date from when the new price is effective|


### Table Name: ERP_Equipment_Logs
|Column Names| Description|
|------------|------------|
|crane_id|Identifier for a particular container handling crane|
|equipment_type| Type of container handling crane|
|date| Equipment activity date|
|crane_operation_hours| Number of hours the crane operated a particular day|
|fuel_consumption_litres| Number of litres of diesel consumed by the crane on a particular day|
|fuel_consumption_kWh| Amount of electricity consumed by the crane on a particular day|
|maintenance_status| Maintenance status of crane whether Good, Under Repair or Due|
|operator_id| Unique id of the operator employee assigned to them (identical to employee id)|
|number_of_moves| Number of moves done by the crane for a particular day|


### Table Name: MD_Reference_Location
|Column Names| Description|
|------------|------------|
|location_id| Unique identifier for the location at the container terminal|
|location_name| Name of the location|
|location_type| Type of location|
|country| Name of country where the port is located|
|max_capacity_teu| Maximum teu's(twenty equivalent unit) which a location is able to store|
|average_dwell_target_time| Number of hours that a container can be stored|
|is_reefer_eligible| Defines whether a location can store reefer containers|
|zone_priority| Defines whether a particular location is high priority or not|


## Architecture Framework: Medallion Architecture
This project follows Medallion Architecture to ensure data integrity, traaceability and high-performance reporting. By organising the data into three distinct layers, we transform raw, fragmented maritime logs into a refined 'Single Source of Truth'.

### Bronze Layer: Raw Staging
- Object Type: Physical Tables
- Loading Strategy: Full Load (Truncate and Insert)
- Objective: To serve as a landing zone for raw source data, ensuring 100% traceability and providing foundation for debugging the upstream data issues
- Description: Raw CSV files from CRM, TOS, ERP and MD are ingested exactly as they exist in the source systems. No transformation is applied at this stage to maintain a historical record of raw input.

### Silver Layer: Cleaned and Standardized
- Object Type: Physical Tables
- Loading Strategy: Full Load (Truncate and Insert)
- Objective: To provide a reliable, intermediate layer where data is 'cleansed' and validated for cross-functional consistency.
- Transformation Logic:
   - Deduplication: Removing duplicate records based on Primary Keys.
   - Data Hygiene: Trimming unwanted spaces and handling NULL, erroneous or orphaned values.
   - Logical Validation: Ensuring data integrity (e.g. verifying start time value is before end time, and ensuring all currency/financial values are positive).
   - Standardization: Mapping inconsistent source values to industry-standard formats.

 ### Gold Layer: Business-Ready Modelling
 - Object Type: SQL Views
 - Objective: To provide high-performance, integrated data optimized for reporting, visualization, and strategic analysis.
 - Description: This is the final consumption layer. Here, we apply complex business rules and logic to perform:
    - Data Integration: Merging disparate datasets (e.g., linking Vessel moves to Billing rates).
    - Data Modelling: Implementing a Galaxy Schema comprised of Dimension and Fact tables.
    - Aggregations: Calculating key performance indicators like Revenue, Equipment Utilization, and Move Velocity.
  








