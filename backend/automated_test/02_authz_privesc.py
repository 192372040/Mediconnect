"""
TEST CAT 2 — Authorization / Privilege Escalation
Calls admin-only and doctor-only endpoints using a patient identity,
and patient endpoints using a doctor identity.
Because the API has NO auth middleware, all calls are effectively anon —
these tests confirm role segregation is absent.
"""
import sys, time
sys.path.insert(0, str(__import__('pathlib').Path(__file__).parent))
from helpers import BASE, req, record, save_results

# Simulate patient identity by passing patient email in body/params
PATIENT_EMAIL = "patient_probe@test.com"
DOCTOR_ID     = "PROBE-DOC-9999"
HOSP_ID       = "PROBE-HOSP-9999"

# (method, path, target_role, simulated_role, body_or_params, expected_http)
PRIVESC_CASES = [
    # Patient tries admin endpoints
    ("GET",  "/get-admin-hospital-summary", "admin",  "patient", {"hospital_id": HOSP_ID},  403),
    ("GET",  "/get-hospital-appointments",  "admin",  "patient", {"hospital_id": HOSP_ID},  403),
    ("GET",  "/get-hospital-beds",          "admin",  "patient", {"hospital_id": HOSP_ID},  403),
    ("GET",  "/get-hospital-analytics",     "admin",  "patient", {"hospital_id": HOSP_ID},  403),
    ("POST", "/add-doctor-to-hospital",     "admin",  "patient", {"hospital_id": HOSP_ID, "doctor_id": DOCTOR_ID}, 403),
    ("POST", "/update-hospital-beds",       "admin",  "patient", {"hospital_id": HOSP_ID, "ward_name": "ICU", "available_beds": 0, "occupied_beds": 10}, 403),
    # Patient tries doctor endpoints
    ("GET",  "/get-doctor-appointments",    "doctor", "patient", {"doctor_id": DOCTOR_ID},  403),
    ("POST", "/save-prescription",          "doctor", "patient", {"patient_name": "Probe", "patient_email": PATIENT_EMAIL, "doctor_name": "Probe", "diagnosis": "X", "medicines": "X", "doctor_notes": "X"}, 403),
    ("GET",  "/get-doctor-summary",         "doctor", "patient", None,                       403),
    ("GET",  "/get-doctor-profile",         "doctor", "patient", None,                       403),
    # Doctor tries admin endpoints
    ("GET",  "/get-admin-hospital-summary", "admin",  "doctor",  {"hospital_id": HOSP_ID},  403),
    ("GET",  "/get-hospital-analytics",     "admin",  "doctor",  {"hospital_id": HOSP_ID},  403),
    # Doctor tries to access other patient's prescriptions
    ("GET",  "/get-patient-prescriptions",  "patient","doctor",  {"patient_email": PATIENT_EMAIL}, 403),
]

print("=" * 60)
print("TEST 2 — Authorization / Privilege Escalation")
print(f"Target: {BASE}")
print("=" * 60)

for method, path, target_role, acting_role, body, expected in PRIVESC_CASES:
    time.sleep(0.15)
    params = body if method == "GET" else None
    json_b = body if method != "GET" else None

    result = req(method, path, role=acting_role, params=params, json_body=json_b)

    is_finding = result["ok"] and 200 <= result["status"] < 300
    severity   = "CRITICAL" if is_finding else "INFO"

    record(
        endpoint=path, method=method, role=acting_role,
        result=result, expected_status=expected,
        test_category="authz_privesc",
        finding=is_finding, severity=severity,
        note=f"{acting_role} accessed {target_role} endpoint" if is_finding else "No unauth access or offline"
    )

save_results("results_02_authz.json")
print("\nTest 2 complete.")
