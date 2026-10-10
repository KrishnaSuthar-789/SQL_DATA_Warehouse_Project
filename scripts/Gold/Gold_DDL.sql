/*
**********************************************************************************
----------------------------------------------------------------------------------
DDL GOLD SCRIPT
---------------------------------------------
SCRIPT PURPOSE:
	This script will create views in the gold layer,
	The Gold Layer represents the final facts and dimensions tables (Star Schema).

	Each view performs transfromation and combines data from silver layer to 
  produce clean business ready data. 

USAGE:
  Views can be directly queried
**********************************************************************************
*/

-- Creating customers dimension table: gold.dim_customers 

CREATE OR ALTER VIEW gold.dim_customers AS 
SELECT
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_num,
	ci.cst_firstname AS firstname,
	ci.cst_lastname AS lastname,
	ca.BDATE AS birthdate,
	lo.CNTRY AS country,
	ci.cst_maritial_status AS maritial_status,
	CASE 
		WHEN UPPER(ci.cst_gender) <> 'UNKNOWN' THEN ci.cst_gender -- CRM is master for gender info
		ElSE COALESCE(ca.GEN,'Unknown')
	END AS gender,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci -- master customer table 
LEFT JOIN silver.erp_CUST_AZ12 ca -- joining to access birth dates of customers 
ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_LOC_A101 lo -- joining to access location of customers
ON ci.cst_key = lo.CID

-- Creating products dimension table: gold.dim_products
  
CREATE OR ALTER VIEW gold.dim_products AS 
SELECT 
	ROW_NUMBER() OVER( ORDER BY prd_start_dt,prd_id) AS product_key, -- creating a surrogate key
	p.prd_id AS product_id,
	p.prd_key AS product_number,
	p.cat_id AS category_id,
	p.prd_nm AS product_name,
	c.SUBCAT AS sub_category,
	c.cat AS category,
	c.MAINTENANCE AS maintenance,
	p.prd_cost AS cost,
	p.prd_line product_line,
	p.prd_start_dt AS start_date
FROM silver.crm_prd_info p
LEFT JOIN silver.erp_PX_CAT_G1V2 c -- joining with category table 
ON p.cat_id = c.ID
WHERE prd_end_dt IS NULL; -- Filter out all historical data

-- Creating sales fact table: gold.fact_sales 


CREATE OR ALTER VIEW gold.fact_sales AS 
SELECT 
	s.sls_ord_num AS order_number,
	p.product_key,
	c.customer_key,
	s.sls_order_dt AS order_date,
	s.sls_ship_dt AS shipping_date ,
	s.sls_due_dt AS due_date,
	s.sls_sales AS sales,
	s.sls_quantity AS quantity,
	s.sls_price AS price
FROM silver.crm_sales_details s
LEFT JOIN gold.dim_products p -- joining with dimensions views 
ON s.sls_ord_key = p.product_number
LEFT JOIN gold.dim_customers c -- joining with dimensions views
ON s.sls_cust_id = c.customer_id; 

