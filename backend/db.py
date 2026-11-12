import os
# pyrefly: ignore [missing-import]
import mysql.connector

def get_db_connection():
    connection = mysql.connector.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        user=os.environ.get("DB_USER", "root"),
        password=os.environ.get("DB_PASSWORD", "your_actual_password"),
        database=os.environ.get("DB_NAME", "flutter_app")
    )
    return connection
