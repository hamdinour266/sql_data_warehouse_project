/*
===============================================================================
Stored Procedure: silver.load_crm_sales_details
Description:      Cleans, standardizes, calculates missing values, and loads 
                  sales transactions from bronze.crm_sales_details into silver.crm_sales_details.
Parameters:       None
Usage:            EXEC silver.load_crm_sales_details;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_crm_sales_details AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @start_time DATETIME, @end_time DATETIME, @rows_inserted INT;

    BEGIN TRY
        SET @start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer: silver.crm_sales_details';
        PRINT '================================================';

        -- Step 1: Truncate Target Table
        PRINT '>> Truncating Target Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        -- Step 2: Transform & Insert Data
        PRINT '>> Inserting Transformed Data into: silver.crm_sales_details';
        
        BEGIN TRANSACTION;

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            -- Primary Key Cleaning
            TRIM(sls_ord_num) AS sls_ord_num,
            TRIM(sls_prd_key) AS sls_prd_key,
            sls_cust_id,

            -- Date Validation & Conversion (YYYYMMDD to DATE)
            CASE 
                WHEN sls_order_dt = 0 OR LEN(CAST(sls_order_dt AS VARCHAR)) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,

            CASE 
                WHEN sls_ship_dt = 0 OR LEN(CAST(sls_ship_dt AS VARCHAR)) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,

            CASE 
                WHEN sls_due_dt = 0 OR LEN(CAST(sls_due_dt AS VARCHAR)) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,

            -- Recalculate Sales if missing, zero, or inconsistent with Quantity * Price
            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                     THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,

            sls_quantity,

            -- Recalculate Price if missing or negative
            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0 
                     THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price
        FROM bronze.crm_sales_details;

        SET @rows_inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;

        SET @end_time = GETDATE();
        PRINT '>> Success! Rows inserted: ' + CAST(@rows_inserted AS VARCHAR);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        -- Rollback active transaction on failure
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Log error details
        PRINT '>> ERROR OCCURRED LOADING silver.crm_sales_details';
        PRINT '>> Error Message: ' + ERROR_MESSAGE();
        
        -- Re-throw error so orchestration pipelines catch the failure
        THROW;
    END CATCH
END;
GO