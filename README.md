# Enterprise Sales Data Warehouse | Medallion Architecture & Automated ETL

A robust SQL Server Data Warehouse integrating CRM and ERP systems. The project implements a Medallion Architecture (Bronze → Silver → Gold) with automated Python orchestration, comprehensive data quality validation, advanced SQL transformations, and dimensional modeling designed for BI consumption.

---

## 🎯 Executive Summary

This repository contains the complete engineering implementation of a data warehouse solution that consolidates transactional sales data from CRM and ERP source systems into a unified analytical platform.

### Key Engineering Highlights

- **Medallion Architecture:** Clear separation of responsibilities across Raw (Bronze), Cleansed (Silver), and Business (Gold) layers.
- **Advanced T-SQL Transformations:** Implementation of SCD Type 2 logic, composite key parsing, domain standardization, deduplication, and referential integrity validation.
- **Automated Orchestration:** Python-based pipeline execution with sequential Bronze → Silver processing and error propagation.
- **Data Quality Framework:** Dedicated Silver and Gold validation suites covering uniqueness, referential integrity, domain validity, and business rules.
- **Dimensional Modeling:** Star Schema design using `fact_sales`, `dim_customers`, and `dim_products` for analytical and BI consumption.

---

## 🏛️ High-Level Architecture

The solution follows the Medallion Architecture pattern, separating data ingestion, transformation, and business consumption:

<img width="1544" height="912" alt="Medallion Architecture" src="https://github.com/user-attachments/assets/5f16b003-dd44-47c8-9052-f359c01fdc9c" />

| Layer | Purpose | Object Type | Load Strategy | Key Characteristics |
| :--- | :--- | :--- | :--- | :--- |
| **🥉 Bronze** | Raw Ingestion | Tables | Full Load (Truncate & Insert) | Raw source data with no transformations |
| **🥈 Silver** | Cleansing & Standardization | Tables | Full Load (Transactional) | Data cleansing, type casting, domain mapping, deduplication, and SCD logic |
| **🥇 Gold** | Business Consumption | Views | On-Demand | Star Schema with surrogate keys and business-ready metrics |

### Data Lineage & Integration

- **Sources:** CSV files from CRM (Customers, Products, Sales) and ERP (Locations, Demographics, Categories).
- **Integration Logic:** A Master Data Management (MDM) approach where CRM serves as the master source for customer and product identities, enriched with ERP demographic and geographic attributes.
- **Orchestration:** A sequential dependency chain managed by Python, where Silver processing is triggered only after successful Bronze completion.

---

## 💻 Technical Stack & Standards

- **Database Engine:** Microsoft SQL Server
- **ETL Language:** T-SQL (Stored Procedures, Window Functions, and SQL transformations)
- **Data Quality:** Automated T-SQL Validation Suites
- **Orchestration:** Python 3.x with `pyodbc`
- **Connectivity:** ODBC Driver 17 for SQL Server
- **Naming Conventions:** `snake_case` naming with schema-scoped objects (`bronze.`, `silver.`, `gold.`)

---
## 📂 Repository Structure

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
 |── .gitignore
 ├── LICENSE
 |── README.md
```
---

## ⚙️ Installation & Execution

### Prerequisites :
1. **SQL Server Instance** running locally or remotely.
2. **ODBC Driver 17 for SQL Server** installed.
3. **Python 3.8+** with pyodbc library: `pip install pyodbc`
4. **Source CSV files** placed in `datasets/source_crm/` and `datasets/source_erp/`.

**Install the required Python dependency:**
pip install pyodbc

### 🔧 Configuration :
Update connection parameters in `orchestration/config.py`:
```python
DB_CONFIG = {
    'server': r'localhost\SQLEXPRESS',
    'database': 'DataWarehouse',
    'driver': 'ODBC Driver 17 for SQL Server',
    'trusted_connection': 'yes'}
```

### 🚀 Running the Pipeline
Execute the end-to-end batch load with built-in monitoring:

```bash
cd orchestration
python run_pipeline.py
```
The orchestration process executes the layers sequentially:
```text
Bronze Layer
     ↓
Silver Layer
     ↓
Pipeline Completed
```
The Python orchestration layer also provides execution monitoring, duration tracking, success/failure reporting, and error propagation.
### Expected Output:
```text
============================================================
Starting Medallion Data Pipeline Batch Load
============================================================

--- 1. BRONZE LAYER ---
>> Loading bronze.crm_cust_info... Success!
>> Loading bronze.erp_loc_a101... Success!
Bronze Layer Execution Duration: 1.82s

--- 2. SILVER LAYER ---
>> Executing silver.load_silver...
>> Loading silver.crm_cust_info... Success!
>> Loading silver.crm_prd_info... Success!
Silver Layer Execution Duration: 2.15s

