import pytest
import os
import socket
from appium import webdriver
from appium.options.android import UiAutomator2Options

@pytest.fixture(scope="session")
def driver():
    # Setup Appium Options
    options = UiAutomator2Options()
    options.platform_name = 'Android'
    options.automation_name = 'UiAutomator2'
    options.device_name = 'Android Emulator' # Assumes default emulator
    
    # Locate the compiled APK in the Flutter build folder
    apk_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'build', 'app', 'outputs', 'flutter-apk', 'app-debug.apk'))
    if not os.path.exists(apk_path):
        pytest.skip(f"APK not found at {apk_path}. Build the Flutter app before running Appium tests.", allow_module_level=True)
    options.app = apk_path
    
    # Do not clear app data between tests for speed, unless necessary
    options.no_reset = False 
    
    # Check Appium server availability and initialize the Appium driver
    try:
        conn = socket.create_connection(("127.0.0.1", 4723), timeout=3)
        conn.close()
    except OSError:
        pytest.skip("Appium server not running at http://127.0.0.1:4723 — start Appium to run these tests.", allow_module_level=True)

    driver = webdriver.Remote('http://127.0.0.1:4723', options=options)
    driver.implicitly_wait(10)
    
    yield driver
    
    # Teardown
    driver.quit()
