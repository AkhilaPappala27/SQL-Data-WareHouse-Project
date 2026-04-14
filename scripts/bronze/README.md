# 📊 Bronze Layer Data Loading

## 🎯 Purpose
The Bronze layer is designed to store raw, unprocessed data from CRM and ERP systems.  
This layer acts as a staging area where data is ingested directly from source files (CSV) without transformations.  
The data will later be cleaned and transformed in the Silver and Gold layers for analytics and reporting.

---

# 🔑 Steps in Bronze Execution

## Create Bronze Tables
- Before loading data, create all required bronze tables using the DDL script.
- Run the script:
  - MySQL: source creation_bronze_tables.sql;
- Tables created:
  - bronze_crm_cust_info
  - bronze_crm_prd_info
  - bronze_crm_sales_details
  - bronze_erp_cust_az12
  - bronze_erp_loc_a101
  - bronze_erp_px_cat_g1v2
- Purpose: Initializes schema to store raw data from CSV files.

---

## Prepare the Environment
- Place all CSV files (px_cat_g1v2.csv, loc_a101.csv, cust_az12.csv, etc.) into:
  C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/
- Ensure ddl_bronze.sql has truncate + load commands.

---

## Truncate Bronze Tables
- MySQL:
  CALL truncate_crm_erp_tables();
- SQL Server:
  EXEC truncate_crm_erp_tables;

---

## Load Fresh Data from CSVs
- MySQL:
  LOAD DATA INFILE 'file.csv' INTO TABLE bronze_table ...
- SQL Server:
  BULK INSERT bronze_table FROM 'file.csv' WITH (...)

---

## Apply Data Cleaning During Load
- Convert empty to NULL:
  NULLIF(@field, '')
- Convert date:
  MySQL: STR_TO_DATE(@field, '%Y-%m-%d')
  SQL Server: CONVERT(DATE, field, 23)
- Handle invalid:
  CASE WHEN @field IN ('', '0') THEN NULL END

---

## Print Status Messages
- MySQL:
  SELECT ">> Updating table bronze_xxx";
- SQL Server:
  PRINT '>> Updating table bronze_xxx';

---

## Track Execution Timing
- MySQL:
  SET @start_time = NOW();
  SET @end_time = NOW();
  SELECT TIMESTAMPDIFF(SECOND, @start_time, @end_time);
- SQL Server:
  DECLARE @start_time DATETIME = GETDATE();
  DECLARE @end_time DATETIME = GETDATE();
  SELECT DATEDIFF(SECOND, @start_time, @end_time);

---

## Execute the Script
- MySQL:
  source load_bronze.sql;
- Using .bat file:
  Run to automate execution.

---

## Confirm Completion
- Output:
  Tables in datawarehouse have been updated

---

# ⚖️ MySQL vs SQL Server Differences

## CSV Loading
- MySQL: LOAD DATA INFILE
- SQL Server: BULK INSERT

## Stored Procedure
- MySQL: CALL procedure_name();
- SQL Server: EXEC procedure_name;

## Date Conversion
- MySQL: STR_TO_DATE()
- SQL Server: CONVERT() / CAST()

## Null Handling
- Both: NULLIF(field, '')

## Timing Functions
- MySQL: NOW(), TIMESTAMPDIFF()
- SQL Server: GETDATE(), DATEDIFF()

## Print Messages
- MySQL: SELECT "message"
- SQL Server: PRINT 'message'

## Bulk Load in Procedures
- MySQL: LOAD DATA INFILE ❌
- SQL Server: BULK INSERT ✅

---

# 🚀 Outcome
- Raw data loaded into Bronze tables  
- Ready for Silver layer  
- Consistent data ingestion pipeline  
