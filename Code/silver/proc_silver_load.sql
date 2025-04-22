/* 

************************************************************
Stored procedure: load data from bronze layer tables into silver layer tables
************************************************************

The purpose of this script:
    - This SQL script truncates the tables in the silver layer
    - It then loads cleaned, transformed data from the bronze layer to the silver layer

Parameters:
    None.

Example usage:
    EXEC silver.load_data;

*/

CREATE OR ALTER PROCEDURE silver.load_data AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @start_time_total DATETIME, @end_time_total DATETIME
    SET @start_time_total = GETDATE()

    BEGIN TRY

        PRINT '======================'
        PRINT 'Loading the CRM data'
        PRINT '======================'

        SET @start_time = GETDATE()

        PRINT '>> Truncating table: silver.crm_cust_info'
        TRUNCATE TABLE silver.crm_cust_info
        PRINT '>> Inserting data into: silver.crm_cust_info'
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date)

        SELECT cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE TRIM(UPPER(cst_marital_status)) 
                WHEN 'S' THEN 'Single'
                WHEN 'M' THEN 'Married'
                ELSE 'Unknown'
            END AS cst_marital_status, 
            CASE TRIM(UPPER(cst_gndr))
                WHEN 'M' THEN 'Male'
                WHEN 'F' THEN 'Female'
                ELSE 'Unknown'
            END AS cst_gndr,
            cst_create_date
        FROM(
            SELECT *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rank_most_recent
                FROM bronze.crm_cust_info
                WHERE cst_id IS NOT NULL
        )t
        WHERE rank_most_recent = 1;
        SET @end_time = GETDATE()
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR(50)) + ' seconds'

        SET @start_time = GETDATE()

        PRINT '>> Truncating table: silver.crm_prd_info'
        TRUNCATE TABLE silver.crm_prd_info
        PRINT '>> Inserting data into: silver.crm_prd_info'
        INSERT INTO silver.crm_prd_info(
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt)

        SELECT prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
        TRIM(prd_nm) AS prd_nm,
        ISNULL(prd_cost, 0) AS prd_cost,
        CASE UPPER(TRIM(prd_line)) 
            WHEN 'S' THEN 'Other Sales'
            WHEN 'M' THEN 'Mountain'
            WHEN 'T' THEN 'Touring'
            WHEN 'R' THEN 'Road'
            ELSE 'Unknown'
        END AS prd_line,
        prd_start_dt,
        DATEADD(day, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC)) AS prd_end_dt
        FROM bronze.crm_prd_info;
        SET @end_time = GETDATE()
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR(50)) + ' seconds'

        SET @start_time = GETDATE()

        PRINT '>> Truncating table: silver.crm_sales_details'
        TRUNCATE TABLE silver.crm_sales_details
        PRINT '>> Inserting data into: silver.crm_sales_details'
        INSERT INTO silver.crm_sales_details(
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )

        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE LEN(sls_order_dt)
                WHEN 8 
                    THEN CAST(CAST(sls_order_dt AS VARCHAR(50)) AS DATE)
                ELSE NULL
            END AS sls_order_dt,
            CASE LEN(sls_ship_dt)
                WHEN 8 
                    THEN CAST(CAST(sls_ship_dt AS VARCHAR(50)) AS DATE)
                ELSE NULL
            END AS sls_ship_dt,
            CASE LEN(sls_due_dt)
                WHEN 8 
                    THEN CAST(CAST(sls_due_dt AS VARCHAR(50)) AS DATE)
                ELSE NULL
            END AS sls_due_dt,
            CASE WHEN sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price) OR sls_sales IS NULL 
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales, 
            sls_quantity,
            CASE WHEN sls_price <0 OR sls_price IS NULL 
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price 
        FROM bronze.crm_sales_details
        SET @end_time = GETDATE()
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR(50)) + ' seconds'

        PRINT '======================'
        PRINT 'Loading the ERP data'
        PRINT '======================'

        SET @start_time = GETDATE()

        PRINT '>> Truncating table: silver.erp_cust_AZ12'
        TRUNCATE TABLE silver.erp_cust_AZ12
        PRINT '>> Inserting data into: silver.erp_cust_AZ12'
        INSERT INTO silver.erp_cust_AZ12(
            CID,
            BDATE,
            GEN
        )

        SELECT
        CASE WHEN CID LIKE 'NAS%'
                THEN SUBSTRING(CID, 4, LEN(CID))
            ELSE CID
        END AS CID, --1
        CASE WHEN BDATE > GETDATE()
                THEN NULL
            ELSE BDATE
        END AS BDATE, --2
        CASE WHEN UPPER(TRIM(GEN)) LIKE '%F%'
                THEN 'Female'
            WHEN UPPER(TRIM(GEN)) LIKE '%M%'
                THEN 'Male'
            ELSE 'Unknown'
        END AS GEN --3
        FROM bronze.erp_cust_AZ12
        SET @end_time = GETDATE()
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR(50)) + ' seconds'

        SET @start_time = GETDATE()

        PRINT '>> Truncating table: silver.erp_loc_A101'
        TRUNCATE TABLE silver.erp_loc_A101
        PRINT '>> Inserting data into: silver.erp_loc_A101'
        INSERT INTO silver.erp_loc_A101(
            CID,
            CNTRY
        )

        SELECT
        REPLACE(CID, '-', '') CID,
        CASE 
            WHEN CleanCNTRY = 'DE' THEN 'Germany'
            WHEN CleanCNTRY IN ('US', 'USA') THEN 'United States'
            WHEN CleanCNTRY = '' OR CleanCNTRY IS NULL THEN 'Unknown'
            ELSE CleanCNTRY
        END AS CNTRY
        FROM (
        SELECT 
            CID,
            REPLACE(TRIM(CNTRY), CHAR(13), '') AS CleanCNTRY
        FROM bronze.erp_loc_A101
        ) t 
        SET @end_time = GETDATE()
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR(50)) + ' seconds'

        SET @start_time = GETDATE()

        PRINT '>> Truncating table: silver.erp_px_cat_G1V2'
        TRUNCATE TABLE silver.erp_px_cat_G1V2
        PRINT '>> Inserting data into: silver.erp_px_cat_G1V2'
        INSERT INTO silver.erp_px_cat_G1V2(
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE
        )

        SELECT 
        CASE ID
            WHEN 'CO_PD'
                THEN 'CO_PE'
            ELSE ID
        END AS ID,
        CAT,
        SUBCAT,
        REPLACE(Maintenance, CHAR(13), '') as Maintenance -- Remove carriage return character
        FROM bronze.erp_px_cat_G1V2
        SET @end_time = GETDATE()
        PRINT 'Time taken: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR(50)) + ' seconds'
    END TRY
    BEGIN CATCH
        PRINT 'There was a problem loading data into the silver layer'
        PRINT 'The error message: ' + ERROR_MESSAGE()
        PRINT 'The error number: ' + CAST(ERROR_NUMBER() AS VARCHAR(50))
        PRINT 'The error state: ' + CAST(ERROR_STATE() AS VARCHAR(50))
    END CATCH

    PRINT '______________________'
    SET @end_time_total = GETDATE()
    PRINT 'Total time taken: ' + CAST(DATEDIFF(second, @start_time_total, @end_time_total) AS VARCHAR(50)) + ' seconds'
END