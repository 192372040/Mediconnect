import os
import sys
# pyrefly: ignore [missing-import]
import mysql.connector

# Ensure we can import from the local directory
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from db import get_db_connection

def reset_database():
    print("Connecting to the database...")
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
    except Exception as e:
        print(f"Error connecting to database: {e}")
        print("Please check your database server status and connection details in db.py.")
        return

    # List of tables to empty
    tables = [
        "prescriptions",
        "appointments",
        "hospital_beds",
        "hospital_doctors",
        "doctor_hospital_details",
        "doctor_professional_details",
        "doctor_details",
        "doctor_login",
        "admin_hospitals",
        "admin_accounts",
        "otp_verification",
        "users"  # Patient accounts
    ]

    print("\nStarting database reset...")
    try:
        # Disable foreign key checks to allow truncating tables with relationships
        cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
        
        for table in tables:
            try:
                print(f" - Emptying table: {table}")
                cursor.execute(f"TRUNCATE TABLE `{table}`;")
            except mysql.connector.Error as err:
                # Fallback to DELETE FROM if TRUNCATE is restricted
                print(f"   (Truncate failed, falling back to DELETE FROM): {err}")
                cursor.execute(f"DELETE FROM `{table}`;")
        
        # Re-enable foreign key checks
        cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
        conn.commit()
        print("\nSuccess! Database has been reset. All accounts and related data have been cleared.")
        print("You can now proceed with registering new accounts.")

    except Exception as e:
        print(f"\nAn error occurred during database reset: {e}")
        try:
            cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
        except:
            pass
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    reset_database()
