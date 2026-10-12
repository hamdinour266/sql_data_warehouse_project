# Enterprise Sales Data Warehouse | Medallion Architecture & Automated ETL  + Analytics & Semantic Reporting Suite
---
A robust SQL Server Data Warehouse integrating CRM and ERP systems. The project implements a Medallion Architecture (Bronze → Silver → Gold) with automated Python orchestration, comprehensive data quality validation, advanced SQL transformations, and dimensional modeling and a production-grade Analytics & Reporting Suite designed for business intelligence consumption.

---

## 🎯 Executive Summary

This repository contains the complete engineering implementation of an end-to-end data platform solution. It consolidates transactional sales data from CRM and ERP source systems into a unified analytical warehouse and provides two distinct consumption layers:
1.  **Semantic Reporting Suite:** Persistent Gold-layer views (`report_customers`, `report_products`) encapsulating complex KPIs, segmentation logic, and behavioral metrics for direct BI tool consumption.
2.  **Analytics Script Library:** A comprehensive collection of 11+ advanced SQL scripts organized into EDA and Advanced Analytics folders for exploratory analysis, performance tracking, strategic segmentation, and executive-ready metrics.


### Key Engineering Highlights
-   **Medallion Architecture:** Clear separation of responsibilities across Raw (Bronze), Cleansed (Silver), Business (Gold), Semantic Reporting, and Analytics layers.
-   **Advanced T-SQL Transformations:** Implementation of SCD Type 2 logic, composite key parsing, domain standardization, deduplication, and referential integrity validation.
-   **Automated Orchestration:** Python-based pipeline execution with sequential Bronze → Silver processing, telemetry, and error propagation.
-   **Data Quality Framework:** Dedicated Silver and Gold validation suites covering uniqueness, referential integrity, domain validity, and business rules.
-   **Dimensional Modeling:** Star Schema design using `fact_sales`, `dim_customers`, and `dim_products` optimized for BI consumption.
-   **Semantic Reporting Suite:** Persistent Gold-layer views (`report_products`, `report_customers`) encapsulating complex KPIs, segmentation logic, and behavioral metrics for direct BI tool consumption.
-   **Analytics Script Library:** 11+ advanced SQL scripts split into EDA (6 scripts) and Advanced Analytics (5 scripts) covering time-series trends, cumulative growth, YoY/MoM benchmarking, part-to-whole contribution, and customer/product segmentation.

---

## 🏛️ High-Level Architecture

The solution follows the Medallion Architecture pattern, separating data ingestion, transformation, and business consumption:

<img width="1024" height="605" alt="image" src="https://github.com/user-attachments/assets/1d43165d-124f-402e-a461-ea5a6750a19c" />


| Layer | Purpose | Object Type | Load Strategy | Key Characteristics |
| :--- | :--- | :--- | :--- | :--- |
| 🥉 Bronze | Raw Ingestion | Tables | Full Load (Truncate & Insert) | Raw source data with no transformations |00
| 🥈 Silver | Cleansing & Standardization | Tables | Full Load (Transactional) | Data cleansing, type casting, domain mapping, deduplication, and SCD logic |
| 🥇 Gold | Business Consumption | Views | On-Demand | Star Schema with surrogate keys and business-ready metrics |
| 📊 Reporting | Semantic KPI & Behavioral Metrics | Persistent Views | Pre-computed / Cached | Encapsulated segmentation, recency, lifetime value, and revenue KPIs |
| 🔍 Analytics | Exploratory & Ad-Hoc Analysis | SQL Scripts | Ad-Hoc / Scheduled | EDA, Trend Reports, Benchmarking, Ranking, Cumulative Metrics |

  > **Architectural Note:** The Reporting and Analytics layers are distinguished from the Gold layer to reflect their distinct consumption patterns. The Gold Star Schema serves as the normalized foundation for flexible querying, while the Semantic Reporting views (`report_*`) encapsulate pre-aggregated business logic for direct BI consumption, and the Analytics scripts support transient exploratory analysis. This separation ensures dimensional model integrity while enabling self-service analytics.

