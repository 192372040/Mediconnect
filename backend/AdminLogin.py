from flask import request, jsonify

from db import get_db_connection


def admin_login():

    try:

        data = request.get_json()

        hospital_id =data.get("hospital_id")

        password =data.get("password")

        conn =get_db_connection()

        cursor =conn.cursor(
            dictionary=True
        )

        query = """
        SELECT *
        FROM admin_accounts
        WHERE hospital_id=%s
        AND password=%s
        """

        cursor.execute(

            query,

            (
                hospital_id,
                password
            )
        )

        admin =cursor.fetchone()

        cursor.close()
        conn.close()

        if admin:

            return jsonify({

                "message":
                "Login successful"

            })

        else:

            return jsonify({

                "error":
                "Invalid Hospital ID or Password"

            })

    except Exception as e:

        return jsonify({

            "error":
            str(e)

        })