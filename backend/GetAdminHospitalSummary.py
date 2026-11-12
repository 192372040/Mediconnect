from flask import request, jsonify

from db import get_db_connection


def get_admin_hospital_summary():

    try:

        hospital_id = request.args.get(
            "hospital_id"
        )

        conn =get_db_connection()

        cursor =conn.cursor(
            dictionary=True
        )

        query = """
        SELECT *
        FROM admin_hospitals
        WHERE hospital_id=%s
        """

        cursor.execute(
            query,
            (hospital_id,)
        )

        hospital =cursor.fetchone()

        cursor.close()
        conn.close()

        if hospital:

            return jsonify({

                "hospital":
                hospital

            })

        else:

            return jsonify({

                "error":
                "Hospital not found"

            })

    except Exception as e:

        return jsonify({

            "error":
            str(e)

        })