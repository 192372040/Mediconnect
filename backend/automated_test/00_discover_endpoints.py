"""
STEP 1 — Endpoint Discovery
Reads input.json for baseUrl, probes /v3/api-docs and /swagger.json,
then prints + saves the canonical route list derived from app.py analysis.
"""
import json, sys, time
from pathlib import Path

try:
    import requests
except ImportError:
    print("pip install requests  — then re-run"); sys.exit(1)

ROOT = Path(__file__).parent
cfg  = json.loads((ROOT / "input.json").read_text())
BASE = cfg["baseUrl"].rstrip("/")

# ── Routes extracted from app.py (static) ─────────────────────────────────
ENDPOINTS = [
    # method, path, expected_auth, roles_allowed, notes
    ("GET",  "/",                          "public",  ["*"],                "Home check"),
    ("GET",  "/test-db",                   "public",  ["*"],                "Exposes DB name — info leak"),
    ("POST", "/send-otp",                  "public",  ["*"],                "Patient OTP trigger"),
    ("POST", "/verify-otp",                "public",  ["*"],                "Patient OTP verify / login"),
    ("POST", "/update-profile",            "auth",    ["patient"],          "Create/update patient profile — no auth guard"),
    ("GET",  "/hospitals",                 "public",  ["*"],                "List hospitals"),
    ("GET",  "/doctors/<hospital_id>",     "public",  ["*"],                "List doctors by hospital"),
    ("POST", "/book-appointment",          "auth",    ["patient"],          "Book appointment — no auth guard"),
    ("GET",  "/booked-slots",              "public",  ["*"],                "Booked slots"),
    ("POST", "/save-doctor-details",       "auth",    ["doctor"],           "Save doctor details — no auth guard"),
    ("POST", "/save-hospital-details",     "auth",    ["doctor"],           "Save hospital details — no auth guard"),
    ("GET",  "/get-doctor-summary",        "auth",    ["doctor"],           "Get doctor summary — no auth guard"),
    ("POST", "/save-professional-details", "auth",    ["doctor"],           "Save professional details — no auth guard"),
    ("GET",  "/get-doctor-profile",        "auth",    ["doctor"],           "Get doctor profile — no auth guard"),
    ("POST", "/save-password",             "auth",    ["doctor"],           "Save doctor password — no auth guard"),
    ("POST", "/doctor-login",              "public",  ["*"],                "Doctor login"),
    ("POST", "/forgot-doctor-id",          "public",  ["*"],                "Forgot doctor ID"),
    ("POST", "/send-admin-otp",            "public",  ["*"],                "Admin OTP trigger"),
    ("POST", "/save-admin-hospital",       "auth",    ["admin"],            "Save admin hospital — no auth guard"),
    ("POST", "/verify-hospital-id",        "public",  ["*"],                "Verify hospital ID"),
    ("POST", "/save-admin-password",       "public",  ["*"],                "Save admin password — no auth guard"),
    ("GET",  "/get-admin-hospital-summary","auth",    ["admin"],            "Admin hospital summary — no auth guard"),
    ("POST", "/admin-login",               "public",  ["*"],                "Admin login"),
    ("POST", "/forgot-admin-id",           "public",  ["*"],                "Forgot admin ID"),
    ("POST", "/add-doctor-to-hospital",    "auth",    ["admin"],            "Add doctor to hospital — no auth guard"),
    ("GET",  "/get-hospital-doctors",      "auth",    ["admin","doctor"],   "Get hospital doctors — no auth guard"),
    ("GET",  "/get-doctor-appointments",   "auth",    ["doctor"],           "Doctor appointments — no auth guard"),
    ("POST", "/save-prescription",         "auth",    ["doctor"],           "Save prescription — no auth guard"),
    ("GET",  "/get-patient-profile",       "auth",    ["patient","doctor"], "Get patient profile — no auth guard"),
    ("GET",  "/get-patient-prescriptions", "auth",    ["patient"],          "Get patient prescriptions — no auth guard"),
    ("POST", "/ai-chat",                   "public",  ["*"],                "AI chat"),
    ("GET",  "/get-patient-appointments",  "auth",    ["patient"],          "Get patient appointments — no auth guard"),
    ("POST", "/delete-account",            "auth",    ["patient"],          "Delete account — no auth guard, DESTRUCTIVE"),
    ("POST", "/update-appointment-status", "auth",    ["doctor","admin"],   "Update appt status — no auth guard"),
    ("GET",  "/get-hospital-appointments", "auth",    ["admin"],            "Hospital appointments — no auth guard"),
    ("POST", "/create-razorpay-order",     "auth",    ["patient"],          "Create payment order — no auth guard"),
    ("GET",  "/get-hospital-beds",         "auth",    ["admin"],            "Get beds — no auth guard"),
    ("POST", "/update-hospital-beds",      "auth",    ["admin"],            "Update beds — no auth guard"),
    ("GET",  "/get-hospital-analytics",    "auth",    ["admin"],            "Hospital analytics — no auth guard"),
]

def probe_spec():
    for path in ["/v3/api-docs", "/swagger.json", "/openapi.json", "/swagger-ui.html"]:
        try:
            r = requests.get(BASE + path, timeout=5)
            if r.status_code == 200:
                print(f"  ✓ OpenAPI spec found at {path}")
                return r.text[:200]
        except Exception:
            pass
    print("  ⚠ No OpenAPI spec found — using static route list from app.py")
    return None

print("=" * 60)
print("STEP 1 — ENDPOINT DISCOVERY")
print(f"Target: {BASE}")
print("=" * 60)
print("\nChecking for OpenAPI/Swagger spec …")
probe_spec()

print(f"\nDiscovered {len(ENDPOINTS)} endpoints (excluding /health, /actuator, /metrics):\n")
print(f"{'#':>3}  {'METHOD':<6}  {'PATH':<35}  {'AUTH':<8}  NOTES")
print("-" * 95)
for i, (method, path, auth, roles, notes) in enumerate(ENDPOINTS, 1):
    flag = "⚠" if auth == "auth" else " "
    print(f"{i:>3}  {method:<6}  {path:<35}  {auth:<8}  {flag} {notes}")

print(f"\nTotal: {len(ENDPOINTS)} endpoints")
print("\n✅ Review the list above, then run the numbered test files to execute tests.")

# Save for other scripts to import
(ROOT / "savepoint.json").write_text(json.dumps({
    "base_url": BASE,
    "endpoints": [{"method": e[0], "path": e[1], "auth": e[2], "roles": e[3], "notes": e[4]}
                  for e in ENDPOINTS],
    "discovered_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
}, indent=2))
print("\nSavepoint written to savepoint.json")
