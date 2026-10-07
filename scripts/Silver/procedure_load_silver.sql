/*
**************************************************************
STORE PROCEDURE: LOAD SILVER LAYER (BRONZE LAYER -> SILVER LAYER)
--------------------------------------------------------------
  Script Purpose: 
    The store procedure in this script performs the ETL (Extract, Transform, Load)
    process to polpulate the silver layer tables from bronze layer tables,
    It truncates the table first
    Then loads the file to ensure upto-date data every time

  Store Procedure Contains:
    Custom Messages to make dubugging easier
--------------------------------------------------------------
This Store Procedure takes no Parameters or returns any values.

Usage E.g:
  EXEC silver.load_silver
***************************************************************
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
DECLARE @START_TIME DATETIME,@END_TIME DATETIME,@BATCH_START_TIME DATETIME,@BATCH_END_TIME DATETIME;
	BEGIN TRY
		SET @BATCH_START_TIME = GETDATE()
		PRINT'==========================================';
		PRINT'Loading Silver Layer';
		PRINT'==========================================';
		PRINT'------------------------------------------';
		PRINT'Loading CRM Tables';
		PRINT'------------------------------------------'
		SET @START_TIME = GETDATE(); 
		PRINT'>> Truncating Table silver.crm_cust_info';		
		TRUNCATE TABLE silver.crm_cust_info
		PRINT'>> Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info( -- Inserting cleaned data into silver layer 
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_maritial_status,
			cst_gender,
			cst_create_date
			)
		SELECT cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname, -- Fixing the leading and trailing spaces
			CASE  -- Replacing gender abbreviations with full terms (using unknown as default value)
				WHEN UPPER(TRIM(cst_maritial_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_maritial_status)) = 'S' THEN 'Single'
				ELSE 'unknown'
			END AS cst_maritial_status,
			CASE 
				WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
				ELSE 'unknown'
			END AS cst_gender,
			cst_create_date
		FROM (
			SELECT *,
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date) AS rn 
				FROM bronze.crm_cust_info
			) t
		WHERE rn = 1 AND cst_id IS NOT NULL; -- Removing duplicates
		PRINT '>> Completed';
		SET @END_TIME = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';
		PRINT '-------------------------------------------';
		SET @START_TIME = GETDATE();
		PRINT'>> Truncating Table silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT'>> Inserting Data Into: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
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
			prd_id,
			REPLACE(LEFT(prd_key,5),'-','_') AS cat_id, -- Extract Category ID
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key, -- Extract Product ID
			prd_nm,
			COALESCE(prd_cost,0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'R' THEN 'Road'
				WHEN 'M' THEN 'Mountain'
				WHEN 'S' THEN 'Other Sales'
				When 'T' THEN 'Touring'
				ELSE 'unknown'
			END AS prd_line,
			prd_start_dt,
			DATEADD(
				DAY,-1,LEAD(prd_start_dt) OVER( PARTITION BY prd_key ORDER BY prd_start_dt)
				)  AS  prd_end_dt
		FROM bronze.crm_prd_info;
		PRINT '>> Completed';
		SET @END_TIME = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';
		PRINT '-------------------------------------------';
		SET @START_TIME = GETDATE();
		PRINT'>> Truncating Table silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details; 
		PRINT'>> Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_ord_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price)
		SELECT 
			sls_ord_num,
			sls_ord_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) < 8 THEN NULL 
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) < 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) < 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
			END AS sls_due_dt,
				CASE	
				WHEN sls_sales <= 0 
				OR sls_sales IS NULL
				OR sls_sales != sls_quantity * ABS(sls_price)
				THEN ABS(sls_price) * sls_quantity 
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 
				THEN sls_sales / NULLIF(sls_quantity,0) 
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
		PRINT '>> Completed';
		SET @END_TIME = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';
		PRINT'------------------------------------------';
		PRINT'Loading ERP Tables';
		PRINT'------------------------------------------';
		SET @START_TIME = GETDATE();
		PRINT'>> Truncating Table silver.erp_CUST_AZ12';
		TRUNCATE TABLE silver.erp_CUST_AZ12;
		PRINT'>> Inserting Data Into: silver.erp_CUST_AZ12';
		INSERT INTO silver.erp_CUST_AZ12 (
			CID,
			BDATE,
			GEN
			)
		SELECT 
			CASE 
				WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID)) -- Remove 'NAS' prefix if prsent 
				ELSE CID 
			END AS CID,
			CASE 
				WHEN BDATE > '2010-01-01' THEN NULL -- setting out of boundries dates to null 
				ELSE BDATE
			END AS BDATE,
			CASE -- Normalize the gender and replacing nulls/blanks with unknown 
				WHEN UPPER(TRIM(GEN)) = 'M' THEN 'Male' 
				WHEN UPPER(TRIM(GEN)) = 'F' THEN 'Female' 
				WHEN TRIM(GEN) = '' OR GEN IS NULL THEN 'Unknown'
				ELSE GEN 
			END AS GEN
		FROM bronze.erp_CUST_AZ12;
		PRINT '>> Completed';
		SET @END_TIME = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';
		PRINT '-------------------------------------------';
		SET @START_TIME = GETDATE();
		PRINT'>> Truncating Table silver.erp_LOC_A101';
		TRUNCATE TABLE silver.erp_LOC_A101;
		PRINT'>> Inserting Data Into: silver.erp_LOC_A101';
		INSERT INTO silver.erp_LOC_A101(
			CID,
			CNTRY
			)
		SELECT
			REPLACE(CID,'-','') AS CID, -- Removing extra hypen in the CID column
			CASE -- Standardization the data and filling nulls/blanks with 'Unknown'
				WHEN UPPER(TRIM(CNTRY)) IN ('US','United States','USA') THEN 'United States'
				WHEN UPPER(TRIM(CNTRY)) = 'DE' THEN 'Germany'
				WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'Unknown'
				ELSE CNTRY
			END AS CNTRY
		FROM bronze.erp_LOC_A101;
		PRINT '>> Completed';
		SET @END_TIME = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';
		PRINT '-------------------------------------------';
		SET @START_TIME = GETDATE();
		PRINT'>> Truncating Table silver.erp_PX_CAT_G1V2';
		TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
		PRINT'>> Inserting Data Into: silver.erp_PX_CAT_G1V2';
		INSERT INTO silver.erp_PX_CAT_G1V2 (
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE)
		SELECT 
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
		FROM bronze.erp_PX_CAT_G1V2;
		SET @END_TIME = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@START_TIME,@END_TIME) AS VARCHAR) +' Seconds';
		PRINT '-------------------------------------------';
		PRINT 'All Tables Loaded';
		PRINT '-------------------------------------------'
		PRINT '===========================================';
		PRINT 'Loading Silver Layer Completed';
		SET @BATCH_END_TIME = GETDATE()
		PRINT '>> Total Duration For Silver Layer: ' + 
			CAST(DATEDIFF(SECOND,@BATCH_START_TIME,@BATCH_END_TIME) AS VARCHAR) + ' Seconds';
		PRINT '===========================================';
	END TRY 
	BEGIN CATCH  
		PRINT '>> AN ERROR HAS OCCURED <<';
		PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'ERROR STAGE: ' + CAST(ERROR_STATE() AS VARCHAR)
	END CATCH
END; 
