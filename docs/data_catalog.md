# Comprehensive Data Catalog

## Overview
This Data Catalog serves as the central documentation for the Medallion Data Warehouse Architecture (Bronze, Silver, and Gold layers). It details schema definitions, column data types, business descriptions, and source traceability.

---

## 1. Bronze Layer (Raw Ingestion Schema)
> **Note:** The Bronze layer mirrors source system structures (CRM & ERP) without applying business transformations or data cleansing. All raw types are captured as ingested.

### `bronze.crm_cust_info`
*Source System:* CRM System (`cust_info.csv`)

| Column Name | Data Type | Key Type | Description |
| :--- | :--- | :--- | :--- |
| `cst_id` | INT | PK (Raw) | Unique customer ID from raw CRM system. |
| `cst_key` | NVARCHAR(50) | Business Key | Customer tracking code/key. |
| `cst_firstname` | NVARCHAR(50) | - | Customer first name (unformatted). |
| `cst_lastname` | NVARCHAR(50) | - | Customer last name (unformatted). |
| `cst_marital_status` | NVARCHAR(50) | - | Raw marital status string code. |
| `cst_gndr` | NVARCHAR(50) | - | Raw gender string code. |
| `cst_create_date` | DATE | - | Account creation date in raw system. |

### `bronze.crm_prd_info`
*Source System:* CRM System (`prd_info.csv`)

| Column Name | Data Type | Key Type | Description |
| :--- | :--- | :--- | :--- |
| `prd_id` | INT | PK (Raw) | Raw product primary identifier. |
| `prd_key` | NVARCHAR(50) | Composite Key | Compound product key containing category and product code. |
| `prd_nm` | NVARCHAR(50) | - | Raw product name. |
| `prd_cost` | INT | - | Product cost value (raw integer). |
| `prd_line` | NVARCHAR(50) | - | Product line abbreviation code. |
| `prd_start_dt` | DATETIME | - | Effective start date for product record. |
| `prd_end_dt` | DATETIME | - | Effective end date for product record. |

### `bronze.crm_sales_details`
*Source System:* CRM System (`sales_details.csv`)

| Column Name | Data Type | Key Type | Description |
| :--- | :--- | :--- | :--- |
| `sls_ord_num` | NVARCHAR(50) | Order Key | Transaction order identifier. |
| `sls_prd_key` | NVARCHAR(50) | FK | Foreign key referencing product identifier. |
| `sls_cust_id` | INT | FK | Foreign key referencing customer ID. |
| `sls_order_dt` | INT | - | Raw order date stored as integer (`YYYYMMDD`). |
| `sls_ship_dt` | INT | - | Raw shipping date stored as integer (`YYYYMMDD`). |
| `sls_due_dt` | INT | - | Raw payment due date stored as integer (`YYYYMMDD`). |
| `sls_sales` | INT | - | Raw total sales amount. |
| `sls_quantity` | INT | - | Number of items purchased. |
| `sls_price` | INT | - | Raw price per unit. |

### `bronze.erp_loc_a101`
*Source System:* ERP System (`LOC_A101.csv`)

| Column Name | Data Type | Key Type | Description |
| :--- | :--- | :--- | :--- |
| `cid` | NVARCHAR(50) | Business Key | Customer ID (contains hyphens formatting). |
| `cntry` | NVARCHAR(50) | - | Country name or abbreviation. |

### `bronze.erp_cust_az12`
*Source System:* ERP System (`CUST_AZ12.csv`)

| Column Name | Data Type | Key Type | Description |
| :--- | :--- | :--- | :--- |
| `cid` | NVARCHAR(50) | Business Key | Customer ID (prefixed formatting, e.g., `NAS...`). |
| `bdate` | DATE | - | Customer birthdate. |
| `gen` | NVARCHAR(50) | - | Gender representation in ERP. |

### `bronze.erp_px_cat_g1v2`
*Source System:* ERP System (`PX_CAT_G1V2.csv`)

| Column Name | Data Type | Key Type | Description |
| :--- | :--- | :--- | :--- |
| `id` | NVARCHAR(50) | PK | Category lookup identifier. |
| `cat` | NVARCHAR(50) | - | High-level product category name. |
| `subcat` | NVARCHAR(50) | - | Product subcategory name. |
| `maintenance` | NVARCHAR(50) | - | Maintenance indicator (`Yes`/`No`). |

