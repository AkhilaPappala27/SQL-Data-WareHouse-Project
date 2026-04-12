# 🔑 Steps in Bronze Execution

## **Prepare the Environment**
- Place all required CSV files (e.g., `px_cat_g1v2.csv`, `loc_a101.csv`, `cust_az12.csv`, etc.) into the designated upload folder (`C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/`).
- Ensure your `ddl_bronze.sql` script contains the truncate + load commands for each bronze table.

## **Truncate Bronze Tables**
- Clear out old data from all bronze tables to avoid duplicates and ensure consistency.
- In MySQL: `CALL truncate_crm_erp_tables();`  
  *Usage:* Executes a stored procedure that truncates staging tables.  
- In SQL Server: `EXEC truncate_crm_erp_tables;`  
  *Usage:* Same purpose, different keyword (`EXEC`).  

## **Load Fresh Data from CSVs**
- For each CSV file, load data into its corresponding bronze table.
- In MySQL: `LOAD DATA INFILE 'file.csv' INTO TABLE bronze_table ...`  
  *Usage:* Quickly loads CSV data into a table, but cannot be used inside stored procedures.  
- In SQL Server: `BULK INSERT bronze_table FROM 'file.csv' WITH (...)`  
  *Usage:* Imports CSV/text data into a table, and can be used inside stored procedures.  

## **Apply Data Cleaning During Load**
- Convert empty strings to `NULL` using `NULLIF`.  
  *Usage:* Ensures missing values are stored as proper `NULL`.  
- Convert text dates into proper date formats (`STR_TO_DATE` in MySQL, `CONVERT` in SQL Server).  
  *Usage:* Standardizes date fields during load.  
- Handle invalid values (e.g., `CASE WHEN @field IN ('', '0') THEN NULL`).  
  *Usage:* Cleans up placeholder or invalid entries.  

## **Print Status Messages**
- Show progress markers for each step.
- In MySQL: `SELECT ">> Updating table bronze_xxx" AS status;`  
  *Usage:* Prints progress messages during script execution.  
- In SQL Server: `PRINT '>> Updating table bronze_xxx';`  
  *Usage:* Prints progress messages during script execution.  

## **Track Execution Timing**
- Record start and end times to measure duration.
- In MySQL: `SET @start_time = NOW(); ... TIMESTAMPDIFF(SECOND, @start_time, @end_time)`  
  *Usage:* Captures execution start/end and calculates duration.  
- In SQL Server: `DECLARE @start_time DATETIME = GETDATE(); ... DATEDIFF(SECOND, @start_time, @end_time)`  
  *Usage:* Same purpose, different functions.  

## **Execute the Script**
- Option A: Manually in MySQL shell → `source load_bronze.sql;`  
  *Usage:* Runs the `.sql` file interactively inside MySQL shell.  
- Option B: Via `.bat` file → double‑click or run in Command Prompt, which calls MySQL and executes the `.sql` automatically.  
  *Usage:* Automates execution with logging and confirmation.  

## **Confirm Completion**
- `.bat` file echoes a message like *“Tables in datawarehouse have been updated”*.  
  *Usage:* Provides user feedback after execution.  
- Log file (`load_log.txt`) captures all commands, outputs, and errors for review.  
  *Usage:* Maintains a permanent record of each run.  

---

# ⚖️ MySQL vs SQL Server Differences

## **CSV Loading**
- MySQL → `LOAD DATA INFILE 'file.csv' INTO TABLE ...`  
  *Usage:* Fast bulk load of CSVs, but not allowed inside procedures.  
- SQL Server → `BULK INSERT ... FROM 'file.csv' WITH (...)` or `OPENROWSET(BULK...)`  
  *Usage:* Bulk load of CSVs, can be used inside procedures.  

## **Stored Procedure Calls**
- MySQL → `CALL procedure_name();`  
  *Usage:* Executes stored procedures.  
- SQL Server → `EXEC procedure_name;`  
  *Usage:* Executes stored procedures (same purpose, different keyword).  

## **Date Conversion**
- MySQL → `STR_TO_DATE(@field, '%Y-%m-%d')`  
  *Usage:* Converts string values into proper date format.  
- SQL Server → `CONVERT(DATE, field, 23)` or `CAST(field AS DATE)`  
  *Usage:* Converts string/numeric values into date format.  

## **Null Handling**
- MySQL → `NULLIF(@field, '')`  
  *Usage:* Converts empty strings into `NULL`.  
- SQL Server → `NULLIF(field, '')`  
  *Usage:* Same function, same purpose.  

## **Timing Functions**
- MySQL → `NOW()` and `TIMESTAMPDIFF()`  
  *Usage:* Capture current time and calculate duration.  
- SQL Server → `GETDATE()` and `DATEDIFF()`  
  *Usage:* Same purpose, different function names.  

## **Print / Output Messages**
- MySQL → `SELECT ">> message" AS status;`  
  *Usage:* Prints progress markers inside SQL scripts.  
- SQL Server → `PRINT '>> message';`  
  *Usage:* Prints progress markers inside SQL scripts.  

## **LOAD Command in Procedures**
- MySQL → `LOAD DATA INFILE`  
  *Usage:* Loads CSV data into tables, but **cannot be used inside stored procedures**.  
- SQL Server → `BULK INSERT`  
  *Usage:* Loads CSV data into tables and **can be used inside stored procedures**.  
