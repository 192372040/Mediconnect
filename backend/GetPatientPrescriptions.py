from flask import request, jsonify
from db import get_db_connection

def get_patient_prescriptions():

    email = request.args.get("email")

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT *
        FROM prescriptions
        WHERE patient_email=%s
        ORDER BY id DESC
    """, (email,))

    prescriptions = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify(prescriptions)