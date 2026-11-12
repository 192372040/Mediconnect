from flask import request, jsonify
from db import get_db_connection
from flask_mail import Message
from extensions import mail


def forgot_doctor_id():

    data = request.json

    email = data["email"]

    conn = get_db_connection()

    cursor = conn.cursor(dictionary=True)

    query = """
    SELECT doctor_id
    FROM doctor_details

    WHERE email = %s
    """

    cursor.execute(
        query,
        (email,)
    )

    doctor = cursor.fetchone()

    cursor.close()
    conn.close()

    if doctor:

        doctor_id = doctor["doctor_id"]

        msg = Message(

            "Your Doctor ID",

            sender=
            "varunprabha999@gmail.com",

            recipients=[email],
        )

        msg.body = f"""
Your Doctor ID is:

{doctor_id}

-MediConnect
"""

        mail.send(msg)

        return jsonify({
            "message":
            "Doctor ID sent to email"
        })

    else:

        return jsonify({
            "error":
            "Email not found"
        })