/*
**************************************************************
STORE PROCEDURE: LOAD BRONZE LAYER (SOURCE -> BRONZE LAYER)
--------------------------------------------------------------
  Script Purpose: 
    The store procedure in this script will load the data 
    into bronze layer from csv file,
    It truncates the table first
    Then loads the file to ensure upto-date data every time

  Store Procedure Contains:
    Custom Messages to make dubugging easier
--------------------------------------------------------------
This Store Procedure takes no Parameters or returns any values.

Usage E.g:
  EXEC bronze.load_bronze
***************************************************************
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @START_TIME DATETIME, @END_TIME DATETIME,@BATCH_START_TIME DATETIME,@BATCH_END_TIME DATETIME;
	BEGIN TRY
		SET @BATCH_START_TIME = GETDATE();
		PRINT'==========================================';
		PRINT'Loading Bronze Layer';
		PRINT'==========================================';
		PRINT'------------------------------------------';
		PRINT'Loading CRM Tables';
		PRINT'------------------------------------------';
		PRINT'>>Truncating Table bronze.crm_cust_info';
		
		

		SET @START_TIME = GETDATE(); 
		TRUNCATE TABLE bronze.crm_cust_info;

	/* Bulk inserting the data from the csv file directly */ 
		PRINT'>>Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info 
		FROM 'C:\Sql projects\Warehouse dataset\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		PRINT '>> Completed';
		SET @END_TIME = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';
		PRINT '-------------------------------------------';
		SET @START_TIME = GETDATE();
		PRINT'>>Truncating Table bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT'>>Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Sql projects\Warehouse dataset\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		PRINT '>>Completed';
		SET @END_TIME = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';
		PRINT '-------------------------------------------';
		SET @START_TIME = GETDATE();
		PRINT'>>Truncating Table bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details; 
		PRINT'>>Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details 
		FROM 'C:\Sql projects\Warehouse dataset\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		PRINT '>>Completed';
		SET @END_TIME = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';
		PRINT'------------------------------------------';
		PRINT'Loading ERP Tables';
		PRINT'------------------------------------------';

		SET @START_TIME = GETDATE();
		PRINT'>>Truncating Table bronze.erp_CUST_AZ12';
		TRUNCATE TABLE bronze.erp_CUST_AZ12;
	
		PRINT'>>Inserting Data Into: bronze.erp_CUST_AZ12';
		BULK INSERT bronze.erp_CUST_AZ12
		FROM 'C:\Sql projects\Warehouse dataset\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		PRINT '>>Completed';
		SET @END_TIME = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';
		PRINT '-------------------------------------------';
		SET @START_TIME = GETDATE();
		PRINT'>>Truncating Table bronze.erp_LOC_A101';
		TRUNCATE TABLE bronze.erp_LOC_A101;

		PRINT'>>Inserting Data Into: bronze.erp_LOC_A101';
		BULK INSERT bronze.erp_LOC_A101
		FROM 'C:\Sql projects\Warehouse dataset\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		PRINT '>>Completed';
		SET @END_TIME = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';
		PRINT '-------------------------------------------';
		SET @START_TIME = GETDATE();
		PRINT'>>Truncating Table bronze.erp_PX_CAT_G1V2';
		TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;

		PRINT'>>Inserting Data Into: bronze.erp_PX_CAT_G1V2';
		BULK INSERT bronze.erp_PX_CAT_G1V2
		FROM 'C:\Sql projects\Warehouse dataset\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @END_TIME = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';

		PRINT '-------------------------------------------';
		PRINT 'All Tables Loaded';
		PRINT '-------------------------------------------'
		PRINT '===========================================';
		PRINT 'Loading Bronze Layer Completed';
		SET @BATCH_END_TIME = GETDATE()
		PRINT '	-Total Duration For All Bronze Layer: ' + 
			CAST(DATEDIFF(SECOND,@BATCH_START_TIME,@BATCH_END_TIME) AS VARCHAR) + ' Seconds';
		PRINT '===========================================';
	END TRY
	BEGIN CATCH
		PRINT '>>AN ERROR HAS OCCURED';
		PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'ERROR STAGE: ' + CAST(ERROR_STATE() AS VARCHAR)
	END CATCH
END;
