from flask import request, jsonify

from db import get_db_connection


def verify_hospital_id():

    try:

        data = request.get_json()

        hospital_id = data.get(
            "hospital_id"
        )

        conn = get_db_connection()

        cursor = conn.cursor(
            dictionary=True
        )

        query = """
        SELECT * FROM admin_hospitals
        WHERE hospital_id=%s
        """

        cursor.execute(
            query,
            (hospital_id,)
        )

        hospital = cursor.fetchone()

        cursor.close()
        conn.close()

        if hospital:

            return jsonify({
                "error":
                "Hospital ID already registered"
            })

        else:

            return jsonify({
                "message":
                "Hospital verified"
            })

    except Exception as e:

        return jsonify({
            "error":
            str(e)
        })