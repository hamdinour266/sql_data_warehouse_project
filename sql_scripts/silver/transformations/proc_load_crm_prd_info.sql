/*
===============================================================================
Stored Procedure: silver.load_crm_prd_info
Description:      Cleans, standardizes, derives category keys, and calculates
                  SCD Type 2 effective end dates for product data from 
                  bronze.crm_prd_info into silver.crm_prd_info.
Parameters:       None
Usage:            EXEC silver.load_crm_prd_info;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_crm_prd_info AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @start_time DATETIME, @end_time DATETIME, @rows_inserted INT;

    BEGIN TRY
        SET @start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer: silver.crm_prd_info';
        PRINT '================================================';

        -- Step 1: Truncate Target Table
        PRINT '>> Truncating Target Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        -- Step 2: Transform & Insert Data
        PRINT '>> Inserting Transformed Data into: silver.crm_prd_info';
        
        BEGIN TRANSACTION;

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,   
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT 
            -- Primary Key
            prd_id,
            
            -- Extract and format Category ID prefix (e.g., replace '-' with '_')
            REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') AS cat_id,
            
            -- Extract actual Product Key (removing Category prefix)
            SUBSTRING(TRIM(prd_key), 7, LEN(TRIM(prd_key))) AS prd_key,
            
            -- String Cleaning: Remove leading/trailing whitespaces
            TRIM(prd_nm) AS prd_nm,
            
            -- Handle NULL costs with default value
            ISNULL(prd_cost, 0) AS prd_cost,
            
            -- Data Standardization: Map Product Line codes to readable descriptions
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            
            -- Standardize Start Date format
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            
            -- Calculate End Date using LEAD() to set effective end date 
            -- (1 day prior to next start date for the same product key)
            CAST(
                DATEADD(
                    day, 
                    -1, 
                    LEAD(prd_start_dt) OVER (
                        PARTITION BY SUBSTRING(TRIM(prd_key), 7, LEN(TRIM(prd_key))) 
                        ORDER BY prd_start_dt
                    )
                ) AS DATE
            ) AS prd_end_dt
        FROM bronze.crm_prd_info;

        SET @rows_inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;

        SET @end_time = GETDATE();
        PRINT '>> Success! Rows inserted: ' + CAST(@rows_inserted AS VARCHAR);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        -- Rollback active transaction on failure to ensure atomicity
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Log error details
        PRINT '>> ERROR OCCURRED LOADING silver.crm_prd_info';
        PRINT '>> Error Message: ' + ERROR_MESSAGE();
        
        -- Re-throw error so orchestration pipelines (Airflow, ADF) catch the failure
        THROW;
    END CATCH
END;
GO