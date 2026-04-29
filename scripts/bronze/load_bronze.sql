/*
Purpose:
---> Wipe bronze clean.
---> Reload fresh CSVs into bronze tables.
---> Apply basic cleaning (NULL handling, date conversion).
---> Print status messages and timing info for transparency.

*/

-- NOTE:
-- If LOAD DATA LOCAL INFILE fails:
-- 1) SET GLOBAL local_infile = 1;
-- 2) Run client with --local-infile=1
SOURCE procedures_bronze.sql;
USE datawarehouse;

SET @start_time = NOW();

-- Step 1: Truncate bronze tables
SELECT ">> Truncating all the tables" as status;
CALL truncate_crm_erp_tables();

-- Step 2: Load px_cat_g1v2
SELECT ">> Updating  erp px_cat_g1v2 table" as status;
LOAD DATA LOCAL INFILE 'datasets/px_cat_g1v2.csv'
INTO TABLE bronze_erp_px_cat_g1v2
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @cat, @subcat, @maintenance)
SET
  id          = NULLIF(@id, ''),
  cat         = NULLIF(@cat, ''),
  subcat      = NULLIF(@subcat, ''),
  maintenance = NULLIF(@maintenance, '');

-- Step 3: Load loc_a101
SELECT ">> Updating erp loc_a101 table" as status;
LOAD DATA LOCAL INFILE 'datasets/loc_a101.csv'
INTO TABLE bronze_erp_loc_a101
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@cid, @cntry)
SET
  cid   = NULLIF(@cid, ''),
  cntry = NULLIF(@cntry, '');

-- Step 4: Load cust_az12
SELECT ">> Updating erp cust_az12 table" as status;
LOAD DATA LOCAL INFILE 'datasets/cust_az12.csv'
INTO TABLE bronze_erp_cust_az12
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@cid, @bdate, @gen)
SET
  cid   = NULLIF(@cid, ''),
  bdate = CASE WHEN @bdate IN ('', '0') THEN NULL ELSE STR_TO_DATE(@bdate, '%Y-%m-%d') END,
  gen   = NULLIF(@gen, '');

-- Step 5: Load sales_details
SELECT ">> Updating crm sales_details table" as status;
LOAD DATA LOCAL INFILE 'datasets/sales_details.csv'
INTO TABLE bronze_crm_sales_details
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@sls_ord_num,@sls_prd_key,@sls_cust_id,@sls_order_dt,@sls_ship_dt,@sls_due_dt,@sls_sales,@sls_quantity,@sls_price)
SET
  sls_ord_num   = NULLIF(@sls_ord_num,''),
  sls_prd_key   = NULLIF(@sls_prd_key,''),
  sls_cust_id   = NULLIF(@sls_cust_id,''),
  sls_order_dt  = NULLIF(@sls_order_dt,''),
  sls_ship_dt   = NULLIF(@sls_ship_dt,''),
  sls_due_dt    = NULLIF(@sls_due_dt,''),
  sls_sales     = NULLIF(@sls_sales,''),
  sls_quantity  = NULLIF(@sls_quantity,''),
  sls_price     = NULLIF(@sls_price,'');

-- Step 6: Load prd_info
SELECT ">> Updating crm prd_info table" as status;
LOAD DATA LOCAL INFILE 'datasets/prd_info.csv'
INTO TABLE bronze_crm_prd_info
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@prd_id, @prd_key, @prd_nm, @prd_cost, @prd_line, @prd_start_dt, @prd_end_dt)
SET
  prd_id       = NULLIF(@prd_id, ''),
  prd_key      = NULLIF(@prd_key, ''),
  prd_nm       = NULLIF(@prd_nm, ''),
  prd_cost     = NULLIF(@prd_cost, ''),
  prd_line     = NULLIF(@prd_line, ''),
  prd_start_dt = CASE WHEN @prd_start_dt IN ('', '0') THEN NULL ELSE STR_TO_DATE(@prd_start_dt, '%Y-%m-%d') END,
  prd_end_dt   = CASE WHEN @prd_end_dt IN ('', '0') THEN NULL ELSE STR_TO_DATE(@prd_end_dt, '%Y-%m-%d') END;

-- Step 7: Load cust_info
SELECT ">> Updating crm cust_info table" as status;
LOAD DATA LOCAL INFILE 'datasets/cust_info.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@cst_id, @cst_key, @cst_firstname, @cst_lastname, @cst_marital_status, @cst_gndr, @cst_create_date)
SET 
  cst_id          = NULLIF(@cst_id, ''),
  cst_key         = NULLIF(@cst_key, ''),
  cst_firstname   = NULLIF(@cst_firstname, ''),
  cst_lastname    = NULLIF(@cst_lastname, ''),
  cst_marital_status = NULLIF(@cst_marital_status, ''),
  cst_gndr        = NULLIF(@cst_gndr, ''),
  cst_create_date = CASE WHEN @cst_create_date IN ('', '0') THEN NULL ELSE STR_TO_DATE(@cst_create_date, '%Y-%m-%d') END;

SET @end_time =NOW();
SELECT CONCAT('started at: ', @start_time) AS start_time,
CONCAT('finished at: ', @end_time) AS end_time,
       CONCAT('Entire load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS duration;
