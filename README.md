# Data-Warehouse-Project

Building a modern Data warehouse

PostgreSQL-based sales analytics warehouse: CRM and ERP CSV extracts, medallion layers (bronze → silver → gold), and star-schema views for reporting. See **About** below for detail.

## About

This repository implements a **medallion-style** data warehouse: raw landings in **bronze**, cleansed and conformed tables in **silver**, and business-ready **gold** dimensions and facts (implemented as views). Source data represents two systems — **CRM** (customers, products, sales details) and **ERP** (customer attributes, locations, product categories) — supplied as files under `datasets/`.

SQL scripts in `scripts/` drive the lifecycle: schema and table DDL (`create_schemas.sql`, `create_tables_bronze.sql`, `create_tables_silver.sql`), loads from CSV into bronze and transformed loads into silver, and gold views (`dim_customers`, `dim_products`, `fact_sales`) for analytics-style queries. Naming and layering are documented in [`docs/naming_conventions.md`](docs/naming_conventions.md).

The project focuses on **current** product and customer snapshots (for example, active products in gold) and normalized quality rules such as trimming codes, deduplicating by business keys, and joining CRM with ERP on shared identifiers.

## Objective
To build a modern data warehouse using PostgreSQL to consolidate sales data from ERP and CRM systems.  
The goal is to create a single, clean data source for analysis and reporting, helping business teams make informed decisions.

---

## Project Overview
This project integrates data from two key systems — ERP and CRM — both provided as CSV files.  
The data is imported, cleaned, and combined into a structured model optimized for reporting and business intelligence.

---

## Specifications

### Data Sources
- Both datasets(CRM,ERP) are provided as CSV files and imported into PostgreSQL.

### Data Quality
- Remove duplicates and handle missing values.  
- Standardize key fields such as customer IDs, dates, and regions.  
- Validate referential integrity between ERP and CRM data.  
- Ensure consistent naming conventions and data types across all tables.

### Data Integration
- Combine ERP and CRM datasets into one schema.   
- Create database views to simplify analytical queries.

### Scope
- Focus only on the **latest dataset**; historical data is not maintained.  



---
