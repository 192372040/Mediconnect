"""
TEST CAT 1 — Authentication Bypass
Hit every endpoint that SHOULD require auth with:
  (a) No Authorization header
  (b) A clearly malformed token  "Bearer INVALID"
  (c) An expired / tampered token (static string)

A 2xx response = FINDING (endpoint not enforcing auth).

NOTE: This API has NO JWT middleware whatsoever (confirmed by source-code
review of app.py + all route handler files — zero token validation).
Every single "auth-required" endpoint is therefore presumed vulnerable.
These live requests confirm the presumption at runtime.
"""
import sys, time
sys.path.insert(0, str(__import__('pathlib').Path(__file__).parent))
from helpers import BASE, req, record, save_results

AUTHN_TARGETS = [
    # (method, path, safe_body_or_params)
    ("POST", "/update-profile",            {"email": "probe@test.com", "name": "probe", "phone": "0000000000", "age": "25", "blood_group": "O+", "gender": "Male", "medical_history": []}),
    ("POST", "/book-appointment",          {"patient_email": "probe@test.com", "patient_name": "Probe", "doctor_name": "Dr.Test", "specialization": "General", "hospital_name": "TestHosp", "appointment_slot": "09:00 AM", "payment_method": "Online", "consultation_fee": "100", "appointment_date": "2099-01-01"}),
    ("POST", "/save-doctor-details",       {"doctor_id": "PROBE-DOC", "full_name": "Probe Doc", "phone": "0000000000", "email": "probe@test.com"}),
    ("POST", "/save-hospital-details",     {"doctor_id": "PROBE-DOC", "hospital_name": "Test", "address": "Test"}),
    ("GET",  "/get-doctor-summary",        None),
    ("POST", "/save-professional-details", {"doctor_id": "PROBE-DOC", "qualification": "MBBS", "specialization": "Gen", "experience": "1", "license_number": "PROBE999", "consultation_fee": "100"}),
    ("GET",  "/get-doctor-profile",        None),
    ("POST", "/save-password",             {"doctor_id": "PROBE-DOC", "password": "probe123"}),
    ("POST", "/save-admin-hospital",       {"hospital_name": "Probe Hosp", "hospital_type": "General", "hospital_address": "123 Test St", "email": "admin@probe.com"}),
    ("POST", "/save-admin-password",       {"hospital_id": "PROBE-HOSP", "password": "probe123"}),
    ("GET",  "/get-admin-hospital-summary",None),
    ("POST", "/add-doctor-to-hospital",    {"hospital_id": "PROBE-HOSP", "doctor_id": "PROBE-DOC"}),
    ("GET",  "/get-hospital-doctors",      None),
    ("GET",  "/get-doctor-appointments",   None),
    ("POST", "/save-prescription",         {"patient_name": "Probe", "patient_email": "probe@test.com", "doctor_name": "Dr.Test", "diagnosis": "Test", "medicines": "Test", "doctor_notes": "Test"}),
    ("GET",  "/get-patient-profile",       None),
    ("GET",  "/get-patient-prescriptions", None),
    ("GET",  "/get-patient-appointments",  None),
    ("POST", "/update-appointment-status", {"appointment_id": 99999, "status": "Completed"}),
    ("GET",  "/get-hospital-appointments", None),
    ("POST", "/create-razorpay-order",     {"amount": "100"}),
    ("GET",  "/get-hospital-beds",         None),
    ("POST", "/update-hospital-beds",      {"hospital_id": "PROBE-HOSP", "ward_name": "General", "available_beds": 5, "occupied_beds": 2}),
    ("GET",  "/get-hospital-analytics",    None),
    # SKIP /delete-account — destructive
]

TOKEN_CASES = [
    ("anon",       {}),
    ("bad_token",  {"Authorization": "Bearer INVALID.TOKEN.HERE"}),
    ("exp_token",  {"Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxfQ.EXPIRED"}),
]

print("=" * 60)
print("TEST 1 — Authentication Bypass")
print(f"Target: {BASE}")
print("=" * 60)

for method, path, body in AUTHN_TARGETS:
    params = None
    json_b = None
    if method == "GET" and body:
        params = body
    else:
        json_b = body

    for role_label, extra_headers in TOKEN_CASES:
        time.sleep(0.15)
        result = req(method, path, role=role_label,
                     headers=extra_headers,
                     params=params, json_body=json_b)

        # Any 2xx without a valid token = auth bypass finding
        is_finding = result["ok"] and 200 <= result["status"] < 300
        severity   = "CRITICAL" if is_finding else "INFO"

        record(
            endpoint=path, method=method, role=role_label,
            result=result, expected_status=401,
            test_category="authn_bypass",
            finding=is_finding, severity=severity,
            note=f"No/bad token accepted" if is_finding else f"Correctly rejected or offline"
        )

save_results("results_01_authn.json")
print("\nTest 1 complete.")
