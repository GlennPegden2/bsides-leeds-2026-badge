# BSides Leeds 2026 Badge - Development Guide

Welcome to the development guide for the BSides Leeds 2026 "Artie the Owl" interactive badge! This document will help you customize, build, and flash your own firmware modifications.

## Table of Contents

- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Hardware Overview](#hardware-overview)
- [Build System](#build-system)
- [Customization Guide](#customization-guide)
- [Memory Management](#memory-management)
- [Programming the Badge](#programming-the-badge)
- [Troubleshooting](#troubleshooting)
- [Advanced Topics](#advanced-topics)

---

## Quick Start

### Prerequisites

- **Arduino CLI** (will be installed automatically by build scripts)
- **Arduino Uno R3** (to program the badge)
- **USB cable** for the Uno
- **4.7kΩ resistor** for SerialUPDI connection
- **Jumper wires**

### macOS/Linux

```bash
# 1. Compile the firmware
chmod +x build.sh flash.sh setup-programmer.sh
./build.sh

# 2. Set up programmer (first time only)
./setup-programmer.sh

# 3. Flash to badge
./flash.sh
```

### Windows

```batch
REM 1. Compile the firmware
build.bat

REM 2. Set up programmer (first time only)
setup-programmer.bat

REM 3. Flash to badge
flash.bat
```

---

## Project Structure

```
bsides-leeds-2026-badge/
├── firmware.ino              # Main firmware (ATtiny814)
├── config.h                  # Easy customization settings
├── build.sh / build.bat      # Build scripts
├── flash.sh / flash.bat      # Upload scripts
├── setup-programmer.sh/bat   # Programmer setup guide
├── compiled/                 # Output directory for binaries
│   ├── firmware.hex         # Compiled firmware
│   ├── firmware.bin
│   └── firmware.elf
├── BOM.csv                   # Bill of materials
├── README.md                 # Project overview
└── DEVELOPMENT.md           # This file
```

---

## Hardware Overview

### ATtiny814 Specifications

- **Microcontroller:** ATtiny814 (megaTinyCore)
- **Flash Memory:** 8 KB (8,192 bytes)
- **SRAM:** 512 bytes
- **EEPROM:** 128 bytes
- **Clock:** 20 MHz internal oscillator

### Components

- **LEDs:** 18x individually addressable WS2812B (NeoPixels)
  - 9 LEDs per "eye"
- **Touch Buttons:** 6x capacitive touch sensors (PTC)
  - Left: Blue, Red, Green
  - Right: Blue, Red, Green
- **Wake Button:** 1x physical button
- **Power:** Battery powered with sleep mode

### Pin Mapping

```c
// LEDs
LED_DATA_PIN = PIN_PB3      // WS2812B data
LED_POWER_PIN = PIN_PB2     // LED power control

// Buttons
WAKE_BUTTON_PIN = PIN_PA3   // Physical wake button

// Touch Sensors
PIN_PA4 = Left Blue
PIN_PA5 = Left Red
PIN_PA6 = Left Green
PIN_PA7 = Right Green
PIN_PB0 = Right Red
PIN_PB1 = Right Blue
```

---

## Build System

### Build Scripts

The build scripts handle:
1. ✅ Arduino CLI installation check
2. ✅ MegaTinyCore board support installation
3. ✅ Firmware compilation
4. ✅ Memory usage reporting
5. ✅ Binary export to `compiled/`

### Flash Scripts

The flash scripts handle:
1. ✅ Serial port detection
2. ✅ Port selection (if multiple available)
3. ✅ SerialUPDI upload
4. ✅ Verification

### Memory Usage Warnings

The build scripts will warn you if:
- **Flash usage > 90%** (7,373+ bytes)
- **RAM usage > 80%** (410+ bytes)

These are warnings, not errors. The badge has very tight memory constraints!

---

## Customization Guide

### Using config.h

The `config.h` file is designed for easy modifications without editing the main firmware. Here's what you can customize:

#### 1. Unlock All Modes

```c
// Set to true to unlock all animation modes immediately
#define UNLOCK_ALL_MODES true
```

By default, some modes are locked until you complete the games. Set this to `true` to unlock everything!

#### 2. Change Colors

```c
// Adjust brightness (0-255, but keep low for power/brightness)
#define COLOR_RED_R 30
#define COLOR_RED_G 0
#define COLOR_RED_B 0

#define COLOR_GREEN_R 0
#define COLOR_GREEN_G 30
#define COLOR_GREEN_B 0
```

**Tip:** Keep RGB values low (10-50) to conserve battery and avoid blinding brightness!

#### 3. Modify Timings

```c
#define WAKE_TIMEOUT_MS 900000UL  // Time before sleep (15 min)
#define LONG_PRESS_THRESHOLD_MS 1200  // Long press duration
```

#### 4. Game Settings

```c
#define FIND_SEQUENCE_LENGTH 7           // Sequence game length
#define FIND_SEQUENCE_STARTING_LIVES 10  // Starting lives
#define MEMORY_START_LEVEL 3             // Memory game start level
```

### Adding Custom Animation Patterns

You can create new patterns by modifying the existing animation functions or adding new ones:

1. Define your colors in `config.h`:
```c
#define CUSTOM_PATTERN_R 25
#define CUSTOM_PATTERN_G 15
#define CUSTOM_PATTERN_B 5
```

2. Look for animation functions in `firmware.ino` like:
   - `knightRider()` - Scanning pattern
   - `breath()` - Breathing effect
   - `spinMode()` - Spinning lights
   - `policeMode()` - Alternating flash

3. Modify the `runAnimationMode()` function to add your custom pattern

**Example:** Change police mode colors:
```c
// In firmware.ino, find policeMode() and modify:
case 8:
  if ((state & B00000001) != 0) { return 0; };
  return policeMode(step);
```

Then in `policeMode()` function, change:
```c
setAllLeds(10,0,0);  // Change red to your color
for (uint8_t i = 0 + initial; i < 18; i = i + 2)
{
  ledStrip.setPixelColor(i, 0,0,255);  // Change blue to your color
}
```

---

## Memory Management

### Why Memory Matters

The ATtiny814 has only **8 KB of flash** and **512 bytes of RAM**. Every byte counts!

### Flash Memory Tips

**Current firmware uses ~88% of flash** - there's not much room left!

**To reduce flash usage:**
- ✅ Use `PROGMEM` for constant arrays (already done)
- ✅ Reuse functions instead of duplicating code
- ✅ Use `uint8_t` instead of `int` when possible
- ✅ Avoid `String` class (use C strings)
- ❌ Don't add `Serial.print()` debugging
- ❌ Don't include unnecessary libraries

### RAM Tips

**To reduce RAM usage:**
- ✅ Use `const` for constants stored in flash
- ✅ Minimize global variables
- ✅ Use local variables when possible
- ❌ Avoid large arrays in RAM
- ❌ Don't use recursion (stack overflow risk)

### Checking Memory Usage

After running `build.sh` or `build.bat`, you'll see:
```
Flash:  7234 / 8192 bytes (88%)
RAM:    387 / 512 bytes (75%)
```

### Compiler Optimizations

The firmware already uses aggressive optimizations:
- `-Os` - Optimize for size
- Link-time optimization (LTO)
- Dead code elimination

---

## Programming the Badge

### SerialUPDI Setup (Recommended)

**Hardware Connection:**
```
Arduino Uno R3          ATtiny814 Badge
──────────────          ───────────────
TX (pin 1) ───────┬──── UPDI (PA0)
                  │
              4.7kΩ resistor
                  │
RX (pin 0) ───────┘

GND ──────────────────── GND
5V ───────────────────── VCC (if badge needs power)
```

**Why the resistor?**
The 4.7kΩ resistor creates a simple current-limiting circuit that allows the Uno's UART to communicate with the ATtiny's UPDI interface.

### Alternative: jtag2updi

If SerialUPDI doesn't work:

1. Flash jtag2updi firmware to Uno
2. Connect Uno D6 to ATtiny UPDI (no resistor)
3. Modify flash script to use `--programmer jtag2updi`

### FQBN Configuration

The default FQBN used is:
```
megaTinyCore:megaavr:atxy4:chip=814
```

To customize (edit build scripts):
```bash
# Example: 16MHz clock instead of 20MHz
FQBN="megaTinyCore:megaavr:atxy4:chip=814,clock=16internal"

# Available options:
# clock=20internal,16internal,10internal,8internal,etc.
# bodvoltage=1v8,2v6,4v2,disabled
# eesave=enable,disable
# millis=enabled,disabled
```

---

## Troubleshooting

### Build Issues

**"Arduino CLI not found"**
- Install via Homebrew: `brew install arduino-cli`
- Or download from: https://github.com/arduino/arduino-cli/releases

**"MegaTinyCore not found"**
- The build script should auto-install it
- Manual: `arduino-cli core install megaTinyCore:megaavr`

**Compilation errors after modifying code**
- Check syntax carefully (missing semicolons, braces)
- Ensure `config.h` definitions match usage
- Revert changes and try again incrementally

### Upload Issues

**"No serial devices detected"**
- Check USB cable is connected
- Try a different USB port
- On macOS: Install CH340 drivers if using clone Uno
- On Windows: Check Device Manager for COM port

**"Upload failed"**
- Verify 4.7kΩ resistor is in place
- Check all connections are secure
- Ensure badge is powered
- Try lower baud rate (modify flash script)
- Verify UPDI pin is PA0

**Wrong port selected**
- Unplug other USB devices
- Re-run flash script and select correct port
- On Windows: Check Device Manager for COM number

### Runtime Issues

**Badge doesn't turn on**
- Check battery is charged
- Press wake button
- Check LED power connections

**Badge behaves erratically**
- May be low battery
- Try resetting (press wake button long)
- Re-flash firmware

**Touch buttons not responding**
- Calibration may be off
- Check touch sensor thresholds in config.h
- Ensure fingers are dry

### Memory Issues

**"Region 'text' overflowed"**
- Flash is full! Remove features or optimize code
- Check memory usage: > 8192 bytes = won't fit

**Random crashes/resets**
- Likely RAM overflow (stack collision)
- Reduce global variables
- Minimize function call depth

---

## Advanced Topics

### Modifying FQBN in Build Scripts

Edit `build.sh` or `build.bat` and change the `FQBN` variable:

```bash
# macOS/Linux (build.sh)
FQBN="megaTinyCore:megaavr:atxy4:chip=814,clock=16internal,bodvoltage=2v6"

# Windows (build.bat)
set FQBN=megaTinyCore:megaavr:atxy4:chip=814,clock=16internal,bodvoltage=2v6
```

### Git Pre-Commit Hook for Memory Check

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
./build.sh || exit 1
echo "Build successful - proceeding with commit"
```

Then: `chmod +x .git/hooks/pre-commit`

### Using Arduino IDE Instead

1. Open `firmware.ino` in Arduino IDE
2. Install MegaTinyCore via Board Manager
3. Select: Tools → Board → megaTinyCore → ATtiny814/1614/etc
4. Select: Tools → Chip → ATtiny814
5. Select: Tools → Programmer → SerialUPDI
6. Select correct port
7. Upload

### Creating New Games

To add a new game:

1. Create a function following the pattern:
```c
bool playMyNewGame() {
  enableRebootOnButton();
  
  // Game logic here
  
  // On success:
  state = state & B11110111;  // Clear bit for unlock
  showSuccess();
  disableRebootOnButton();
  return true;
  
  // On failure:
  showFailure();
  disableRebootOnButton();
  return false;
}
```

2. Add to `handleWakeButtonPress()`:
```c
case LEFT_BLUE_MASK | LEFT_RED_MASK:  // New combo
  playMyNewGame();
  break;
```

### Understanding the State Variable

The `state` variable (stored in EEPROM) tracks game completion:
- Bit 0: Stop the Light unlocked
- Bit 1: Follow the Sequence unlocked
- Bit 2: Find the Sequence unlocked

Modes check this:
```c
if ((state & B00000001) != 0) { return 0; }  // Skip if bit 0 is set
```

To unlock all modes, set bits to 0: `state = 0;`

### Button Press Combinations

Current combinations:
- Wake button only → Next animation mode
- Wake + Left Blue → Stop the Light (1P)
- Wake + Left Red → Find the Sequence (1P)
- Wake + Left Green → Follow the Sequence (1P)
- Wake + Right Blue → Stop the Light (2P)
- Wake + Right Red → Find the Sequence (2P)
- Wake + Right Green → Follow the Sequence (2P)
- Wake (long press) → Sleep mode

---

## Resources

- **MegaTinyCore:** https://github.com/SpenceKonde/megaTinyCore
- **Arduino CLI:** https://arduino.github.io/arduino-cli/
- **ATtiny814 Datasheet:** https://www.microchip.com/en-us/product/ATtiny814
- **WS2812B (NeoPixel):** https://learn.adafruit.com/adafruit-neopixel-uberguide
- **SerialUPDI:** https://github.com/SpenceKonde/AVR-Guidance/blob/master/UPDI/jtag2updi.md

---

## Contributing

If you create cool modifications:
1. Fork the repository
2. Make your changes
3. Test thoroughly (memory usage, runtime)
4. Submit a pull request with description

**Share your badges at BSides Leeds 2026!** 🦉

---

## License

See main README.md for license information.

---

**Happy Hacking! 🎉**
