from flask import request, jsonify
from db import get_db_connection

def get_doctor_appointments():

    try:

        doctor_name = request.args.get(
            "doctor_name"
        )
        print("DOCTOR NAME =", doctor_name)
        conn = get_db_connection()

        cursor = conn.cursor(
            dictionary=True
        )

        cursor.execute(
            """
            SELECT *
            FROM appointments
            WHERE LOWER(TRIM(doctor_name)) = LOWER(TRIM(%s))
            ORDER BY appointment_date
            """,
            (doctor_name,)
        )

        data = cursor.fetchall()

        cursor.close()
        conn.close()

        # Format appointment_date to standard YYYY-MM-DD string
        for row in data:
            if "appointment_date" in row and row["appointment_date"] is not None:
                row["appointment_date"] = str(row["appointment_date"])

        return jsonify(data)

    except Exception as e:

        return jsonify({
            "error": str(e)
        })

def delete_appointment():
    try:
        data = request.get_json(silent=True) or {}
        appointment_id = data.get("appointment_id") or request.args.get("appointment_id")
        if not appointment_id:
            return jsonify({"success": False, "error": "appointment_id is required"}), 400

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM appointments WHERE id = %s", (appointment_id,))
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"success": True, "message": "Appointment deleted successfully"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500