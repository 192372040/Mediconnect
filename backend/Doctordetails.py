from flask import request, jsonify
from db import get_db_connection
from datetime import datetime

def save_doctor_details():
    try:
        data = request.get_json() or {}

        email = data.get("email", "").strip() if data.get("email") else ""
        full_name = data.get("full_name", "").strip() if data.get("full_name") else ""
        age = data.get("age")
        gender = data.get("gender", "").strip() if data.get("gender") else ""
        phone = data.get("phone", "").strip() if data.get("phone") else ""
        dob_raw = data.get("dob")

        # Parse date of birth to YYYY-MM-DD
        dob = None
        if dob_raw:
            dob_str = str(dob_raw).strip()
            for fmt in (
                "%d %B %Y",
                "%d %b %Y",
                "%Y-%m-%d",
                "%d/%m/%Y",
                "%d-%m-%Y",
                "%m/%d/%Y",
                "%Y/%m/%d",
            ):
                try:
                    dob = datetime.strptime(dob_str, fmt).strftime("%Y-%m-%d")
                    break
                except ValueError:
                    pass

        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if a doctor with this email already exists
        cursor.execute("SELECT doctor_id FROM doctor_details WHERE email = %s", (email,))
        existing = cursor.fetchone()

        if existing:
            doctor_id = existing[0]
            query = """
            UPDATE doctor_details
            SET full_name = %s, age = %s, gender = %s, phone = %s, dob = %s
            WHERE doctor_id = %s
            """
            values = (full_name, age, gender, phone, dob, doctor_id)
            cursor.execute(query, values)
        else:
            cursor.execute("SELECT COUNT(*) FROM doctor_details")
            count = cursor.fetchone()[0] + 1
            doctor_id = f"MED-DOC-2026-{count:05d}"

            # Ensure uniqueness
            while True:
                cursor.execute("SELECT 1 FROM doctor_details WHERE doctor_id = %s", (doctor_id,))
                if cursor.fetchone():
                    count += 1
                    doctor_id = f"MED-DOC-2026-{count:05d}"
                else:
                    break

            query = """
            INSERT INTO doctor_details
            (
                doctor_id,
                email,
                full_name,
                age,
                gender,
                phone,
                dob
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            values = (
                doctor_id,
                email,
                full_name,
                age,
                gender,
                phone,
                dob
            )
            cursor.execute(query, values)

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            "message": "Doctor details saved",
            "doctor_id": doctor_id
        })

    except Exception as e:
        return jsonify({
            "error": str(e)
        })