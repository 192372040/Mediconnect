# -*- coding: utf-8 -*-
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
"""
TEST CAT 8 — Hardcoded Credentials / Secrets Scanner
Static analysis: walks the entire backend source tree and flags files
containing patterns that look like committed secrets.
Does NOT send any network request.
"""
import re, sys, json
from pathlib import Path

ROOT_BACKEND = Path(__file__).parent.parent  # backend/

PATTERNS = [
    ("SendGrid API key",       re.compile(r"SG\.[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{20,}")),
    ("Razorpay key ID",        re.compile(r"rzp_(test|live)_[A-Za-z0-9]{14,}")),
    ("Razorpay key secret",    re.compile(r"['\"][A-Za-z0-9]{20,}['\"].*razorpay|razorpay.*['\"][A-Za-z0-9]{20,}['\"]", re.IGNORECASE)),
    ("Gmail app password",     re.compile(r"['\"][a-z]{4} [a-z]{4} [a-z]{4} [a-z]{4}['\"]")),
    ("Generic API key",        re.compile(r"api[_-]?key\s*=\s*['\"][A-Za-z0-9_\-]{16,}['\"]", re.IGNORECASE)),
    ("Google Gemini API key",  re.compile(r"['\"]AIza[0-9A-Za-z_\-]{35}['\"]")),
    ("Hardcoded password",     re.compile(r"password\s*=\s*['\"][^'\"]{4,}['\"]", re.IGNORECASE)),
    ("DB connection string",   re.compile(r"(mysql|postgresql|mongodb)://[^'\" ]{8,}")),
    ("Private key header",     re.compile(r"-----BEGIN (RSA |EC )?PRIVATE KEY-----")),
    ("JWT secret",             re.compile(r"(jwt|secret)[_-]?key\s*=\s*['\"][^'\"]{6,}['\"]", re.IGNORECASE)),
    ("Bearer token literal",   re.compile(r"Bearer\s+[A-Za-z0-9_\-\.]{30,}")),
]

SKIP_DIRS = {"venv", "__pycache__", ".git", "node_modules", "build", ".dart_tool"}

findings = []

print("=" * 60)
print("TEST 8 — Hardcoded Credentials / Secrets Scan")
print(f"Scanning: {ROOT_BACKEND}")
print("=" * 60)

for fpath in ROOT_BACKEND.rglob("*"):
    if fpath.is_dir():
        continue
    if any(skip in fpath.parts for skip in SKIP_DIRS):
        continue
    if fpath.suffix not in {".py", ".dart", ".env", ".json", ".yaml", ".yml", ".txt", ".sh", ".bat", ".properties", ".gradle"}:
        continue
    if fpath.stat().st_size > 500_000:   # skip large binaries
        continue
    try:
        text = fpath.read_text(errors="ignore")
    except Exception:
        continue

    for pat_name, pattern in PATTERNS:
        for m in pattern.finditer(text):
            line_num = text[:m.start()].count("\n") + 1
            # Mask secret: show only first 6 and last 4 chars
            raw = m.group(0)
            if len(raw) > 12:
                masked = raw[:6] + "..." + raw[-4:]
            else:
                masked = raw[:3] + "***"

            findings.append({
                "file":     str(fpath.relative_to(ROOT_BACKEND)),
                "line":     line_num,
                "pattern":  pat_name,
                "snippet":  masked,
                "severity": "CRITICAL",
            })
            print(f"  ✗  [{pat_name}]  {fpath.relative_to(ROOT_BACKEND)}:{line_num}  →  {masked}")

print(f"\nTotal secrets found: {len(findings)}")

# Save
out = Path(__file__).parent / "results_08_hardcoded.json"
records = []
import time as _time
for f in findings:
    records.append({
        "endpoint":         f["file"],
        "method":           "STATIC",
        "role":             "N/A",
        "status":           0,
        "expected_status":  0,
        "finding":          True,
        "severity":         f["severity"],
        "response_time_ms": 0,
        "test_category":    "hardcoded_creds",
        "note":             f"[{f['pattern']}] line {f['line']}: {f['snippet']}",
        "timestamp":        _time.strftime("%Y-%m-%dT%H:%M:%SZ", _time.gmtime()),
    })
out.write_text(json.dumps(records, indent=2))
print(f"Results saved to {out.name}")
print("\nTest 8 complete.")
