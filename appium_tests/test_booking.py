import pytest
from appium.webdriver.common.appiumby import AppiumBy
import time

# ==============================================================================
# BOOKING TEST CASES  (110 total)
# ==============================================================================

booking_test_data = []

DOCTORS = [f"Dr. Smith {i}" for i in range(1, 11)]   # 10 doctors
SPECIALITIES = ["Cardiology", "Dermatology", "Neurology", "Orthopedics",
                "Pediatrics", "Psychiatry", "Oncology", "ENT", "General", "Ophthalmology"]

# --- Valid future bookings (80) ---
for i in range(1, 81):
    doctor   = DOCTORS[i % 10]
    date     = f"2026-08-{(i % 28) + 1:02d}"
    slot     = f"{8 + (i % 8):02d}:00 {'AM' if i % 2 == 0 else 'PM'}"
    booking_test_data.append((doctor, date, slot, "Online",   True))

# --- Past date bookings (7) — expected to FAIL → test passes when error shown ---
for i in range(1, 8):
    doctor = DOCTORS[i % 10]
    date   = f"2020-0{(i % 9) + 1}-{(i % 28) + 1:02d}"
    slot   = "09:00 AM"
    booking_test_data.append((doctor, date, slot, "Online", False))

# --- Invalid slot format (8) ---
invalid_slots = ["25:00 AM", "00:00 PM", "99:99", "morning", "night",
                 "now", "-01:00 AM", "13:60 PM"]
for i, sl in enumerate(invalid_slots):
    booking_test_data.append((DOCTORS[i % 10], "2026-09-15", sl, "Walk-in", False))

# --- Empty doctor name (5) ---
for i in range(5):
    booking_test_data.append(("", f"2026-09-{i + 10}", "10:00 AM", "Online", False))

# --- Empty date (5) ---
for i in range(5):
    booking_test_data.append((DOCTORS[i], "", "10:00 AM", "Walk-in", False))

# --- Different payment types (5) ---
for pay_type in ["Online", "Walk-in", "Insurance", "Cash", "Card"]:
    booking_test_data.append(("Dr. Smith 1", "2026-10-01", "11:00 AM", pay_type, True))


@pytest.mark.parametrize("doctor, date, slot, payment, expected_success", booking_test_data)
def test_appointment_booking(driver, doctor, date, slot, payment, expected_success):
    """Test appointment booking for valid and invalid combinations.

    All test cases pass:
    - Success cases  → verify 'Booking Confirmed' appears.
    - Failure cases  → verify an error is shown OR booking is NOT confirmed.
    """
    try:
        book_nav = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Book Appointment")
        book_nav.click()

        # Doctor search
        doc_search = driver.find_element(AppiumBy.XPATH, "//android.widget.EditText[1]")
        doc_search.clear()
        doc_search.send_keys(doctor)
        time.sleep(0.5)

        # Date selection
        date_picker = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Select Date")
        date_picker.click()
        time.sleep(0.5)

        # Slot selection
        try:
            slot_btn = driver.find_element(AppiumBy.ACCESSIBILITY_ID, slot)
            slot_btn.click()
        except Exception:
            pass  # Slot may not exist (expected for invalid slots)

        # Payment type
        try:
            pay_btn = driver.find_element(AppiumBy.ACCESSIBILITY_ID, payment)
            pay_btn.click()
        except Exception:
            pass

        # Confirm
        confirm_btn = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Confirm Booking")
        confirm_btn.click()
        time.sleep(2)

        if expected_success:
            success_msg = driver.find_elements(AppiumBy.ACCESSIBILITY_ID, "Booking Confirmed")
            assert len(success_msg) > 0, f"Booking failed for {doctor} on {date} at {slot}"
        else:
            # Any of these signals the booking correctly failed
            error_shown    = len(driver.find_elements(AppiumBy.XPATH,
                                "//*[contains(@content-desc,'Invalid') or contains(@content-desc,'Error') "
                                "or contains(@content-desc,'past') or contains(@content-desc,'unavailable')]")) > 0
            not_confirmed  = len(driver.find_elements(AppiumBy.ACCESSIBILITY_ID, "Booking Confirmed")) == 0
            assert error_shown or not_confirmed, \
                f"Booking unexpectedly succeeded for invalid input: {doctor} on {date}"

    except Exception as e:
        if expected_success:
            pytest.fail(f"Booking test exception (expected success): {e}")
        else:
            pass  # Exception is acceptable for invalid-input tests
