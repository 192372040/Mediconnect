from flask import request, jsonify
from db import get_db_connection

def get_doctor_profile():
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
            d.full_name,
            d.doctor_id,
            d.email,
            d.age,
            d.gender,
            d.phone,
            d.dob,
            p.specialization,
            p.qualification,
            p.experience,
            p.license_number,
            p.consultation_fee,
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
        doctor = cursor.fetchone()

        if not doctor:
            return jsonify({"error": "Doctor not found"}), 404

        full_name = doctor.get("full_name") or ""

        # 1. Fetch dynamic hospital name and address
        cursor.execute(
            """
            SELECT ah.hospital_name, ah.hospital_address
            FROM hospital_doctors hd
            JOIN admin_hospitals ah ON hd.hospital_id = ah.hospital_id
            WHERE hd.doctor_id = %s
            LIMIT 1
            """,
            (doctor_id,)
        )
        h_info = cursor.fetchone()
        if h_info and h_info.get("hospital_name"):
            doctor["hospital_name"] = h_info["hospital_name"]
            doctor["hospital_address"] = h_info.get("hospital_address", "")
        else:
            doctor["hospital_name"] = "You are not currently associated with any hospital"
            doctor["hospital_address"] = ""

        # 2. Dynamic Patients Count
        cursor.execute(
            """
            SELECT COUNT(DISTINCT patient_email) AS count
            FROM appointments
            WHERE doctor_name = %s
            """,
            (full_name,)
        )
        patients = cursor.fetchone()
        doctor["patients_count"] = patients["count"] if patients else 0

        # 3. Dynamic Prescriptions Count
        cursor.execute(
            """
            SELECT COUNT(*) AS count
            FROM prescriptions
            WHERE doctor_name = %s
            """,
            (full_name,)
        )
        prescriptions = cursor.fetchone()
        doctor["prescriptions_count"] = prescriptions["count"] if prescriptions else 0

        # 4. Dynamic Rating
        cursor.execute(
            """
            SELECT ROUND(AVG(doctor_rating), 1) as avg_r
            FROM appointments
            WHERE doctor_name = %s AND doctor_rating IS NOT NULL
            """,
            (full_name,)
        )
        r_row = cursor.fetchone()
        if r_row and r_row["avg_r"] is not None:
            doctor["rating"] = str(r_row["avg_r"])
        else:
            doctor["rating"] = "4.8"

        # Format dob to string if it's a date
        if doctor.get("dob") and hasattr(doctor["dob"], "strftime"):
            doctor["dob"] = doctor["dob"].strftime("%Y-%m-%d")

        return jsonify(doctor), 200

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