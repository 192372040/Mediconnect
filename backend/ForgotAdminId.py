from flask import request, jsonify
from db import get_db_connection
from flask_mail import Message
from extensions import mail

def forgot_admin_id():
    data = request.json
    email = data.get("email")
    if not email:
        return jsonify({"error": "Email is required"}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
    SELECT hospital_id
    FROM admin_hospitals
    WHERE admin_email = %s
    """

    cursor.execute(query, (email,))
    admin = cursor.fetchone()

    cursor.close()
    conn.close()

    if admin:
        hospital_id = admin["hospital_id"]
        try:
            msg = Message(
                "Your Admin/Hospital ID",
                sender="varunprabha999@gmail.com",
                recipients=[email],
            )
            msg.body = f"Your Admin ID (Hospital ID) is:\n\n{hospital_id}\n\n-MediConnect"
            mail.send(msg)
            return jsonify({"message": "Admin ID sent to email"})
        except Exception as e:
            return jsonify({"error": f"Failed to send email: {str(e)}"}), 500
    else:
        return jsonify({"error": "Mail not registered"}), 404
