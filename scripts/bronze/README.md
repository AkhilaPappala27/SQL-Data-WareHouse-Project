# 🔑 Steps in Bronze Execution

## **Prepare the Environment**
- Place all required CSV files (e.g., `px_cat_g1v2.csv`, `loc_a101.csv`, `cust_az12.csv`, etc.) into the designated upload folder (`C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/`).
- Ensure your `ddl_bronze.sql` script contains the truncate + load commands for each bronze table.

## **Truncate Bronze Tables**
- Clear out old data from all bronze tables to avoid duplicates and ensure consistency.
- In MySQL: `CALL truncate_crm_erp_tables();`
- In SQL Server: `EXEC truncate_crm_erp_tables;`

## **Load Fresh Data from CSVs**
- For each CSV file, load data into its corresponding bronze table.
- In MySQL: `LOAD DATA INFILE 'file.csv' INTO TABLE bronze_table ...`
- In SQL Server: `BULK INSERT bronze_table FROM 'file.csv' WITH (...)`

## **Apply Data Cleaning During Load**
- Convert empty strings to `NULL` using `NULLIF`.
- Convert text dates into proper date formats (`STR_TO_DATE` in MySQL, `CONVERT` in SQL Server).
- Handle invalid values (e.g., `CASE WHEN @field IN ('', '0') THEN NULL`).

## **Print Status Messages**
- Show progress markers for each step.
- In MySQL: `SELECT ">> Updating table bronze_xxx" AS status;`
- In SQL Server: `PRINT '>> Updating table bronze_xxx';`

## **Track Execution Timing**
- Record start and end times to measure duration.
- In MySQL: `SET @start_time = NOW(); ... TIMESTAMPDIFF(SECOND, @start_time, @end_time)`
- In SQL Server: `DECLARE @start_time DATETIME = GETDATE(); ... DATEDIFF(SECOND, @start_time, @end_time)`

## **Execute the Script**
- Option A: Manually in MySQL shell → `source load_bronze.sql;`
- Option B: Via `.bat` file → double‑click or run in Command Prompt, which calls MySQL and executes the `.sql` automatically.

## **Confirm Completion**
- `.bat` file echoes a message like *“Tables in datawarehouse have been updated”*.
- Log file (`load_log.txt`) captures all commands, outputs, and errors for review.

---

# ⚖️ MySQL vs SQL Server Differences

## **CSV Loading**
- MySQL → Uses `LOAD DATA INFILE 'file.csv' INTO TABLE ...`
- SQL Server → Uses `BULK INSERT ... FROM 'file.csv' WITH (...)` or `OPENROWSET(BULK...)`

## **Stored Procedure Calls**
- MySQL → `CALL procedure_name();`
- SQL Server → `EXEC procedure_name;`

## **Date Conversion**
- MySQL → `STR_TO_DATE(@field, '%Y-%m-%d')`
- SQL Server → `CONVERT(DATE, field, 23)` or `CAST(field AS DATE)`

## **Null Handling**
- MySQL → `NULLIF(@field, '')`
- SQL Server → `NULLIF(field, '')` (same function exists)

## **Timing Functions**
- MySQL → `NOW()` to capture current time, `TIMESTAMPDIFF()` to calculate duration
- SQL Server → `GETDATE()` to capture current time, `DATEDIFF()` to calculate duration

## **Print / Output Messages**
- MySQL → Uses `SELECT ">> message" AS status;` inside the `.sql` file to print progress markers
- SQL Server → Uses `PRINT '>> message';` for the same purpose

## **LOAD Command in Procedures**
- MySQL → `LOAD DATA INFILE` **cannot be used inside stored procedures**
- SQL Server → `BULK INSERT` **can be used inside stored procedures**
