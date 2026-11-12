"""
TEST CAT 4 — RBAC Matrix
Exhaustive cross-product: each simulated role × each role-restricted endpoint.
Since the API has no JWT, all roles are effectively anonymous.
Records actual vs expected HTTP status for every combination.
"""
import sys, time
sys.path.insert(0, str(__import__('pathlib').Path(__file__).parent))
from helpers import BASE, req, record, save_results

ROLES = ["anon", "patient", "doctor", "admin"]

# (method, path, allowed_roles, sample_body_or_params)
ROLE_ENDPOINTS = [
    ("GET",  "/get-patient-profile",        ["patient"],        {"email": "probe@test.com"}),
    ("GET",  "/get-patient-appointments",   ["patient"],        {"patient_email": "probe@test.com"}),
    ("GET",  "/get-patient-prescriptions",  ["patient"],        {"patient_email": "probe@test.com"}),
    ("POST", "/update-profile",             ["patient"],        {"email": "probe@test.com", "name": "P", "phone": "0", "age": "1", "blood_group": "O+", "gender": "M", "medical_history": []}),
    ("POST", "/book-appointment",           ["patient"],        {"patient_email": "probe@test.com", "patient_name": "Probe", "doctor_name": "Dr.X", "specialization": "Gen", "hospital_name": "H", "appointment_slot": "09:00 AM", "payment_method": "Online", "consultation_fee": "100", "appointment_date": "2099-01-01"}),
    ("GET",  "/get-doctor-profile",         ["doctor"],         None),
    ("GET",  "/get-doctor-summary",         ["doctor"],         None),
    ("GET",  "/get-doctor-appointments",    ["doctor"],         None),
    ("POST", "/save-prescription",          ["doctor"],         {"patient_name": "P", "patient_email": "probe@test.com", "doctor_name": "Dr.X", "diagnosis": "X", "medicines": "X", "doctor_notes": "X"}),
    ("GET",  "/get-admin-hospital-summary", ["admin"],          {"hospital_id": "1"}),
    ("GET",  "/get-hospital-appointments",  ["admin"],          {"hospital_id": "1"}),
    ("GET",  "/get-hospital-beds",          ["admin"],          {"hospital_id": "1"}),
    ("GET",  "/get-hospital-analytics",     ["admin"],          {"hospital_id": "1"}),
    ("POST", "/add-doctor-to-hospital",     ["admin"],          {"hospital_id": "1", "doctor_id": "X"}),
    ("POST", "/update-hospital-beds",       ["admin"],          {"hospital_id": "1", "ward_name": "G", "available_beds": 1, "occupied_beds": 0}),
    ("POST", "/update-appointment-status",  ["doctor", "admin"],{"appointment_id": 1, "status": "Completed"}),
    ("GET",  "/get-hospital-doctors",       ["admin", "doctor"],{"hospital_id": "1"}),
]

print("=" * 60)
print("TEST 4 — RBAC Matrix")
print(f"Target: {BASE}")
print("=" * 60)

for method, path, allowed, body in ROLE_ENDPOINTS:
    for role in ROLES:
        time.sleep(0.12)
        params = body if method == "GET" else None
        json_b = body if method != "GET" else None

        result = req(method, path, role=role, params=params, json_body=json_b)

        expected_ok  = role in allowed
        # If no auth enforcement, every role gets 2xx → that IS the finding
        got_2xx      = result["ok"] and 200 <= result["status"] < 300
        is_finding   = got_2xx and not expected_ok   # non-allowed role got through
        # Also flag: allowed role rejected (misconfiguration)
        false_reject = not got_2xx and expected_ok and result["status"] not in (0,)

        severity = "CRITICAL" if is_finding else ("MEDIUM" if false_reject else "INFO")
        note = (
            f"{role} NOT in allowed={allowed} but got 2xx" if is_finding else
            f"{role} correctly {'allowed' if got_2xx else 'denied'}" if not false_reject else
            f"{role} SHOULD be allowed but got {result['status']}"
        )

        record(
            endpoint=path, method=method, role=role,
            result=result,
            expected_status=200 if expected_ok else 403,
            test_category="rbac_matrix",
            finding=is_finding or false_reject,
            severity=severity,
            note=note
        )

save_results("results_04_rbac.json")
print("\nTest 4 complete.")
