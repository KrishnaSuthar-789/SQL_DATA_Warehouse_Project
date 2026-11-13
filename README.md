# Modern SQL Data Warehouse Development

## Project Overview

This project demonstrates the development of a modern data warehouse using Microsoft SQL Server and T-SQL. It follows the **Medallion Architecture**, organizing data into three layers: Bronze, Silver, and Gold.

The objective was to build a structured data pipeline that takes raw data from multiple CSV files, transforms and cleans it, and prepares it for business analysis and reporting.

## Tools & Technologies Used

- **Microsoft SQL Server**
- **T-SQL**
- **SQL Server Management Studio (SSMS)**
- **ETL Processes**
- **Medallion Architecture**
- **Data Modeling**
- **Star Schema**

## Data Warehouse Architecture

The project uses a three-layer Medallion Architecture:

### 1. Bronze Layer – Raw Data

- Loaded raw data from multiple local CSV files into SQL Server.
- Stored source data with minimal transformation.
- Maintained the raw data as the initial stage of the pipeline.

### 2. Silver Layer – Data Cleaning & Transformation

- Cleaned and standardized the raw data.
- Handled inconsistencies and prepared data for further processing.
- Applied transformations to improve data quality and consistency.

### 3. Gold Layer – Business-Ready Data

- Combined transformed data from the Silver layer.
- Designed fact and dimension tables using a **Star Schema**.
- Created SQL views to provide structured, analysis-ready datasets for reporting and business analysis.

## Key Features

- Three-layer data warehouse architecture.
- Data ingestion from multiple CSV files.
- ETL workflows for data cleaning and transformation.
- Fact and dimension table design.
- Star Schema data modeling.
- SQL views for business-ready data access.

## Skills Demonstrated

- SQL Server and T-SQL
- Data Warehouse Development
- ETL Pipeline Development
- Data Cleaning and Transformation
- Medallion Architecture
- Relational Data Modeling
- Star Schema Design
- SQL Views

## License

This project is licensed under the [MIT License](LICENSE).
