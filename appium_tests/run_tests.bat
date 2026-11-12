@echo off
setlocal

echo =======================================================
echo  MedCare App - Full E2E Automated Test Suite
echo  Target: 300+ test cases, all passing
echo =======================================================

:: -------------------------------------------------------
:: Step 1: Build the Flutter debug APK
:: -------------------------------------------------------
echo.
echo [1/3] Building Flutter APK...
cd ..
call flutter build apk --debug
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter build failed. Exiting.
    pause
    exit /b 1
)

:: -------------------------------------------------------
:: Step 2: Run all tests with verbose output + Excel report
:: -------------------------------------------------------
echo.
echo [2/3] Running all test suites...
cd appium_tests
call pytest -v ^
    test_login.py ^
    test_registration.py ^
    test_booking.py ^
    test_ai.py ^
    test_vitals.py ^
    test_doctor.py ^
    test_admin.py ^
    test_profile_settings.py ^
    test_hospital_search.py ^
    test_notifications.py ^
    test_patient_appointments.py ^
    --excelreport=report.xlsx ^
    --tb=short ^
    -q

:: -------------------------------------------------------
:: Step 3: Summary
:: -------------------------------------------------------
echo.
echo [3/3] Test run complete!
echo =======================================================
echo  Results saved to: appium_tests\report.xlsx
echo =======================================================
echo.
echo  Test file breakdown:
echo    test_login.py              ~  75 cases
echo    test_registration.py       ~  70 cases
echo    test_booking.py            ~ 110 cases
echo    test_ai.py                 ~ 100 cases
echo    test_vitals.py             ~  60 cases
echo    test_doctor.py             ~  60 cases
echo    test_admin.py              ~  55 cases
echo    test_profile_settings.py   ~  50 cases
echo    test_hospital_search.py    ~  45 cases
echo    test_notifications.py      ~  35 cases
echo    test_patient_appointments.py~ 40 cases
echo   -------------------------------------------
echo    TOTAL                      ~ 700+ cases
echo =======================================================
pause
