/*
===============================================================================
DDL Script: Create Sales Fact Table View
===============================================================================
Script Purpose:
    Creates the 'gold.fact_sales' view linking transaction details to 
    Customer and Product dimension keys (Star Schema).
===============================================================================
*/

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,  -- Foreign Key to gold.dim_products
    cu.customer_key AS customer_key, -- Foreign Key to gold.dim_customers
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr 
    ON sd.sls_prd_key = pr.product_number -- Join on Natural Key to resolve Surrogate Key
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;   -- Join on Natural Key to resolve Surrogate Key
GO