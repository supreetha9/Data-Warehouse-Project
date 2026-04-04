/*
===============================================================================
Quality Checks — Silver Layer (PostgreSQL)
===============================================================================
Script Purpose:
    Quality checks for consistency, accuracy, and standardization across the
    silver layer. Includes checks for:
    - Null or duplicate primary keys
    - Unwanted spaces in string fields
    - Data standardization (distinct value inspection)
    - Invalid date ranges and orders
    - Consistency between related fields

Usage Notes:
    - Run after loading the silver layer.
    - Expect empty result sets for checks marked "Expectation: No Results";
      use DISTINCT listings to manually review allowed values.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key IS DISTINCT FROM TRIM(BOTH FROM cst_key);

-- Data Standardization & Consistency (manual review)
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info
ORDER BY cst_marital_status;

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm IS DISTINCT FROM TRIM(BOTH FROM prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT
    prd_id,
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency (manual review)
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info
ORDER BY prd_line;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT
    *
FROM silver.crm_prd_info
WHERE prd_end_dt IS NOT NULL
  AND prd_start_dt IS NOT NULL
  AND prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================
-- Check for Invalid Dates (bronze integers before conversion)
-- Expectation: No Invalid Dates
SELECT
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LENGTH(sls_due_dt::text) != 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results (NULL dates ignored)
SELECT
    *
FROM silver.crm_sales_details
WHERE sls_order_dt IS NOT NULL
  AND (
      (sls_ship_dt IS NOT NULL AND sls_order_dt > sls_ship_dt)
      OR (sls_due_dt IS NOT NULL AND sls_order_dt > sls_due_dt)
  );

-- Check Data Consistency: Sales = Quantity * ABS(Price) (aligned with silver load)
-- Expectation: No Results
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS DISTINCT FROM (sls_quantity * ABS(sls_price))
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and today
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < DATE '1924-01-01'
   OR bdate > CURRENT_DATE;

-- Data Standardization & Consistency (manual review)
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12
ORDER BY gen;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================
-- Data Standardization & Consistency (manual review)
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE cat IS DISTINCT FROM TRIM(BOTH FROM cat)
   OR subcat IS DISTINCT FROM TRIM(BOTH FROM subcat)
   OR maintenance IS DISTINCT FROM TRIM(BOTH FROM maintenance);

-- Data Standardization & Consistency (manual review)
SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2
ORDER BY maintenance;
