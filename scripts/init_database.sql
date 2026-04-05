-- Create Database if not exists
DROP DATABASE IF EXISTS datawarehouse;
CREATE DATABASE datawarehouse;

-- Use database
USE datawarehouse;

/*
Purpose:
This database is created to build a Data Warehouse for storing and analyzing data.
It supports data processing, transformation, and analytical queries.

Note:
MySQL does not support separate schemas inside a database,
so we use naming conventions:

bronze_* → raw data tables (bronze_customers, bronze_orders)
silver_* → cleaned data tables (silver_customers, silver_orders)
gold_* → final analytics tables (gold_sales, gold_reports)

Warning:
Dropping the database will permanently delete all tables and data.
Use DROP DATABASE carefully.
*/
