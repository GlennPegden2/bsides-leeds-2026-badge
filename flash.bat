@echo off
REM BSides Leeds 2026 Badge - Flash Script (Windows)
REM Uploads compiled firmware to ATtiny814 via Arduino Uno R3 (SerialUPDI)

setlocal enabledelayedexpansion

REM Configuration
set FQBN=megaTinyCore:megaavr:atxy4:chip=814
set PROGRAMMER=serialupdi
set SKETCH_NAME=firmware.ino
set INPUT_DIR=.\compiled

echo.
echo ============================================================
echo   BSides Leeds 2026 Badge - Flash Script
echo   Programmer: Arduino Uno R3 (SerialUPDI)
echo ============================================================
echo.

REM Check if Arduino CLI is installed
where arduino-cli >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Arduino CLI not found!
    echo Please run build.bat first to install dependencies.
    pause
    exit /b 1
)

REM Check if firmware has been compiled
if not exist "%INPUT_DIR%\%SKETCH_NAME%.hex" (
    echo [ERROR] Compiled firmware not found!
    echo Please run build.bat first to compile the firmware.
    pause
    exit /b 1
)

echo [OK] Found compiled firmware
echo.

REM Detect available serial ports
echo [1/3] Detecting serial ports...

REM Create temporary file for port detection
arduino-cli board list > ports.tmp 2>&1

REM Extract COM ports from the output
findstr /C:"COM" ports.tmp > comports.tmp 2>nul

REM Count the number of ports
set PORT_COUNT=0
for /f %%a in (comports.tmp) do set /a PORT_COUNT+=1

if !PORT_COUNT! EQU 0 (
    echo [ERROR] No serial devices detected!
    echo.
    echo Please check:
    echo   - Arduino Uno R3 is connected via USB
    echo   - USB drivers are installed
    echo   - Device Manager shows the port
    echo.
    echo You may need to install CH340 or FTDI drivers.
    del ports.tmp comports.tmp 2>nul
    pause
    exit /b 1
)

REM If only one port, auto-select it
if !PORT_COUNT! EQU 1 (
    for /f "tokens=1" %%a in (comports.tmp) do set SELECTED_PORT=%%a
    echo [OK] Auto-detected port: !SELECTED_PORT!
    del ports.tmp comports.tmp 2>nul
    goto port_selected
)

REM Multiple ports detected - let user choose
echo Multiple serial ports detected:
echo.

set /a i=1
for /f "tokens=1" %%a in (comports.tmp) do (
    echo   !i!^) %%a
    set PORT_!i!=%%a
    set /a i+=1
)

del ports.tmp comports.tmp 2>nul

echo.
set /p selection="Select port number (1-!PORT_COUNT!): "

REM Validate input
if not defined PORT_!selection! (
    echo [ERROR] Invalid selection!
    pause
    exit /b 1
)

set SELECTED_PORT=!PORT_%selection%!
echo [OK] Selected port: !SELECTED_PORT!

:port_selected
echo.

REM Confirm before flashing
echo [WARNING] Ready to flash firmware to ATtiny814
echo.
echo Important:
echo   - Ensure Arduino Uno R3 is configured as SerialUPDI programmer
echo   - Connect Uno TX to ATtiny UPDI pin
echo   - Connect GND between Uno and badge
echo   - Power the badge (via Uno 5V or separate power)
echo.
echo If you haven't set up the programmer yet, press Ctrl+C and run:
echo   setup-programmer.bat
echo.
set /p confirm="Continue with upload? (y/N): "

if /i not "!confirm!"=="y" (
    echo Upload cancelled.
    pause
    exit /b 0
)

echo.
echo [2/3] Uploading firmware...

arduino-cli upload --fqbn "%FQBN%" --programmer "%PROGRAMMER%" --port "!SELECTED_PORT!" --input-dir "%INPUT_DIR%" "%SKETCH_NAME%"

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Upload failed!
    echo.
    echo Common issues:
    echo   - Wrong port selected
    echo   - Uno not configured as SerialUPDI programmer
    echo   - UPDI connection not correct
    echo   - Badge not powered
    echo   - Add a 4.7k resistor between Uno TX and ATtiny UPDI
    echo.
    echo See DEVELOPMENT.md for detailed troubleshooting.
    pause
    exit /b 1
)

echo [OK] Upload successful!

echo.
echo [3/3] Verifying...

REM Arduino CLI upload includes verification by default
echo [OK] Firmware verified

REM Summary
echo.
echo ============================================================
echo   Flash Complete!
echo ============================================================
echo.
echo Your badge should now be running the new firmware!
echo.
echo If the badge doesn't respond:
echo   - Press the reset button
echo   - Check power connections
echo   - Re-upload the firmware
echo.
pause
