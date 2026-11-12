from flask import request, jsonify
from db import get_db_connection

def update_doctor_details():
    try:
        data = request.get_json()
        doctor_id = data.get("doctor_id")
        consultation_fee = data.get("consultation_fee")
        working_days = data.get("working_days")
        start_time = data.get("start_time")
        end_time = data.get("end_time")
        consultation_mode = data.get("consultation_mode")

        if not doctor_id:
            return jsonify({"success": False, "error": "Doctor ID is required"}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        # Update professional details (consultation fee)
        cursor.execute("SELECT COUNT(*) FROM doctor_professional_details WHERE doctor_id = %s", (doctor_id,))
        p_exists = cursor.fetchone()[0] > 0
        if not p_exists:
            cursor.execute(
                """
                INSERT INTO doctor_professional_details
                (doctor_id, consultation_fee, specialization, qualification, experience, license_number)
                VALUES (%s, %s, '', '', '', '')
                """,
                (doctor_id, consultation_fee)
            )
        else:
            cursor.execute(
                """
                UPDATE doctor_professional_details
                SET consultation_fee = %s
                WHERE doctor_id = %s
                """,
                (consultation_fee, doctor_id)
            )

        # Update hospital details (working days, timings, consultation mode)
        working_days_str = ",".join(working_days) if isinstance(working_days, list) else working_days
        consultation_mode_str = ",".join(consultation_mode) if isinstance(consultation_mode, list) else consultation_mode

        cursor.execute("SELECT COUNT(*) FROM doctor_hospital_details WHERE doctor_id = %s", (doctor_id,))
        h_exists = cursor.fetchone()[0] > 0
        if not h_exists:
            cursor.execute(
                """
                INSERT INTO doctor_hospital_details
                (doctor_id, working_days, start_time, end_time, consultation_mode, hospital_name, department, hospital_address)
                VALUES (%s, %s, %s, %s, %s, '', '', '')
                """,
                (doctor_id, working_days_str, start_time, end_time, consultation_mode_str)
            )
        else:
            cursor.execute(
                """
                UPDATE doctor_hospital_details
                SET working_days = %s, start_time = %s, end_time = %s, consultation_mode = %s
                WHERE doctor_id = %s
                """,
                (working_days_str, start_time, end_time, consultation_mode_str, doctor_id)
            )

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"success": True, "message": "Doctor details updated successfully"})

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
