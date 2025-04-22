/* 

************************************************************
Create Data Warehouse and Schemas of Data Warehouse Layers
************************************************************

The purpose of this script.
    - This SQL script will create a database called DataWarehouse.
    - The DataWarehouse will contain three layers, following a medallion methodology: 
        "bronze", "silver", and "gold".
    - The script will first check to see if the DataWarehouse exists. 
    If it exists, it will be removed and recreated. It will otherwise be created for the first time.
    - The schema for the three database layers will then be created.

Warning:
    - This script will permanently delete the DataWarehouse database if it exists.
    - Use with caution, and ensure that all relevant data is backed up before running the script.

*/

USE master;

-- Check if DataWarehouse exists, and if it does, remove it
IF EXISTS (SELECT 1 from sys.databases WHERE name='DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;

-- Create the DataWarehouse
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Creat the schemas for each layer of the data warehouse
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;