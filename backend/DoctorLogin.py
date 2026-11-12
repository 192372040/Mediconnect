from flask import request, jsonify
from db import get_db_connection

def doctor_login():
    conn = None
    cursor = None
    try:
        data = request.get_json() or {}

        doctor_id = data.get("doctor_id", "").strip() if data.get("doctor_id") else ""
        password = data.get("password", "").strip() if data.get("password") else ""

        if not doctor_id or not password:
            return jsonify({"error": "Doctor ID and password are required"}), 400

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True, buffered=True)

        query = """
        SELECT *
        FROM doctor_login
        WHERE doctor_id = %s
        AND password = %s
        """
        cursor.execute(query, (doctor_id, password))
        doctor = cursor.fetchone()

        if doctor:
            return jsonify({
                "message": "Login success",
                "doctor_id": doctor_id
            }), 200

        # Check if the doctor ID exists but password hasn't been set yet
        cursor.execute("SELECT doctor_id FROM doctor_details WHERE doctor_id = %s", (doctor_id,))
        doc_exists = cursor.fetchone()

        if doc_exists:
            cursor.execute("SELECT doctor_id FROM doctor_login WHERE doctor_id = %s", (doctor_id,))
            login_exists = cursor.fetchone()
            if not login_exists:
                return jsonify({
                    "error": "Password not set for this account yet. Please create a password first."
                }), 400

        return jsonify({
            "error": "Invalid credentials"
        }), 401

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