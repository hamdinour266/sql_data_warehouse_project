/*
===============================================================================
DDL Script: Create Product Dimension View
===============================================================================
Script Purpose:
    Creates the 'gold.dim_products' view containing product catalog information
    and current active versions.
===============================================================================
*/

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate Key
    pn.prd_id                                                AS product_id,  -- Natural Key
    pn.prd_key                                               AS product_number,
    pn.prd_nm                                                AS product_name,
    pn.cat_id                                                AS category_id,
    pc.cat                                                   AS category,
    pc.subcat                                                AS subcategory,
    pc.maintenance                                           AS maintenance,
    pn.prd_cost                                              AS cost,
    pn.prd_line                                              AS product_line,
    pn.prd_start_dt                                          AS start_date
FROM silver.crm_prd_info pn 
LEFT JOIN silver.erp_px_cat_g1v2 pc 
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- Select current active product records only
GO