"""
TEST CAT 5 — Token Tampering
Since the API uses NO JWT validation, this test confirms:
  (a) The server accepts any Authorization header value without rejection.
  (b) Tampered JWTs (alg=none, flipped role, wrong secret) all yield 2xx.
Each 2xx with a tampered token = CRITICAL finding.
"""
import sys, time, base64, json as _json
sys.path.insert(0, str(__import__('pathlib').Path(__file__).parent))
from helpers import BASE, req, record, save_results

def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()

def make_jwt(header: dict, payload: dict, signature: str = "FAKESIG") -> str:
    h = b64url(_json.dumps(header).encode())
    p = b64url(_json.dumps(payload).encode())
    return f"{h}.{p}.{signature}"

TAMPERED_TOKENS = [
    ("alg_none_admin",  make_jwt({"alg": "none", "typ": "JWT"}, {"sub": "1", "role": "admin", "exp": 9999999999})),
    ("alg_none_doctor", make_jwt({"alg": "none", "typ": "JWT"}, {"sub": "2", "role": "doctor","exp": 9999999999})),
    ("hs256_bad_sig",   make_jwt({"alg": "HS256","typ": "JWT"}, {"sub": "1", "role": "admin", "exp": 9999999999}, "BADSIGNATURE")),
    ("rs256_as_hs",     make_jwt({"alg": "HS256","typ": "JWT"}, {"sub": "1", "role": "admin", "exp": 9999999999}, "WRONGALGO")),
    ("expired_admin",   make_jwt({"alg": "HS256","typ": "JWT"}, {"sub": "1", "role": "admin", "exp": 1},          "EXPIREDSIG")),
]

# Test against a sample of auth-required endpoints
TARGETS = [
    ("GET",  "/get-admin-hospital-summary", {"hospital_id": "1"}),
    ("GET",  "/get-hospital-analytics",     {"hospital_id": "1"}),
    ("GET",  "/get-patient-profile",        {"email": "probe@test.com"}),
    ("GET",  "/get-doctor-profile",         None),
    ("POST", "/update-appointment-status",  {"appointment_id": 99, "status": "Completed"}),
]

print("=" * 60)
print("TEST 5 — Token Tampering")
print(f"Target: {BASE}")
print("=" * 60)

for token_name, token_value in TAMPERED_TOKENS:
    for method, path, body in TARGETS:
        time.sleep(0.12)
        params = body if method == "GET" else None
        json_b = body if method != "GET" else None
        hdrs   = {"Authorization": f"Bearer {token_value}"}

        result = req(method, path, role=token_name, headers=hdrs,
                     params=params, json_body=json_b)

        # Server MUST reject tampered tokens with 401/403.
        # Any 2xx = CRITICAL (token validation absent).
        is_finding = result["ok"] and 200 <= result["status"] < 300
        severity   = "CRITICAL" if is_finding else "INFO"

        record(
            endpoint=path, method=method, role=token_name,
            result=result, expected_status=401,
            test_category="token_tampering",
            finding=is_finding, severity=severity,
            note=f"Tampered token '{token_name}' accepted — no sig verification" if is_finding
                 else f"Tampered token correctly rejected or server offline"
        )

save_results("results_05_token.json")
print("\nTest 5 complete.")
