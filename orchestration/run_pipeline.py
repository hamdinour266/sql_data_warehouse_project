import datetime
import time
from db_connector import DatabaseConnector

def run_data_pipeline():
    db = DatabaseConnector()
    pipeline_start_time = time.time()
    
    print("=" * 60)
    print("Starting Medallion Data Pipeline Batch Load")
    print(f"Start Time: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

    try:
        # Step 1: Execute Bronze Layer Load (Raw Data Bulk Ingestion)
        print("\n--- 1. BRONZE LAYER ---")
        bronze_start = time.time()
        db.execute_procedure("bronze.load_bronze")
        print(f"Bronze Layer Execution Duration: {round(time.time() - bronze_start, 2)}s")

        # Step 2: Execute Silver Layer Load (Cleansing & Transformations)
        print("\n--- 2. SILVER LAYER ---")
        silver_start = time.time()
        db.execute_procedure("silver.load_silver")
        print(f"Silver Layer Execution Duration: {round(time.time() - silver_start, 2)}s")

        # Step 3: Pipeline Completion Summary
        total_duration = round(time.time() - pipeline_start_time, 2)
        print("\n" + "=" * 60)
        print("PIPELINE EXECUTED SUCCESSFULLY!")
        print(f"Total Batch Duration: {total_duration} seconds")
        print(f"End Time: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 60)

    except Exception as e:
        print("\n" + "!" * 60)
        print(f"PIPELINE FAILED WITH ERROR: {e}")
        print("!" * 60)

if __name__ == "__main__":
    run_data_pipeline()