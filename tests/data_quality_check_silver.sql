/*
**************************************************************

--------------------------------------------------------------
  Script Purpose: 
    This scrip is used to perfrom analysis on the RAW data 
    without making any changes in the data to check the
    data quality and consistency.
--------------------------------------------------------------

***************************************************************
*/

/* 
	- Quality Analysis of the raw data 
	- Table Name: crm_cust_info 	
*/

--Checking for duplicates in customer id
SELECT * FROM (
	SELECT * , ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) rn
	FROM bronze.crm_cust_info
	) t
WHERE rn > 1;

-- Checking in duplicates in customer key
SELECT *
FROM (
	SELECT * ,ROW_NUMBER() OVER(PARTITION BY cst_key ORDER BY cst_create_date DESC) rn
	FROM bronze.crm_cust_info
	) t
WHERE rn > 1;

-- checking for leading and trailing spaces 
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_maritial_status
FROM bronze.crm_cust_info
WHERE cst_maritial_status != TRIM(cst_maritial_status);

SELECT cst_gender
FROM bronze.crm_cust_info
WHERE cst_gender != TRIM(cst_gender);

/* 
	- Quality Analysis of the raw data 
	- Table Name: crm_prd_info 	
*/

SELECT *
FROM bronze.crm_prd_info;

SELECT prd_id,COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


SELECT prd_key,COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_key
HAVING COUNT(*) > 1 OR prd_key IS NULL;

SELECT *
FROM bronze.crm_prd_info
WHERE prd_key = 'AC-HE-HL-U509'

SELECT *
FROM bronze.crm_prd_info
WHERE prd_line <> TRIM(prd_line)

/*
	- Quality Analysis of the raw data 
	- Table Name: sls_ord_num 
*/

-- Checking for Nulls in sls_ord_num, sls_ord_key and sls_cust_id 

SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL;

SELECT sls_ord_key
FROM bronze.crm_sales_details
WHERE sls_ord_key IS NULL;


SELECT sls_cust_id
FROM bronze.crm_sales_details
WHERE sls_cust_id IS NULL;

-- Checking for incorrect date (According to Int Format)

SELECT DISTINCT
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR  sls_ship_dt <= 0 OR sls_due_dt <= 0
	OR LEN(sls_order_dt) < 8 OR  LEN(sls_ship_dt) < 8 OR LEN(sls_due_dt) < 8;

-- Checking for dates whose order date is more than shipping date

SELECT 
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
	OR sls_ship_dt > sls_due_dt; -- Only if there are no order dues  

-- Checking for incorrect sales, price and quantity

SELECT 
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales != ABS(sls_price) * sls_quantity;

/*
	- Quality Analysis of the raw data 
	- Table Name: erp_CUST_AZ12 
*/

-- Checking for out of range Bith dates
SELECT BDATE
FROM bronze.erp_CUST_AZ12
WHERE BDATE < '1900-01-01' OR BDATE > '2010-01-01';

-- Checking Data for joining 

SELECT CID 
FROM bronze.erp_CUST_AZ12 
WHERE CID NOT IN (
	SELECT cst_key 
	FROM silver.crm_cust_info
	); -- Some Id has 'NAS' as prefix which need to be removed 

-- Normalizing the data 
SELECT DISTINCT Gen
FROM bronze.erp_CUST_AZ12;


/*
	- Quality Analysis of the raw data 
	- Table Name: erp_LOC_A101 
*/

-- Over view of erp_loc table 

SELECT 
	CID,
	CNTRY
FROM bronze.erp_LOC_A101;

-- checking for any differnt customer keys/id

SELECT DISTINCT LEN(CID)
FROM bronze.erp_LOC_A101; -- joining key length in cust info is 10, here it's 11 which is incorrect

-- check data for joining, Output should be blank

SELECT * 
FROM bronze.erp_LOC_A101
WHERE CID NOT IN (
	SELECT cst_key
	FROM silver.crm_cust_info) -- there is one extra hyphen in the key 

/*
	- Quality Analysis of the raw data 
	- Table Name: erp_PX_CAT_G1V2 
*/

-- check data for joining, Output should be blank  
SELECT ID 
FROM bronze.erp_PX_CAT_G1V2 
WHERE ID NOT IN (
	SELECT cat_id
	FROM silver.crm_prd_info
	);
-- Checking data consistency 

SELECT DISTINCT CAT 
FROM bronze.erp_PX_CAT_G1V2;

SELECT DISTINCT SUBCAT 
FROM bronze.erp_PX_CAT_G1V2;

SELECT DISTINCT
	MAINTENANCE
FROM bronze.erp_PX_CAT_G1V2;

-- Checking for unwanted spaces 

SELECT * 
FROM bronze.erp_PX_CAT_G1V2 
WHERE TRIM(CAT) <> CAT 
	OR TRIM(SUBCAT) <> SUBCAT 
	OR TRIM(MAINTENANCE) <> MAINTENANCE;
