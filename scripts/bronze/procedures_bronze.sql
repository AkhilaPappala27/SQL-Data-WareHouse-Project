-- ============================================================
-- PURPOSE:
-- This procedure truncates (clears) all Bronze layer tables.
-- It is used before loading fresh data to ensure that:
-- 1. Old data is removed
-- 2. Duplicate data is avoided
-- 3. Each load starts with a clean staging environment
--
-- This supports a re-runnable and consistent data ingestion process.
-- ============================================================

DROP PROCEDURE IF EXISTS truncate_crm_erp_tables;
DELIMITER $$

CREATE PROCEDURE truncate_crm_erp_tables()
BEGIN
    TRUNCATE TABLE bronze_crm_cust_info;
    TRUNCATE TABLE bronze_crm_prd_info;
    TRUNCATE TABLE bronze_crm_sales_details;
    TRUNCATE TABLE bronze_erp_cust_az12;
    TRUNCATE TABLE bronze_erp_loc_a101;
    TRUNCATE TABLE bronze_erp_px_cat_g1v2;
END$$

DELIMITER ;
