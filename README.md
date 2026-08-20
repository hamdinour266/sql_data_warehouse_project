# Enterprise Sales Data Warehouse | Medallion Architecture & Automated ETL

A robust SQL Server Data Warehouse integrating CRM & ERP systems. Implements a Medallion Architecture (Bronze $\rightarrow$ Silver $\rightarrow$ Gold) with automated procedure orchestration, comprehensive data quality frameworks, and dimensional modeling optimized for BI consumption.

---

## 🎯 Executive Summary

This repository contains the complete engineering implementation of a data warehouse solution. It consolidates transactional sales data from disparate CRM and ERP source systems into a unified analytical platform.

### Key Engineering Highlights
* **Medallion Architecture:** Strict separation of concerns across Raw (Bronze), Cleansed (Silver), and Business (Gold) layers[cite: 7].
* **Advanced T-SQL Transformations:** Implementation of SCD Type 2 logic, composite key parsing, domain standardization, and referential integrity enforcement[cite: 7, 10, 11].
* **Data Quality Framework:** Dual-layer validation suite ensuring PK uniqueness, FK integrity, and business rule compliance post-load[cite: 7, 16, 17].
* **Dimensional Modeling:** Star Schema design (`fact_sales`, `dim_customers`, `dim_products`) optimized for Power BI / Tableau consumption[cite: 7, 20, 21].

---

## 🏛️ High-Level Architecture

The solution follows the Medallion Architecture pattern, enforcing separation of concerns between ingestion, cleansing, and consumption:
<img width="1544" height="912" alt="image" src="https://github.com/user-attachments/assets/5f16b003-dd44-47c8-9052-f359c01fdc9c" />

| Layer | Purpose | Object Type | Load Strategy | Key Characteristics |
| :--- | :--- | :--- | :--- | :--- |
| **🥉 Bronze** | Raw Ingestion | Tables | Full Load (Truncate & Insert) | As-is source mirror. No transformations[cite: 7, 9]. |
| **🥈 Silver** | Standardization | Tables | Full Load (Transactional) | Cleansing, type casting, domain mapping, deduplication, SCD logic[cite: 7, 8, 10, 11, 12, 13, 14, 15]. |
| **🥇 Gold** | Business Consumption | Views | On-Demand (Computed) | Star Schema with surrogate keys and business metrics[cite: 7, 20, 21]. |

---

**Data Lineage & Integration**

**Sources**: CSV files from CRM (Sales, Customers, Products) and ERP (Locations, Demographics, Categories).

**Integration Logic**: Master Data Management (MDM) approach where CRM serves as the master for customer/product identities, enriched with ERP demographic and geographic attributes.

**Orchestration**: Sequential dependency chain managed by Python wrapper; Silver loads only trigger upon successful Bronze completion.

---

## 💻 Technical Stack & Standards

* **Database Engine:** Microsoft SQL Server 2019+
* **ETL Language:** T-SQL (Stored Procedures, Window Functions, CTEs)[cite: 7]
* **Data Quality:** Automated T-SQL Validation Suites[cite: 7, 16, 17]
* **Orchestration:** Python 3.x (`pyodbc`)
* **Naming Conventions:** Strict `snake_case` policy with schema-scoped objects (`bronze.`, `silver.`, `gold.`)
---
## 📂 Repository Structure

📂 Repository Structure

```text
sql_data_warehouse_project/
├── datasets/                     # Source System Extracts (CSV)
│   ├── source_crm/               # CRM System Files
│   └── source_erp/               # ERP System Files
├── docs/                         # Architecture & Governance Docs
│   ├── data_architecture.png     # High-Level Medallion Diagram
│   ├── data_catalog.md           # Column-level Metadata & Lineage
│   ├── naming-conventions.md     # Engineering Style Guide
│   └── data_models/              # ERD & Star Schema Visuals
├── orchestration/                # 🐍 Pipeline Execution Engine
│   ├── config.py                 # Secure DB Connection Config
│   ├── db_connector.py           # Reusable PyODBC Manager
│   └── run_pipeline.py           # Main Orchestrator w/ Telemetry
├── sql_scripts/                  # 🗄️ Database Objects
│   ├── init_database.sql         # Schema & Permission Setup
│   ├── bronze/                   # DDL + Bulk Ingestion Procs
│   ├── silver/                   # DDL + Transformation Procs
│   │   └── transformations/      # Granular Table-Level ETL
│   └── gold/                     # Dimensional Model Views
├── tests/                        # ✅ Data Quality Validation
│   ├── test_silver_quality_checks.sql
│   └── test_gold_quality_checks.sql
── .gitignore
├── LICENSE
── README.md
```
---
️**Installation & Execution**

**Prerequisites**

SQL Server Instance running locally or remotely.

ODBC Driver 17 for SQL Server installed.

Python 3.8+ with pyodbc library: pip install pyodbc

Source CSV files placed in datasets/source_crm/ and datasets/source_erp/.

**Configuration**

