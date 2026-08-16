/*
===============================================================================
DDL Script: Create Bronze Layer Tables
Author:         Senior Data Engineer
Description:    Defines the raw ingestion structure for source system data 
                (CRM & ERP). All tables mirror source schemas prior to ETL.
===============================================================================
*/

-- 1. CRM Customer Information Table
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL DROP TABLE bronze.crm_cust_info;
GO
CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,            -- Primary Key (Raw)
    cst_key             NVARCHAR(50),   -- Cleaned Business Key
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO

-- 2. CRM Product Information Table
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL DROP TABLE bronze.crm_prd_info;
GO
CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,            -- Primary Key (Raw)
    prd_key      NVARCHAR(50),   -- Composite Product Key
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);
GO

-- 3. CRM Sales Details Table
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL DROP TABLE bronze.crm_sales_details;
GO
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),   -- Order Number
    sls_prd_key  NVARCHAR(50),   -- Foreign Key to Product
    sls_cust_id  INT,            -- Foreign Key to Customer
    sls_order_dt INT,            -- Raw Date Code (YYYYMMDD)
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
GO

-- 4. ERP Customer Location Table
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL DROP TABLE bronze.erp_loc_a101;
GO
CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),   -- Customer ID (Raw with hyphens)
    cntry  NVARCHAR(50)    -- Country Code / Name
);
GO

-- 5. ERP Customer Demographic Table
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL DROP TABLE bronze.erp_cust_az12;
GO
CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),   -- Customer ID (Raw with NAS prefix)
    bdate  DATE,           -- Birth Date
    gen    NVARCHAR(50)    -- Raw Gender String
);
GO

-- 6. ERP Product Category Table
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL DROP TABLE bronze.erp_px_cat_g1v2;
GO
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),   -- Category ID
    cat          NVARCHAR(50),   -- Category Name
    subcat       NVARCHAR(50),   -- Subcategory Name
    maintenance  NVARCHAR(50)
);
GO