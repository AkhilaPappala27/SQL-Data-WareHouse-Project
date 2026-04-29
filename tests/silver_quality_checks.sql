/*
===============================================================================
PURPOSE:
-------------------------------------------------------------------------------
This script performs data quality validation on the Silver layer tables.

Key Objectives:
1. Validate primary key integrity (no NULLs or duplicates)
2. Detect unwanted spaces in string fields
3. Ensure data standardization and consistency
4. Identify invalid or out-of-range dates
5. Verify logical relationships between columns (e.g., order dates, sales calculations)
6. Detect negative or incorrect numerical values
7. Ensure overall data reliability before further processing

Usage:
- Run this script after executing the Silver layer load process
- Review any records returned by these queries
- Investigate and resolve data issues before proceeding to the next layer
===============================================================================
*/


-- ====================================================================
-- Checking 'silver_crm_cust_info'
-- ====================================================================
SELECT cst_id, COUNT(*) 
FROM silver_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

SELECT cst_key 
FROM silver_crm_cust_info
WHERE cst_key != TRIM(cst_key);

SELECT DISTINCT cst_marital_status 
FROM silver_crm_cust_info;

-- ====================================================================
-- Checking 'silver_crm_prd_info'
-- ====================================================================
SELECT prd_id, COUNT(*) 
FROM silver_crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

SELECT prd_nm 
FROM silver_crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

SELECT prd_cost 
FROM silver_crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

SELECT DISTINCT prd_line 
FROM silver_crm_prd_info;

SELECT * 
FROM silver_crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checking 'silver_crm_sales_details'
-- ====================================================================
SELECT sls_due_dt 
FROM silver_crm_sales_details
WHERE sls_due_dt IS NULL;

SELECT * 
FROM silver_crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

SELECT DISTINCT sls_sales, sls_quantity, sls_price 
FROM silver_crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0;

-- ====================================================================
-- Checking 'silver_erp_cust_az12'
-- ====================================================================
SELECT DISTINCT bdate 
FROM silver_erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > CURDATE();

SELECT DISTINCT gen 
FROM silver_erp_cust_az12;

-- ====================================================================
-- Checking 'silver_erp_loc_a101'
-- ====================================================================
SELECT DISTINCT cntry 
FROM silver_erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'silver_erp_px_cat_g1v2'
-- ====================================================================
SELECT * 
FROM silver_erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

SELECT DISTINCT maintenance 
FROM silver_erp_px_cat_g1v2;