Update connection parameters in orchestration/config.py:

DB_CONFIG= {
    'server': r'localhost\SQLEXPRESS',
    'database': 'DataWarehouse',
    'driver': 'ODBC Driver 17 for SQL Server',
    'trusted_connection': 'yes'
}

**Running the Pipeline**

Execute the end-to-end batch load with built-in monitoring:

cd orchestration
python run_pipeline.py

**Expected Output:**

============================================================
Starting Medallion Data Pipeline Batch Load
Start Time: 2024-05-20 14:30:00
============================================================

--- 1. BRONZE LAYER ---
>> Loading bronze.crm_cust_info... Success! (0.45s)
>> Loading bronze.erp_loc_a101... Success! (0.12s)
Bronze Layer Execution Duration: 1.82s

--- 2. SILVER LAYER ---
>> Executing silver.load_silver...
>> Loading silver.crm_cust_info... Success! (0.33s)
>> Loading silver.crm_prd_info... Success! (SCD Type 2 Applied)
Silver Layer Execution Duration: 2.15s

============================================================
PIPELINE EXECUTED SUCCESSFULLY!
Total Batch Duration: 4.12 seconds
End Time: 2024-05-20 14:30:04
============================================================
---
**🔍 Data Quality & Governance**

Data integrity is enforced at two critical checkpoints. All quality check scripts are located in /tests.

**Silver Layer Checks (test_silver_quality_checks.sql)**

**Uniqueness:** Primary Key duplicate detection across all entities.

**Domain Validity**: Gender, Marital Status, Product Line standardization verification.

**Referential Integrity**: Sales transactions must link to valid Customer/Product records.

**Business Logic**: Sales Amount == Quantity * Price validation.

**Gold Layer Checks (test_gold_quality_checks.sql)**

**Surrogate Key Uniqueness**: Ensures ROW_NUMBER() generation is deterministic.

**FK Completeness**: Zero tolerance for orphaned fact records.

**Metric Sanity**: No negative prices, quantities, or sales amounts.

**⚠️ Production Note: In a CI/CD environment, these SQL checks should be wrapped in a Python test harness that fails the pipeline if any query returns > 0 rows.**
---
**🧠 Advanced Engineering Decisions**

**1. SCD Type 2 Implementation (Products)**

Tracks historical product pricing and category alterations using window functions:

-- Calculated End Date Logic in Silver Layer
DATEADD(day, -1, LEAD(prd_start_dt) OVER (
    PARTITION BY prd_key ORDER BY prd_start_dt
)) AS prd_end_dt

Active records have prd_end_dt IS NULL; expired records point to the next version's start date minus one day.

**2. Composite Key Parsing**

ERP product keys embed category information. Transformation extracts hierarchical components:

**-- Category ID Extraction**
REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') AS cat_id
-- Product Code Extraction  
SUBSTRING(TRIM(prd_key), 7, LEN(TRIM(prd_key))) AS prd_key

**3. Transactional Safety**

All Silver layer procedures use explicit transaction blocks with rollback on failure:

BEGIN TRY
    BEGIN TRANSACTION;
    TRUNCATE TABLE silver.target_table;
    INSERT INTO silver.target_table SELECT ... FROM bronze.source_table;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW; -- Propagates error to Python orchestrator
END CATCH

**4. Surrogate Key Generation**

Gold layer uses ROW_NUMBER() over natural keys for stable, reproducible surrogate keys without requiring identity columns or sequences.
---
**📊 Target Data Model (Star Schema)**
<img width="1500" height="667" alt="image" src="https://github.com/user-attachments/assets/b4b588e5-d381-4b32-92a2-9211bdd84cf6" />

Object

Type

Description

gold.fact_sales

Fact View

Transactional grain. Links to dims via surrogate keys. Measures: sales_amount, quantity, price.

gold.dim_customers

Dim View

Conformed dimension. Merges CRM demographics + ERP location/birthdate. Master source: CRM.

gold.dim_products

Dim View

Active-only product catalog. Includes category hierarchy and SCD-effective pricing.

**Contributing & Standards**

This project adheres to senior-level engineering practices:

**Idempotency:** All ETL procedures are re-runnable without side effects.

**Explicit Typing:** Never rely on implicit conversions; always CAST/CONVERT.

**Schema Scoping:** Always prefix objects (bronze.table, not just table).

**Error Propagation:** Catch-blocks re-THROW errors to ensure orchestration layer detects failures.

**Documentation First:** Every stored procedure includes header comments with purpose, params, and usage.
---
**📄 License**

MIT License © 2024. Free for educational and portfolio use. Attribution appreciated.

**💡This project follows professional data engineering practices: Note: This project demonstrates more than SQL syntax—it showcases system thinking. The value lies in the orchestration layer, the quality gates, the transactional safety patterns, and the deliberate architectural choices that make this warehouse maintainable, auditable, and scalable. These practices help make the warehouse maintainable, auditable, and scalable beyond a basic tutorial implementation.**
