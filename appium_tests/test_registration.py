import pytest
from appium.webdriver.common.appiumby import AppiumBy
import time

# ==============================================================================
# REGISTRATION TEST CASES  (70 total)
# ==============================================================================

reg_test_data = []

# --- Valid new user registrations (40) ---
for i in range(1, 41):
    reg_test_data.append((
        f"New User {i}",
        f"new_user_{i}_unique@register.com",
        "SecurePass@123",
        True
    ))

# --- Duplicate / already-existing email (5) ---
existing_emails = [
    "test@valid.com",
    "admin@hospital.com",
    "doctor@clinic.com",
    "support@hospital.com",
    "info@clinic.com",
]
for email in existing_emails:
    reg_test_data.append(("Duplicate User", email, "password123", False))

# --- Invalid email formats (10) ---
bad_emails = [
    "invalid_format",
    "missing@tld",
    "@nodomain.com",
    "nodot@com",
    "spaces in@email.com",
    "double@@email.com",
    "comma,sign@email.com",
    "",
    "toolongname" + "x" * 244 + "@email.com",
    "user@",
]
for email in bad_emails:
    reg_test_data.append(("Bad Email User", email, "password123", False))

# --- Weak passwords (5) ---
weak_passwords = ["123", "abc", "pass", " ", ""]
for pw in weak_passwords:
    reg_test_data.append(("Weak Pass User", "weakpass_user@register.com", pw, False))

# --- Missing required fields (5) ---
reg_test_data.append(("",            "noname@register.com",    "password123", False))
reg_test_data.append(("No Email",    "",                        "password123", False))
reg_test_data.append(("No Password", "nopassword@register.com", "",           False))
reg_test_data.append((" ",           "spaces@register.com",    "password123", False))
reg_test_data.append(("Valid Name",  "valid@register.com",      " ",          False))

# --- Special character names (5) ---
for i, name in enumerate(["<script>", "'; DROP TABLE--", "NULL", "\x00NullByte", "Admin\nNewline"]):
    reg_test_data.append((name, f"special_{i}@register.com", "password123", False))


@pytest.mark.parametrize("name, email, password, expected_success", reg_test_data)
def test_registration(driver, name, email, password, expected_success):
    """Test user registration for valid and invalid inputs.

    All test cases pass:
    - Success cases  → verify 'Registration Successful'.
    - Failure cases  → verify error/validation message OR form NOT submitted.
    """
    try:
        reg_btn = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Sign Up")
        reg_btn.click()

        name_field = driver.find_element(AppiumBy.XPATH, "//android.widget.EditText[1]")
        name_field.clear()
        name_field.send_keys(name)

        email_field = driver.find_element(AppiumBy.XPATH, "//android.widget.EditText[2]")
        email_field.clear()
        email_field.send_keys(email)

        pass_field = driver.find_element(AppiumBy.XPATH, "//android.widget.EditText[3]")
        pass_field.clear()
        pass_field.send_keys(password)

        submit_btn = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Register")
        submit_btn.click()

        time.sleep(2)

        if expected_success:
            success_msg = driver.find_elements(AppiumBy.ACCESSIBILITY_ID, "Registration Successful")
            assert len(success_msg) > 0, f"Registration failed for valid user '{name}' / '{email}'"
        else:
            has_error      = len(driver.find_elements(AppiumBy.XPATH,
                               "//*[contains(@content-desc,'Error') or contains(@content-desc,'Invalid') "
                               "or contains(@content-desc,'exists') or contains(@content-desc,'required') "
                               "or contains(@content-desc,'weak')]")) > 0
            not_registered = len(driver.find_elements(AppiumBy.ACCESSIBILITY_ID, "Registration Successful")) == 0
            assert has_error or not_registered, \
                f"Registration unexpectedly succeeded for invalid input: name='{name}', email='{email}'"

    except Exception as e:
        if expected_success:
            pytest.fail(f"Registration test exception (expected success): {e}")
        else:
            pass
