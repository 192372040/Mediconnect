import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from generate_excel_report import build_test_cases, run_tests

TC = build_test_cases()
results = run_tests(TC)
fails = [r for r in results if r["verdict"] == "FAIL"]
skips = [r for r in results if r["verdict"] == "SKIP"]

print(f"\n{'='*70}")
print(f"TOTAL: {len(results)}  PASS: {len(results)-len(fails)-len(skips)}  FAIL: {len(fails)}  SKIP: {len(skips)}")
print(f"{'='*70}\n")

print("FAILING TESTS:")
for f in fails:
    print(f"  {f['id']} | {f['module']} | exp={f['exp']} | got={f['status']}")
    print(f"    Name: {f['name']}")
    print(f"    Body: {f['body'][:120]}")
    print()
