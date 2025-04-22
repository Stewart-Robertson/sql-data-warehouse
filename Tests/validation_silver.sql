USE DataWarehouse;

/*

######## DATA QUALITY CHECKS ########

*/ 

-- =========== silver.crm_cust_info table ===========

SELECT * 
FROM silver.crm_cust_info;

-- Check for NULLs or duplicates in the primary key
-- Expectation: No result
SELECT cst_id,
COUNT (*) AS count_of_primary_keys
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted whitespace in string columns
-- Expectation: No result
SELECT *
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT *
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT *
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

SELECT *
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Check the unique values present in the marital status and gender columns
-- Expectation: ('Single', 'Married' [,'Unknown']) -> Present in cst_marital_status | ('Male','Female' [,'Unknown']) -> Present in cst_gndr
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- =========== silver.crm_prod_info table ===========

SELECT *
FROM silver.crm_prd_info;

-- Check for NULLs or duplicates in the primary key
-- Expectation: No result
SELECT prd_id,
COUNT (*) AS count_of_primary_keys
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check unique values of product line
-- Expectation: ('Mountain', 'Road', 'Other Sales', 'Touring' [,'Unknown'])
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check no product end dates are before the product start date
-- Expectation: No result
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- =========== silver.crm_sales_details ===========

-- Check order number, product key, customer id values
-- Expectation: No result
SELECT sls_ord_num,
sls_prd_key,
sls_cust_id
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num) OR sls_ord_num IS NULL 
OR sls_prd_key IS NULL
OR sls_cust_id <=0 OR sls_cust_id IS NULL

-- Check for any product keys that are not present in the product info (silver.crm_prd_info) table
-- Expectation: No result
SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

-- Check for invalid sales/quantity/price values
-- Expectation: No result
SELECT sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales <=0 OR  sls_sales != sls_quantity * sls_price OR sls_sales IS NULL
OR sls_quantity <=0 OR sls_quantity IS NULL 
OR sls_price <=0 OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price

-- Check validity of dates order (no order date can be before shipping or due date. Shipping date can be after due date)
-- Expectation: No result
SELECT sls_order_dt,
sls_ship_dt,
sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- =========== silver.erp_cust_AZ12 table ===========

SELECT *
FROM silver.erp_cust_AZ12

-- Check format of first characters in CID column
-- Expectation: One distinct substring returned
SELECT DISTINCT
SUBSTRING(CID, 0, 4)
FROM silver.erp_cust_AZ12

-- Check all bdates are of the same length
-- Expectation: All bdates of length 10, or NULL
SELECT DISTINCT
LEN(BDATE)
FROM silver.erp_cust_AZ12

-- Check for very old people (>90)
-- Expectation: 67 people >90 years old
SELECT BDATE
FROM silver.erp_cust_AZ12
WHERE DATEDIFF(year, BDATE, GETDATE()) > 90
ORDER BY BDATE DESC

-- Check for very young people (>18)
-- Expectation: No result
SELECT BDATE
FROM silver.erp_cust_AZ12
WHERE DATEDIFF(year, BDATE, GETDATE()) < 18 and BDATE < GETDATE()
ORDER BY BDATE DESC

-- Check for birth dates that are impossible
-- Expectation: No result
SELECT BDATE
FROM silver.erp_cust_AZ12
WHERE BDATE > GETDATE()

-- Check what distinct genders exist
-- Expectation: ('F', 'M' [, 'Unknown'])
SELECT DISTINCT
GEN 
FROM silver.erp_cust_AZ12

-- =========== silver.erp_loc_A101 ===========

-- Check all the values in the CID column exist in the silver.crm_cust_info
-- Expectation: No result
SELECT CID
FROM silver.erp_loc_A101
WHERE CID NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-- Check if '-' is present in the CID values
-- Expectation: No result
SELECT 
CID
FROM silver.erp_loc_A101
WHERE CID LIKE '%-%'

-- Check the first characters in the CIDs
-- Expectation: All begin with 'AW00'
SELECT DISTINCT
SUBSTRING(CID, 0, 5) AS distinct_CID_starts
FROM silver.erp_loc_A101 

-- Check all the CIDs are of the same lenght
-- Expectation: All of length 10
SELECT DISTINCT
LEN(CID) AS distinct_CID_lengths
FROM silver.erp_loc_A101

-- Check what variety of country records exists
-- Expectation: country values are ('Australia', 'Canada', 'France', 'Germany', 'United Kingdom', 'United States' [, 'Unknown'])
SELECT DISTINCT
CNTRY AS distinct_countries
FROM silver.erp_loc_A101
ORDER BY CNTRY

-- =========== silver.erp_px_cat_G1V2 ===========

-- Check that all IDs are present in silver.crm_prd_info
-- Expectation: No result
SELECT 
ID
FROM silver.erp_px_cat_G1V2
WHERE ID NOT IN (SELECT cat_id FROM silver.crm_prd_info)

-- Check no whitespace in CAT, SUBCAT columns
-- Expectation: No result
SELECT 
CAT,
SUBCAT,
Maintenance
FROM silver.erp_px_cat_G1V2
WHERE TRIM(CAT) != CAT OR TRIM(SUBCAT) != SUBCAT

-- Check distinct values in CAT column
SELECT DISTINCT
CAT
FROM silver.erp_px_cat_G1V2

-- Check distinct values in SUBCAT column
SELECT DISTINCT
SUBCAT
FROM silver.erp_px_cat_G1V2

-- Maintenance column has carriage return character

SELECT
Maintenance
FROM silver.erp_px_cat_G1V2