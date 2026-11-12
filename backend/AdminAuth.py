import os
import random

from flask import request, jsonify

from db import get_db_connection

from flask_mail import Message
from extensions import mail


def send_admin_otp():

    try:

        data = request.get_json()

        email = data.get("email")

        otp = str(
            random.randint(
                100000,
                999999,
            )
        )

        conn = get_db_connection()

        cursor = conn.cursor()

        cursor.execute(
            "DELETE FROM otp_verification WHERE email=%s",
            (email,)
        )

        query = """
        INSERT INTO otp_verification
        (email, otp)
        VALUES (%s, %s)
        """

        cursor.execute(
            query,
            (email, otp)
        )

        conn.commit()

        msg = Message(
            'Admin OTP Verification',
            sender=os.environ.get('MAIL_USERNAME', 'varunprabha999@gmail.com'),
            recipients=[email]
        )
        msg.body = f"Your Admin OTP is {otp}"

        try:
            mail.send(msg)
        except Exception as mail_err:
            print(f"[WARNING] Admin Email Sending Failed (SMTP issues): {mail_err}")
            print(f"[DEV FALLBACK] Admin OTP for {email} is {otp}")
            cursor.close()
            conn.close()
            return jsonify({
                "message": f"OTP sent (Dev Fallback: {otp})"
            })

        cursor.close()
        conn.close()

        return jsonify({
            "message":
            "OTP sent successfully"
        })

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500