# SQL_DATA_Warehouse_Project
Building a modern data warehouse using SQL Server, Including ETL processing, Data Modeling and Analytics.
This project follows the Medallion architecture to convert the RAW data into a useful dataset which can be
used to built various reports and analystics.

# Data Architecture
'--Layers--'
**1.Bronze Layer:** Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
**2.Silver Layer:** This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
**3.Gold Layer:** Houses business-ready data modeled into a star schema required for reporting and analytics.