### Data Lineage & Integration
-   **Sources:** CSV files from CRM (Customers, Products, Sales) and ERP (Locations, Demographics, Categories).
-   **Integration Logic:** A Master Data Management (MDM) approach where CRM serves as the master source for customer and product identities, enriched with ERP demographic and geographic attributes.
-   **Orchestration:** A sequential dependency chain managed by Python, where Silver processing is triggered only after successful Bronze completion. Semantic Reporting views and Analytics scripts consume validated Gold layer data to ensure insight accuracy.


---

## 💻 Technical Stack & Standards

-   **Database Engine:** Microsoft SQL Server
-   **ETL Language:** T-SQL (Stored Procedures, Window Functions, CTEs, and SQL transformations)
-   **Reporting & Analytics Language:** Advanced T-SQL (`LAG`/`LEAD`, `DATETRUNC`, `FORMAT`, `RANK`/`DENSE_RANK`, `SUM OVER()`, Complex CASE Logic)
-   **Data Quality:** Automated T-SQL Validation Suites
-   **Orchestration:** Python 3.x with `pyodbc`
-   **Connectivity:** ODBC Driver 17 for SQL Server
-   **Naming Conventions:** `snake_case` naming with schema-scoped objects (`bronze.`, `silver.`, `gold.`)

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
  ├── orchestration/                #  Pipeline Execution Engine
  │   ├── config.py                 # Secure DB Connection Config
  │   ├── db_connector.py           # Reusable PyODBC Manager
  │   └── run_pipeline.py           # Main Orchestrator w/ Telemetry
  ├── sql_scripts/                  # 🗄️ Database Objects
  │   ├── init_database.sql         # Schema & Permission Setup
  │   ├── bronze/                   # DDL + Bulk Ingestion Procs
  │   ├── silver/                   # DDL + Transformation Procs
  │   │   └── transformations/      # Granular Table-Level ETL
  │   └── gold/                     # Dimensional Model Views & Reports
  │       ├── fact_sales.sql        # Core Fact View
  │       ├── dim_customers.sql     # Customer Dimension
  │       ├── dim_products.sql      # Product Dimension (SCD2)
  │       ├── report_customers.sql  # 📊 Customer Behavioral Report View
  │       └── report_products.sql   #  Product Performance Report View
  ├── tests/                        # ✅ Data Quality Validation
  │   ├── test_silver_quality_checks.sql
  │   └── test_gold_quality_checks.sql
  ├── analytics/                    #  Analytics Script Library
  │   ├── EDA/                      # Exploratory Data Analysis (01-06)
  │   │   ├── 01_database_exploration.sql
  │   │   ├── 02_dimensions_exploration.sql
  │   │   ├── 03_data_range_exploration.sql
  │   │   ├── 04_measures_exploration.sql
  │   │   ├── 05_magnitude_analysis.sql
  │   │   └── 06_ranking_analysis.sql
  │   └── advanced_analytics/       # Advanced Business Analytics (01-05)
  │       ├── 01_change_over_time.sql
  │       ├── 02_cumulative_analysis.sql
  │       ├── 03_performance_analysis.sql
  │       ├── 04_part_to_whole_analysis.sql
  │       └── 05_data_segmentation.sql
  ├── .gitignore
  ├── LICENSE
  └── README.md
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
## 📊 Semantic Reporting Suite (Persistent Views)

Beyond infrastructure, this project delivers a **persistent Semantic Reporting Layer** within the Gold schema. These views encapsulate complex business logic, making them ready for direct consumption by Power BI, Tableau, or Excel without requiring end-users to write SQL.

