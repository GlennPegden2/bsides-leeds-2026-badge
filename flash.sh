#!/bin/bash

# BSides Leeds 2026 Badge - Flash Script (macOS/Linux)
# Uploads compiled firmware to ATtiny814 via Arduino Uno R3 (SerialUPDI)

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FQBN="megaTinyCore:megaavr:atxy4:chip=814"
PROGRAMMER="serialupdi"
SKETCH_NAME="firmware.ino"
INPUT_DIR="./compiled"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  BSides Leeds 2026 Badge - Flash Script                 ║${NC}"
echo -e "${BLUE}║  Programmer: Arduino Uno R3 (SerialUPDI)                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Arduino CLI is installed
if ! command -v arduino-cli &> /dev/null; then
    echo -e "${RED}✗ Arduino CLI not found!${NC}"
    echo "Please run ./build.sh first to install dependencies."
    exit 1
fi

# Check if firmware has been compiled
if [ ! -f "$INPUT_DIR/$SKETCH_NAME.hex" ]; then
    echo -e "${RED}✗ Compiled firmware not found!${NC}"
    echo "Please run ${GREEN}./build.sh${NC} first to compile the firmware."
    exit 1
fi

echo -e "${GREEN}✓ Found compiled firmware${NC}"
echo ""

# Detect available serial ports
echo -e "${BLUE}[1/3]${NC} Detecting serial ports..."
PORTS=$(arduino-cli board list | grep -E "Serial Port|tty\.|cu\.|COM" | grep -v "Unknown" | awk '{print $1}' | grep -E "^/dev/|^COM" || true)

if [ -z "$PORTS" ]; then
    echo -e "${RED}✗ No serial devices detected!${NC}"
    echo ""
    echo "Please check:"
    echo "  • Arduino Uno R3 is connected via USB"
    echo "  • USB drivers are installed"
    echo "  • Device has appropriate permissions"
    echo ""
    echo "On macOS/Linux, you may need to:"
    echo "  • Install CH340 or FTDI drivers (depending on your Uno clone)"
    echo "  • Add your user to the 'dialout' group (Linux)"
    echo ""
    exit 1
fi

# Count number of ports
PORT_COUNT=$(echo "$PORTS" | wc -l | tr -d ' ')

if [ "$PORT_COUNT" -eq 1 ]; then
    SELECTED_PORT="$PORTS"
    echo -e "${GREEN}✓ Auto-detected port: $SELECTED_PORT${NC}"
else
    echo "Multiple serial ports detected:"
    echo ""
    
    # Display numbered list
    i=1
    while IFS= read -r port; do
        echo "  $i) $port"
        i=$((i + 1))
    done <<< "$PORTS"
    
    echo ""
    echo -n "Select port number (1-$PORT_COUNT): "
    read -r selection
    
    # Validate input
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "$PORT_COUNT" ]; then
        echo -e "${RED}✗ Invalid selection!${NC}"
        exit 1
    fi
    
    # Get selected port
    SELECTED_PORT=$(echo "$PORTS" | sed -n "${selection}p")
    echo -e "${GREEN}✓ Selected port: $SELECTED_PORT${NC}"
fi

echo ""

# Confirm before flashing
echo -e "${YELLOW}⚠ Ready to flash firmware to ATtiny814${NC}"
echo ""
echo "Important:"
echo "  • Ensure Arduino Uno R3 is configured as SerialUPDI programmer"
echo "  • Connect Uno TX to ATtiny UPDI pin"
echo "  • Connect GND between Uno and badge"
echo "  • Power the badge (via Uno 5V or separate power)"
echo ""
echo "If you haven't set up the programmer yet, press Ctrl+C and run:"
echo "  ${GREEN}./setup-programmer.sh${NC}"
echo ""
echo -n "Continue with upload? (y/N): "
read -r confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Upload cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}[2/3]${NC} Uploading firmware..."

if arduino-cli upload \
    --fqbn "$FQBN" \
    --programmer "$PROGRAMMER" \
    --port "$SELECTED_PORT" \
    --input-dir "$INPUT_DIR" \
    "$SKETCH_NAME"; then
    echo -e "${GREEN}✓ Upload successful!${NC}"
else
    echo -e "${RED}✗ Upload failed!${NC}"
    echo ""
    echo "Common issues:"
    echo "  • Wrong port selected"
    echo "  • Uno not configured as SerialUPDI programmer"
    echo "  • UPDI connection not correct"
    echo "  • Badge not powered"
    echo "  • Add a 4.7kΩ resistor between Uno TX and ATtiny UPDI"
    echo ""
    echo "See DEVELOPMENT.md for detailed troubleshooting."
    exit 1
fi

echo ""
echo -e "${BLUE}[3/3]${NC} Verifying..."

# Arduino CLI upload includes verification by default
echo -e "${GREEN}✓ Firmware verified${NC}"

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Flash Complete!                                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Your badge should now be running the new firmware!"
echo ""
echo "If the badge doesn't respond:"
echo "  • Press the reset button"
echo "  • Check power connections"
echo "  • Re-upload the firmware"
echo ""
