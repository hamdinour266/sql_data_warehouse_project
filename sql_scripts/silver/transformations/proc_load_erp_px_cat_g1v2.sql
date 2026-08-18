/*
===============================================================================
Stored Procedure: silver.load_erp_px_cat_g1v2
Description:      Cleans and standardizes product category and subcategory 
                  hierarchy data from bronze.erp_px_cat_g1v2 into silver.erp_px_cat_g1v2.
Parameters:       None
Usage:            EXEC silver.load_erp_px_cat_g1v2;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_erp_px_cat_g1v2 AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @start_time DATETIME, @end_time DATETIME, @rows_inserted INT;

    BEGIN TRY
        SET @start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer: silver.erp_px_cat_g1v2';
        PRINT '================================================';

        -- Step 1: Truncate Target Table
        PRINT '>> Truncating Target Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        -- Step 2: Transform & Insert Data
        PRINT '>> Inserting Transformed Data into: silver.erp_px_cat_g1v2';
        
        BEGIN TRANSACTION;

        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT 
            -- String Cleaning: Remove leading and trailing whitespaces from ID
            TRIM(id) AS id,
            
            -- String Cleaning: Standardize Category name
            TRIM(cat) AS cat,
            
            -- String Cleaning: Standardize Subcategory name
            TRIM(subcat) AS subcat,
            
            -- String Cleaning: Standardize Maintenance flag
            TRIM(maintenance) AS maintenance
        FROM bronze.erp_px_cat_g1v2;

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
        PRINT '>> ERROR OCCURRED LOADING silver.erp_px_cat_g1v2';
        PRINT '>> Error Message: ' + ERROR_MESSAGE();
        
        -- Re-throw error so orchestration pipelines (Airflow, ADF) capture the failure
        THROW;
    END CATCH
END;
GO