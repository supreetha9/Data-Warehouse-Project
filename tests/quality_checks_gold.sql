/*
===============================================================================
Quality Checks — Gold Layer (PostgreSQL)
===============================================================================
Script Purpose:
    Validates integrity and consistency of the gold layer (views):
    - Uniqueness of surrogate keys in dimensions
    - Connectivity between fact and dimensions (orphan keys)

Usage Notes:
    - Run after gold views are created and underlying silver data is loaded.
    - Investigate any rows returned by uniqueness or join checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Uniqueness of customer_key
-- Expectation: No results
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.dim_products'
-- ====================================================================
-- Uniqueness of product_key
-- Expectation: No results
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Fact rows missing dimension matches (NULL surrogate keys after join)
SELECT
    f.*
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL
   OR c.customer_key IS NULL;
