##📊 **Bronze Layer – Data Ingestion**

---

## 🎯 Purpose

The Bronze layer stores **raw, unprocessed data** from CRM and ERP systems.
It acts as a **staging layer**, where data is ingested directly from CSV files with minimal transformation.

This layer preserves source data and prepares it for further processing in the **Silver** and **Gold** layers.

---

## 🔑 Execution Steps

### 1. Create Bronze Tables

Run the DDL script to create raw tables:

```sql
SOURCE creation_of_bronze_tables.sql;
```

**Tables:**

* bronze_crm_cust_info
* bronze_crm_prd_info
* bronze_crm_sales_details
* bronze_erp_cust_az12
* bronze_erp_loc_a101
* bronze_erp_px_cat_g1v2

---

### 2. Prepare Environment

* Place CSV files in:

```
C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/
```

* Ensure `load_bronze.sql` contains truncate and load logic

---

### 3. Truncate Existing Data

```sql
CALL truncate_crm_erp_tables();
```

---

### 4. Load Data from CSV

```sql
LOAD DATA INFILE 'file.csv'
INTO TABLE bronze_table;
```

---

### 5. Minimal Data Standardization

* Convert empty values → NULL
* Basic date formatting (if required)

---

### 6. Logging & Monitoring

* Status messages for each table load
* Execution time tracking

---

### 7. Execute Pipeline

```sql
SOURCE load_bronze.sql;
```

OR run:

```
run_bronze.bat
```

---

### 8. Confirmation

✔ Data successfully loaded into Bronze tables
✔ Ready for Silver layer processing

---

## ⚖️ MySQL vs SQL Server (Quick Comparison)

| Feature         | MySQL            | SQL Server       |
| --------------- | ---------------- | ---------------- |
| Bulk Load       | LOAD DATA INFILE | BULK INSERT      |
| Procedure Call  | CALL             | EXEC             |
| Date Conversion | STR_TO_DATE()    | CONVERT()/CAST() |
| Timing          | NOW()            | GETDATE()        |
| Logging         | SELECT           | PRINT            |

---

## 🚀 Outcome

* Raw data ingested into Bronze tables
* Re-runnable and automated pipeline
* Foundation ready for Silver transformations

---

## 💡 Architecture Note

This project follows **Medallion Architecture**:

* Bronze → Raw data
* Silver → Cleaned & transformed data
* Gold → Business insights
