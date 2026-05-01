# Data Warehouse and Analytics Project

---

## 🎯 Overview

This project builds a **data warehouse pipeline** using three layers:

* **Bronze** → Raw data ingestion
* **Silver** → Data cleaning & transformation
* **Gold** → Business-ready data for analytics

The pipeline processes CRM and ERP datasets and prepares them for reporting.

---

## 🏗️ Architecture

```id="u2k7hs"
Raw Data → Bronze → Silver → Gold → Analytics
```

---

## 📁 Project Structure

```id="v9d3lp"
project/
│
├── datasets/        ← CSV files (source data)
├── bronze/
├── silver/
├── gold/
├── tests/
└── README.md
```

---

## 📂 Datasets

The `datasets/` folder contains all raw CSV files used as input for the pipeline.

Example files:

* `cust_info.csv`
* `prd_info.csv`
* `sales_details.csv`
* `cust_az12.csv`
* `loc_a101.csv`
* `px_cat_g1v2.csv`

---

## 🥉 Bronze Layer

* Loads raw data from CSV files
* Stores data without transformation
* Handles basic NULL conversion

---

## 🥈 Silver Layer

* Cleans and standardizes data
* Removes duplicates
* Converts data types
* Prepares structured datasets

---

## 🥇 Gold Layer

* Creates dimension and fact views
* Applies business logic
* Provides analytics-ready data

### Views:

* `gold_dim_customers`
* `gold_dim_products`
* `gold_fact_sales`

---

## 🚀 Execution Steps

```sql id="e4p9xt"
-- Bronze
SOURCE load_bronze.sql;

-- Silver
SOURCE load_silver.sql;
CALL load_silver();

-- Gold
SOURCE create_gold_views.sql;
```

---

## 🧪 Data Quality Checks

* Silver → `tests/silver_quality_checks.sql`
* Gold → `tests/gold_quality_checks.sql`

---

## 🚀 Outcome

* Clean and structured data pipeline
* Business-ready datasets
* Ready for dashboards and analytics

---

## ✅ Summary

✔ End-to-end pipeline
✔ Data cleaning and transformation
✔ Analytics-ready structure

---

