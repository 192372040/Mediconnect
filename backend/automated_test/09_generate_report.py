"""
Report generator — merges all partial result files into report.json
and prints a human-readable summary.
"""
import json, time
from pathlib import Path
from collections import Counter

ROOT = Path(__file__).parent

# Merge all partial result files
all_records = []
for f in sorted(ROOT.glob("results_*.json")):
    try:
        data = json.loads(f.read_text())
        all_records.extend(data)
    except Exception as e:
        print(f"⚠  Could not read {f.name}: {e}")

# Write consolidated report
report_path = ROOT / "report.json"
report_path.write_text(json.dumps(all_records, indent=2))

# ── Summary ────────────────────────────────────────────────────────────────
findings    = [r for r in all_records if r.get("finding")]
by_severity = Counter(r["severity"] for r in findings)
by_category = Counter(r["test_category"] for r in findings)

print("=" * 65)
print("MEDICONNECT DAST — FINAL REPORT SUMMARY")
print(f"Generated: {time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}")
print("=" * 65)
print(f"\n  Total tests recorded : {len(all_records)}")
print(f"  Total FINDINGS       : {len(findings)}")
print()
print("  Findings by severity:")
for sev in ["CRITICAL", "HIGH", "MEDIUM", "LOW", "INFO"]:
    n = by_severity.get(sev, 0)
    bar = "█" * min(n, 40)
    print(f"    {sev:<10} {n:>4}  {bar}")

print()
print("  Findings by category:")
for cat, n in by_category.most_common():
    print(f"    {cat:<30} {n}")

print()
print("  ─── CRITICAL / HIGH findings ───────────────────────────")
for r in findings:
    if r["severity"] in ("CRITICAL", "HIGH"):
        icon = "✗"
        print(f"  {icon} [{r['severity']:<8}] {r['method']:<5} {r['endpoint']:<38} HTTP {r['status']}")
        print(f"           Category: {r['test_category']}  |  {r['note'][:80]}")

print()
print("  ─── TOP ISSUES TO FIX (priority order) ─────────────────")
issues = [
    ("1", "CRITICAL", "ZERO authentication on the entire API",
     "None of the 'auth-required' endpoints validate any token. Implement Flask-JWT-Extended "
     "or similar middleware and apply @jwt_required() to every protected route."),
    ("2", "CRITICAL", "No RBAC / role enforcement",
     "Admin, Doctor, Patient endpoints are accessible by anyone. Add role decorators "
     "@admin_required, @doctor_required, @patient_required after JWT verification."),
    ("3", "CRITICAL", "Hardcoded secrets committed to source code",
     "SendGrid API key, Razorpay key+secret, and Gmail app-password are in plain text in "
     "auth.py, AdminAuth.py, razorpay_integration.py, AiChat.py. Move to environment "
     "variables / .env (add to .gitignore) immediately and ROTATE all exposed keys."),
    ("4", "CRITICAL", "Passwords stored and compared in plain text",
     "admin_login() and doctor_login() compare passwords with =. Use bcrypt/argon2 hashing."),
    ("5", "HIGH",     "IDOR on all patient data endpoints",
     "/get-patient-profile, /get-patient-appointments, /get-patient-prescriptions accept "
     "any email with no ownership check. After adding auth, verify request.user.email == param email."),
    ("6", "HIGH",     "No rate limiting on OTP / login endpoints",
     "Brute-force and OTP enumeration are unrestricted. Add Flask-Limiter with limits on "
     "/send-otp, /verify-otp, /doctor-login, /admin-login."),
    ("7", "HIGH",     "/test-db exposes database name publicly",
     "Remove or restrict this diagnostic endpoint. Never expose DB internals in production."),
    ("8", "HIGH",     "Unprotected /delete-account — anyone can delete any account",
     "This POST endpoint deletes all user data by email with no authentication. Enforce auth "
     "and verify the requesting user owns the account."),
    ("9", "MEDIUM",   "OTP not expiring / time-limited",
     "verify_otp() checks only the latest OTP by ID with no expiry window. Enforce a "
     "5-minute TTL and single-use constraint in the otp_verification table."),
    ("10","MEDIUM",   "CORS wildcard (CORS(app) with no origin restriction)",
     "app.py uses CORS(app) allowing any origin. Restrict to known frontend domains."),
]
for num, sev, title, detail in issues:
    print(f"\n  {num}. [{sev}] {title}")
    print(f"     {detail}")

print(f"\n\n  Full machine-readable results: {report_path}")
print("=" * 65)
