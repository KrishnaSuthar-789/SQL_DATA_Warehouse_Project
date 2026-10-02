/*
-----------------------------------------
	CREATING SQL DATABASE AND SCHEMAS
-----------------------------------------

Script Purpose: 
	This script checks for the data base named Datawarehouse,
	if exists then it will drop it and then create a new one with the name Datawarehouse,
	Apart from that it will also create three schemas within that database named 
	bronze,silver,gold.

Warning: 
	This script will drop the entire data base, backup all files before running the script. 
*/


USE master;
GO
/* Checking if the database with name Datawarehouse already exist if it does then droping it*/ 

DROP DATABASE IF EXISTS Datawarehouse;

/* Creating the database named Datawarehouse*/

CREATE DATABASE Datawarehouse;

/* Using the database Datawarehouse*/ 

USE Datawarehouse;
GO 

/* Creating the schemas (bronze,silver,gold) in the database*/

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
