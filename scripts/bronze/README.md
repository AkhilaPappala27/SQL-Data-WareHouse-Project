# 📊 Bronze Layer – Data Ingestion

---

## 🎯 Purpose

The Bronze layer stores **raw, unprocessed data** from CRM and ERP systems.
It acts as a **staging layer**, where data is ingested directly from CSV files with minimal transformation.

This layer preserves source data and prepares it for further processing in downstream layers.

---

## 🚀 Run Order

Follow this order to execute the Bronze layer correctly:

1. Create tables

   ```sql
   SOURCE create_bronze_tables.sql;
   ```

2. Run data load pipeline

   ```sql
   SOURCE load_bronze.sql;
   ```

OR simply run:

```
run_bronze.bat
```

> ✔ The `.bat` file automatically handles execution.

---

## 🔑 Execution Steps

### 1. Create Bronze Tables

```sql
SOURCE create_bronze_tables.sql;
```

---

### 2. Enable & Check File Loading (if required)

Check current status:

```sql
SHOW VARIABLES LIKE 'local_infile';
```

Enable if needed:

```sql
SET GLOBAL local_infile = 1;
```

> ⚠️ Only required if `LOAD DATA LOCAL INFILE` is disabled.

---

### 3. Prepare Environment

Place CSV files in:

```
datasets/
```

Example:

```
datasets/
├── px_cat_g1v2.csv
├── loc_a101.csv
├── cust_az12.csv
├── sales_details.csv
├── prd_info.csv
├── cust_info.csv
```

---

### 4. Truncate Existing Data

```sql
CALL truncate_crm_erp_tables();
```

---

### 5. Load Data from CSV

```sql
LOAD DATA LOCAL INFILE 'datasets/file.csv'
INTO TABLE bronze_table;
```

---

### 6. Minimal Data Standardization

* Convert empty values → `NULL` using `NULLIF()`
* Date conversion using `STR_TO_DATE()`

---

### 7. Logging & Monitoring

* Status messages for each table load
* Execution time tracking using `NOW()` and `TIMESTAMPDIFF()`

---

### 8. Execute Pipeline

```sql
SOURCE load_bronze.sql;
```

OR

```
run_bronze.bat
```

---

### 9. Confirmation

✔ Data successfully loaded into Bronze tables
✔ Ready for further processing

---

## ⚖️ MySQL vs SQL Server

| Feature         | MySQL                  | SQL Server            |
| --------------- | ---------------------- | --------------------- |
| Bulk Load       | LOAD DATA LOCAL INFILE | BULK INSERT           |
| Procedure Call  | CALL                   | EXEC                  |
| Date Conversion | STR_TO_DATE()          | CONVERT()/CAST()      |
| Timing          | NOW(), TIMESTAMPDIFF() | GETDATE(), DATEDIFF() |
| Logging         | SELECT                 | PRINT                 |

---

## 🚀 Outcome

* Raw data ingested into Bronze tables
* Minimal cleaning applied during load
* Re-runnable and automated pipeline
* Data ready for transformation in the Silver layer

---
