"""
TEST CAT 7 — Rate Limiting
Sends 30 rapid successive requests to key endpoints.
Confirms whether a rate-limit (429) is enforced.
A test passes if ANY request returns 429 within the burst.
"""
import sys, time, threading
sys.path.insert(0, str(__import__('pathlib').Path(__file__).parent))
from helpers import BASE, req, record, save_results, RESULTS

RATE_TARGETS = [
    ("POST", "/send-otp",     {"email": "ratetest@probe.com"}),
    ("POST", "/verify-otp",   {"email": "ratetest@probe.com", "otp": "000000"}),
    ("POST", "/doctor-login", {"doctor_id": "PROBE", "password": "PROBE"}),
    ("POST", "/admin-login",  {"hospital_id": "PROBE", "password": "PROBE"}),
    ("GET",  "/hospitals",    None),
]

BURST = 30

print("=" * 60)
print("TEST 7 — Rate Limiting")
print(f"Target: {BASE}  (burst={BURST} per endpoint)")
print("=" * 60)

for method, path, body in RATE_TARGETS:
    print(f"\n  Bursting {BURST}x {method} {path} …")
    statuses = []
    params = body if method == "GET" else None
    json_b = body if method != "GET" else None

    for i in range(BURST):
        r = req(method, path, params=params, json_body=json_b)
        statuses.append(r["status"])

    got_429    = 429 in statuses
    is_finding = not got_429  # No 429 within burst = missing rate limit
    severity   = "HIGH" if is_finding else "INFO"
    note       = (
        "No 429 in 30-req burst — rate limiting absent" if is_finding
        else f"429 received at request #{statuses.index(429)+1}"
    )
    print(f"  Statuses seen: {sorted(set(statuses))}  → {'✗ NO rate limit' if is_finding else '✓ Rate limited'}")

    # Record using last result dict (approximate)
    r_fake = {"ok": True, "status": statuses[-1], "ms": 0, "body": ""}
    record(path, method, "anon", r_fake, 429,
           "rate_limiting", is_finding, severity, note)

save_results("results_07_ratelimit.json")
print("\nTest 7 complete.")
