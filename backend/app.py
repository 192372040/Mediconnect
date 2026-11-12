import os
# pyrefly: ignore [missing-import]
from dotenv import load_dotenv
load_dotenv()

from extensions import mail
from auth import send_otp, verify_otp
from GetPatientPrescriptions import get_patient_prescriptions
from DoctorAppointments import get_doctor_appointments, delete_appointment
from GetDoctorPrescriptions import get_doctor_prescriptions
from db import get_db_connection

from flask import Flask
from AiChat import ai_chat
from flask_cors import CORS
from AdminLogin import admin_login
from SavePrescription import save_prescription
from ForgotDoctorId import forgot_doctor_id
from DoctorSummary import get_doctor_summary
from auth import update_profile, delete_account
from DoctorPassword import save_password
from add_doctor_to_hospital import add_doctor_to_hospital
from VerifyHospitalId import verify_hospital_id
from GetAdminHospitalSummary import get_admin_hospital_summary
from DoctorLogin import doctor_login
from SaveAdminPassword import save_admin_password
from DoctorProfessionalDetails import save_professional_details
from DoctorHospitalDetails import save_hospital_details
from DoctorProfile import get_doctor_profile
from AdminAuth import send_admin_otp
from SaveAdminHospital import save_admin_hospital
from get_hospital_doctors import get_hospital_doctors
from UpdateDoctorDetails import update_doctor_details
from GetPatientProfile import get_patient_profile
from hospitalbooking import (
    get_hospitals,
    get_doctors,
    book_appointment,
    get_booked_slots,
    get_patient_appointments,
    update_appointment_status
)
from AdminHospitalAPIs import (
    get_hospital_appointments,
    get_hospital_beds,
    update_hospital_beds,
    get_hospital_analytics
)
from Doctordetails import save_doctor_details

app = Flask(__name__)
CORS(app)
app.config['MAIL_SERVER'] = os.environ.get('MAIL_SERVER', 'smtp.gmail.com')
app.config['MAIL_PORT'] = int(os.environ.get('MAIL_PORT', 587))
app.config['MAIL_USE_TLS'] = os.environ.get('MAIL_USE_TLS', 'True').lower() == 'true'
app.config['MAIL_USERNAME'] = os.environ.get('MAIL_USERNAME', 'varunprabha999@gmail.com')
app.config['MAIL_PASSWORD'] = os.environ.get('MAIL_PASSWORD', 'zthdobkvqhlvqxmj')
mail.init_app(app)
@app.route("/")
def home():
    return "Backend running successfully!"
@app.route("/test-db")
def test_db():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT DATABASE();")
        result = cursor.fetchone()

        cursor.close()
        conn.close()

        return f"Connected to database: {result[0]}"

    except Exception as e:
        return str(e)
    
@app.route("/send-otp", methods=["POST"])
def send_otp_route():
    return send_otp()
@app.route("/verify-otp", methods=["POST"])
def verify_otp_route():
    return verify_otp()
@app.route("/update-profile", methods=["POST"])
def update_profile_route():
    return update_profile()

@app.route("/hospitals", methods=["GET"])
def hospitals_route():
    return get_hospitals()
@app.route("/doctors/<int:hospital_id>", methods=["GET"])
def doctors_route(hospital_id):
    return get_doctors(hospital_id)
@app.route("/book-appointment", methods=["POST"])
def book_appointment_route():
    return book_appointment()
@app.route("/booked-slots", methods=["GET"])
def booked_slots_route():
    return get_booked_slots()
@app.route(
    "/save-doctor-details",
    methods=["POST"]
)
def save_doctor_details_route():

    return save_doctor_details()
@app.route(
    "/save-hospital-details",
    methods=["POST"]
)
def save_hospital_details_route():

    return save_hospital_details()
@app.route(
    "/get-doctor-summary",
    methods=["GET"]
)
def get_doctor_summary_route():

    return get_doctor_summary()
@app.route(
    "/save-professional-details",
    methods=["POST"]
)
def save_professional_details_route():

    return save_professional_details()
@app.route(
    "/get-doctor-profile",
    methods=["GET"]
)
def get_doctor_profile_route():

    return get_doctor_profile()
@app.route(
    "/save-password",
    methods=["POST"]
)
def save_password_route():

    return save_password()
@app.route(
    "/doctor-login",
    methods=["POST"]
)
def doctor_login_route():

    return doctor_login()
@app.route(
    "/forgot-doctor-id",
    methods=["POST"]
)
def forgot_doctor_id_route():

    return forgot_doctor_id()
@app.route(
    "/send-admin-otp",
    methods=["POST"]
)
def send_admin_otp_route():

    return send_admin_otp()
@app.route(
    "/save-admin-hospital",
    methods=["POST"]
)
def save_admin_hospital_route():

    return save_admin_hospital()
@app.route(
    "/verify-hospital-id",
    methods=["POST"]
)
def verify_hospital_id_route():

    return verify_hospital_id()
