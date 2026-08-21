/*
===============================================================================
Quality Checks: Gold Layer Data Validation
===============================================================================
Script Purpose:
    Validates data integrity, primary/surrogate key uniqueness, and referential 
    integrity across Gold layer fact and dimension views.
===============================================================================
*/

-- ----------------------------------------------------------------------------
-- 1. Uniqueness Checks (Primary / Surrogate Keys)
-- Expectation: 0 rows returned
-- ----------------------------------------------------------------------------
SELECT customer_key, COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT product_key, COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------
-- 2. Foreign Key Referential Integrity Checks
-- Expectation: 0 rows returned (Every sale transaction must link to dimensions)
-- ----------------------------------------------------------------------------
-- Check for sales missing valid product key
SELECT order_number, product_key
FROM gold.fact_sales
WHERE product_key IS NULL;

-- Check for sales missing valid customer key
SELECT order_number, customer_key
FROM gold.fact_sales
WHERE customer_key IS NULL;

-- ----------------------------------------------------------------------------
-- 3. Business Logic Validation
-- Expectation: 0 rows returned (No negative or zero monetary/quantity values)
-- ----------------------------------------------------------------------------
SELECT * 
FROM gold.fact_sales 
WHERE sales_amount <= 0 OR quantity <= 0 OR price <= 0;