@echo off
REM BSides Leeds 2026 Badge - Build Script (Windows)
REM Compiles the ATtiny814 firmware using Arduino CLI

setlocal enabledelayedexpansion

REM Configuration
set FQBN=megaTinyCore:megaavr:atxy4:chip=814
set BOARD_MANAGER_URL=http://drazzy.com/package_drazzy.com_index.json
set CORE_PACKAGE=megaTinyCore:megaavr
set SKETCH_NAME=firmware.ino
set OUTPUT_DIR=.\compiled
set BACKUP_DIR=.\compiled\backup

REM Memory limits (in bytes)
set FLASH_SIZE=8192
set RAM_SIZE=512
set /a FLASH_WARNING_THRESHOLD=FLASH_SIZE * 90 / 100
set /a RAM_WARNING_THRESHOLD=RAM_SIZE * 80 / 100

echo.
echo ============================================================
echo   BSides Leeds 2026 Badge - Build Script
echo   Target: ATtiny814
echo ============================================================
echo.

REM Check if Arduino CLI is installed
echo [1/6] Checking for Arduino CLI...
where arduino-cli >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Arduino CLI not found!
    echo.
    echo Please install Arduino CLI using one of these methods:
    echo.
    echo   Using winget:
    echo     winget install ArduinoSA.CLI
    echo.
    echo   Using Chocolatey:
    echo     choco install arduino-cli
    echo.
    echo   Manual download:
    echo     https://github.com/arduino/arduino-cli/releases/latest
    echo     Download arduino-cli_*_Windows_64bit.zip
    echo     Extract arduino-cli.exe to a folder in your PATH
    echo.
    echo After installation, run this script again.
    pause
    exit /b 1
)
echo [OK] Arduino CLI found
arduino-cli version | findstr /C:"arduino-cli"

REM Initialize config if needed
if not exist "%USERPROFILE%\.arduino15\arduino-cli.yaml" (
    echo [2/6] Initializing Arduino CLI configuration...
    arduino-cli config init
) else (
    echo [2/6] Checking board manager configuration...
)

REM Check if board manager URL is configured
arduino-cli config dump | findstr /C:"drazzy.com" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo   Adding MegaTinyCore board manager URL...
    arduino-cli config add board_manager.additional_urls %BOARD_MANAGER_URL%
    arduino-cli core update-index
)
echo [OK] Board manager configured

REM Check if MegaTinyCore is installed
echo [3/6] Checking for MegaTinyCore...
arduino-cli core list | findstr /C:"megaTinyCore:megaavr" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo   MegaTinyCore not found. Installing...
    arduino-cli core update-index
    arduino-cli core install %CORE_PACKAGE%
    echo [OK] MegaTinyCore installed
) else (
    echo [OK] MegaTinyCore already installed
)

REM Create backup of existing firmware if this is first build
if exist "%OUTPUT_DIR%\firmware.hex" (
    if not exist "%BACKUP_DIR%" (
        echo [4/6] Backing up original firmware...
        mkdir "%BACKUP_DIR%"
        copy "%OUTPUT_DIR%\firmware.hex" "%BACKUP_DIR%\firmware.hex.original" >nul
        if exist "%OUTPUT_DIR%\firmware.bin" copy "%OUTPUT_DIR%\firmware.bin" "%BACKUP_DIR%\firmware.bin.original" >nul
        echo [OK] Original firmware backed up to %BACKUP_DIR%
        goto backup_done
    )
)
echo [4/6] Skipping backup (already exists or no previous build)
:backup_done

REM Compile the firmware
echo [5/6] Compiling firmware...
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

arduino-cli compile --fqbn "%FQBN%" --output-dir "%OUTPUT_DIR%" --export-binaries "%SKETCH_NAME%" 2>&1 | tee build.log
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed!
    echo Check the output above for errors.
    pause
    exit /b 1
)
echo [OK] Compilation successful

REM Parse memory usage
echo [6/6] Checking memory usage...

REM Try to extract from build log
set FLASH_USED=0
set RAM_USED=0

for /f "tokens=3" %%a in ('findstr /C:"Sketch uses" build.log') do set FLASH_USED=%%a
for /f "tokens=4" %%a in ('findstr /C:"Global variables use" build.log') do set RAM_USED=%%a

if !FLASH_USED! GTR 0 (
    set /a FLASH_PERCENT=FLASH_USED * 100 / FLASH_SIZE
    set /a RAM_PERCENT=RAM_USED * 100 / RAM_SIZE
    
    echo.
    echo   Flash:  !FLASH_USED! / !FLASH_SIZE! bytes ^(!FLASH_PERCENT!%%^)
    echo   RAM:    !RAM_USED! / !RAM_SIZE! bytes ^(!RAM_PERCENT!%%^)
    echo.
    
    REM Check for warnings
    set WARNED=0
    if !FLASH_USED! GEQ !FLASH_WARNING_THRESHOLD! (
        echo [WARNING] Flash usage is above 90%%!
        echo   Consider optimizing code to free up space.
        set WARNED=1
    )
    
    if !RAM_USED! GEQ !RAM_WARNING_THRESHOLD! (
        echo [WARNING] RAM usage is above 80%%!
        echo   Watch out for stack overflow at runtime.
        set WARNED=1
    )
    
    if !WARNED! EQU 0 (
        echo [OK] Memory usage is within safe limits
    )
) else (
    echo [WARNING] Could not parse memory usage
)

REM Clean up temporary log
if exist build.log del build.log

REM Summary
echo.
echo ============================================================
echo   Build Complete!
echo ============================================================
echo.
echo Compiled files:
echo   - %OUTPUT_DIR%\%SKETCH_NAME%.hex
echo   - %OUTPUT_DIR%\%SKETCH_NAME%.bin
echo   - %OUTPUT_DIR%\%SKETCH_NAME%.elf
echo.
echo Next steps:
echo   1. Connect Arduino Uno R3 (as programmer) to your computer
echo   2. Run: flash.bat
echo.
pause
