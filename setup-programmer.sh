#!/bin/bash

# BSides Leeds 2026 Badge - SerialUPDI Programmer Setup (macOS/Linux)
# Guides you through setting up Arduino Uno R3 as a SerialUPDI programmer

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Arduino Uno R3 → SerialUPDI Programmer Setup            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo "The Arduino Uno R3 can be used as a SerialUPDI programmer to flash"
echo "the ATtiny814 badge. This is simpler than traditional ISP programming!"
echo ""

echo -e "${YELLOW}What is SerialUPDI?${NC}"
echo "SerialUPDI uses the Uno's USB-to-serial chip to program modern AVR chips"
echo "that use UPDI (Unified Program and Debug Interface) instead of ISP."
echo ""

echo -e "${BLUE}═══ Hardware Setup ═══${NC}"
echo ""
echo "You need:"
echo "  • Arduino Uno R3 (or compatible board with ATmega16U2/ATmega328P)"
echo "  • USB cable to connect Uno to computer"
echo "  • 4.7kΩ resistor (recommended for reliability)"
echo "  • Jumper wires"
echo "  • The BSides Leeds 2026 badge"
echo ""

echo -e "${GREEN}Connection Diagram:${NC}"
echo ""
echo "  Arduino Uno R3          BSides Badge (ATtiny814)"
echo "  ─────────────           ─────────────────────────"
echo "       TX (pin 1) ────────┬──── UPDI (PA0)"
echo "                          │"
echo "                      4.7kΩ resistor"
echo "                          │"
echo "       RX (pin 0) ────────┘"
echo ""
echo "       GND ────────────────── GND"
echo "       5V ─────────────────── VCC (optional if badge has power)"
echo ""

echo -e "${YELLOW}Important Notes:${NC}"
echo "  1. The 4.7kΩ resistor between TX and RX is REQUIRED"
echo "  2. Connect TX to both the resistor AND to UPDI"
echo "  3. Connect RX to the other end of the resistor"
echo "  4. Ensure common ground between Uno and badge"
echo "  5. The badge must be powered (via Uno 5V or battery)"
echo ""

echo -e "${BLUE}═══ Software Setup ═══${NC}"
echo ""
echo "Good news! No special firmware needed on the Uno."
echo "The stock Uno firmware works perfectly with SerialUPDI."
echo ""

echo -e "${GREEN}✓ Your Uno is ready to use as a programmer!${NC}"
echo ""

echo -e "${BLUE}═══ Testing the Connection ═══${NC}"
echo ""
echo "To test if your setup works:"
echo ""
echo "  1. Make the hardware connections as shown above"
echo "  2. Connect the Uno to your computer via USB"
echo "  3. Run ${GREEN}./build.sh${NC} to compile the firmware"
echo "  4. Run ${GREEN}./flash.sh${NC} to upload to the badge"
echo ""

echo -e "${YELLOW}⚠ Troubleshooting${NC}"
echo ""
echo "If upload fails, check:"
echo "  • All connections are secure"
echo "  • The 4.7kΩ resistor is in place"
echo "  • Badge is powered"
echo "  • Correct COM port is selected"
echo "  • No other programs are using the serial port"
echo "  • Try a different USB cable"
echo ""

echo -e "${BLUE}═══ Alternative: jtag2updi Firmware ═══${NC}"
echo ""
echo "If SerialUPDI doesn't work, you can use jtag2updi firmware:"
echo ""
echo "  1. Open Arduino IDE"
echo "  2. Go to File → Examples → jtag2updi → jtag2updi"
echo "  3. Upload to your Uno R3"
echo "  4. Wire: Uno D6 → ATtiny UPDI (no resistor needed)"
echo "  5. Use --programmer jtag2updi when flashing"
echo ""
echo "However, SerialUPDI is recommended as it requires no firmware changes."
echo ""

read -p "Press Enter to continue..."
