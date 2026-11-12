from flask import request, jsonify
from db import get_db_connection

def save_professional_details():
    conn = None
    cursor = None
    try:
        data = request.get_json() or {}

        doctor_id = data.get("doctor_id", "").strip() if data.get("doctor_id") else ""
        qualification = data.get("qualification", "").strip() if data.get("qualification") else ""
        specialization = data.get("specialization", "").strip() if data.get("specialization") else ""
        experience = data.get("experience", "").strip() if data.get("experience") else ""
        license_number = data.get("license_number", "").strip() if data.get("license_number") else ""
        consultation_fee = data.get("consultation_fee", "").strip() if data.get("consultation_fee") else ""

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True, buffered=True)

        # 1. VERIFY DOCTOR EXISTS
        cursor.execute(
            """
            SELECT full_name
            FROM doctor_details
            WHERE doctor_id = %s
            """,
            (doctor_id,)
        )

        doctor = cursor.fetchone()
        if doctor is None:
            return jsonify({"error": "Doctor not found"}), 404

        # 2. CHECK DUPLICATE LICENSE (only flag if used by a DIFFERENT doctor)
        if license_number:
            cursor.execute(
                """
                SELECT doctor_id
                FROM doctor_professional_details
                WHERE license_number = %s
                """,
                (license_number,)
            )

            existing_license = cursor.fetchone()
            if existing_license and existing_license["doctor_id"] != doctor_id:
                return jsonify({"error": "This license number is already registered to another doctor"}), 400

        # 3. UPSERT: Update existing record or insert new one
        cursor.execute(
            """
            SELECT id
            FROM doctor_professional_details
            WHERE doctor_id = %s
            """,
            (doctor_id,)
        )
        existing_record = cursor.fetchone()

        if existing_record:
            query = """
            UPDATE doctor_professional_details
            SET qualification = %s,
                specialization = %s,
                experience = %s,
                license_number = %s,
                consultation_fee = %s
            WHERE doctor_id = %s
            """
            values = (
                qualification,
                specialization,
                experience,
                license_number,
                consultation_fee,
                doctor_id,
            )
            cursor.execute(query, values)
        else:
            query = """
            INSERT INTO doctor_professional_details
            (
                doctor_id,
                qualification,
                specialization,
                experience,
                license_number,
                consultation_fee
            )
            VALUES (%s, %s, %s, %s, %s, %s)
            """
            values = (
                doctor_id,
                qualification,
                specialization,
                experience,
                license_number,
                consultation_fee,
            )
            cursor.execute(query, values)

        conn.commit()
        return jsonify({"message": "Professional details saved"}), 200

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
