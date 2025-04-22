/*

*****************************************************************************************
Create the Gold Layer: Use silver layer tables to create business-ready data
*****************************************************************************************

The purpose of this script:
    - This script uses the Star Schema methodology to create the gold layer by producing two dimension views and one fact view
    - Dimension view 1: gold.dim_customers
        - Contains customer information, enriched with data from multiple tables
        - A surrogate key – 'customer_key' – is created as the view's Primary Key
    - Dimension view 2: gold.dim_products
        - Containts enriched product information
        - A surrogate key – 'product_key' – is created as the view's Primary Key
    - Fact view: gold.fact_sales
        - Contains sales information
        - Related to the customer and product tables using the Primary Keys above as Foreign Keys


*/


-- ********************* Customers Dimension


CREATE VIEW gold.dim_customers 
AS
    SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_ID,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    ci.cst_marital_status AS marital_status,
    CASE WHEN ci.cst_gndr != 'Unknown' 
            THEN ci.cst_gndr
        ELSE COALESCE(ce.GEN, 'Unknown')
    END AS gender,
    ce.BDATE AS birth_date,
    lo.CNTRY AS country,
    ci.cst_create_date AS created_date
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_AZ12 ce
    ON ci.cst_key = ce.CID
    LEFT JOIN silver.erp_loc_A101 lo
    ON ci.cst_key = lo.CID


-- ********************* Products Dimension


CREATE VIEW gold.dim_products
AS
    SELECT
    ROW_NUMBER() OVER (ORDER BY prd_id) AS product_key,
    pi.prd_key AS product_number,
    pi.prd_nm AS product_name,
    pi.cat_id AS category_id,
    px.CAT AS category,
    px.SUBCAT AS subcategory,
    pi.prd_line AS product_line,
    pi.prd_cost AS product_cost,
    px.maintenance AS maintenance,
    pi.prd_start_dt AS product_start_date
    FROM silver.crm_prd_info pi
    LEFT JOIN silver.erp_px_cat_G1V2 px
    ON pi.cat_id = px.ID
    WHERE prd_end_dt IS NULL -- select only active products


-- ********************* Sales Fact


CREATE VIEW gold.fact_sales
AS
    SELECT 
        sd.sls_ord_num AS order_number,
        pr.product_key,
        cu.customer_key,
        sd.sls_quantity AS quantity,
        sd.sls_price AS price,
        sd.sls_sales AS sales_amount,
        sd.sls_order_dt AS order_date,
        sd.sls_ship_dt AS shipped_date,
        sd.sls_due_dt AS due_date,
        sd.dwh_create_date
    FROM silver.crm_sales_details sd
    LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id
    LEFT JOIN gold.dim_products pr 
    ON sd.sls_prd_key = pr.product_number