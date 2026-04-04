# **Naming Conventions**

This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the data warehouse.

## **Table of Contents**

1. [General Principles](#general-principles)
2. [Table Naming Conventions](#table-naming-conventions)
   - [Bronze Rules](#bronze-rules)
   - [Silver Rules](#silver-rules)
   - [Gold Rules](#gold-rules)
3. [Column Naming Conventions](#column-naming-conventions)
   - [Surrogate Keys](#surrogate-keys)
   - [Technical Columns](#technical-columns)
4. [Scripts and Load Jobs](#scripts-and-load-jobs)

---

## **General Principles**

- **Naming Conventions**: Use snake_case, with lowercase letters and underscores (`_`) to separate words.
- **Language**: Use English for all names.
- **Avoid Reserved Words**: Do not use SQL reserved words as object names.

## **Table Naming Conventions**

### **Bronze Rules**

- All names must start with the source system name, and table names align with the source dataset or system naming (often abbreviated to match file or legacy names).
- **`<sourcesystem>_<entity>`**
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`).
  - `<entity>`: Entity or file identifier from the source (e.g., `cust_info`, `prd_info`, `sales_details`, `cust_az12`, `loc_a101`, `px_cat_g1v2`).
  - Examples in this project:
    - `crm_cust_info` — Customer information from CRM.
    - `crm_prd_info` — Product information from CRM.
    - `crm_sales_details` — Sales line details from CRM.
    - `erp_cust_az12` — Customer attributes from ERP.
    - `erp_loc_a101` — Location / country from ERP.
    - `erp_px_cat_g1v2` — Product category reference from ERP.

### **Silver Rules**

- Same pattern as bronze: preserve source-oriented table names so bronze-to-silver mapping stays obvious.
- **`<sourcesystem>_<entity>`**
  - Examples mirror bronze: `crm_cust_info`, `crm_prd_info`, `crm_sales_details`, `erp_cust_az12`, `erp_loc_a101`, `erp_px_cat_g1v2`.

### **Gold Rules**

- All names must use meaningful, business-aligned names for views (star-schema style), starting with a category prefix.
- **`<category>_<entity>`**
  - `<category>`: Role of the object, such as `dim` (dimension) or `fact` (fact).
  - `<entity>`: Descriptive business name (plural for dimensions where used).
  - Examples in this project:
    - `dim_customers` — Customer dimension (view).
    - `dim_products` — Product dimension (view).
    - `fact_sales` — Sales fact (view).

#### **Glossary of Category Patterns**

| Pattern   | Meaning          | Example(s) in this project        |
|-----------|------------------|-----------------------------------|
| `dim_`    | Dimension        | `dim_customers`, `dim_products`   |
| `fact_`   | Fact             | `fact_sales`                      |
| `report_` | Report (future)  | e.g. `report_sales_monthly`       |

## **Column Naming Conventions**

### **Surrogate Keys**

- Surrogate keys in gold dimensions use the suffix `_key`.
- **`<entity>_key`**
  - Example: `customer_key` in `dim_customers`, `product_key` in `dim_products`.
- Natural or business identifiers are exposed with clear aliases (e.g., `customer_id`, `customer_number`, `product_id`, `product_number`).

### **Technical Columns**

- Technical / warehouse metadata columns use the prefix `dwh_`, followed by a descriptive name.
- **`dwh_<column_name>`**
  - `dwh`: Prefix for system-generated or load metadata.
  - Example in silver tables: `dwh_create_date` — Timestamp when the silver record was created (default `NOW()`).

### **Source-aligned columns (bronze / silver)**

- **CRM customer**: `cst_*` (e.g., `cst_id`, `cst_key`, `cst_firstname`, `cst_lastname`, `cst_marital_status`, `cst_gender`, `cst_create_date`).
- **CRM product**: `prd_*`, plus `cat_id` on silver for category linkage (e.g., `prd_id`, `prd_key`, `prd_nm`, `prd_cost`, `prd_line`, `prd_start_dt`, `prd_end_dt`).
- **CRM sales**: `sls_*` (e.g., `sls_ord_num`, `sls_prd_key`, `sls_cust_id`, `sls_order_dt`, `sls_ship_dt`, `sls_due_dt`, `sls_sales`, `sls_quantity`, `sls_price`).
- **ERP**: Short names as in source files (e.g., `cid`, `bdate`, `gen`, `cntry`; category table `id`, `cat`, `subcat`, `maintenance`).

## **Scripts and Load Jobs**

This project uses SQL script files (not stored procedures) under `scripts/`. Patterns:

| Purpose              | Pattern | Example |
|----------------------|---------|---------|
| Database / schemas   | `create*.sql` | `create.sql`, `create_schemas.sql` |
| Layer DDL            | `create_tables_<layer>.sql` | `create_tables_bronze.sql`, `create_tables_silver.sql` |
| Bronze load          | `load_data_bronze_layer.sql` | Single script loading all bronze tables |
| Silver load (CRM)    | `load_data_silver_layer_<area>.sql` | `load_data_silver_layer_crm_cust_info.sql`, `load_data_silver_layer_crm_prd.sql`, `load_data_silver_layer_crm_sales.sql` |
| Silver load (ERP)    | `load_silver_layer_<sourcesystem>_<entity>.sql` | `load_silver_layer_erp_cust_az12.sql`, `load_silver_layer_erp_loc_a101.sql`, `load_silver_layer_erp_px_cat_g1v2.sql` |
| Gold (views)         | `gold_layer_<kind>_<name>.sql` | `gold_layer_dimension_dim.customers.sql`, `gold_layer_dimension_dim.products.sql`, `gold_layer_fact_sales.sql` |

When adding new objects, keep the same snake_case object names and align new script names with the patterns above.
