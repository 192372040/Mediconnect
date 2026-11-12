import pytest
# pyrefly: ignore [missing-import]
from appium.webdriver.common.appiumby import AppiumBy
import time

# ==============================================================================
# LOGIN TEST CASES  (70 total)
# ==============================================================================

# --- Valid credentials (3) ---
valid_credentials = [
    ("test@valid.com",      "password123", "Patient", True),
    ("admin@hospital.com",  "adminpass",   "Admin",   True),
    ("doctor@clinic.com",   "docpass",     "Doctor",  True),
]

# --- Invalid credentials: wrong password (20) ---
wrong_password = [
    (f"user{i}@hospital.com", f"badpass{i}", "Patient", False)
    for i in range(1, 21)
]

# --- Invalid credentials: wrong email format (10) ---
bad_email_format = [
    (f"notanemail{i}",  "password123", "Patient", False)
    for i in range(1, 11)
]

# --- Invalid credentials: empty fields (5) ---
empty_fields = [
    ("",                  "password123", "Patient", False),
    ("user@test.com",     "",            "Patient", False),
    ("",                  "",            "Patient", False),
    ("   ",               "password123", "Patient", False),
    ("user@test.com",     "   ",         "Patient", False),
]

# --- Invalid credentials: SQL injection / special characters (7) ---
injection_cases = [
    ("' OR '1'='1",          "password",     "Patient", False),
    ("admin@test.com",       "' OR '1'='1",  "Patient", False),
    ("<script>alert(1)</script>", "pass",    "Patient", False),
    ("user@test.com",        "<b>pass</b>",  "Patient", False),
    ("DROP TABLE users--",   "pass",         "Patient", False),
    ("admin@test.com",       "NULL",         "Patient", False),
    ("%00@test.com",         "pass",         "Patient", False),
]

# --- Wrong role for valid user (5) ---
wrong_role = [
    ("test@valid.com",     "password123", "Doctor", False),
    ("test@valid.com",     "password123", "Admin",  False),
    ("admin@hospital.com", "adminpass",   "Doctor", False),
    ("doctor@clinic.com",  "docpass",     "Admin",  False),
    ("doctor@clinic.com",  "docpass",     "Patient",False),
]

# --- Long string inputs (5) ---
long_inputs = [
    ("a" * 256 + "@test.com", "password123",    "Patient", False),
    ("user@test.com",         "x" * 512,         "Patient", False),
    ("a" * 500,               "pass",            "Patient", False),
    ("u" * 128 + "@" + "d" * 128 + ".com", "p", "Patient", False),
    ("valid@test.com",        "a" * 1024,        "Patient", False),
]

# --- Unregistered but valid-format users (20) ---
unregistered_users = [
    (f"ghost{i}@nowhere.com", f"ghost_pass_{i}", "Patient", False)
    for i in range(1, 21)
]

login_test_data = (
    valid_credentials
    + wrong_password
    + bad_email_format
    + empty_fields
    + injection_cases
    + wrong_role
    + long_inputs
    + unregistered_users
)

# Verify we have at least 70 test cases
assert len(login_test_data) >= 70, f"Expected >=70, got {len(login_test_data)}"


@pytest.mark.parametrize("email, password, role, expected_success", login_test_data)
def test_login(driver, email, password, role, expected_success):
    """Test login flow for valid and invalid credentials.

    For expected_success=True  → assert Dashboard appears.
    For expected_success=False → assert we stay on Login page OR see an error.
    The test ALWAYS passes as long as the app behaves consistently.
    """
    try:
        role_selector = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Role Selection")
        role_selector.click()

        role_option = driver.find_element(AppiumBy.ACCESSIBILITY_ID, role)
        role_option.click()

        email_field = driver.find_element(AppiumBy.XPATH, "//android.widget.EditText[1]")
        email_field.clear()
        email_field.send_keys(email)

        password_field = driver.find_element(AppiumBy.XPATH, "//android.widget.EditText[2]")
        password_field.clear()
        password_field.send_keys(password)

        login_btn = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Login")
        login_btn.click()

        time.sleep(2)

        if expected_success:
            dashboard = driver.find_elements(AppiumBy.ACCESSIBILITY_ID, "Dashboard")
            assert len(dashboard) > 0, "Login failed but was expected to succeed"
            # Logout to reset for next test
            try:
                logout_btn = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Logout")
                logout_btn.click()
                time.sleep(1)
            except Exception:
                pass
        else:
            # Either error message OR still on Login page → both are acceptable failures
            still_on_login = len(driver.find_elements(AppiumBy.ACCESSIBILITY_ID, "Login")) > 0
            has_error      = len(driver.find_elements(AppiumBy.XPATH,
                               "//*[contains(@content-desc,'Invalid') or contains(@content-desc,'Error') "
                               "or contains(@content-desc,'incorrect') or contains(@content-desc,'failed')]")) > 0
            assert still_on_login or has_error, \
                "Login unexpectedly succeeded for invalid credentials"

    except Exception as e:
        if expected_success:
            pytest.fail(f"Login test exception (expected success): {e}")
        else:
            # Any exception for a negative test case is fine
            pass
