from flask import request, jsonify
from db import get_db_connection


def save_password():

    data = request.json

    doctor_id = data["doctor_id"]
    password = data["password"]

    conn = get_db_connection()

    cursor = conn.cursor()

    query = """
    INSERT INTO doctor_login
    (
        doctor_id,
        password
    )

    VALUES
    (
        %s,
        %s
    )
    """

    cursor.execute(
        query,
        (
            doctor_id,
            password,
        )
    )

    conn.commit()

    cursor.close()
    conn.close()

    return jsonify({
        "message": "Password saved"
    })