### 👤 `gold.report_customers`
A comprehensive customer behavioral view that pre-calculates critical KPIs:
-   **Segmentation:** Automatic classification into **VIP**, **Regular**, or **New** based on lifespan (>12 months) and total spend (>€5,000).
-   **Demographics:** Age grouping (**Under 20**, **20-29**, **30-39**, **40-49**, **50+**) derived from birthdate.
-   **Behavioral Metrics:** Recency (months since last order), Average Order Value (AOV), and Average Monthly Spend.
-   **Lifetime Value:** Total orders, total sales, total quantity, unique products purchased, and customer lifespan in months.
---
### 📦 `gold.report_products`
A product performance view designed for merchandising and inventory analysis:
-   **Performance Segmentation:** Classification into **High-Performer** (>€50k), **Mid-Range** (€10k-€50k), or **Low-Performer** (<€10k).
-   **Sales Velocity:** Average Order Revenue (AOR) and Average Monthly Revenue normalized by product lifespan.
-   **Market Reach:** Total unique customers, total orders, and total quantity sold per product.
-   **Recency Tracking:** Months since last sale to identify dormant SKUs.

> 💡 **Why This Matters:** By materializing these reports as *views* rather than ad-hoc scripts, we ensure consistency, reduce redundancy, and enable self-service analytics. Stakeholders get trusted, pre-validated metrics instantly.

---

## 🔍 Analytics Script Library (EDA + Advanced Analytics)

Complementing the persistent reports, this library contains 11+ specialized SQL scripts organized into two dedicated folders for deeper investigation and exploratory work:

### 🧭 Exploratory Data Analysis (EDA) — `/analytics/EDA/`
Scripts designed to validate, explore, and establish baseline understanding of the Gold layer data model:
-   **01_database_exploration.sql:** Inspecting schema metadata, table structures, and column types via `INFORMATION_SCHEMA`.
-   **02_dimensions_exploration.sql:** Identifying unique values and categorical distributions in `dim_customers` and `dim_products`.
-   **03_data_range_exploration.sql:** Determining temporal boundaries (first/last order dates) and customer age ranges.
-   **04_measures_exploration.sql:** Calculating KPI baselines (Total Sales, Avg Price, Order Counts, Customer/Product counts).
-   **05_magnitude_analysis.sql:** Quantifying revenue and volume distribution across countries, genders, and categories.
-   **06_ranking_analysis.sql:** Using `RANK()`, `DENSE_RANK()`, and `TOP N` to identify top/bottom performing products and customers.
---
### 📈 Advanced Business Analytics — `/analytics/advanced_analytics/`
Production-grade analytical queries solving specific business questions:
-   **01_change_over_time.sql:** Time-series trend analysis using `DATETRUNC()`, `FORMAT()`, and date aggregation to track monthly/yearly sales patterns.
-   **02_cumulative_analysis.sql:** Calculating running totals and moving averages using `SUM() OVER()` and `AVG() OVER()` window functions for growth tracking.
-   **03_performance_analysis.sql:** Year-over-Year (YoY) and Month-over-Month (MoM) comparisons using `LAG()` to measure product performance against historical averages and prior periods.
-   **04_part_to_whole_analysis.sql:** Category contribution analysis showing percentage-of-total revenue breakdowns using window aggregates.
-   **05_data_segmentation.sql:** Strategic customer segmentation (VIP vs Regular vs New) based on spending thresholds and lifespan, plus product cost-tier grouping using conditional `CASE` logic.

---

## 🔒 Data Quality & Governance

Data integrity is enforced at two critical checkpoints. All quality check scripts are located in `/tests`. Reliable reporting and analytics depend entirely on clean Gold layer data.

### Silver Layer Checks (`test_silver_quality_checks.sql`)
-   **Uniqueness:** Primary Key duplicate detection across all entities.
-   **Domain Validity:** Gender, Marital Status, Product Line standardization verification.
-   **Referential Integrity:** Sales transactions must link to valid Customer/Product records.
-   **Business Logic:** Sales Amount == Quantity × Price validation.

### Gold Layer Checks (`test_gold_quality_checks.sql`)
-   **Surrogate Key Uniqueness:** Ensures `ROW_NUMBER()` generation is deterministic.
-   **FK Completeness:** Zero tolerance for orphaned fact records.
-   **Metric Sanity:** No negative prices, quantities, or sales amounts.

> ️ **Production Note:** In a CI/CD environment, these SQL validation scripts could be integrated into an automated test harness to fail the pipeline when critical quality checks return invalid records. Accurate analytics and reporting require zero-tolerance data quality gates.

