"""
Shared helpers for all test scripts.
"""
import json, time, sys
from pathlib import Path
try:
    import requests
except ImportError:
    print("Install dependencies:  pip install requests"); sys.exit(1)

ROOT = Path(__file__).parent
cfg  = json.loads((ROOT / "input.json").read_text())
BASE = cfg["baseUrl"].rstrip("/")

RESULTS = []

def req(method, path, role="anon", headers=None, params=None, json_body=None, timeout=10):
    """Make one request and return a result dict."""
    url  = BASE + path
    hdrs = {"Content-Type": "application/json"}
    if headers:
        hdrs.update(headers)
    t0 = time.time()
    try:
        r = requests.request(method, url, headers=hdrs, params=params,
                             json=json_body, timeout=timeout, allow_redirects=False)
        elapsed = round((time.time() - t0) * 1000, 1)
        return {"ok": True, "status": r.status_code, "body": r.text[:300], "ms": elapsed}
    except requests.exceptions.ConnectionError:
        return {"ok": False, "status": 0, "body": "CONNECTION_ERROR", "ms": 0}
    except requests.exceptions.Timeout:
        return {"ok": False, "status": 0, "body": "TIMEOUT", "ms": timeout * 1000}

def record(endpoint, method, role, result, expected_status,
           test_category, finding, severity, note):
    rec = {
        "endpoint": endpoint,
        "method":   method,
        "role":     role,
        "status":          result["status"],
        "expected_status": expected_status,
        "finding":         finding,
        "severity":        severity,
        "response_time_ms": result["ms"],
        "test_category":   test_category,
        "note":            note,
        "timestamp":       time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }
    RESULTS.append(rec)
    icon = "✗" if finding else "✓"
    print(f"  {icon}  [{severity:<8}] {method:<5} {endpoint:<38} {result['status']} (expect {expected_status})  {note[:60]}")
    return rec

def save_results(filename="results_partial.json"):
    out = ROOT / filename
    existing = []
    if out.exists():
        try:
            existing = json.loads(out.read_text())
        except Exception:
            pass
    existing.extend(RESULTS)
    out.write_text(json.dumps(existing, indent=2))
    print(f"\n  💾  {len(RESULTS)} new records written to {filename}")
