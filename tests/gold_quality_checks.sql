/*
===============================================================================
GOLD LAYER – QUALITY CHECKS
===============================================================================

PURPOSE:
This script validates the integrity, consistency, and correctness 
of the Gold layer.

Checks included:
- Uniqueness of surrogate keys (dimension tables)
- Referential integrity between fact and dimension tables
- Data model validation for analytics

USAGE:
- Run after Gold layer views are created
- Investigate any records returned by queries
===============================================================================
*/

-- ============================================================================
-- Checking 'gold_dim_customers'
-- ============================================================================

-- Check for duplicate customer_key
-- Expectation: No Results
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- Checking 'gold_dim_products'
-- ============================================================================

-- Check for duplicate product_key
-- Expectation: No Results
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- Checking 'gold_fact_sales'
-- ============================================================================

-- Check referential integrity (fact → dimensions)
-- Expectation: No NULL keys
SELECT *
FROM gold_fact_sales f

LEFT JOIN gold_dim_customers c 
    ON c.customer_key = f.customer_key

LEFT JOIN gold_dim_products p 
    ON p.product_key = f.product_key

WHERE f.customer_key IS NULL 
   OR f.product_key IS NULL;