============================================================
PIPELINE EXECUTED SUCCESSFULLY!
Total Batch Duration: 4.12 seconds
============================================================
```
---
## 🔍 Data Quality & Governance

Data integrity is enforced at two critical checkpoints. All quality check scripts are located in `/tests`.

### Silver Layer Checks (`test_silver_quality_checks.sql`):
The Silver validation suite covers:
- **Uniqueness:** Primary Key duplicate detection across all entities.
- **Domain Validity:** Gender, Marital Status, Product Line standardization verification.
- **Referential Integrity:** Sales transactions must link to valid Customer/Product records.
- **Business Logic:** Sales Amount == Quantity * Price validation.

### Gold Layer Checks (`test_gold_quality_checks.sql`):
The Gold validation suite covers:
- **Surrogate Key Uniqueness:** Ensures ROW_NUMBER() generation is deterministic.
- **FK Completeness:** Zero tolerance for orphaned fact records.
- **Metric Sanity:** No negative prices, quantities, or sales amounts.

 ⚠️ **Production Note:** In a CI/CD environment, these SQL validation scripts could be integrated into an automated test harness to fail the pipeline when critical quality checks return invalid records.
---

## 🧠 Advanced Engineering Decisions

### 1. SCD Type 2 Implementation (Products):
The product transformation implements SCD Type 2 logic to track historical product versions using window functions.

The end date of each historical version is calculated using LEAD():
-- Calculated End Date Logic in Silver Layer
```sql
DATEADD(day, -1, LEAD(prd_start_dt) OVER (
    PARTITION BY prd_key ORDER BY prd_start_dt
)) AS prd_end_dt
```
**The logic results in:**

- **Active records:** `prd_end_dt IS NULL`.
- **Expired records:** End date equals the next version's start date minus one day.
This allows historical product versions to be represented while maintaining the currently active record.

### 2. Composite Key Parsing:
ERP product keys contain embedded category information.
The transformation extracts the category identifier and product code from the composite key:
-- Category ID Extraction
```sql
REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') AS cat_id

-- Product Code Extraction
SUBSTRING(TRIM(prd_key), 7, LEN(TRIM(prd_key))) AS prd_key
```
This transformation separates hierarchical category information from the product identifier to support integration and analytical modeling.

### 3. Transactional Safety:
Silver layer procedures use explicit transaction handling to protect data integrity during transformations:
```sql
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
````
This ensures that a failed transformation does not leave the target table in a partially loaded state.
The THROW statement also propagates the error to the Python orchestration layer.

### 4. Surrogate Key Generation
Gold dimensions use ROW_NUMBER() to generate surrogate keys based on natural keys.

This approach provides stable and reproducible surrogate key values without relying on identity columns or database sequences.

These surrogate keys are then used to establish relationships between the fact table and dimension views.

---
**📊 Target Data Model (Star Schema)**
The Gold layer follows a Star Schema designed for analytical consumption.
<img width="1500" height="667" alt="image" src="https://github.com/user-attachments/assets/b4b588e5-d381-4b32-92a2-9211bdd84cf6" />

| Object | Type | Description |
| :--- | :--- | :--- |
| gold.fact_sales | Fact View | Transactional grain. Links to dims via surrogate keys. Measures: sales_amount, quantity, price. |
| gold.dim_customers | Dim View | Conformed dimension. Merges CRM demographics + ERP location/birthdate. Master source: CRM. |
| gold.dim_products | Dim View | Active-only product catalog. Includes category hierarchy and SCD-effective pricing. |

## Data Model Characteristics
- **Fact Table:** `gold.fact_sales`
- **Dimensions:** `gold.dim_customers`, `gold.dim_products`
- **Surrogate Keys:** Generated using `ROW_NUMBER()`
- **Integration:** CRM and ERP data unified through Silver-layer transformations
- **Historical Tracking:** SCD Type 2 applied to product versions
- **Consumption:** Designed for analytical and BI workloads

---

## 🤝 Engineering Practices

The project applies several professional data engineering practices:

- **Idempotency:** ETL procedures can be re-executed without creating duplicate data.
- **Explicit Typing:** Explicit `CAST` and `CONVERT` operations are used where required instead of relying on implicit conversions.
- **Schema Scoping:** Database objects are referenced using their schema names (`bronze.`, `silver.`, `gold.`).
- **Error Propagation:** SQL errors are re-thrown using `THROW` so that the Python orchestration layer can detect pipeline failures.
- **Transactional Processing:** Silver transformations use transaction handling with rollback on failure.
- **Modular Transformations:** Entity-specific transformations are organized into individual stored procedures.
- **Data Quality Gates:** Dedicated validation scripts are executed to verify data integrity across Silver and Gold layers.
---

## 📄 License

MIT License © 2024. Free for educational and portfolio use. Attribution appreciated.

> 💡 **Note:** This project demonstrates more than SQL syntax—it showcases system thinking. The value lies in the orchestration layer, the quality gates, the transactional safety patterns, and the deliberate architectural choices that make this warehouse maintainable, auditable, and scalable beyond a basic tutorial implementation.
