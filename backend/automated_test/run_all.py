"""
Master runner — executes all test categories in order and then
merges results into a single report.json.
Usage:  python run_all.py
"""
import subprocess, sys, json, time
from pathlib import Path

ROOT = Path(__file__).parent
SCRIPTS = [
    "00_discover_endpoints.py",
    "01_authn_bypass.py",
    "02_authz_privesc.py",
    "03_idor.py",
    "04_rbac_matrix.py",
    "05_token_tampering.py",
    "06_injection.py",
    "07_rate_limiting.py",
    "08_hardcoded_creds.py",
    "09_generate_report.py",
]

print("=" * 60)
print("MEDICONNECT DAST — Full Run")
print(f"Started: {time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}")
print("=" * 60)

for script in SCRIPTS:
    path = ROOT / script
    if not path.exists():
        print(f"\n⚠  {script} not found — skipping")
        continue
    print(f"\n{'─'*60}")
    print(f"▶  Running {script}")
    print(f"{'─'*60}")
    result = subprocess.run(
        [sys.executable, str(path)],
        cwd=str(ROOT)
    )
    if result.returncode != 0:
        print(f"⚠  {script} exited with code {result.returncode}")

print(f"\n{'='*60}")
print("All tests complete. See automated_test/report.json")
