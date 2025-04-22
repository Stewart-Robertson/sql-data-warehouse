/* 

************************************************************
Stored procedure: load data from source into bronze layer tables
************************************************************

The purpose of this script:
    - This SQL script first truncates the tables in the warehouse
    - It then bulk loads data from csv files into their respective tables in the warehouse

Parameters:
    None.

Example usage:
    EXEC bronze.load_data;

*/

CREATE OR ALTER PROCEDURE bronze.load_data AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @start_time_total DATETIME, @end_time_total DATETIME;
    SET @start_time_total = GETDATE()
    BEGIN TRY

        SET @start_time = GETDATE();

        PRINT '======================'
        PRINT 'Loading the CRM data'
        PRINT '======================'

        PRINT '>> Truncating table: bronze_crm_cust_info'
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT '>> Inserting data into: bronze_crm_cust_info'
        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/data/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'

        PRINT ' '

        SET @start_time = GETDATE();

        PRINT '>> Truncating table: bronze_crm_prd_info'
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT '>> Inserting data into: bronze_crm_prd_info'
        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/data/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE()
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'
        PRINT ' '

        SET @start_time = GETDATE()

        PRINT '>> Truncating table: bronze_crm_sales_details'
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT '>> Inserting data into: bronze_crm_prd_info'
        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/data/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE()
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'
        PRINT ' '
        PRINT '----- CRM data loaded successfully -----'

        PRINT '======================'
        PRINT 'Loading the ERP data'
        PRINT '======================'

        SET @start_time = GETDATE()

        PRINT '>> Truncating table: bronze.erp_cust_AZ12'
        TRUNCATE TABLE bronze.erp_cust_AZ12;
        PRINT '>> Inserting data into: bronze.erp_cust_AZ12'
        BULK INSERT bronze.erp_cust_AZ12
        FROM '/var/opt/mssql/data/cust_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE()
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'
        PRINT ' '

        SET @start_time = GETDATE()

        PRINT '>> Truncating table: bronze.erp.loc_A101'
        TRUNCATE TABLE bronze.erp_loc_A101;
        PRINT '>> Inserting data into: bronze.erp.loc_A101'
        BULK INSERT bronze.erp_loc_A101
        FROM '/var/opt/mssql/data/LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE()
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'
        PRINT ' '

        SET @start_time = GETDATE()

        PRINT '>> Truncating table: bronze.erp_px_cat_G1V2'
        TRUNCATE TABLE bronze.erp_px_cat_G1V2;
        PRINT '>> Inserting data into: bronze.erp_px_cat_G1V2'
        BULK INSERT bronze.erp_px_cat_G1V2
        FROM '/var/opt/mssql/data/PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE()
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds'
        PRINT ' '
        PRINT '----- ERP data loaded successfully -----'
        PRINT '_______________________'
    END TRY
    BEGIN CATCH
        PRINT 'There was an error loading the data into the bronze layer'
        PRINT 'Error message: ' + ERROR_MESSAGE()
        PRINT 'Error code: ' + CAST(ERROR_NUMBER() AS VARCHAR)
        PRINT 'Error state: ' + CAST(ERROR_STATE() AS VARCHAR)
    END CATCH

    SET @end_time_total = GETDATE()
    PRINT 'Total time taken to load data into the bronze layer: ' + CAST(DATEDIFF(SECOND, @start_time_total, @end_time) AS VARCHAR) + ' seconds'
END