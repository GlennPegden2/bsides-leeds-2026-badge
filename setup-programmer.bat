@echo off
REM BSides Leeds 2026 Badge - SerialUPDI Programmer Setup (Windows)
REM Guides you through setting up Arduino Uno R3 as a SerialUPDI programmer

echo.
echo ============================================================
echo   Arduino Uno R3 - SerialUPDI Programmer Setup
echo ============================================================
echo.

echo The Arduino Uno R3 can be used as a SerialUPDI programmer to flash
echo the ATtiny814 badge. This is simpler than traditional ISP programming!
echo.

echo What is SerialUPDI?
echo -------------------
echo SerialUPDI uses the Uno's USB-to-serial chip to program modern AVR chips
echo that use UPDI (Unified Program and Debug Interface) instead of ISP.
echo.

echo ============================================================
echo   Hardware Setup
echo ============================================================
echo.
echo You need:
echo   - Arduino Uno R3 (or compatible board with ATmega16U2/ATmega328P)
echo   - USB cable to connect Uno to computer
echo   - 4.7k resistor (recommended for reliability)
echo   - Jumper wires
echo   - The BSides Leeds 2026 badge
echo.

echo Connection Diagram:
echo.
echo   Arduino Uno R3          BSides Badge (ATtiny814)
echo   ─────────────           ─────────────────────────
echo        TX (pin 1) ────────┬──── UPDI (PA0)
echo                           │
echo                       4.7k resistor
echo                           │
echo        RX (pin 0) ────────┘
echo.
echo        GND ────────────────── GND
echo        5V ─────────────────── VCC (optional if badge has power)
echo.

echo Important Notes:
echo   1. The 4.7k resistor between TX and RX is REQUIRED
echo   2. Connect TX to both the resistor AND to UPDI
echo   3. Connect RX to the other end of the resistor
echo   4. Ensure common ground between Uno and badge
echo   5. The badge must be powered (via Uno 5V or battery)
echo.
pause

echo.
echo ============================================================
echo   Software Setup
echo ============================================================
echo.
echo Good news! No special firmware needed on the Uno.
echo The stock Uno firmware works perfectly with SerialUPDI.
echo.

echo [OK] Your Uno is ready to use as a programmer!
echo.

echo ============================================================
echo   Testing the Connection
echo ============================================================
echo.
echo To test if your setup works:
echo.
echo   1. Make the hardware connections as shown above
echo   2. Connect the Uno to your computer via USB
echo   3. Run build.bat to compile the firmware
echo   4. Run flash.bat to upload to the badge
echo.

echo ============================================================
echo   Troubleshooting
echo ============================================================
echo.
echo If upload fails, check:
echo   - All connections are secure
echo   - The 4.7k resistor is in place
echo   - Badge is powered
echo   - Correct COM port is selected (check Device Manager)
echo   - No other programs are using the serial port
echo   - Try a different USB cable
echo   - Install CH340 drivers if using a clone Uno
echo.

echo ============================================================
echo   Alternative: jtag2updi Firmware
echo ============================================================
echo.
echo If SerialUPDI doesn't work, you can use jtag2updi firmware:
echo.
echo   1. Open Arduino IDE
echo   2. Go to File - Examples - jtag2updi - jtag2updi
echo   3. Upload to your Uno R3
echo   4. Wire: Uno D6 - ATtiny UPDI (no resistor needed)
echo   5. Use --programmer jtag2updi when flashing
echo.
echo However, SerialUPDI is recommended as it requires no firmware changes.
echo.

pause
