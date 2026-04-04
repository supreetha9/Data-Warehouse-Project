# Data Catalog for Gold Layer

## Overview

The gold layer is the business-facing dataset for analytics and reporting. In this project it is implemented as **PostgreSQL views** (not physical tables): **dimensions** for customers and products and a **fact** view for sales line items. Values are derived from the silver layer and joined across CRM and ERP sources.

---

### 1. **gold.dim_customers**

- **Purpose:** Customer attributes merged from CRM with ERP demographics and location.
- **Columns:**

| Column Name     | Data Type    | Description                                                                                   |
|-----------------|--------------|-----------------------------------------------------------------------------------------------|
| customer_key    | BIGINT       | Surrogate key (`ROW_NUMBER` over `cst_id`); PostgreSQL returns `bigint`.                      |
| customer_id     | INT          | CRM natural customer identifier (`cst_id`).                                                   |
| customer_number | VARCHAR(50)  | CRM business key (`cst_key`); joins to ERP `cid` for birth date, gender, and country.         |
| first_name      | VARCHAR(50)  | Customer first name from CRM.                                                                |
| last_name       | VARCHAR(50)  | Customer last name from CRM.                                                                 |
| marital_status  | VARCHAR(50)  | Normalized marital status from silver (e.g., Single, Married, n/a).                         |
| gender          | VARCHAR(50)  | CRM gender when not `n/a`; otherwise ERP `gen`, coalesced to `n/a`.                          |
| create_date     | DATE         | Date the customer record was created in CRM (`cst_create_date`).                             |
| birthdate       | DATE         | Date of birth from ERP when available (`bdate`).                                             |
| country         | VARCHAR(50)  | Country from ERP location (`cntry`) keyed by `customer_number` / `cid`.                      |

---

### 2. **gold.dim_products**

- **Purpose:** Current products (silver rows where `prd_end_dt` is NULL), enriched with ERP category attributes.
- **Columns:**

| Column Name   | Data Type    | Description                                                                                   |
|---------------|--------------|-----------------------------------------------------------------------------------------------|
| product_key   | BIGINT       | Surrogate key (`ROW_NUMBER` over `prd_start_dt`, `prd_key`); PostgreSQL returns `bigint`.     |
| product_id    | INT          | CRM product identifier (`prd_id`).                                                            |
| product_number| VARCHAR(50)  | CRM product key (`prd_key`); used to join sales lines to this dimension.                      |
| product_name  | VARCHAR(50)  | Product display name (`prd_nm`).                                                              |
| category_id   | VARCHAR(50)  | Category code derived in silver from `prd_key`; matches ERP category reference `id`.          |
| category      | VARCHAR(50)  | High-level category from ERP (`cat`).                                                         |
| sub_category  | VARCHAR(50)  | Subcategory from ERP (`subcat`).                                                              |
| maintenance   | VARCHAR(50)  | Maintenance flag or description from ERP (`maintenance`).                                     |
| cost          | INT          | Product cost (`prd_cost`), whole units as stored in source.                                   |
| product_line  | VARCHAR(50)  | Normalized line from silver (e.g., Mountain, Road, Touring, Other Sales, n/a).              |
| start_date    | DATE         | Date the product version became effective (`prd_start_dt`).                                   |

---

### 3. **gold.fact_sales**

- **Purpose:** Sales order lines with surrogate keys to `dim_products` and `dim_customers` for star-schema queries.
- **Columns:**

| Column Name   | Data Type    | Description                                                                                   |
|---------------|--------------|-----------------------------------------------------------------------------------------------|
| order_number  | VARCHAR(50)  | Order or line identifier from CRM (`sls_ord_num`).                                            |
| product_key   | BIGINT       | Surrogate key to `gold.dim_products` (via `sls_prd_key` = `product_number`). NULL if no match. |
| customer_key  | BIGINT       | Surrogate key to `gold.dim_customers` (via `sls_cust_id` = `customer_id`). NULL if no match.    |
| order_date    | DATE         | Order date converted from bronze `YYYYMMDD` integer. NULL if invalid or zero in source.       |
| shipping_date | DATE         | Ship date converted from bronze integer; NULL if invalid or missing.                          |
| due_date      | DATE         | Due date converted from bronze integer; NULL if invalid or missing.                           |
| sales_amount  | INT          | Line sales amount (`sls_sales`), aligned with quantity × unit price in silver load.           |
| quantity      | INT          | Units ordered (`sls_quantity`).                                                               |
| price         | INT          | Unit price (`sls_price`), whole currency units as stored.                                     |
