from flask import request, jsonify
from db import get_db_connection

def rate_doctor():
    try:
        data = request.get_json()
        appointment_id = data.get("appointment_id")
        rating = data.get("rating")
        
        if not appointment_id or rating is None:
            return jsonify({"success": False, "error": "appointment_id and rating are required"}), 400
            
        try:
            rating_val = int(rating)
            if rating_val < 1 or rating_val > 5:
                return jsonify({"success": False, "error": "Rating must be between 1 and 5"}), 400
        except ValueError:
            return jsonify({"success": False, "error": "Rating must be an integer"}), 400
            
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Update doctor_rating in appointments
        cursor.execute(
            """
            UPDATE appointments
            SET doctor_rating = %s
            WHERE id = %s
            """,
            (rating_val, appointment_id)
        )
        conn.commit()
        
        affected = cursor.rowcount
        
        cursor.close()
        conn.close()
        
        if affected == 0:
            return jsonify({"success": False, "error": "Appointment not found"}), 404
            
        return jsonify({"success": True, "message": "Rating submitted successfully"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
