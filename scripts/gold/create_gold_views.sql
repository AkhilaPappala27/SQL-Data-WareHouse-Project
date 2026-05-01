/*
===============================================================================
GOLD LAYER – BUSINESS READY DATA
===============================================================================

PURPOSE:
This script creates Gold layer views which provide clean, structured, and 
business-ready data for analytics and reporting.

The Gold layer:
- Combines data from multiple Silver tables
- Applies business logic and transformations
- Creates dimension and fact views
- Generates surrogate keys for analysis

These views are optimized for:
- Dashboards
- Reporting
- Business analytics

===============================================================================
*/

-- ============================================================================
-- VIEW: gold_dim_customers
-- PURPOSE:
-- Creates a customer dimension by combining CRM and ERP data.
-- Resolves gender conflicts and enriches with location details.
-- ============================================================================

CREATE OR REPLACE VIEW gold_dim_customers AS
SELECT 
    -- Generate surrogate key
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,

    -- Customer identifiers
    ci.cst_id        AS customer_id,
    ci.cst_key       AS customer_number,

    -- Customer details
    ci.cst_firstname AS first_name,
    ci.cst_lastname  AS last_name,

    -- Location from ERP
    la.cntry         AS country,

    -- Attributes
    ci.cst_marital_status AS marital_status,

    -- Resolve gender (CRM priority, ERP fallback)
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    -- Additional fields
    ca.bdate            AS birthdate,
    ci.cst_create_date  AS create_date

FROM silver_crm_cust_info ci

LEFT JOIN silver_erp_cust_az12 ca 
    ON ci.cst_key = ca.cid

LEFT JOIN silver_erp_loc_a101 la 
    ON ci.cst_key = la.cid;


-- ============================================================================
-- VIEW: gold_dim_products
-- PURPOSE:
-- Creates a product dimension by combining CRM product data with ERP category.
-- Filters active products and generates surrogate keys.
-- ============================================================================

CREATE OR REPLACE VIEW gold_dim_products AS
SELECT 
    -- Surrogate key
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,

    -- Product identifiers
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,

    -- Product details
    pn.prd_nm       AS product_name,

    -- Category mapping
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,

    -- Attributes
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date

FROM silver_crm_prd_info pn

LEFT JOIN silver_erp_px_cat_g1v2 pc 
    ON pn.cat_id = pc.id

-- Keep only active products
WHERE pn.prd_end_dt IS NULL;


-- ============================================================================
-- VIEW: gold_fact_sales
-- PURPOSE:
-- Creates a sales fact table by linking transactions with dimensions.
-- Used for revenue analysis, trends, and reporting.
-- ============================================================================

CREATE OR REPLACE VIEW gold_fact_sales AS
SELECT 
    -- Order info
    sd.sls_ord_num  AS order_number,

    -- Dimension keys
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,

    -- Dates
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS ship_date,
    sd.sls_due_dt   AS due_date,

    -- Metrics
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price

FROM silver_crm_sales_details sd  

-- Join product dimension
LEFT JOIN gold_dim_products pr 
    ON pr.product_number = sd.sls_prd_key  

-- Join customer dimension
LEFT JOIN gold_dim_customers cu 
    ON sd.sls_cust_id = cu.customer_id;
