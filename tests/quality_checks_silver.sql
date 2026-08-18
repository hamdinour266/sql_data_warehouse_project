/*
===============================================================================
Quality Checks Script: Silver Layer (CRM & ERP)
Author:         Senior Data Engineer
Purpose:        Comprehensive Data Quality (DQ), Referential Integrity, 
                and Business Logic Validation across Silver Layer Tables.
Execution Strategy: Run post-ETL pipeline. ALL queries MUST return 0 rows.
===============================================================================
*/

-- ====================================================================
-- 1. Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check PK Integrity (Uniqueness & Non-Null)
SELECT cst_id, COUNT(*) AS dup_count 
FROM silver.crm_cust_info 
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check Whitespaces and Empty Key Strings
SELECT cst_key 
FROM silver.crm_cust_info 
WHERE cst_key != TRIM(cst_key) OR cst_key IS NULL OR cst_key = '';

-- Check Domain Value Standardization
SELECT DISTINCT cst_marital_status 
FROM silver.crm_cust_info 
WHERE cst_marital_status NOT IN ('Married', 'Single', 'n/a');

SELECT DISTINCT cst_gndr 
FROM silver.crm_cust_info 
WHERE cst_gndr NOT IN ('Male', 'Female', 'n/a');


-- ====================================================================
-- 2. Checking 'silver.crm_prd_info'
-- ====================================================================
-- Check Primary Key Integrity
SELECT prd_id, COUNT(*) AS dup_count 
FROM silver.crm_prd_info 
GROUP BY prd_id 
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check Product Name Formatting & Nulls
SELECT prd_id, prd_nm 
FROM silver.crm_prd_info 
WHERE prd_nm != TRIM(prd_nm) OR prd_nm IS NULL OR prd_nm = '';

-- Check Cost Integrity (Must be non-null and non-negative)
SELECT prd_id, prd_cost 
FROM silver.crm_prd_info 
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Check Product Line Standard Domain Values
SELECT DISTINCT prd_line 
FROM silver.crm_prd_info 
WHERE prd_line NOT IN ('Mountain', 'Road', 'Other Sales', 'Touring', 'n/a');

-- Check Date Logic Consistency (Start Date <= End Date)
SELECT prd_id, prd_start_dt, prd_end_dt 
FROM silver.crm_prd_info 
WHERE prd_end_dt < prd_start_dt;


-- ====================================================================
-- 3. Checking 'silver.crm_sales_details'
-- ====================================================================
-- Check Order Number Formatting & Nulls
SELECT sls_ord_num 
FROM silver.crm_sales_details 
WHERE sls_ord_num IS NULL OR sls_ord_num != TRIM(sls_ord_num) OR sls_ord_num = '';

-- Check Foreign Key Mandatory Nulls
SELECT sls_ord_num, sls_prd_key, sls_cust_id
FROM silver.crm_sales_details 
WHERE sls_prd_key IS NULL OR sls_prd_key = ''
   OR sls_cust_id IS NULL OR sls_cust_id = 0;

-- Referential Integrity: Product Key exists in Product Dimension
SELECT DISTINCT s.sls_prd_key 
FROM silver.crm_sales_details s
WHERE NOT EXISTS (
    SELECT 1 FROM silver.crm_prd_info p WHERE p.prd_key = s.sls_prd_key
);

-- Referential Integrity: Customer ID exists in Customer Dimension
SELECT DISTINCT s.sls_cust_id 
FROM silver.crm_sales_details s
WHERE NOT EXISTS (
    SELECT 1 FROM silver.crm_cust_info c WHERE c.cst_id = s.sls_cust_id
);

-- Check Mandatory Dates & Logical Date Sequence
SELECT sls_ord_num, sls_order_dt, sls_ship_dt, sls_due_dt 
FROM silver.crm_sales_details 
WHERE sls_order_dt IS NULL 
   OR sls_ship_dt IS NULL 
   OR sls_due_dt IS NULL
   OR sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check Financial Math Integrity (Sales = Quantity * Price)
SELECT sls_ord_num, sls_sales, sls_quantity, sls_price 
FROM silver.crm_sales_details 
WHERE sls_sales != sls_quantity * ABS(sls_price)
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;


-- ====================================================================
-- 4. Checking 'silver.erp_cust_az12'
-- ====================================================================
-- Check Cleaned Customer ID Duplicates & Trimming
SELECT cid, COUNT(*) AS dup_count 
FROM silver.erp_cust_az12 
GROUP BY cid 
HAVING COUNT(*) > 1 OR cid != TRIM(cid) OR cid IS NULL OR cid = '';

-- Referential Integrity: ERP Customer ID exists in CRM Customer Dimension
SELECT DISTINCT e.cid 
FROM silver.erp_cust_az12 e
WHERE NOT EXISTS (
    SELECT 1 FROM silver.crm_cust_info c WHERE c.cst_key = e.cid
);

-- Check Birth Date Out-of-Boundaries
SELECT DISTINCT bdate 
FROM silver.erp_cust_az12 
WHERE bdate > GETDATE() OR bdate < '1924-01-01';

-- Check Gender Standardization
SELECT DISTINCT gen 
FROM silver.erp_cust_az12 
WHERE gen NOT IN ('Male', 'Female', 'n/a');


-- ====================================================================
-- 5. Checking 'silver.erp_loc_a101'
-- ====================================================================
-- Check Key Duplicates & Formatting
SELECT cid, COUNT(*) AS dup_count 
FROM silver.erp_loc_a101 
GROUP BY cid 
HAVING COUNT(*) > 1 OR cid != TRIM(cid) OR cid IS NULL OR cid = '';

-- Referential Integrity: ERP Location CID exists in CRM Customer Dimension
SELECT DISTINCT l.cid 
FROM silver.erp_loc_a101 l
WHERE NOT EXISTS (
    SELECT 1 FROM silver.crm_cust_info c WHERE c.cst_key = l.cid
);

-- Check Country Field Consistency & Whitespaces
SELECT DISTINCT cntry 
FROM silver.erp_loc_a101 
WHERE cntry != TRIM(cntry) OR cntry IS NULL OR cntry = '';


-- ====================================================================
-- 6. Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Check Category ID Integrity & Duplicates
SELECT id, COUNT(*) AS dup_count 
FROM silver.erp_px_cat_g1v2 
GROUP BY id 
HAVING COUNT(*) > 1 OR id IS NULL OR id != TRIM(id) OR id = '';

-- Referential Integrity: Category ID exists in Product Dimension
SELECT DISTINCT x.id 
FROM silver.erp_px_cat_g1v2 x
WHERE NOT EXISTS (
    SELECT 1 FROM silver.crm_prd_info p WHERE p.cat_id = x.id
);

-- Check Unwanted Whitespaces in Text Columns
SELECT id, cat, subcat, maintenance 
FROM silver.erp_px_cat_g1v2 
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);