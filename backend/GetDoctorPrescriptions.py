from flask import request, jsonify
from db import get_db_connection

def get_doctor_prescriptions():
    try:
        doctor_name = request.args.get("doctor_name")
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        if doctor_name:
            cursor.execute("""
                SELECT *
                FROM prescriptions
                WHERE LOWER(TRIM(doctor_name)) = LOWER(TRIM(%s))
                ORDER BY id DESC
            """, (doctor_name,))
        else:
            cursor.execute("""
                SELECT *
                FROM prescriptions
                ORDER BY id DESC
            """)

        prescriptions = cursor.fetchall()
        cursor.close()
        conn.close()

        for rx in prescriptions:
            if "created_at" in rx and rx["created_at"] is not None:
                rx["created_at"] = str(rx["created_at"])

        return jsonify(prescriptions)

    except Exception as e:
        return jsonify({"error": str(e)}), 500
