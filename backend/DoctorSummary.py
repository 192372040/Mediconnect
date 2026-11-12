from flask import request, jsonify
from db import get_db_connection

def get_doctor_summary():
    conn = None
    cursor = None
    try:
        doctor_id = request.args.get("doctor_id", "").strip() if request.args.get("doctor_id") else ""

        if not doctor_id:
            return jsonify({"error": "doctor_id is required"}), 400

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True, buffered=True)

        query = """
        SELECT
            d.doctor_id,
            d.full_name,
            d.email,
            d.phone,
            p.specialization,
            p.qualification,
            p.experience,
            p.license_number,
            p.consultation_fee,
            h.hospital_name,
            h.department,
            h.working_days,
            h.start_time,
            h.end_time,
            h.consultation_mode
        FROM doctor_details d
        LEFT JOIN (
            SELECT * FROM doctor_professional_details
            WHERE doctor_id = %s
            ORDER BY id DESC LIMIT 1
        ) p ON d.doctor_id = p.doctor_id
        LEFT JOIN (
            SELECT * FROM doctor_hospital_details
            WHERE doctor_id = %s
            ORDER BY id DESC LIMIT 1
        ) h ON d.doctor_id = h.doctor_id
        WHERE d.doctor_id = %s
        LIMIT 1
        """

        cursor.execute(query, (doctor_id, doctor_id, doctor_id))
        data = cursor.fetchone()

        if not data:
            return jsonify({"error": "Doctor not found"}), 404

        # Clean null values to empty strings or defaults
        for k, v in data.items():
            if v is None:
                data[k] = ""

        return jsonify(data), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
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