/* 

************************************************************
DDL script: Create Bronze Layer Tables
************************************************************

The purpose of this script:
    - This SQL script defines the tables that will exist in the bronze layer
    - Running this script will re-define the tables' structure

*/

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE,
);

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
);

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

IF OBJECT_ID('bronze.erp_cust_AZ12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_AZ12;
CREATE TABLE bronze.erp_cust_AZ12(
    CID VARCHAR(50),
    BDATE DATE,
    GEN VARCHAR(50),
);

IF OBJECT_ID('bronze.erp_loc_A101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_A101;
CREATE TABLE bronze.erp_loc_A101(
    CID VARCHAR(50),
    CNTRY VARCHAR(50),
);

IF OBJECT_ID('bronze.px_cat_G1V2', 'U') IS NOT NULL
    DROP TABLE bronze.er_px_cat_G1V2;
CREATE TABLE bronze.erp_px_cat_G1V2(
    ID VARCHAR(50),
    CAT VARCHAR(50),
    SUBCAT VARCHAR(50),
    MAINTENANCE VARCHAR(50)
);


