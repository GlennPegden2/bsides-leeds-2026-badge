#!/bin/bash

# BSides Leeds 2026 Badge - Build Script (macOS/Linux)
# Compiles the ATtiny814 firmware using Arduino CLI

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FQBN="megaTinyCore:megaavr:atxy4:chip=814"
BOARD_MANAGER_URL="http://drazzy.com/package_drazzy.com_index.json"
CORE_PACKAGE="megaTinyCore:megaavr"
SKETCH_NAME="firmware.ino"
OUTPUT_DIR="./compiled"
BACKUP_DIR="./compiled/backup"

# Memory limits (in bytes)
FLASH_SIZE=8192
RAM_SIZE=512
FLASH_WARNING_THRESHOLD=$((FLASH_SIZE * 90 / 100))  # 90% = 7373 bytes
RAM_WARNING_THRESHOLD=$((RAM_SIZE * 80 / 100))      # 80% = 410 bytes

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  BSides Leeds 2026 Badge - Build Script                 ║${NC}"
echo -e "${BLUE}║  Target: ATtiny814                                       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Arduino CLI is installed
echo -e "${BLUE}[1/6]${NC} Checking for Arduino CLI..."
if ! command -v arduino-cli &> /dev/null; then
    echo -e "${RED}✗ Arduino CLI not found!${NC}"
    echo ""
    echo "Please install Arduino CLI using one of these methods:"
    echo ""
    echo "  macOS (using Homebrew):"
    echo "    ${GREEN}brew install arduino-cli${NC}"
    echo ""
    echo "  macOS/Linux (using installer):"
    echo "    ${GREEN}curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh${NC}"
    echo ""
    echo "After installation, run this script again."
    exit 1
fi
echo -e "${GREEN}✓ Arduino CLI found: $(arduino-cli version | head -n 1)${NC}"

# Initialize config if needed
if [ ! -f ~/.arduino15/arduino-cli.yaml ]; then
    echo -e "${BLUE}[2/6]${NC} Initializing Arduino CLI configuration..."
    arduino-cli config init
fi

# Check if board manager URL is configured
echo -e "${BLUE}[2/6]${NC} Checking board manager configuration..."
if ! arduino-cli config dump | grep -q "drazzy.com"; then
    echo "  Adding MegaTinyCore board manager URL..."
    arduino-cli config add board_manager.additional_urls "$BOARD_MANAGER_URL"
    arduino-cli core update-index
fi
echo -e "${GREEN}✓ Board manager configured${NC}"

# Check if MegaTinyCore is installed
echo -e "${BLUE}[3/6]${NC} Checking for MegaTinyCore..."
if ! arduino-cli core list | grep -q "megaTinyCore:megaavr"; then
    echo "  MegaTinyCore not found. Installing..."
    arduino-cli core update-index
    arduino-cli core install "$CORE_PACKAGE"
    echo -e "${GREEN}✓ MegaTinyCore installed${NC}"
else
    echo -e "${GREEN}✓ MegaTinyCore already installed${NC}"
fi

# Create backup of existing firmware if this is first build
if [ -f "$OUTPUT_DIR/firmware.hex" ] && [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${BLUE}[4/6]${NC} Backing up original firmware..."
    mkdir -p "$BACKUP_DIR"
    cp "$OUTPUT_DIR/firmware.hex" "$BACKUP_DIR/firmware.hex.original"
    [ -f "$OUTPUT_DIR/firmware.bin" ] && cp "$OUTPUT_DIR/firmware.bin" "$BACKUP_DIR/firmware.bin.original"
    echo -e "${GREEN}✓ Original firmware backed up to $BACKUP_DIR${NC}"
else
    echo -e "${BLUE}[4/6]${NC} Skipping backup (already exists or no previous build)"
fi

# Compile the firmware
echo -e "${BLUE}[5/6]${NC} Compiling firmware..."
mkdir -p "$OUTPUT_DIR"

if arduino-cli compile \
    --fqbn "$FQBN" \
    --output-dir "$OUTPUT_DIR" \
    --export-binaries \
    "$SKETCH_NAME" 2>&1 | tee /tmp/arduino-build.log; then
    echo -e "${GREEN}✓ Compilation successful${NC}"
else
    echo -e "${RED}✗ Compilation failed!${NC}"
    echo "Check the output above for errors."
    exit 1
fi

# Parse memory usage
echo -e "${BLUE}[6/6]${NC} Checking memory usage..."

# Extract memory usage from build log or ELF file
if command -v avr-size &> /dev/null; then
    SIZE_OUTPUT=$(avr-size "$OUTPUT_DIR/$SKETCH_NAME.elf" 2>/dev/null || echo "")
    if [ -n "$SIZE_OUTPUT" ]; then
        # Parse avr-size output (text data bss dec hex filename)
        FLASH_USED=$(echo "$SIZE_OUTPUT" | awk 'NR==2 {print $1+$2}')
        RAM_USED=$(echo "$SIZE_OUTPUT" | awk 'NR==2 {print $2+$3}')
    fi
fi

# Fallback: try to find it in the build log
if [ -z "$FLASH_USED" ]; then
    FLASH_USED=$(grep -oP "Sketch uses \K\d+" /tmp/arduino-build.log | head -1 || echo "0")
    RAM_USED=$(grep -oP "Global variables use \K\d+" /tmp/arduino-build.log | head -1 || echo "0")
fi

if [ "$FLASH_USED" -gt 0 ]; then
    FLASH_PERCENT=$((FLASH_USED * 100 / FLASH_SIZE))
    RAM_PERCENT=$((RAM_USED * 100 / RAM_SIZE))
    
    echo ""
    echo "  Flash:  $FLASH_USED / $FLASH_SIZE bytes ($FLASH_PERCENT%)"
    echo "  RAM:    $RAM_USED / $RAM_SIZE bytes ($RAM_PERCENT%)"
    echo ""
    
    # Check for warnings
    WARNED=0
    if [ "$FLASH_USED" -ge "$FLASH_WARNING_THRESHOLD" ]; then
        echo -e "${YELLOW}⚠ WARNING: Flash usage is above 90%!${NC}"
        echo -e "${YELLOW}  Consider optimizing code to free up space.${NC}"
        WARNED=1
    fi
    
    if [ "$RAM_USED" -ge "$RAM_WARNING_THRESHOLD" ]; then
        echo -e "${YELLOW}⚠ WARNING: RAM usage is above 80%!${NC}"
        echo -e "${YELLOW}  Watch out for stack overflow at runtime.${NC}"
        WARNED=1
    fi
    
    if [ "$WARNED" -eq 0 ]; then
        echo -e "${GREEN}✓ Memory usage is within safe limits${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Could not parse memory usage${NC}"
fi

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Build Complete!                                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Compiled files:"
echo "  • $OUTPUT_DIR/$SKETCH_NAME.hex"
echo "  • $OUTPUT_DIR/$SKETCH_NAME.bin"
echo "  • $OUTPUT_DIR/$SKETCH_NAME.elf"
echo ""
echo "Next steps:"
echo "  1. Connect Arduino Uno R3 (as programmer) to your computer"
echo "  2. Run: ${GREEN}./flash.sh${NC}"
echo ""