---

## 2. Silver Layer (Cleansed & Standardized Schema)
> **Note:** The Silver layer applies data quality rules, standardized domains (e.g., gender, marital status), calculated date fields, and adds system audit metadata (`dwh_create_date`).

### `silver.crm_cust_info`
| Column Name | Data Type | Key Type | Description & Transformation Rules |
| :--- | :--- | :--- | :--- |
| `cst_id` | INT | PK | Unique customer identifier. Truncated duplicates removed. |
| `cst_key` | NVARCHAR(50) | Business Key | Standardized customer business code. |
| `cst_firstname` | NVARCHAR(50) | - | Trimmed whitespace and capitalized first name. |
| `cst_lastname` | NVARCHAR(50) | - | Trimmed whitespace and capitalized last name. |
| `cst_marital_status` | NVARCHAR(50) | - | Standardized values: `'Single'`, `'Married'`, or `'n/a'`. |
| `cst_gndr` | NVARCHAR(50) | - | Standardized values: `'Male'`, `'Female'`, or `'n/a'`. |
| `cst_create_date` | DATE | - | Validated customer registration date. |
| `dwh_create_date` | DATETIME2 | Audit | System loading timestamp (`GETDATE()`). |

### `silver.crm_prd_info`
| Column Name | Data Type | Key Type | Description & Transformation Rules |
| :--- | :--- | :--- | :--- |
| `prd_id` | INT | PK | Cleaned product primary identifier. |
| `cat_id` | NVARCHAR(50) | FK | Derived category key extracted from `prd_key` prefix. |
| `prd_key` | NVARCHAR(50) | Business Key | Derived product business key extracted from `prd_key`. |
| `prd_nm` | NVARCHAR(50) | - | Cleaned product name. |
| `prd_cost` | DECIMAL(10,2) | - | Converted monetary cost value (handled nulls to 0). |
| `prd_line` | NVARCHAR(50) | - | Expanded product line name (`R` -> `Road`, `M` -> `Mountain`, etc.). |
| `prd_start_dt` | DATE | - | Validated effective start date. |
| `prd_end_dt` | DATE | - | Calculated effective end date (SCD Type 2 handling). |
| `dwh_create_date` | DATETIME2 | Audit | System loading timestamp. |

### `silver.crm_sales_details`
| Column Name | Data Type | Key Type | Description & Transformation Rules |
| :--- | :--- | :--- | :--- |
| `sls_ord_num` | NVARCHAR(50) | Order Key | Validated sales order number. |
| `sls_prd_key` | NVARCHAR(50) | FK | Standardized foreign key referencing product. |
| `sls_cust_id` | INT | FK | Standardized foreign key referencing customer. |
| `sls_order_dt` | DATE | - | Converted integer date (`YYYYMMDD`) to `DATE` type. |
| `sls_ship_dt` | DATE | - | Converted integer date (`YYYYMMDD`) to `DATE` type. |
| `sls_due_dt` | DATE | - | Converted integer date (`YYYYMMDD`) to `DATE` type. |
| `sls_sales` | DECIMAL(10,2) | - | Re-calculated/validated total sales (`quantity * price`). |
| `sls_quantity` | INT | - | Validated order quantity. |
| `sls_price` | DECIMAL(10,2) | - | Re-calculated unit price (`sales / quantity` if missing). |
| `dwh_create_date` | DATETIME2 | Audit | System loading timestamp. |

### `silver.erp_loc_a101`
| Column Name | Data Type | Key Type | Description & Transformation Rules |
| :--- | :--- | :--- | :--- |
| `cid` | NVARCHAR(50) | Business Key | Cleaned ID (removed hyphens `-` to align with CRM keys). |
| `cntry` | NVARCHAR(50) | - | Standardized country name (e.g., `'US'` -> `'United States'`). |
| `dwh_create_date` | DATETIME2 | Audit | System loading timestamp. |

### `silver.erp_cust_az12`
| Column Name | Data Type | Key Type | Description & Transformation Rules |
| :--- | :--- | :--- | :--- |
| `cid` | NVARCHAR(50) | Business Key | Cleaned ID (removed prefix `NAS` to align with CRM keys). |
| `bdate` | DATE | - | Validated date of birth (checked bounds for future dates). |
| `gen` | NVARCHAR(50) | - | Standardized gender codes (`M` -> `'Male'`, `F` -> `'Female'`). |
| `dwh_create_date` | DATETIME2 | Audit | System loading timestamp. |