---

## 🧠 Advanced Engineering Decisions

### 1. SCD Type 2 Implementation (Products)
The product transformation implements SCD Type 2 logic to track historical product versions using window functions. The end date of each historical version is calculated using `LEAD()`:
```sql
DATEADD(day, -1, LEAD(prd_start_dt) OVER (
    PARTITION BY prd_key ORDER BY prd_start_dt
)) AS prd_end_dt
```
-   **Active records:** `prd_end_dt IS NULL`
-   **Expired records:** End date equals the next version's start date minus one day.

This allows historical product versions to be represented while maintaining the currently active record.


### 2. Composite Key Parsing
ERP product keys contain embedded category information. The transformation extracts the category identifier and product code from the composite key:

```sql
-- Category ID Extraction
REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') AS cat_id

-- Product Code Extraction
SUBSTRING(TRIM(prd_key), 7, LEN(TRIM(prd_key))) AS prd_key
```

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
## 🤝 Engineering Practices

The project applies several professional data engineering practices:

- **Idempotency:** ETL procedures can be re-executed without creating duplicate data.
- **Explicit Typing:** Explicit `CAST` and `CONVERT` operations are used where required instead of relying on implicit conversions.
- **Schema Scoping:** Database objects are referenced using their schema names (`bronze.`, `silver.`, `gold.`).
- **Error Propagation:** SQL errors are re-thrown using `THROW` so that the Python orchestration layer can detect pipeline failures.
- **Transactional Processing:** Silver transformations use transaction handling with rollback on failure.
- **Modular Transformations:** Entity-specific transformations are organized into individual stored procedures.
- **Data Quality Gates:** Dedicated validation scripts are executed to verify data integrity across Silver and Gold layers.
- **Semantic Abstraction:** Complex business logic encapsulated in reusable Gold-layer views for consistent reporting.
- **Analytical Documentation:** Every analytics script includes purpose headers, business context, and function references for maintainability.
---
**📊 Target Data Model (Star Schema)**
The Gold layer follows a Star Schema designed for analytical consumption.
<img width="1024" height="455" alt="image" src="https://github.com/user-attachments/assets/4b532e39-1ec4-48ec-8439-500a9fd43620" />

| Object | Type | Description |
| :--- | :--- | :--- |
| gold.fact_sales | Fact View | Transactional grain. Links to dims via surrogate keys. Measures: sales_amount, quantity, price. |
| gold.dim_customers | Dim View | Conformed dimension. Merges CRM demographics + ERP location/birthdate. Master source: CRM. |
| gold.dim_products | Dim View | Active-only product catalog. Includes category hierarchy and SCD-effective pricing. |
| gold.report_customers | Report View |Pre-computed customer KPIs: segmentation, recency, AOV, monthly spend, lifespan. |
| gold.report_products | Report View |Pre-computed product KPIs: performance tier, AOR, monthly revenue, market reach. |

## Data Model Characteristics
- **Fact Table:** `gold.fact_sales`
- **Dimensions:** `gold.dim_customers`, `gold.dim_products`
- **Semantic Reports:** `gold.report_customers`, `gold.report_products`
- **Analytics Scripts:** 11 scripts in /analytics/EDA/ and /analytics/advanced_analytics/
- **Surrogate Keys:** Generated using `ROW_NUMBER()`
- **Integration:** CRM and ERP data unified through Silver-layer transformations
- **Historical Tracking:** SCD Type 2 applied to product versions
- **Consumption:** Designed for analytical workloads, self-service BI, structured reporting, and exploratory analysis

---



## 📄 License

MIT License © 2024. Free for educational and portfolio use. Attribution appreciated.

> 💡 **Note:** This project demonstrates more than SQL syntax—it showcases system thinking. The value lies in the orchestration layer, the quality gates, the transactional safety patterns, the dimensional modeling, the Semantic Reporting Suite, AND the Analytics Script Library that together prove the warehouse delivers real, actionable, consistent, and explorable business intelligence.
