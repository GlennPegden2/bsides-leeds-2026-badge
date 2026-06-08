# bsides-leeds-2026-badge
The Artie the Owl badge for BSIDES Leeds 2026!

Full details coming after the con! For now, take a look at the firmware for clues.

If you fork this repo and modify the firmware, we'll flash it to your badge on the day! Never done Arduino / C++ code before? That's what ChatGPT is for...

---

## 🎉 Custom Enhancements (This Fork)

This fork includes several community-contributed enhancements:

### 🌹 New Animation Mode: Lancashire Rose (Mode 11)
A War of the Roses themed animation mode complementing the existing York Rose mode:
- **York Rose** (Mode 7): Blue & purple static pattern representing Yorkshire
- **Lancashire Rose** (Mode 11): Red & white static pattern representing Lancashire
- Both modes use the `nuclearMode` function with color variations

### ⏱️ Configurable Timer Duration
The timer mode (Mode 10) now supports adjustable durations:
- **Available durations:** 5, 10, 15, 20, 25, or 30 minutes (5-minute intervals)
- **How to configure:** Press wake button while holding **both blue touch buttons**
- **Visual feedback:** Eyes flash cyan to show selected duration (1-6 flashes)
- **Persistence:** Duration saved to EEPROM, survives power cycles
- **EEPROM usage:** Uses bits 3-5 of state byte, preserving game unlock states (bits 0-2)

### 🎮 Konami Code Easter Egg
Unlock all games with the classic gaming cheat code:
- **The Code:** UP UP DOWN DOWN LEFT RIGHT LEFT RIGHT B A
- **Badge mapping:** 
  - UP = Left-Blue
  - DOWN = Left-Green
  - LEFT = Left-Blue
  - RIGHT = Right-Blue
  - B = Left-Red
  - A = Right-Red
- **Full sequence:** L-Blue, L-Blue, L-Green, L-Green, L-Blue, R-Blue, L-Blue, R-Blue, L-Red, R-Red
- **Success animation:** 
  - 3 purple flashes (magenta)
  - 15 cycles of alternating red/blue eyes
  - Final green flash
- **Result:** All games permanently unlocked (saved to EEPROM)

---

## Quick Start - Build Your Own Firmware

### Prerequisites

- Arduino Uno R3 (for programming the badge)
- USB cable
- 4.7kΩ resistor
- Jumper wires

### macOS/Linux

```bash
# Make scripts executable
chmod +x build.sh flash.sh setup-programmer.sh

# 1. Compile the firmware
./build.sh

# 2. Set up programmer (first time only)
./setup-programmer.sh

# 3. Flash to your badge
./flash.sh
```

### Windows

```batch
# 1. Compile the firmware
build.bat

# 2. Set up programmer (first time only)
setup-programmer.bat

# 3. Flash to your badge
flash.bat
```

### Easy Customization

Edit `config.h` to customize your badge:
- **Unlock all modes** - Set `UNLOCK_ALL_MODES true`
- **Change colors** - Modify RGB values
- **Adjust timings** - Change animation speeds
- **Game settings** - Modify difficulty

See **[DEVELOPMENT.md](DEVELOPMENT.md)** for detailed documentation!

---

## Technical Details

We've included the firmware in firmware.ino, and also the compiled firmware in the compiled folder. Some of this firmware is pretty and some is ugly. 

This is the first bit of firmware where we've used AI to try and reduce flash footprint. It's always a battle with these badges to keep the flash footprint down, and in this case we have 8192KB of space available. As with all AI work, it's hard to stop it going off-piste. Some of the random functions are a bit heavy handed, but it was worth it to reduce the footprint and get all 6 games on the badge.

We've also included the BOM.csv, which tells you the parts used to build the badge. This may help you (or the AI) understand what you've got to work with. Mainly the LEDs (individually addressible) and microcontroller (ATTINY814).

This badge stands on the back of the fantastic work done by [MegaTinyCore](https://github.com/SpenceKonde/megaTinyCore). Without this, this firmware would be harder to read and the PTC library has been amazing to use.

### Custom Fork Enhancements - Technical Details

**Memory Efficiency:**
- Lancashire Rose mode: ~0 bytes (reuses existing `nuclearMode` function)
- Configurable timer: ~150 bytes flash, 11 bytes RAM
- Konami Code detector: ~150 bytes flash, 11 bytes RAM
- **Total overhead:** ~300 bytes flash, 22 bytes RAM (well within 8KB/512B limits)

**EEPROM State Byte Layout:**
```
Bits 0-2: Game unlock states (preserved)
Bits 3-5: Timer duration index (0-5 for 5-30 min)
Bits 6-7: Reserved for future use
```

**Implementation Highlights:**
- Konami Code uses circular buffer for sequence detection
- Timer configuration persists across power cycles
- All features integrate seamlessly with existing mode switching
- Zero-overhead preprocessor directives for conditional compilation

---

## Project Structure

```
bsides-leeds-2026-badge/
├── firmware.ino              # Main firmware (ATtiny814)
├── config.h                  # Easy customization settings
├── build.sh / build.bat      # Build scripts
├── flash.sh / flash.bat      # Flash scripts
├── setup-programmer.sh/bat   # Programmer setup guide
├── compiled/                 # Compiled binaries
├── BOM.csv                   # Bill of materials
├── README.md                 # This file
└── DEVELOPMENT.md           # Full development guide
```

---

## Hardware

- **Microcontroller:** ATtiny814 (8KB flash, 512B RAM)
- **LEDs:** 18x WS2812B individually addressable
- **Touch Sensors:** 6x capacitive touch buttons
- **Power:** Battery with sleep mode

---

## Resources

- **Full Development Guide:** [DEVELOPMENT.md](DEVELOPMENT.md)
- **MegaTinyCore:** https://github.com/SpenceKonde/megaTinyCore
- **Arduino CLI:** https://arduino.github.io/arduino-cli/

---

**Happy Hacking! 🦉**

