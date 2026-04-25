USE DataWarehouse;


CREATE TABLE gold.dim_date (
    date_sk INT PRIMARY KEY,
    full_date DATE,
    year INT,
    month_number INT,
    month_name VARCHAR(20),
    month_year_label VARCHAR(20),
    day_of_month INT,
    day_name VARCHAR(20),
    day_of_week_number INT,
    Is_weekend BIT,
    quarter VARCHAR(2),
    fiscal_year INT
);

