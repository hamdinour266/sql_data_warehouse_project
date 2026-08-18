/*
===============================================================================
Stored Procedure: silver.load_erp_loc_a101
Description:      Cleans, standardizes, and maps customer location/country 
                  data from bronze.erp_loc_a101 into silver.erp_loc_a101.
Parameters:       None
Usage:            EXEC silver.load_erp_loc_a101;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_erp_loc_a101 AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @start_time DATETIME, @end_time DATETIME, @rows_inserted INT;

    BEGIN TRY
        SET @start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer: silver.erp_loc_a101';
        PRINT '================================================';

        -- Step 1: Truncate Target Table
        PRINT '>> Truncating Target Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        -- Step 2: Transform & Insert Data
        PRINT '>> Inserting Transformed Data into: silver.erp_loc_a101';
        
        BEGIN TRANSACTION;

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT 
            -- Customer ID Cleaning: Remove hyphens and whitespace to standardize primary/foreign key format
            REPLACE(TRIM(cid), '-', '') AS cid,
            
            -- Country Standardization: Map codes (US, USA, DE) to full country names and handle NULL/empty strings
            CASE UPPER(TRIM(cntry))
                WHEN 'US'  THEN 'United States'
                WHEN 'USA' THEN 'United States'
                WHEN 'DE'  THEN 'Germany'
                WHEN 'DEU' THEN 'Germany'
                WHEN ''    THEN 'n/a'
                ELSE ISNULL(TRIM(cntry), 'n/a')
            END AS cntry
        FROM bronze.erp_loc_a101;

        SET @rows_inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;

        SET @end_time = GETDATE();
        PRINT '>> Success! Rows inserted: ' + CAST(@rows_inserted AS VARCHAR);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        -- Rollback active transaction on failure to preserve data integrity
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Log error details
        PRINT '>> ERROR OCCURRED LOADING silver.erp_loc_a101';
        PRINT '>> Error Message: ' + ERROR_MESSAGE();
        
        -- Re-throw error so orchestration pipelines (Airflow, ADF) capture the failure
        THROW;
    END CATCH
END;
GO