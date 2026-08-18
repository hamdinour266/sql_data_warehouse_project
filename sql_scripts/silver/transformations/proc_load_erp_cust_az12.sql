/*
===============================================================================
Stored Procedure: silver.load_erp_cust_az12
Description:      Cleans, standardizes, and validates customer demographic data 
                  from bronze.erp_cust_az12 into silver.erp_cust_az12.
Parameters:       None
Usage:            EXEC silver.load_erp_cust_az12;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_erp_cust_az12 AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @start_time DATETIME, @end_time DATETIME, @rows_inserted INT;

    BEGIN TRY
        SET @start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer: silver.erp_cust_az12';
        PRINT '================================================';

        -- Step 1: Truncate Target Table
        PRINT '>> Truncating Target Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        -- Step 2: Transform & Insert Data
        PRINT '>> Inserting Transformed Data into: silver.erp_cust_az12';
        
        BEGIN TRANSACTION;

        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT 
            -- Customer ID Cleaning: Strip leading 'NAS' prefix if present, otherwise trim whitespace
            CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE TRIM(cid) 
            END AS cid,
            
            -- Birth Date Validation: NULLify impossible future dates or dates older than 1924-01-01
            CASE 
                WHEN bdate > GETDATE() OR bdate < '1924-01-01' THEN NULL 
                ELSE CAST(bdate AS DATE) 
            END AS bdate,
            
            -- Gender Standardization: Map variations ('M', 'Male', 'F', 'Female') to standard terms
            CASE UPPER(TRIM(gen))
                WHEN 'M'      THEN 'Male'
                WHEN 'MALE'   THEN 'Male'
                WHEN 'F'      THEN 'Female'
                WHEN 'FEMALE' THEN 'Female'
                ELSE 'n/a'
            END AS gen
        FROM bronze.erp_cust_az12;

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
        PRINT '>> ERROR OCCURRED LOADING silver.erp_cust_az12';
        PRINT '>> Error Message: ' + ERROR_MESSAGE();
        
        -- Re-throw error so orchestration pipelines catch the failure
        THROW;
    END CATCH
END;
GO