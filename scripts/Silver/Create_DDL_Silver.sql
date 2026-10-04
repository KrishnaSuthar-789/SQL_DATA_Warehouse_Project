/*
**********************************************
---------------------------------------------
DDL SILVER SCRIPT
---------------------------------------------
SCRIPT PURPOSE -
	This script will create tables in the silver layer,
	it will drop the table if alredy exist,
	adding a MetaData column 'DWH_create_date'		
***********************************************
*/

USE Datawarehouse;
GO
IF OBJECT_ID('silver.crm_cust_info','U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info(
	 cst_id int,
	 cst_key varchar(20),
	 cst_firstname varchar(20),
	 cst_lastname varchar(20),
	 cst_maritial_status varchar(20),
	 cst_gender varchar(20),
	 cst_create_date date,
	 dwh_create_Date date default getdate()
);

IF OBJECT_ID('silver.crm_prd_info','U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info(
	prd_id int,
	prd_key varchar(20),
	prd_nm varchar(34),
	prd_cost DECIMAL(10,2),
	prd_line varchar(20),
	prd_start_dt date,
	prd_end_dt date,
	 dwh_create_Date date default getdate()
);

IF OBJECT_ID('silver.crm_sales_details','U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
	sls_ord_num varchar(20),
	sls_ord_key varchar(20),
	sls_cust_id varchar(20),
	sls_order_dt int,
	sls_ship_dt int,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int,
	sls_price decimal(10,2),
	dwh_create_Date date default getdate()
);

IF OBJECT_ID('silver.erp_CUST_AZ12','U') IS NOT NULL
	DROP TABLE silver.erp_CUST_AZ12;
CREATE TABLE silver.erp_CUST_AZ12(
	CID varchar(20),
	BDATE date,
	GEN varchar(20),
	dwh_create_Date date default getdate()
);

IF OBJECT_ID('silver.erp_LOC_A101','U') IS NOT NULL
	DROP TABLE silver.erp_LOC_A101;
CREATE TABLE silver.erp_LOC_A101(
	CID varchar(20),
	CNTRY VARCHAR(20),
	dwh_create_Date date default getdate()
);

IF OBJECT_ID('silver.erp_PX_CAT_G1V2','U') IS NOT NULL
	DROP TABLE silver.erp_PX_CAT_G1V2;
CREATE TABLE silver.erp_PX_CAT_G1V2(
	ID varchar(10),
	CAT varchar(14),
	SUBCAT varchar(20),
	MAINTENANCE varchar(20),
	dwh_create_Date date default getdate()
);
