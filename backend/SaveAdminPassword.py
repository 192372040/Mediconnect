from flask import request, jsonify

from db import get_db_connection


def save_admin_password():

    try:

        data = request.get_json()

        hospital_id = data.get(
            "hospital_id"
        )

        password = data.get(
            "password"
        )

        conn = get_db_connection()

        cursor = conn.cursor(
            dictionary=True
        )

        # CHECK PASSWORD
        cursor.execute(

            """
            SELECT *
            FROM admin_accounts
            WHERE password=%s
            """,

            (password,)
        )

        password_exists =cursor.fetchone()

        if password_exists:

            return jsonify({

                "error":
                "Try different password"

            })

        # SAVE ACCOUNT
        query = """
        INSERT INTO admin_accounts
        (
            hospital_id,
            password
        )

        VALUES (%s,%s)
        """

        cursor.execute(

            query,

            (
                hospital_id,
                password
            )
        )

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({

            "message":
            "Admin registered successfully"

        })

    except Exception as e:

        return jsonify({

            "error":
            str(e)

        })