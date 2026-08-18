/*
===============================================================================
Stored Procedure: silver.load_crm_cust_info
Description:      Cleans, standardizes, and deduplicates customer data from 
                  bronze.crm_cust_info into silver.crm_cust_info.
Parameters:       None
Usage:            EXEC silver.load_crm_cust_info;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_crm_cust_info AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @start_time DATETIME, @end_time DATETIME, @rows_inserted INT;

    BEGIN TRY
        SET @start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer: silver.crm_cust_info';
        PRINT '================================================';

        -- Step 1: Truncate Target Table
        PRINT '>> Truncating Target Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        -- Step 2: Transform & Insert Data
        PRINT '>> Inserting Transformed Data into: silver.crm_cust_info';
        
        BEGIN TRANSACTION;

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT 
            -- Cast Primary Key to Integer format
            CAST(cst_id AS INT) AS cst_id,
            
            -- String Cleaning: Remove leading and trailing whitespaces
            TRIM(cst_key) AS cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            
            -- Data Standardization: Map Marital Status codes to readable values
            CASE UPPER(TRIM(cst_marital_status))
                WHEN 'M' THEN 'Married'
                WHEN 'S' THEN 'Single'
                ELSE 'n/a'
            END AS cst_marital_status,
            
            -- Data Standardization: Map Gender codes to readable values
            CASE UPPER(TRIM(cst_gndr))
                WHEN 'M' THEN 'Male'
                WHEN 'F' THEN 'Female'
                ELSE 'n/a'
            END AS cst_gndr,
            
            -- Cast Creation Date to standard DATE data type
            CAST(cst_create_date AS DATE) AS cst_create_date
        FROM (
            -- Subquery: Deduplicate records based on Primary Key (cst_id)
            -- Keep the most recent record based on cst_create_date
            SELECT 
                *, 
                ROW_NUMBER() OVER (
                    PARTITION BY cst_id 
                    ORDER BY cst_create_date DESC
                ) AS rn
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE rn = 1;

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
        PRINT '>> ERROR OCCURRED LOADING silver.crm_cust_info';
        PRINT '>> Error Message: ' + ERROR_MESSAGE();
        
        -- Re-throw error so orchestration pipelines catch the failure
        THROW;
    END CATCH
END;
GO