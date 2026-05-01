# 🥇 Gold Layer – Business Ready Data

---

## 🎯 Purpose

The Gold layer provides **business-ready, analytics-friendly data** by transforming and integrating cleaned Silver layer data.

This layer:

* Combines multiple datasets
* Applies business logic
* Creates dimension and fact views
* Supports reporting and dashboards

---

## 🚀 Run Order (Important)

1. Ensure Silver layer is completed

```sql id="g1a2b3"
SOURCE load_silver.sql;
CALL load_silver();
```

2. Create Gold views

```sql id="h4c5d6"
SOURCE create_gold_views.sql;
```

---

## ⚙️ What Happens in Gold Layer

* Data integration from multiple Silver tables
* Creation of dimension views
* Creation of fact view
* Application of business rules
* Generation of surrogate keys
* Preparation of analytics-ready dataset

---

## 🧱 Objects Created

### 📌 1. gold_dim_customers

**Source Tables (Silver Layer):**

* silver_crm_cust_info
* silver_erp_cust_az12
* silver_erp_loc_a101

**Description:**

* Combines CRM and ERP customer data
* Resolves gender conflicts (CRM priority, ERP fallback)
* Adds country information
* Generates `customer_key`

---

### 📌 2. gold_dim_products

**Source Tables (Silver Layer):**

* silver_crm_prd_info
* silver_erp_px_cat_g1v2

**Description:**

* Combines product and category data
* Maps product categories
* Filters active products
* Generates `product_key`

---

### 📌 3. gold_fact_sales

**Source Tables (Silver Layer):**

* silver_crm_sales_details

**Also Uses:**

* gold_dim_products
* gold_dim_customers

**Description:**

* Links customers and products
* Stores transactional sales data
* Includes:

  * order details
  * dates
  * sales metrics

---

## 🔄 Transformations Applied

* Multi-table joins (CRM + ERP)
* Surrogate key generation using `ROW_NUMBER()`
* Conditional logic using `CASE`
* Handling missing values using `COALESCE()`
* Filtering active records

---

## 🧪 Data Quality Checks

Quality checks are available in:

```
tests/gold_quality_checks.sql
```

These checks validate:

* Uniqueness of surrogate keys
* Referential integrity (fact ↔ dimensions)
* Data consistency

---

## 🚀 Outcome

* Business-ready dataset
* Star schema (fact + dimensions)
* Optimized for analytics and reporting
* Ready for dashboards

---

