# MediConnect API - Baseline / Load Test

## What it does
Simulates **100 virtual users** hitting the API continuously for **1 minute**,
then writes a full Excel report: `LoadTest_Report.xlsx`.

---

## Folder structure
```
backend/load_test/
  load_test.py          <- main script (run this)
  LoadTest_Report.xlsx  <- auto-generated after the run
```

---

## Requirements
Make sure your backend server is running first:
```bash
# In the backend folder:
python app.py
```

Install dependencies (one-time):
```bash
pip install requests openpyxl
```

---

## Run the test
```bash
cd backend/load_test
python load_test.py
```

The test will:
1. Ramp up 100 virtual users over 5 seconds
2. Hammer all major API endpoints for 60 seconds
3. Print live progress: `[####------] 30s | Reqs: 3420 | RPS: 114.0`
4. Print final summary
5. Save `LoadTest_Report.xlsx`

---

## What you'll see in the terminal
```
=================================================================
  MediConnect API - Baseline Load Test
  Users    : 100
  Duration : 60s  |  Ramp-up: 5s
  Target   : http://localhost:5000
=================================================================

  All 100 users active. Running for 60s ...

  [########------------------]  30s | Reqs:  3420 | RPS:  114.0

=================================================================
  LOAD TEST RESULTS
=================================================================
  Total Requests     : 7260
  Successful         : 7260
  Errors             : 0 (0.0%)
  Requests/sec (RPS) : 121.0
  Avg Response Time  : 247 ms
  Min Response Time  :  42 ms
  Max Response Time  : 1380 ms
  95th Percentile    : 890 ms
  99th Percentile    : 1200 ms
=================================================================
```

---

## Excel Report tabs
| Sheet | Contents |
|---|---|
| **Summary** | KPI scorecard (RPS, Avg/Min/Max, P95, P99, Error %) |
| **Endpoint Breakdown** | Per-endpoint request count, error rate, timing |
| **Timeline (per second)** | Requests & avg response time every second + line charts |
| **Raw Results (sample)** | First 1000 individual request records |
