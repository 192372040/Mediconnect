"""
TEST CAT 6 — Injection Probes (SQLi / NoSQLi detection)
Detection-only: sends payloads in parameters and body fields.
Flags: anomalous status codes, verbose DB error messages in response body,
or significant timing anomalies (time-based blind SQLi heuristic).

SAFE payloads — no data extraction, no DROP/DELETE/UPDATE statements.
"""
import sys, time
sys.path.insert(0, str(__import__('pathlib').Path(__file__).parent))
from helpers import BASE, req, record, save_results

SQLI_PAYLOADS = [
    ("sqli_quote",        "' "),
    ("sqli_comment",      "' -- "),
    ("sqli_or_true",      "' OR '1'='1"),
    ("sqli_sleep",        "'; WAITFOR DELAY '0:0:3'--"),   # MSSQL-style (won't fire on MySQL, harmless)
    ("sqli_sleep_mysql",  "' AND SLEEP(3) -- "),
    ("sqli_union_safe",   "' UNION SELECT NULL-- "),
    ("nosqli_gt",         "{\"$gt\": \"\"}"),
    ("nosqli_where",      "{\"$where\": \"1==1\"}"),
]

# Endpoints + the field most likely to hit a DB query
INJECT_TARGETS = [
    # (method, path, field_name, delivery)  delivery: "param" or "body"
    ("POST", "/send-otp",          "email",        "body"),
    ("POST", "/verify-otp",        "email",        "body"),
    ("POST", "/doctor-login",      "doctor_id",    "body"),
    ("POST", "/doctor-login",      "password",     "body"),
    ("POST", "/admin-login",       "hospital_id",  "body"),
    ("POST", "/admin-login",       "password",     "body"),
    ("GET",  "/get-patient-profile","email",       "param"),
    ("GET",  "/get-patient-prescriptions","patient_email","param"),
    ("GET",  "/get-patient-appointments","patient_email","param"),
    ("GET",  "/booked-slots",      "doctor_name",  "param"),
    ("GET",  "/get-hospital-appointments","hospital_id","param"),
    ("GET",  "/get-hospital-analytics","hospital_id","param"),
]

ERROR_KEYWORDS = [
    "mysql", "sql", "syntax", "unclosed", "where clause",
    "you have an error", "warning: mysql", "sqlstate",
    "operationalerror", "pymysql", "connector",
    "traceback", "exception", "error in your sql"
]

print("=" * 60)
print("TEST 6 — Injection Probes")
print(f"Target: {BASE}")
print("=" * 60)

for method, path, field, delivery in INJECT_TARGETS:
    for payload_name, payload_val in SQLI_PAYLOADS:
        time.sleep(0.2)
        t_start = time.time()

        if delivery == "param":
            params = {field: payload_val}
            result = req(method, path, params=params)
        else:
            # Minimal valid body with injection in target field
            base_body = {"email": "probe@test.com", "otp": "000000",
                         "doctor_id": "PROBE", "password": "PROBE",
                         "hospital_id": "PROBE", "message": "test"}
            base_body[field] = payload_val
            result = req(method, path, json_body=base_body)

        elapsed_total = (time.time() - t_start) * 1000

        body_lower   = result["body"].lower()
        has_db_error = any(kw in body_lower for kw in ERROR_KEYWORDS)
        timing_anomaly = elapsed_total > 2800   # >2.8 s suggests sleep() fired

        is_finding = has_db_error or timing_anomaly
        severity   = "HIGH" if has_db_error else ("MEDIUM" if timing_anomaly else "INFO")
        note_parts = []
        if has_db_error:
            note_parts.append("DB error in response — possible SQLi")
        if timing_anomaly:
            note_parts.append(f"Timing anomaly {elapsed_total:.0f}ms — possible blind SQLi")
        note = "; ".join(note_parts) if note_parts else f"No anomaly detected for {payload_name}"

        record(
            endpoint=path, method=method, role="anon",
            result=result, expected_status=400,
            test_category="injection",
            finding=is_finding, severity=severity,
            note=f"[{payload_name}@{field}] {note}"
        )

save_results("results_06_injection.json")
print("\nTest 6 complete.")
