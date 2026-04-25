-- Create a Database named 'Data Warehouse'

/*
USE master;
GO

--Drop and recreate the 'DataWarehouse' database--

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

*/

USE master;

CREATE DATABASE DataWarehouse;

USE DataWarehouse;


CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO