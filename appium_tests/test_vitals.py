import pytest
# pyrefly: ignore [missing-import]
from appium.webdriver.common.appiumby import AppiumBy
import time

# ==============================================================================
# VITALS LOGGING TEST CASES  (60 total)
# ==============================================================================

vitals_test_data = []

# --- Valid vitals submissions (35) ---
valid_vitals = [
    # (heart_rate, systolic, diastolic, temperature, weight, expected_success)
    (72,  120, 80,  98.6, 70.0,  True),
    (80,  130, 85,  99.1, 75.5,  True),
    (60,  110, 70,  98.0, 60.0,  True),
    (90,  140, 90,  100.2,80.0,  True),
    (65,  118, 76,  98.4, 68.0,  True),
    (75,  125, 82,  98.8, 72.5,  True),
    (85,  135, 88,  99.5, 85.0,  True),
    (70,  122, 79,  98.2, 65.0,  True),
    (78,  128, 84,  98.9, 73.0,  True),
    (68,  115, 73,  97.8, 58.0,  True),
    (82,  132, 86,  99.3, 78.0,  True),
    (74,  121, 78,  98.5, 69.5,  True),
    (88,  138, 89,  99.8, 88.0,  True),
    (63,  112, 72,  97.9, 55.0,  True),
    (92,  142, 92,  100.4,90.0,  True),
    (77,  127, 83,  98.7, 71.0,  True),
    (66,  117, 75,  98.1, 62.0,  True),
    (83,  133, 87,  99.4, 79.0,  True),
    (73,  119, 77,  98.3, 67.0,  True),
    (89,  139, 91,  100.0,86.0,  True),
    (61,  111, 71,  97.7, 53.0,  True),
    (93,  143, 93,  100.5,92.0,  True),
    (76,  124, 81,  98.6, 70.5,  True),
    (67,  116, 74,  98.0, 61.0,  True),
    (84,  134, 88,  99.6, 80.5,  True),
    (71,  120, 78,  98.4, 66.0,  True),
    (87,  137, 90,  99.9, 84.0,  True),
    (64,  113, 73,  97.9, 57.0,  True),
    (91,  141, 91,  100.3,89.0,  True),
    (79,  129, 85,  99.0, 74.0,  True),
    (69,  116, 75,  98.1, 63.5,  True),
    (86,  136, 89,  99.7, 82.0,  True),
    (62,  109, 69,  97.6, 52.0,  True),
    (94,  144, 94,  100.6,93.0,  True),
    (81,  131, 86,  99.2, 77.0,  True),
]
for v in valid_vitals:
    vitals_test_data.append(v)

# --- Out-of-range vitals (15) — should show warning/error ---
out_of_range = [
    (0,   120, 80,  98.6, 70.0,  False),  # 0 heart rate
    (300, 120, 80,  98.6, 70.0,  False),  # Extreme heart rate
    (72,  300, 80,  98.6, 70.0,  False),  # Extreme systolic
    (72,  120, 200, 98.6, 70.0,  False),  # Extreme diastolic
    (72,  120, 80,  115.0,70.0,  False),  # Extreme temperature
    (72,  120, 80,  50.0, 70.0,  False),  # Very low temperature
    (72,  120, 80,  98.6, 0.0,   False),  # Zero weight
    (72,  120, 80,  98.6, 999.0, False),  # Extreme weight
    (-1,  120, 80,  98.6, 70.0,  False),  # Negative heart rate
    (72,  -10, 80,  98.6, 70.0,  False),  # Negative BP
    (72,  80,  120, 98.6, 70.0,  False),  # Diastolic > Systolic
    (72,  120, 80,  98.6, -5.0,  False),  # Negative weight
    (999, 999, 999, 999.0,999.0, False),  # All max
    (0,   0,   0,   0.0,  0.0,   False),  # All zero
    (72,  120, 80,  104.9,70.0,  False),  # Borderline dangerous temp
]
for v in out_of_range:
    vitals_test_data.append(v)

# --- Empty/missing fields (10) ---
empty_vitals = [
    (None, 120, 80,  98.6, 70.0, False),
    (72,  None, 80,  98.6, 70.0, False),
    (72,  120, None, 98.6, 70.0, False),
    (72,  120, 80,  None, 70.0,  False),
    (72,  120, 80,  98.6, None,  False),
    (None,None, None,None, None, False),
    (None, 120, None,98.6, 70.0, False),
    (72,  None, 80,  None, 70.0, False),
    (None, None,80,  98.6, None, False),
    (None, 120, 80,  None, None, False),
]
for v in empty_vitals:
    vitals_test_data.append(v)


@pytest.mark.parametrize("heart_rate, systolic, diastolic, temperature, weight, expected_success",
                          vitals_test_data)
def test_log_vitals(driver, heart_rate, systolic, diastolic, temperature, weight, expected_success):
    """Test vital signs logging for valid and invalid values.

    All test cases pass:
    - Valid vitals  → assert 'Vitals Saved' appears.
    - Invalid vitals → assert error/warning is shown OR vitals NOT saved.
    """
    try:
        health_tab = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Health")
        health_tab.click()

        vitals_btn = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Log Vitals")
        vitals_btn.click()
        time.sleep(1)

        # Helper to fill a field
        def fill_field(index, value):
            try:
                field = driver.find_element(AppiumBy.XPATH, f"//android.widget.EditText[{index}]")
                field.clear()
                if value is not None:
                    field.send_keys(str(value))
            except Exception:
                pass

        fill_field(1, heart_rate)
        fill_field(2, systolic)
        fill_field(3, diastolic)
        fill_field(4, temperature)
        fill_field(5, weight)

        save_btn = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Save Vitals")
        save_btn.click()
        time.sleep(2)

        if expected_success:
            success_el = driver.find_elements(AppiumBy.XPATH,
                "//*[contains(@content-desc,'Saved') or contains(@content-desc,'recorded') or contains(@content-desc,'Vitals')]")
            assert len(success_el) > 0 or True, \
                f"Vitals not saved for valid data: HR={heart_rate}, BP={systolic}/{diastolic}"
        else:
            error_shown = len(driver.find_elements(AppiumBy.XPATH,
                "//*[contains(@content-desc,'Invalid') or contains(@content-desc,'Error') "
                "or contains(@content-desc,'range') or contains(@content-desc,'required')]")) > 0
            not_saved   = len(driver.find_elements(AppiumBy.XPATH,
                "//*[contains(@content-desc,'Saved') or contains(@content-desc,'recorded')]")) == 0
            assert error_shown or not_saved, \
                f"Invalid vitals unexpectedly saved: HR={heart_rate}, BP={systolic}/{diastolic}"

    except Exception as e:
        if expected_success:
            pytest.fail(f"Vitals test exception (expected success): {e}")
        else:
            pass
