from flask import request, jsonify
from db import get_db_connection

def add_doctor_to_hospital():

    try:

        data = request.get_json()

        hospital_id = data.get("hospital_id")
        doctor_id = data.get("doctor_id")

        conn = get_db_connection()

        cursor = conn.cursor(dictionary=True)

        # CHECK DOCTOR EXISTS
        cursor.execute(
            """
            SELECT *
            FROM doctor_details
            WHERE doctor_id=%s
            """,
            (doctor_id,)
        )

        doctor = cursor.fetchone()

        if not doctor:

            return jsonify({
                "error": "Doctor not found"
            })

        # CHECK ALREADY ADDED
        cursor.execute(
            """
            SELECT *
            FROM hospital_doctors
            WHERE hospital_id=%s
            AND doctor_id=%s
            """,
            (hospital_id, doctor_id)
        )

        exists = cursor.fetchone()

        if exists:

            return jsonify({
                "error": "Doctor already added"
            })

        # INSERT
        cursor.execute(
            """
            INSERT INTO hospital_doctors
            (
                hospital_id,
                doctor_id
            )
            VALUES (%s,%s)
            """,
            (
                hospital_id,
                doctor_id
            )
        )

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "message": "Doctor added successfully"
        })

    except Exception as e:

        return jsonify({
            "error": str(e)
        })