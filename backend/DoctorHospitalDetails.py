from flask import request, jsonify
from db import get_db_connection

def save_hospital_details():
    conn = None
    cursor = None
    try:
        data = request.get_json() or {}

        doctor_id = data.get("doctor_id")
        hospital_name = data.get("hospital_name")
        department = data.get("department")
        working_days = data.get("working_days") or []
        start_time = data.get("start_time")
        end_time = data.get("end_time")
        hospital_address = data.get("hospital_address")
        consultation_mode = data.get("consultation_mode") or []

        working_days_str = ",".join(working_days) if isinstance(working_days, list) else str(working_days or "")
        consultation_mode_str = ",".join(consultation_mode) if isinstance(consultation_mode, list) else str(consultation_mode or "")

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True, buffered=True)

        cursor.execute("SELECT id FROM doctor_hospital_details WHERE doctor_id = %s", (doctor_id,))
        existing = cursor.fetchone()

        if existing:
            query = """
            UPDATE doctor_hospital_details
            SET hospital_name = %s,
                department = %s,
                working_days = %s,
                start_time = %s,
                end_time = %s,
                hospital_address = %s,
                consultation_mode = %s
            WHERE doctor_id = %s
            """
            values = (
                hospital_name,
                department,
                working_days_str,
                start_time,
                end_time,
                hospital_address,
                consultation_mode_str,
                doctor_id
            )
            cursor.execute(query, values)
        else:
            query = """
            INSERT INTO doctor_hospital_details
            (
                doctor_id,
                hospital_name,
                department,
                working_days,
                start_time,
                end_time,
                hospital_address,
                consultation_mode
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            values = (
                doctor_id,
                hospital_name,
                department,
                working_days_str,
                start_time,
                end_time,
                hospital_address,
                consultation_mode_str
            )
            cursor.execute(query, values)

        conn.commit()
        return jsonify({
            "message": "Hospital details saved"
        }), 200

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500
    finally:
        if cursor:
            try:
                cursor.close()
            except Exception:
                pass
        if conn:
            try:
                conn.close()
            except Exception:
                pass