from flask import request, jsonify
from db import get_db_connection

def save_password():
    conn = None
    cursor = None
    try:
        data = request.get_json() or {}

        doctor_id = data.get("doctor_id")
        password = data.get("password")

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True, buffered=True)

        cursor.execute("SELECT doctor_id FROM doctor_login WHERE doctor_id = %s", (doctor_id,))
        existing = cursor.fetchone()

        if existing:
            cursor.execute(
                "UPDATE doctor_login SET password = %s WHERE doctor_id = %s",
                (password, doctor_id)
            )
        else:
            query = """
            INSERT INTO doctor_login
            (
                doctor_id,
                password
            )
            VALUES (%s, %s)
            """
            cursor.execute(query, (doctor_id, password))

        conn.commit()
        return jsonify({
            "message": "Password saved"
        }), 200

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500
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