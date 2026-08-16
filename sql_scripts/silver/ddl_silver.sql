/*
===============================================================================
DDL Script: Create Silver Layer Tables
Author:         Senior Data Engineer
Description:    Defines cleansed, standardized, and typed tables for the 
                'silver' schema, ready for business logic and modeling.
===============================================================================
*/

-- 1. Silver CRM Customer Information Table
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL DROP TABLE silver.crm_cust_info;
GO
CREATE TABLE silver.crm_cust_info (
    cst_id             INT,                        -- Cleaned Primary Key
    cst_key            NVARCHAR(50),               -- Standard Business Key
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_marital_status NVARCHAR(50),               -- Standardized Domain Value
    cst_gndr           NVARCHAR(50),               -- Standardized Gender
    cst_create_date    DATE,                       -- Standard Creation Date
    dwh_create_date    DATETIME2 DEFAULT GETDATE() -- System Audit Field
);
GO

-- 2. Silver CRM Product Information Table
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL DROP TABLE silver.crm_prd_info;
GO
CREATE TABLE silver.crm_prd_info (
    prd_id          INT,                        -- Cleaned Primary Key
    cat_id          NVARCHAR(50),               -- Extracted Category Key
    prd_key         NVARCHAR(50),               -- Extracted Product Key
    prd_nm          NVARCHAR(50),               -- Product Name
    prd_cost        DECIMAL(10,2),              -- Numeric Cost Value
    prd_line        NVARCHAR(50),               -- Standardized Product Line
    prd_start_dt    DATE,                       -- Effective Start Date
    prd_end_dt      DATE,                       -- Calculated End Date (SCD Type 2)
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- System Audit Field
);
GO

-- 3. Silver CRM Sales Details Table
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL DROP TABLE silver.crm_sales_details;
GO
CREATE TABLE silver.crm_sales_details (
    sls_ord_num     NVARCHAR(50),               -- Cleaned Order Number
    sls_prd_key     NVARCHAR(50),               -- FK to Product
    sls_cust_id     INT,                        -- FK to Customer
    sls_order_dt    DATE,                       -- Converted Order Date
    sls_ship_dt     DATE,                       -- Converted Ship Date
    sls_due_dt      DATE,                       -- Converted Due Date
    sls_sales       DECIMAL(10,2),              -- Calculated Total Sales Amount
    sls_quantity    INT,                        -- Quantity Sold
    sls_price       DECIMAL(10,2),              -- Recalculated Unit Price
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- System Audit Field
);
GO

-- 4. Silver ERP Customer Location Table
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL DROP TABLE silver.erp_loc_a101;
GO
CREATE TABLE silver.erp_loc_a101 (
    cid             NVARCHAR(50),               -- Cleansed FK Customer ID
    cntry           NVARCHAR(50),               -- Standardized Country Name
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- System Audit Field
);
GO

-- 5. Silver ERP Customer Demographic Table
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL DROP TABLE silver.erp_cust_az12;
GO
CREATE TABLE silver.erp_cust_az12 (
    cid             NVARCHAR(50),               -- Cleansed FK Customer ID
    bdate           DATE,                       -- Validated Birth Date
    gen             NVARCHAR(50),               -- Standardized Gender
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- System Audit Field
);
GO

-- 6. Silver ERP Product Category Table
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL DROP TABLE silver.erp_px_cat_g1v2;
GO
CREATE TABLE silver.erp_px_cat_g1v2 (
    id              NVARCHAR(50),               -- Primary Category Key
    cat             NVARCHAR(50),               -- Cleaned Category Name
    subcat          NVARCHAR(50),               -- Cleaned Subcategory Name
    maintenance     NVARCHAR(50),               -- Maintenance Indicator
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- System Audit Field
);
GO