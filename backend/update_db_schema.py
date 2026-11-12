# pyrefly: ignore [missing-import]
import mysql.connector
import os
import sys

# Ensure we can import from db.py
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from db import get_db_connection

def migrate_database():
    print("Connecting to the database for schema update...")
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Check if doctor_rating column already exists
        cursor.execute("DESCRIBE `appointments`")
        columns = [col[0] for col in cursor.fetchall()]
        
        if "doctor_rating" not in columns:
            print("Adding 'doctor_rating' column to 'appointments' table...")
            cursor.execute("ALTER TABLE `appointments` ADD COLUMN `doctor_rating` INT DEFAULT NULL")
            conn.commit()
            print("Successfully added 'doctor_rating' column.")
        else:
            print("'doctor_rating' column already exists in 'appointments' table.")
            
        cursor.close()
        conn.close()
        print("Database migration completed.")
    except Exception as e:
        print(f"Error during migration: {e}")

if __name__ == "__main__":
    migrate_database()
