from flask import request, jsonify
from db import get_db_connection

def get_hospital_doctors():

    try:

        hospital_id = request.args.get(
            "hospital_id"
        )

        conn = get_db_connection()

        cursor = conn.cursor(
            dictionary=True
        )

        cursor.execute(
            """
            SELECT
                d.doctor_id,
                d.full_name,
                p.specialization
            FROM hospital_doctors h

            JOIN doctor_details d
            ON h.doctor_id = d.doctor_id

            LEFT JOIN doctor_professional_details p
            ON d.doctor_id = p.doctor_id

            WHERE h.hospital_id = %s
            """,
            (hospital_id,)
        )

        doctors = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify(doctors)

    except Exception as e:

        return jsonify({
            "error": str(e)
        })