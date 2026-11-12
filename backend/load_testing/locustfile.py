"""
MediConnect Backend – Baseline / Load Test
==========================================
Configuration:
  - 100 virtual users
  - Spawn rate: 10 users/second  (all 100 up in 10 s)
  - Duration: 1 minute
  - Target: http://localhost:5000

Run via run_load_test.py  OR  manually:
  locust -f locustfile.py --headless -u 100 -r 10 --run-time 1m \
         --host http://localhost:5000 --csv=results/load_test
"""

# pyrefly: ignore [missing-import]
from locust import HttpUser, task, between, constant_throughput


class MediConnectUser(HttpUser):
    """Simulates a patient / general user browsing and using the app."""

    # Each user waits 0.5–2 seconds between tasks (realistic pacing)
    wait_time = between(0.5, 2)

    # ------------------------------------------------------------------ #
    #  Read-heavy / GET endpoints  (weighted higher – more realistic)
    # ------------------------------------------------------------------ #

    @task(5)
    def get_home(self):
        """Health-check / root endpoint."""
        with self.client.get("/", catch_response=True) as resp:
            if resp.status_code != 200:
                resp.failure(f"Home returned {resp.status_code}")

    @task(4)
    def get_hospitals(self):
        """List all hospitals."""
        with self.client.get("/hospitals", catch_response=True) as resp:
            if resp.status_code != 200:
                resp.failure(f"Hospitals returned {resp.status_code}")

    @task(3)
    def get_hospital_beds(self):
        """Check hospital bed availability."""
        with self.client.get("/get-hospital-beds?hospital_id=1", catch_response=True,
                             name="/get-hospital-beds") as resp:
            if resp.status_code not in (200, 400, 404):
                resp.failure(f"Hospital beds returned {resp.status_code}")

    @task(3)
    def get_hospital_analytics(self):
        """Fetch hospital analytics dashboard data."""
        with self.client.get("/get-hospital-analytics?hospital_id=1", catch_response=True,
                             name="/get-hospital-analytics") as resp:
            if resp.status_code in (200, 400, 404):
                resp.success()
            else:
                resp.failure(f"Analytics returned {resp.status_code}")

    @task(2)
    def get_hospital_appointments(self):
        """Fetch all hospital-level appointments."""
        with self.client.get(
            "/get-hospital-appointments?hospital_id=1",
            catch_response=True,
            name="/get-hospital-appointments"
        ) as resp:
            if resp.status_code in (200, 400, 404):
                resp.success()
            else:
                resp.failure(f"Hospital appointments returned {resp.status_code}")

    @task(2)
    def get_patient_profile(self):
        """Fetch a patient's profile (simulated with a test email param)."""
        with self.client.get(
            "/get-patient-profile?email=testuser@mediconnect.test",
            catch_response=True,
            name="/get-patient-profile"
        ) as resp:
            if resp.status_code not in (200, 400, 404):
                resp.failure(f"Patient profile returned {resp.status_code}")

    @task(2)
    def get_patient_appointments(self):
        """Fetch patient appointment list."""
        with self.client.get(
            "/get-patient-appointments?email=testuser@mediconnect.test",
            catch_response=True,
            name="/get-patient-appointments"
        ) as resp:
            if resp.status_code not in (200, 400, 404):
                resp.failure(f"Patient appointments returned {resp.status_code}")

    @task(2)
    def get_doctor_summary(self):
        """Fetch doctor summary stats."""
        with self.client.get(
            "/get-doctor-summary?doctor_id=DOC001",
            catch_response=True,
            name="/get-doctor-summary"
        ) as resp:
            if resp.status_code not in (200, 400, 404):
                resp.failure(f"Doctor summary returned {resp.status_code}")

    @task(2)
    def get_doctor_appointments(self):
        """Fetch doctor-level appointment list."""
        with self.client.get(
            "/get-doctor-appointments?doctor_id=DOC001",
            catch_response=True,
            name="/get-doctor-appointments"
        ) as resp:
            if resp.status_code not in (200, 400, 404):
                resp.failure(f"Doctor appointments returned {resp.status_code}")

    @task(2)
    def get_admin_hospital_summary(self):
        """Fetch admin hospital summary."""
        with self.client.get(
            "/get-admin-hospital-summary?admin_id=ADM001",
            catch_response=True,
            name="/get-admin-hospital-summary"
        ) as resp:
            if resp.status_code not in (200, 400, 404):
                resp.failure(f"Admin hospital summary returned {resp.status_code}")

    # ------------------------------------------------------------------ #
    #  Write / POST endpoints  (lower weight – less frequent)
    # ------------------------------------------------------------------ #

    @task(1)
    def send_otp(self):
        """Trigger OTP generation (POST)."""
        with self.client.post(
            "/send-otp",
            json={"email": "loadtest@mediconnect.test"},
            catch_response=True
        ) as resp:
            # 200 = sent, 400 = validation error, 500 = email provider error (expected in test env)
            if resp.status_code in (200, 400, 500):
                resp.success()
            else:
                resp.failure(f"Send OTP returned {resp.status_code}")

    @task(1)
    def verify_otp_invalid(self):
        """Simulate an OTP verify call (will return 'Invalid OTP' – that's fine)."""
        with self.client.post(
            "/verify-otp",
            json={"email": "loadtest@mediconnect.test", "otp": "000000"},
            catch_response=True
        ) as resp:
            if resp.status_code in (200, 400):
                resp.success()
            else:
                resp.failure(f"Verify OTP returned {resp.status_code}")

    @task(1)
    def update_hospital_beds(self):
        """Simulate updating hospital bed count."""
        with self.client.post(
            "/update-hospital-beds",
            json={
                "hospital_id": 1,
                "available_beds": 50
            },
            catch_response=True
        ) as resp:
            if resp.status_code in (200, 400, 404):
                resp.success()
            else:
                resp.failure(f"Update beds returned {resp.status_code}")

    @task(1)
    def update_appointment_status(self):
        """Simulate updating an appointment status."""
        with self.client.post(
            "/update-appointment-status",
            json={"appointment_id": 9999, "status": "completed"},
            catch_response=True
        ) as resp:
            if resp.status_code in (200, 400, 404):
                resp.success()
            else:
                resp.failure(f"Update appointment status returned {resp.status_code}")
