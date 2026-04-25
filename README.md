# SQL Data Warehouse Project - Maritime Logistics
This is an end-to-end Galaxy Schema Data Warehouse that integrates siloed terminal operations, financial billing and asset performance data insto single source of truth for maritime logistics.


## Contents
- Project Overview
- Tools
- Data Overview

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
|vessel_id| | Identifier for container ship|
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
|shipping_line_id| Unique identifier for shipping line companies|
|vessel_id| Identifier for container ship|
|delay_complaint_flag| Boolean column with values 1, when the vessel departure gets delayed and 0 when vessel departs on time from port|
|satisfaction_score| Satisfaction rating ranging from 0 to 10 given by the shipping line company, with 0 as poor and 10 as best|




