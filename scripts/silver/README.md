# 🧹 Silver Layer – Data Transformation & Cleaning

---

## 🎯 Purpose

The Silver layer transforms raw Bronze data into **clean, consistent, and structured datasets**.

This layer ensures data quality by applying:

* Data cleaning
* Standardization
* Validation
* Transformation

It prepares data for downstream consumption in the **Gold layer (analytics/reporting)**.

---

## 🚀 Run Order (Important)

1. Create Silver tables

```sql
SOURCE create_silver_tables.sql;
```

2. Load & transform data

```sql
SOURCE load_silver.sql;
```

3. Execute procedure

```sql
CALL load_silver();
```

OR run:

```
run_silver.bat
```

---

## ⚙️ What Happens in Silver Layer

* Truncate existing tables
* Load data from Bronze
* Apply transformations
* Remove duplicates
* Standardize values
* Validate data
* Log execution

---

## 🧹 Column-Level Transformations

---

### 📌 1. CRM Customers (`silver_crm_cust_info`)

| Column             | Technique Applied      | Function Used               |
| ------------------ | ---------------------- | --------------------------- |
| cst_id             | Remove NULL values     | `WHERE cst_id IS NOT NULL`  |
| cst_firstname      | Remove unwanted spaces | `TRIM()`                    |
| cst_lastname       | Remove unwanted spaces | `TRIM()`                    |
| cst_marital_status | Standardization        | `UPPER()`, `TRIM()`, `CASE` |
| cst_gndr           | Standardization        | `UPPER()`, `TRIM()`, `CASE` |
| (all rows)         | Remove duplicates      | `ROW_NUMBER()`              |

---

### 📌 2. CRM Products (`silver_crm_prd_info`)

| Column       | Technique Applied    | Function Used               |
| ------------ | -------------------- | --------------------------- |
| cat_id       | Derived column       | `REPLACE()`, `SUBSTRING()`  |
| prd_key      | Extract clean key    | `SUBSTRING()`, `LENGTH()`   |
| prd_cost     | Handle NULL values   | `IFNULL()`                  |
| prd_line     | Standardization      | `UPPER()`, `TRIM()`, `CASE` |
| prd_start_dt | Data type conversion | `DATE()`                    |
| prd_end_dt   | Derived column       | `LEAD()`                    |

---

### 📌 3. CRM Sales (`silver_crm_sales_details`)

| Column       | Technique Applied         | Function Used                         |
| ------------ | ------------------------- | ------------------------------------- |
| sls_order_dt | INT → DATE + validation   | `CAST()`, `STR_TO_DATE()`, `LENGTH()` |
| sls_ship_dt  | INT → DATE + validation   | `CAST()`, `STR_TO_DATE()`, `LENGTH()` |
| sls_due_dt   | INT → DATE + validation   | `CAST()`, `STR_TO_DATE()`, `LENGTH()` |
| sls_sales    | Data correction           | `CASE`, `ABS()`                       |
| sls_price    | Derived / corrected value | `CASE`, `NULLIF()`                    |

---

### 📌 4. ERP Customers (`silver_erp_cust_az12`)

| Column | Technique Applied | Function Used               |
| ------ | ----------------- | --------------------------- |
| cid    | Remove prefix     | `SUBSTRING()`, `LIKE`       |
| bdate  | Validate dates    | `CASE`, `CURDATE()`         |
| gen    | Standardization   | `UPPER()`, `TRIM()`, `CASE` |

---

### 📌 5. ERP Location (`silver_erp_loc_a101`)

| Column | Technique Applied               | Function Used    |
| ------ | ------------------------------- | ---------------- |
| cid    | Remove unwanted characters      | `REPLACE()`      |
| cntry  | Standardization + NULL handling | `TRIM()`, `CASE` |

---

### 📌 6. ERP Product Category (`silver_erp_px_cat_g1v2`)

| Column      | Technique Applied            | Function Used |
| ----------- | ---------------------------- | ------------- |
| All columns | Direct load (reference data) | None          |

---

## ➕ Additional Columns Added in Silver Layer

| Table               | Column          | Description                                   |
| ------------------- | --------------- | --------------------------------------------- |
| All tables          | dwh_create_date | Metadata column for record creation timestamp |
| silver_crm_prd_info | cat_id          | Derived category ID from product key          |
| silver_crm_prd_info | prd_end_dt      | Derived end date using window function        |

---

## ⚖️ MySQL vs SQL Server (Quick Comparison)

| Feature          | MySQL                | SQL Server                  |
| ---------------- | -------------------- | --------------------------- |
| Window Functions | ROW_NUMBER(), LEAD() | Same                        |
| String Functions | TRIM(), REPLACE()    | LTRIM(), RTRIM(), REPLACE() |
| Date Conversion  | STR_TO_DATE()        | CONVERT()/CAST()            |
| Null Handling    | IFNULL()             | ISNULL()                    |
| Procedure        | CALL                 | EXEC                        |
| Error Handling   | DECLARE HANDLER      | TRY...CATCH                 |

---
## 🧪 Data Quality Checks

Quality checks are implemented in:
tests/silver_quality_checks.sql

These checks validate:
- Primary key uniqueness
- Null values
- Data consistency
- Date validity
- Standardization

---

## 🚀 Outcome

* Clean and standardized datasets
* Duplicate-free data
* Validated and corrected values
* Structured schema ready for analytics
* Reliable input for Gold layer

---



