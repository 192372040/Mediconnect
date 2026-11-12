from flask import request, jsonify
from db import get_db_connection

def get_patient_profile():
    conn = None
    cursor = None
    try:
        email = request.args.get("email", "").strip() if request.args.get("email") else ""
        if not email:
            return jsonify({"error": "email is required"}), 400

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True, buffered=True)

        cursor.execute(
            "SELECT * FROM users WHERE email=%s LIMIT 1",
            (email,)
        )
        patient = cursor.fetchone()

        if patient:
            return jsonify(patient), 200
        else:
            return jsonify({"error": "Patient not found"}), 404

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