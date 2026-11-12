from flask import request, jsonify

from db import get_db_connection


def save_admin_hospital():

    try:

        data = request.get_json()

        admin_email = data.get(
            "admin_email"
        )

        hospital_id = data.get(
            "hospital_id"
        )

        conn = get_db_connection()

        cursor = conn.cursor(
            dictionary=True
        )

        # CHECK EMAIL
        cursor.execute(

            """
            SELECT *
            FROM admin_hospitals
            WHERE admin_email=%s
            """,

            (admin_email,)
        )

        email_exists =cursor.fetchone()

        if email_exists:

            return jsonify({

                "error":
                "Email already registered"

            })

        # CHECK HOSPITAL ID
        cursor.execute(

            """
            SELECT *
            FROM admin_hospitals
            WHERE hospital_id=%s
            """,

            (hospital_id,)
        )

        hospital_exists = cursor.fetchone()

        if hospital_exists:

            return jsonify({

                "error":
                "Hospital ID already registered"

            })

        # INSERT
        query = """
        INSERT INTO admin_hospitals
        (
            admin_email,
            hospital_name,
            admin_name,
            hospital_address,
            hospital_type,
            established_year,
            hospital_id
        )

        VALUES (%s,%s,%s,%s,%s,%s,%s)
        """

        cursor.execute(

            query,

            (
                data.get("admin_email"),
                data.get("hospital_name"),
                data.get("admin_name"),
                data.get("hospital_address"),
                data.get("hospital_type"),
                data.get("established_year"),
                data.get("hospital_id")
            )
        )

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({

            "message":
            "Hospital details saved"

        })

    except Exception as e:

        return jsonify({

            "error":
            str(e)

        })