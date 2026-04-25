# SQL Data Warehouse Project - Maritime Logistics
This is an end-to-end Galaxy Schema Data Warehouse that integrates siloed terminal operations, financial billing and asset performance data insto single source of truth for maritime logistics.


## Contents
- [Project Overview](# Project-Overview)
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

## Data Modelling & ERD Design
To support cross-functional analysis across operations, finance, and asset management, this project implements a Galaxy Schema (also known as a Fact Constellation). This design allows multiple Fact tables to share Conformed Dimensions, ensuring a "Single Version of Truth" across the entire terminal.

### The ERD Diagram
<img width="1042" height="1662" alt="data model ss" src="https://github.com/user-attachments/assets/1ec0142c-73ba-4e56-8e89-5f144f2a5f8a" />

### Key Design Patterns
- **Galaxy Schema Architecture**: Unlike a standard Star Schema with one central fact, this model features four distinct Fact tables (container_moves, terminal_revenue, equipment_performance, and customer_experience). This reflects a real-world enterprise environment where different business processes are analyzed simultaneously.
- **Conformed Dimensions:** Dimensions such as dim_date and dim_vessels are shared across multiple Fact tables. This enables Cross-Fact Analysis (e.g., correlating Vessel Productivity with Total Revenue) without the risk of data duplication.
- **Surrogate Key Implementation:** Every table in the Gold Layer utilizes Surrogate Keys (e.g., vessel_key, revenue_id). This strategy shields the warehouse from changes in source-system business keys and simplifies join logic within BI tools.
- **Granularity Control:**
   - **Operations:** Granularity is at the individual move level.
   - **Finance:** Granularity is at the revenue transaction level, allowing for storage and handling fees to be audited separately.
- **Auditability:** By including degenerate dimensions like move_id in the revenue fact table, the model maintains a clear "paper trail" from financial figures back to physical operational events.


## Gold Layer: Data DIctionary and Business Logic
The Gold Layer is the final consumption layer, consisting of SQL Views that transform cleaned data into actionable insights. This layer implements a Galaxy Schema designed for high-performance reporting in tools like Power BI or Tableau.
  
### Table Name: fact_container_moves
|Column Names| Description|
|------------|------------|
|vessel_sk| A surrogate foreign key that maps operational transactions of dimension table dim_vessels|
|location_sk| A surrogate foreign key that maps operational transactions of dimension table dim_locations|
|equipment_sk| A surrogate foreign key that maps operational transactions of dimension table dim_equipment|
|shipping_line_sk| A surrogate foreign key that maps operational transactions of dimension table dim_shipping_lines|
|date_sk| A surrogate foreign key that maps operational transactions of dimension table dim_date|
|move_id| Unique identifier and primary key of the fact table|
|container_id| Unique identifier for the box|
|move_type| Type of move whether Loading or Discharge|
|container_size| Size of container whether 20ft or 40ft|
|move_duration_minutes| Time taken in minutes to handle one container|
|move_count| Number of containers handled|
|moves_per_hour| Number of containers handled per hour|


### Table Name: fact_customer_experience
|Column Names| Description|
|------------|------------|
|feedback_id|Unique identifier and primary of fact table customer_experience|
|shipping_line_sk|A surrogate foreign key that maps operational transactions of dimension table dim_shipping_lines|
|vessel_sk| A surrogate foreign key that maps operational transactions of dimension table dim_vessels|
|company_name|Unique identifier and primary of fact table customer_experience|
|vessel_name|Name of the container ship|
|satisfaction_score|Satisfaction rating ranging from 0 to 10 given by the shipping line company, with 0 as poor and 10 as best|
|delay_complaint_flag|Boolean column with values 1, when the vessel departure gets delayed and 0 when vessel departs on time from port|
|customer_sentiment|Calculated column with categories based on satisfaction score as Promoters (score 9 to 10, which are loyalists), Passives (score 7 to 8, which can be called as At-Risk Customers) and Detractors (score 0 to 6, which are unhappy customers)|


### Table Name: fact_equipment_performance
|Column Names| Description|
|------------|------------|
|record_id| Unique indentifier and primary key of fact table equipment_performance|
|equipment_sk| A surrogate foreign key that maps operational transactions of dimension table dim_equipment|
|date_sk| A surrogate foreign key that maps operational transactions of dimension table dim_date|
|crane_id| Identifier for a particular container handling crane|
|crane_operation_hours| | Number of hours the crane operated a particular day|
|fuel_consumption_litres| Number of litres of diesel consumed by the crane on a particular day|
|fuel_consumption_kWh| Amount of electricity consumed by the crane on a particular day|
|number_of_moves| Total number of moves done by the crane for a particular day|
|maintenance_status| Maintenance status of crane whether Good, Under Repair or Due|
|moves_per_hour| Number of containers handled per hour, which is the ratio of number_of_moves and crane_operation_hours|
|fuel_per_move| Amount of fuel consumed to handle one container which is ratio of fuel consumed and number of moves|
|daily_utilization_pct| The ratio of active operational hours to the total available 24-hour window, used to evaluate equipment efficiency and identify idle capacity. |


### Table Name: fact_terminal_revenue
|Column Names| Description|
|------------|------------|
|revenue_id| Unique identifier and primary key of fact table terminal_revenue|
|date-sk| A surrogate foreign key that maps operational transactions of dimension table dim_date|
|vessel_sk|A surrogate foreign key that maps operational transactions of dimension table dim_vessels|
|location_sk| A surrogate foreign key that maps operational transactions of dimension table dim_locations|
|shipping_line_sk| A surrogate foreign key that maps operational transactions of dimension table dim_shipping_lines|
|container_id| Unique identifier for the box|
|move_id| Unique identifier for the physical move made|
|move_type| Type of move whether Loading or Discharge|
|container_size| Unique identifier and primary key of fact table terminal_revenue|
|handling_revenue| The fixed service fee per container move, derived from the ERP billing tariff based on container size and move type.|
|storage_revenue| The penalty fee for cargo exceeding the 3-day grace period, calculated as $50 for each additional day of yard dwell time.|
|total_revenue| The cumulative income per transaction, representing the sum of both operational handling fees and applicable storage penalties.|


### Table Name: dim_date
|Column Names| Description|
|------------|------------|
|date_sk| Surrogate primary key of dimension table dim_date.|
|full_date| Date value in standard format YYYY-MM-DD|
|year| The four-digit calendar year used for high-level annual trend analysis and year-over-year comparisons.|
|month_number|The numerical representation of the month (1-12), essential for chronological sorting in reports.|
|month_name| The full text name of the month (e.g., January) used as a categorical label in visualizations.|
|month_year label|A concatenated string (e.g., "Jan 2026") providing a clean, readable label for time-series axis formatting. |
|day_of_the_month|The day of the month (1-31), used to analyze daily operational peaks and month-end fluctuations.|
|day_name|The name of the day (e.g., Monday), used to identify weekly patterns in vessel arrivals and gate traffic. |
|day_of_week_number| A numerical index for days (e.g., 1-7), enabling custom sorting of charts starting from Sunday or Monday.|
|is_weekend|A boolean flag (1/0) used to segment operational productivity between weekdays and weekend shifts. |
|quarter|The calendar quarter (Q1-Q4), used for quarterly business reviews and financial reporting cycles. |
|fiscal_year|The adjusted financial year based on organizational accounting cycles, often used for budget tracking. |


### Table Name: dim_equipment
|Column Names| Description|
|------------|------------|
|equipment_sk| Surrogate primary key of dimension table dim_equipment|
|crane_id| Unique identifier for a particular crane|
|equipment_type| Tyep of container handling crane|
|energy_source| Energy source whether hybrid/diesel or electric|
|asset_priority_level| Categorical calculated column determining priority of crane whether high or normal|



### Table Name: dim_locations
|Column Names| Description|
|------------|------------|
|location_sk|Surrogate primary key of dimension table dim_locations|
|location_id| Unique identifier for the location at the container terminal|
|location_name| The specific identifier for a yard block or berth position used to pinpoint container placement.|
|location_type| Categorizes the area by its operational function, such as Berth or Yard.|
|capacity_category|Defines the storage volume limit (standard block, or non-storage operational area) to manage yard density and prevent congestion. |
|dwell_priority|A ranking used to determine which locations are reserved for fast-moving vs. long-stay cargo. |
|is_reefer_eligible| A boolean flag indicating if the location is equipped with electrical power points for refrigerated containers.|
|zone_priority|A strategic value used to optimize equipment travel distance by prioritizing zones closest to the vessel or gate. |


### Table Name: dim_shipping_lines
|Column Names| Description|
|------------|------------|
|shipping_line_sk|Surrogate primary key of dimension table dim_shipping_lines.|
|shipping_line_id |The original natural key from the source CRM system, maintained for cross-system data reconciliation. |
|company_name |The legal entity name of the carrier, defaulted to "Generic Carrier" if not provided in the source. |
|parent_company| Identifies the larger global conglomerate or alliance (e.g., Maersk, MSC) for group-level volume tracking.|
|contract_start_date|The official commencement date of the terminal service agreement, used to track customer longevity. |
|partnership_years |A calculated field measuring the duration of the business relationship to identify long-term strategic partners. |
|sla_category | A business-tier classification (Tier 1-5) derived from the priority level to standardize service quality expectations.|


### Table Name: dim_vessels
|Column Names| Description|
|------------|------------|
|vessel_sk|Surrogate primary key of dimension table dim_vessels.|
|vessel_id|The unique natural identifier for the ship as assigned by the Terminal Operating System (TOS).|
|vessel_name|The registered name of the vessel|
|shipping_line_id|The foreign key linking the vessel to its operating carrier for fleet-level performance analysis.|
|arrival_time_atb|The "Actual Time of Berthing" (ATB) marking the official start of the vessel's terminal operations.|
|departure_time_atd|The "Actual Time of Departure" (ATD) marking the conclusion of cargo operations and vessel unberthing.|
|terminal_id|The identifier for the specific port facility or terminal where the vessel called.|
|port_stay_duration_hours|A calculated field measuring total turnaround time from arrival to departure to evaluate berth productivity.|
|vessel_class|Categorizes ships into size classes (e.g., Post-Panamax, Feeder) to compare operational efficiency across different ship scales.|
|vessel_status|A dynamic logic field indicating if the ship is currently 'At Berth', 'In Port', or has already 'Departed'.|


## Key Strategic Insights
The Gold Layer Galaxy Schema enables the terminal to answer critical business questions through cross-functional data correlation. Below are the primary strategic insights derived from this model:

#### 1. Operational Efficiency & Asset Optimization:
- **Vessel Turnaround Analysis:** By correlating vessel_class with port_stay_duration_hours, we can identify if 'Post-Panamax' vessels are experiencing disproportionate delays compared to 'Feeder' vessels.
- **Asset Availability vs. Utilization:** By comparing maintenance_status (Downtime) against daily_utilization_pct, the terminal can identify the 'Top 10%' of overworked assets. This allows for proactive maintenance scheduling for high-utilization units before they reach a failure point and create operational bottlenecks.


#### 2. Revenue Leakage & Financial Recovery
- **Dwell-Time Penalties:** The storage_revenue logic identifies 'long-stay' containers that exceed the 3-day grace period. This highlights specific shipping lines that are using the yard as a warehouse, allowing for targeted tariff adjustments.
- **SLA Profitability:** By joining fact_terminal_revenue with dim_shipping_lines, we can determine if 'Platinum' tier customers (who demand the highest resource intensity) are providing a proportional return on investment (ROI).


#### 3. Customer Sentiment & Retention
- **Performance vs. Loyalty:** We can statistically analyze if a shift in Customer Sentiment (from Promoter to Detractor) correlates with a decrease in moves_per_hour or an increase in port_stay_duration_hours.
- **Retention Strategy**: By identifying 'Detractors' among high-volume shipping lines, the commercial team can proactively intervene with service recovery plans before contracts are up for renewal.


#### 4. Resource Allocation & Planning
- **Vessel-Driven Workload Forecasting:** By joining dim_vessels with dim_date, the terminal can identify 'Peak Arrival Days'. This allows management to optimize staffing levels for crane operators and yard equipment during high-volume windows.
- **Infrastructure Readiness:** Using the is_reefer_eligible flag in the locations dimension, the terminal can perform 'Gap Analysis' between the number of arriving refrigerated units (via vessel manifests) and the available powered slots in the yard, preventing cargo spoilage.








