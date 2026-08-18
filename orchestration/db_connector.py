import pyodbc
from config import DB_CONFIG

class DatabaseConnector:
    def __init__(self):
        self.connection_string = (
            f"DRIVER={{{DB_CONFIG['driver']}}};"
            f"SERVER={DB_CONFIG['server']};"
            f"DATABASE={DB_CONFIG['database']};"
            f"Trusted_Connection={DB_CONFIG['trusted_connection']};"
        )

    def get_connection(self):
        try:
            conn = pyodbc.connect(self.connection_string, autocommit=True)
            return conn
        except pyodbc.Error as e:
            print(f"Database Connection Error: {e}")
            raise

    def execute_procedure(self, proc_name: str):
        conn = self.get_connection()
        cursor = conn.cursor()
        try:
            print(f"Executing Stored Procedure: {proc_name}...")
            cursor.execute(f"EXEC {proc_name}")
            print(f"Successfully executed {proc_name}!")
        except pyodbc.Error as e:
            print(f"Error executing {proc_name}: {e}")
            raise
        finally:
            cursor.close()
            conn.close()