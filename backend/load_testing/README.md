# MediConnect – Load Testing

Baseline/load testing suite for the MediConnect Flask backend using **Locust**.

---

## 📁 Folder Structure

```
backend/
└── load_testing/
    ├── locustfile.py          ← Locust tasks (100 virtual users)
    ├── run_load_test.py       ← Runner + Excel report generator
    ├── requirements.txt       ← Python dependencies
    ├── README.md              ← This file
    └── results/               ← Auto-created on first run
        ├── load_test_stats.csv
        ├── load_test_stats_history.csv
        ├── load_test_failures.csv
        └── MediConnect_Load_Test_Report.xlsx
```

---

## ⚙️ Setup (one-time)

Make sure your Flask backend is running first:

```bash
# In the backend/ folder
python app.py
```

Then install load-testing dependencies:

```bash
cd backend/load_testing
pip install -r requirements.txt
```

---

## ▶️ Run the Test

### Option A – Automatic (recommended)
Runs the test **and** generates the Excel report in one command:

```bash
python run_load_test.py
```

With custom options:

```bash
# Change host, users, or duration
python run_load_test.py --host http://localhost:5000 --users 100 --duration 1m
python run_load_test.py --host http://192.168.1.10:5000 --users 200 --duration 2m
```

### Option B – Locust Web UI
Opens a browser dashboard at http://localhost:8089 where you can watch live metrics:

```bash
locust -f locustfile.py --host http://localhost:5000
```

---

## 📊 What You Get

### Console Output (during run)
```
════════════════════════════════════════════════════════════
  LOAD TEST RESULTS
════════════════════════════════════════════════════════════
  Total Requests   : 7,284
  Requests/sec     : 121.40 req/s
  Failures         : 3  (0.04%)
  Avg Response     : 248.3 ms
  Min Response     : 12.0 ms
  Max Response     : 1,843.0 ms
════════════════════════════════════════════════════════════
  Excel Report     : results/MediConnect_Load_Test_Report.xlsx
════════════════════════════════════════════════════════════
```

### Excel Workbook (4 sheets)

| Sheet | Contents |
|-------|----------|
| **Summary** | KPI dashboard (RPS, avg/min/max, fail %, grade) + threshold checks |
| **Per-Endpoint Stats** | Row per endpoint: requests, failures, percentiles (50/90/95/99) |
| **Throughput History** | Time-series table + embedded bar chart of Req/s over time |
| **Failures** | All failed requests with error messages and occurrence counts |

---

## 🎯 Test Configuration

| Parameter | Value |
|-----------|-------|
| Virtual Users | 100 |
| Spawn Rate | 10 users/sec |
| Duration | 1 minute |
| Endpoints Tested | 14 API routes |

### Endpoints Covered

| Endpoint | Method | Weight |
|----------|--------|--------|
| `/` | GET | High |
| `/hospitals` | GET | High |
| `/get-hospital-beds` | GET | Medium |
| `/get-hospital-analytics` | GET | Medium |
| `/get-hospital-appointments` | GET | Medium |
| `/get-patient-profile` | GET | Medium |
| `/get-patient-appointments` | GET | Medium |
| `/get-doctor-summary` | GET | Medium |
| `/get-doctor-appointments` | GET | Medium |
| `/get-admin-hospital-summary` | GET | Medium |
| `/send-otp` | POST | Low |
| `/verify-otp` | POST | Low |
| `/update-hospital-beds` | POST | Low |
| `/update-appointment-status` | POST | Low |

---

## ✅ Pass / Fail Thresholds

| Metric | Target | Grade |
|--------|--------|-------|
| Avg Response Time | < 500 ms | PASS |
| Max Response Time | < 3,000 ms | PASS |
| Failure Rate | < 1 % | PASS |
| Requests/sec | > 10 req/s | PASS |