### `silver.erp_px_cat_g1v2`
| Column Name | Data Type | Key Type | Description & Transformation Rules |
| :--- | :--- | :--- | :--- |
| `id` | NVARCHAR(50) | PK | Cleaned category ID. |
| `cat` | NVARCHAR(50) | - | Standardized category name. |
| `subcat` | NVARCHAR(50) | - | Standardized subcategory name. |
| `maintenance` | NVARCHAR(50) | - | Validated flag (`'Yes'`, `'No'`). |
| `dwh_create_date` | DATETIME2 | Audit | System loading timestamp. |

---

## 3. Gold Layer (Business Star Schema Views)
> **Note:** The Gold layer presents analytical views structured as a Dimensional Star Schema (Dimension Views and Fact View) ready for Power BI and SQL reporting.

### `gold.dim_customers`
- **Purpose:** Consolidated view combining customer demographics and location from CRM and ERP sources.

| Column Name | Data Type | Key Type | Description |
| :--- | :--- | :--- | :--- |
| `customer_key` | INT | Surrogate Key | Auto-generated surrogate primary key (`ROW_NUMBER()`). |
| `customer_id` | INT | Business Key | Natural customer identifier (`cst_id`). |
| `customer_number` | NVARCHAR(50) | Business Key | Unique alphanumeric tracking code (`cst_key`). |
| `first_name` | NVARCHAR(50) | - | Customer first name. |
| `last_name` | NVARCHAR(50) | - | Customer last name. |
| `country` | NVARCHAR(50) | - | Customer country of residence (joined from `erp_loc_a101`). |
| `marital_status` | NVARCHAR(50) | - | Customer marital status. |
| `gender` | NVARCHAR(50) | - | Consolidated gender (Mastered from CRM, fallback to ERP). |
| `birthdate` | DATE | - | Customer birth date (joined from `erp_cust_az12`). |
| `create_date` | DATE | - | Account creation date. |

### `gold.dim_products`
- **Purpose:** Dimension view containing active product catalog info and hierarchy classifications.

| Column Name | Data Type | Key Type | Description |
| :--- | :--- | :--- | :--- |
| `product_key` | INT | Surrogate Key | Auto-generated surrogate primary key (`ROW_NUMBER()`). |
| `product_id` | INT | Business Key | Natural product identifier (`prd_id`). |
| `product_number` | NVARCHAR(50) | Business Key | Alphanumeric product key (`prd_key`). |
| `product_name` | NVARCHAR(50) | - | Descriptive product name (`prd_nm`). |
| `category_id` | NVARCHAR(50) | FK | Category classification code (`cat_id`). |
| `category` | NVARCHAR(50) | - | High-level category name (joined from `erp_px_cat_g1v2`). |
| `subcategory` | NVARCHAR(50) | - | Subcategory name (joined from `erp_px_cat_g1v2`). |
| `maintenance` | NVARCHAR(50) | - | Maintenance indicator flag (`maintenance`). |
| `cost` | DECIMAL(10,2) | - | Base product cost (`prd_cost`). |
| `product_line` | NVARCHAR(50) | - | Product line series (e.g., `'Road'`, `'Mountain'`). |
| `start_date` | DATE | - | Product effective availability date (`prd_start_dt`). |

### `gold.fact_sales`
- **Purpose:** Fact view storing transactional sales events linked to Customer and Product dimension surrogate keys.

| Column Name | Data Type | Key Type | Description |
| :--- | :--- | :--- | :--- |
| `order_number` | NVARCHAR(50) | Transaction ID | Unique alphanumeric identifier for sales order. |
| `product_key` | INT | FK | Foreign key linking to `gold.dim_products.product_key`. |
| `customer_key` | INT | FK | Foreign key linking to `gold.dim_customers.customer_key`. |
| `order_date` | DATE | - | Transaction date when order was placed. |
| `shipping_date` | DATE | - | Date when order was shipped. |
| `due_date` | DATE | - | Payment due date. |
| `sales_amount` | DECIMAL(10,2) | Measure | Total sales value in monetary currency. |
| `quantity` | INT | Measure | Total number of item units ordered. |
| `price` | DECIMAL(10,2) | Measure | Unit price per item. |