@app.route(
    "/save-admin-password",
    methods=["POST"]
)
def save_admin_password_route():

    return save_admin_password()
@app.route(
    "/get-admin-hospital-summary",
    methods=["GET"]
)
def get_admin_hospital_summary_route():

    return get_admin_hospital_summary()
@app.route(
    "/admin-login",
    methods=["POST"],
)
def admin_login_route():
    return admin_login()

from ForgotAdminId import forgot_admin_id

@app.route("/forgot-admin-id", methods=["POST"])
def forgot_admin_id_route():
    return forgot_admin_id()

app.add_url_rule(
    "/add-doctor-to-hospital",
    "add_doctor_to_hospital",
    add_doctor_to_hospital,
    methods=["POST"]
)
app.add_url_rule(
    "/get-hospital-doctors",
    "get_hospital_doctors",
    get_hospital_doctors,
    methods=["GET"]
)
@app.route(
    "/get-doctor-appointments",
    methods=["GET"]
)
def get_doctor_appointments_route():

    return get_doctor_appointments()
@app.route(
    "/save-prescription",
    methods=["POST"]
)
def save_prescription_route():

    return save_prescription()
@app.route(
    "/get-patient-profile",
    methods=["GET"]
)
def get_patient_profile_route():

    return get_patient_profile()
@app.route(
    "/get-patient-prescriptions",
    methods=["GET"]
)
def get_patient_prescriptions_route():

    return get_patient_prescriptions()
@app.route(
    "/ai-chat",
    methods=["POST"]
)

def ai_chat_route():

    return ai_chat()
@app.route(
    "/get-patient-appointments",
    methods=["GET"]
)
def get_patient_appointments_route():

    return get_patient_appointments()

@app.route(
    "/delete-account",
    methods=["POST"]
)
def delete_account_route():
    return delete_account()

@app.route(
    "/update-appointment-status",
    methods=["POST"]
)
def update_appointment_status_route():
    return update_appointment_status()

@app.route(
    "/get-doctor-prescriptions",
    methods=["GET"]
)
def get_doctor_prescriptions_route():
    return get_doctor_prescriptions()

@app.route(
    "/delete-appointment",
    methods=["POST"]
)
def delete_appointment_route():
    return delete_appointment()

from RateDoctor import rate_doctor


@app.route("/rate-doctor", methods=["POST"])
def rate_doctor_route():
    return rate_doctor()

@app.route("/get-hospital-appointments", methods=["GET"])
def get_hospital_appointments_route():
    return get_hospital_appointments()

from razorpay_integration import create_razorpay_order
from flask import request, jsonify

@app.route("/create-razorpay-order", methods=["POST"])
def create_razorpay_order_route():
    try:
        data = request.json
        amount = data.get("amount")
        if not amount:
            return jsonify({"success": False, "error": "Amount is required"}), 400
        
        # Clean fee string if it has symbols like '₹' or ','
        amount_str = str(amount).replace('₹', '').replace(',', '').strip()
        
        result = create_razorpay_order(amount_str)
        return jsonify(result)
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/get-hospital-beds", methods=["GET"])
def get_hospital_beds_route():
    return get_hospital_beds()

@app.route("/update-hospital-beds", methods=["POST"])
def update_hospital_beds_route():
    return update_hospital_beds()

@app.route("/get-hospital-analytics", methods=["GET"])
def get_hospital_analytics_route():
    return get_hospital_analytics()

@app.route("/update-doctor-details", methods=["POST"])
def update_doctor_details_route():
    return update_doctor_details()

call_rooms = {}

@app.route("/join-call", methods=["POST"])
def join_call_route():
    try:
        data = request.json or {}
        room_name = data.get("room_name")
        role = data.get("role")
        if not room_name or not role:
            return jsonify({"success": False, "error": "room_name and role are required"}), 400
        
        if room_name not in call_rooms:
            call_rooms[room_name] = {"doctor_joined": False, "patient_joined": False}
        
        if role == "doctor":
            call_rooms[room_name]["doctor_joined"] = True
        elif role == "patient":
            call_rooms[room_name]["patient_joined"] = True
            
        return jsonify({"success": True, "status": call_rooms[room_name]})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/leave-call", methods=["POST"])
def leave_call_route():
    try:
        data = request.json or {}
        room_name = data.get("room_name")
        role = data.get("role")
        if not room_name or not role:
            return jsonify({"success": False, "error": "room_name and role are required"}), 400
        
        if room_name in call_rooms:
            if role == "doctor":
                call_rooms[room_name]["doctor_joined"] = False
            elif role == "patient":
                call_rooms[room_name]["patient_joined"] = False
                
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/call-status/<room_name>", methods=["GET"])
def call_status_route(room_name):
    try:
        status = call_rooms.get(room_name, {"doctor_joined": False, "patient_joined": False})
        return jsonify(status)
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)