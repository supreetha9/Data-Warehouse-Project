# Data-Warehouse-Project
Building a modern Data warehouse 
# Data Warehouse for Sales Analytics (PostgreSQL)

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
