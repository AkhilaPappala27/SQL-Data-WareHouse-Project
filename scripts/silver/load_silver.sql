/*
============================================================
PURPOSE:
------------------------------------------------------------
This procedure loads and transforms data from the Bronze layer
into the Silver layer.

The Silver layer represents cleaned, standardized, and structured
data ready for analytical processing.

Key Objectives:
1. Remove duplicates using window functions
2. Handle missing values (NULL handling, default replacements)
3. Perform data normalization and standardization
4. Convert data types (e.g., INT → DATE)
5. Derive new columns (e.g., category ID, end dates)
6. Validate and correct inconsistent data
7. Ensure data quality and consistency across tables
8. Maintain a re-runnable pipeline using TRUNCATE + INSERT

Additional Features:
- Step-wise logging for monitoring execution
- Execution time tracking for performance visibility
- Error handling using SQL exception handlers

Outcome:
Clean, reliable, and structured data in the Silver layer,
ready for downstream consumption (Gold layer / analytics).
============================================================
*/

DROP PROCEDURE IF EXISTS load_silver;
DELIMITER $$

CREATE PROCEDURE load_silver()
BEGIN

-- =========================
-- Variables for timing
-- =========================
DECLARE start_time DATETIME;
DECLARE end_time DATETIME;

-- Error handling
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    SELECT '❌ Error occurred during Silver load' AS ERROR_MSG;
END;

SET start_time = NOW();
SELECT CONCAT('🚀 Silver Load Started at: ', start_time) AS MSG;

-- =========================
-- Step 1: Load CRM Customers
-- =========================
SET @step_start = NOW();
-- Removing old data before loading fresh cleaned data
SELECT ">> Truncating Table: silver_crm_cust_info" as MSG;
TRUNCATE TABLE silver_crm_cust_info;

SELECT ">> Inserting Data Into: silver_crm_cust_info" as MSG;
INSERT INTO silver_crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT 
    cst_id,
    cst_key,

    -- Removing unwanted spaces
    TRIM(cst_firstname),

    -- Removing unwanted spaces
    TRIM(cst_lastname),

    -- Data normalization and standardization (marital status)
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'   -- Handling missing / invalid values
    END,

    -- Data normalization and standardization (gender)
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'   -- Handling missing / invalid values
    END,

    cst_create_date

FROM (
    SELECT *,
           -- Removing duplicates (keeping latest record)
           ROW_NUMBER() OVER (
               PARTITION BY cst_id 
               ORDER BY cst_create_date DESC
           ) AS flag_last
    FROM bronze_crm_cust_info
    WHERE cst_id IS NOT NULL   -- Handling missing values (null IDs removed)
) t
WHERE flag_last = 1;

SET @step_end = NOW();
SELECT CONCAT('✔ Customers Loaded in ',
TIMESTAMPDIFF(SECOND, @step_start, @step_end), ' seconds') AS MSG;

-- =========================
-- Step 2: Load CRM Products
-- =========================
SET @step_start = NOW();
-- Removing old data before loading fresh cleaned data
SELECT ">> Truncating Table: silver_crm_prd_info" as MSG;
TRUNCATE TABLE silver_crm_prd_info;


SELECT ">> Inserting Data Into: silver_crm_prd_info" as MSG;
INSERT INTO silver_crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT 
    prd_id,

    -- Extract category id
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

    -- Extract product key
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,

    prd_nm,

    -- Handling missing values
    IFNULL(prd_cost, 0) AS prd_cost,

    -- Data normalization and standardization
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line, -- Map product line codes to descriptive values

    -- Convert datetime to date
    DATE(prd_start_dt) AS prd_start_dt,

    -- Derive end date
    DATE(
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key 
            ORDER BY prd_start_dt
        ) - INTERVAL 1 DAY) -- Calculate end date as one day before the next start date

     AS prd_end_dt 
FROM bronze_crm_prd_info;

SET @step_end = NOW();
SELECT CONCAT('✔ Products Loaded in ',
TIMESTAMPDIFF(SECOND, @step_start, @step_end), ' seconds') AS MSG;

-- =========================
-- Step 3: Load CRM Sales
-- =========================
SET @step_start = NOW();
-- Removing old data before loading fresh cleaned data
SELECT ">> Truncating Table: silver_crm_sales_details" as MSG;
TRUNCATE TABLE silver_crm_sales_details;


