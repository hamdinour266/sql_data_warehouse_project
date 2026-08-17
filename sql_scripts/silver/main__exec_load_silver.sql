/*
===============================================================================
Script Name:      main__exec_load_silver.sql
Stored Procedure: silver.load_silver
Description:      Master Orchestrator Procedure to execute all Silver Layer ETLs.
Parameters:       None
Usage:            EXEC silver.load_silver;
===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Starting Silver Layer ETL Batch Load';
        PRINT '================================================';

        -- Execute CRM Transformations
        EXEC silver.load_crm_cust_info;
        EXEC silver.load_crm_prd_info;
        EXEC silver.load_crm_sales_details;

        -- Execute ERP Transformations
        EXEC silver.load_erp_cust_az12;
        EXEC silver.load_erp_loc_a101;
        EXEC silver.load_erp_px_cat_g1v2;

        SET @batch_end_time = GETDATE();
        PRINT '================================================';
        PRINT 'Silver Layer Load Completed Successfully!';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'CRITICAL ERROR: Silver Layer Batch Load Failed!';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '================================================';
        THROW;
    END CATCH
END;
GO