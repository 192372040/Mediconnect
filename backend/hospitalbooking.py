from flask import jsonify, request
from db import get_db_connection

def get_hospitals():

    try:

        conn = get_db_connection()

        cursor = conn.cursor(
            dictionary=True
        )

        query = """
        SELECT
            hospital_id AS id,
            hospital_name AS name,
            hospital_type AS type,
            hospital_address,
            'Open 24/7' AS status,
            COALESCE(
                (
                    SELECT ROUND(AVG(a.doctor_rating), 1)
                    FROM appointments a
                    JOIN doctor_details d ON a.doctor_name = d.full_name
                    JOIN hospital_doctors hd ON d.doctor_id = hd.doctor_id
                    WHERE hd.hospital_id = admin_hospitals.hospital_id AND a.doctor_rating IS NOT NULL
                ),
                '4.8'
            ) AS rating,
            1 AS online,
            1 AS emergency,
            1 AS top_rated,
            0 AS latitude,
            0 AS longitude,
            '0 km' AS distance
        FROM admin_hospitals
        """

        cursor.execute(query)

        hospitals = cursor.fetchall()

        cursor.close()
        conn.close()
        print(hospitals)
        return jsonify(
            hospitals
        )

    except Exception as e:

        return jsonify({
            "error": str(e)
        })
from flask import jsonify
from db import get_db_connection

def get_doctors(hospital_id):

    try:

        conn = get_db_connection()

        cursor = conn.cursor(
            dictionary=True
        )

        query = """
        SELECT
            d.full_name AS name,
            p.specialization,
            p.experience,
            p.consultation_fee AS fee,
            COALESCE(
                (
                    SELECT ROUND(AVG(doctor_rating), 1)
                    FROM appointments
                    WHERE doctor_name = d.full_name AND doctor_rating IS NOT NULL
                ),
                '4.8'
            ) AS rating,
            '09:00 AM,10:00 AM,11:00 AM,02:00 PM' AS available_slots
        FROM hospital_doctors h
        JOIN doctor_details d
            ON h.doctor_id = d.doctor_id
        JOIN doctor_professional_details p
            ON d.doctor_id = p.doctor_id
        WHERE h.hospital_id = %s
        """

        cursor.execute(
            query,
            (hospital_id,)
        )

        doctors = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify(
            doctors
        )

    except Exception as e:

        return jsonify({
            "error": str(e)
        })
    

def book_appointment():
    try:
        data = request.get_json()

        patient_email = data.get("patient_email")
        patient_name = data.get("patient_name")
        doctor_name = data.get("doctor_name")
        specialization = data.get("specialization")
        hospital_name = data.get("hospital_name")
        appointment_slot = data.get("appointment_slot")
        payment_method = data.get("payment_method")
        consultation_fee = data.get("consultation_fee")
        appointment_date = data.get("appointment_date")

        conn = get_db_connection()
        cursor = conn.cursor()

        # ✅ CHECK SLOT
        check_query = """
        SELECT * FROM appointments
        WHERE doctor_name = %s
        AND appointment_slot = %s
        AND appointment_date = %s
        """

        check_values = (
            doctor_name,
            appointment_slot,
            appointment_date
        )

        cursor.execute(check_query, check_values)

        existing_booking = cursor.fetchone()

        if existing_booking:
            cursor.close()
            conn.close()

            return jsonify({
                "error": "Slot already booked"
            })

        # ✅ INSERT BOOKING
        query = """
        INSERT INTO appointments
        (
            patient_email,
             patient_name,
            doctor_name,
            specialization,
            hospital_name,
            appointment_slot,
            payment_method,
            consultation_fee,
            appointment_date,
           payment_status,
booking_status
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """

        values = (
            patient_email,
            patient_name,
            doctor_name,
            specialization,
            hospital_name,
            appointment_slot,
            payment_method,
            consultation_fee,
            appointment_date,
            "Paid",
            "Confirmed"
        )

        cursor.execute(query, values)

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Payment successful",
              "booking_status": "Confirmed"

        })

    except Exception as e:
        return jsonify({"error": str(e)})
def get_booked_slots():
    try:
        doctor_name = request.args.get("doctor_name")
        appointment_date = request.args.get("appointment_date")

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
        SELECT appointment_slot
        FROM appointments
        WHERE doctor_name = %s
        AND appointment_date = %s
        """

        values = (
            doctor_name,
            appointment_date
        )

        cursor.execute(query, values)

        slots = cursor.fetchall()

        cursor.close()
        conn.close()

        booked_slots = [
            slot["appointment_slot"]
            for slot in slots
        ]

        return jsonify(booked_slots)

    except Exception as e:
        return jsonify({"error": str(e)})
def get_patient_appointments():

    try:

        patient_email = request.args.get("patient_email")

        conn = get_db_connection()

        cursor = conn.cursor(dictionary=True)

        query = """
        SELECT *
        FROM appointments
        WHERE patient_email = %s
        ORDER BY id DESC
        """

        cursor.execute(
            query,
            (patient_email,)
        )

        appointments = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "appointments": appointments
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "error": str(e)
        })

def update_appointment_status():
    try:
        data = request.get_json()
        appointment_id = data.get("appointment_id")
        status = data.get("status")
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        query = """
        UPDATE appointments
        SET booking_status = %s
        WHERE id = %s
        """
        cursor.execute(query, (status, appointment_id))
        conn.commit()
        
        cursor.close()
        conn.close()
        
        return jsonify({"success": True, "message": f"Appointment status updated to {status}"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})