SELECT ">> Inserting Data Into: silver_crm_sales_details" as MSG;
INSERT INTO silver_crm_sales_details (
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

    -- Data validation + type conversion (INT → DATE)
    CASE 
        WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS CHAR)) != 8 THEN NULL
        ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
    END AS sls_order_dt,

    -- Handling invalid or missing ship date
    CASE 
        WHEN sls_ship_dt = 0 OR LENGTH(CAST(sls_ship_dt AS CHAR)) != 8 THEN NULL
        ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
    END AS sls_ship_dt,

    -- Handling invalid or missing due date
    CASE 
        WHEN sls_due_dt = 0 OR LENGTH(CAST(sls_due_dt AS CHAR)) != 8 THEN NULL
        ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
    END AS sls_due_dt,

    -- Data validation + correction (sales calculation)
    CASE 
        WHEN sls_sales IS NULL 
             OR sls_sales <= 0 
             OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales, -- Recalculate sales if origin value is missing or incorrect

    sls_quantity,

    -- Handling missing or invalid price
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0 
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price -- Derive price if original value is invalid

FROM bronze_crm_sales_details;
SET @step_end = NOW();
SELECT CONCAT('✔ Sales Loaded in ',
TIMESTAMPDIFF(SECOND, @step_start, @step_end), ' seconds') AS MSG;

-- =========================
-- Step 4: Load ERP Customers
-- =========================
SET @step_start = NOW();
-- Removing old data before loading fresh cleaned data
SELECT ">> Truncating Table: silver_erp_cust_az12" as MSG;
TRUNCATE TABLE silver_erp_cust_az12;

SELECT ">> Inserting Data Into: silver_erp_cust_az12" as MSG;
INSERT INTO silver_erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT 
    -- Data cleaning (removing unwanted prefix 'NAS')
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) -- remove 'NAS' prefix if present
        ELSE cid 
    END AS cid,

    -- Handling invalid dates (future birthdates)
    CASE 
        WHEN bdate > CURDATE() THEN NULL
        ELSE bdate 
    END AS bdate, -- set future birthdates to NULL

    -- Data normalization and standardization (gender)
    CASE 
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'   -- Handling missing / invalid values
    END AS gen -- Normalize gender values and handle unknown cases

FROM bronze_erp_cust_az12;
SET @step_end = NOW();
SELECT CONCAT('✔ ERP Customers Loaded in ',
TIMESTAMPDIFF(SECOND, @step_start, @step_end), ' seconds') AS MSG;

-- =========================
-- Step 5: Load ERP Location
-- =========================
SET @step_start = NOW();
-- Removing old data before loading fresh cleaned data
SELECT ">> Truncating Table: silver_erp_loc_a101" as MSG;
TRUNCATE TABLE silver_erp_loc_a101;

SELECT ">> Inserting Data Into: silver_erp_loc_a101" as MSG;
INSERT INTO silver_erp_loc_a101 (
    cid,
    cntry
)
SELECT 
    -- Data cleaning (removing unwanted characters '-')
    REPLACE(cid, '-', '') AS cid,

    -- Data normalization and standardization (country names)
    CASE 
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'   -- Handling missing values
        ELSE TRIM(cntry)
    END AS cntry

FROM bronze_erp_loc_a101;
SET @step_end = NOW();
SELECT CONCAT('✔ ERP Location Loaded in ',
TIMESTAMPDIFF(SECOND, @step_start, @step_end), ' seconds') AS MSG;

-- =========================
-- Step 6: Load ERP Product Category
-- =========================
SET @step_start = NOW();
-- Removing old data before loading fresh cleaned data
SELECT ">> Truncating Table: silver_erp_px_cat_g1v2" as MSG;
TRUNCATE TABLE silver_erp_px_cat_g1v2;

SELECT ">> Inserting Data Into: silver_erp_px_cat_g1v2" as MSG;
INSERT INTO silver_erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT 
    id,
    cat,
    subcat,
    maintenance
FROM bronze_erp_px_cat_g1v2;
SET @step_end = NOW();
SELECT CONCAT('✔ ERP Category Loaded in ',
TIMESTAMPDIFF(SECOND, @step_start, @step_end), ' seconds') AS MSG;

-- =========================
-- Total Time
-- =========================
SET end_time = NOW();

SELECT CONCAT('🎉 Silver Load Completed at: ', end_time) AS MSG,
       CONCAT('⏱ Total Duration: ',
       TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS TOTAL_TIME;

END$$

DELIMITER ;
