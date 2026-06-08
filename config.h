/*
 * BSides Leeds 2026 Badge - Configuration File
 * 
 * This file contains easy-to-modify settings for the badge firmware.
 * Modify these values to customize behavior without editing the main firmware.
 */

#ifndef CONFIG_H
#define CONFIG_H

// ============================================================================
// MODE UNLOCK CONFIGURATION
// ============================================================================
// Set to true to unlock all animation modes by default (no games required)
// Set to false to require game completion to unlock modes
#define UNLOCK_ALL_MODES true

// Individual mode unlock flags (only used if UNLOCK_ALL_MODES is false)
#define UNLOCK_DEVSECOPS_MODE true    // Mode 5
#define UNLOCK_NUCLEAR_MODE true      // Mode 6
#define UNLOCK_YORK_ROSE_MODE true    // Mode 7
#define UNLOCK_POLICE_MODE true       // Mode 8

// EASTER EGG: Konami Code unlock sequence!
// Enter the classic Konami Code to unlock all games (clears unlock bits in EEPROM)
// 
// The code sequence (must be entered without wake button):
//   UP UP DOWN DOWN LEFT RIGHT LEFT RIGHT B A
// 
// Mapped to badge buttons:
//   Left-Blue, Left-Blue, Left-Green, Left-Green, 
//   Left-Blue, Right-Blue, Left-Blue, Right-Blue,
//   Left-Red, Right-Red
//
// When successfully entered, you'll see:
//   - 3 purple flashes (magenta)
//   - 15 cycles of red/blue eye alternation
//   - Final green flash
// 
// All games will be permanently unlocked (saved to EEPROM)!


// ============================================================================
// ANIMATION COLORS (RGB values 0-255, but keep low for brightness/power)
// ============================================================================
// Standard colors used throughout
#define COLOR_OFF_R 0
#define COLOR_OFF_G 0
#define COLOR_OFF_B 0

#define COLOR_RED_R 30
#define COLOR_RED_G 0
#define COLOR_RED_B 0

#define COLOR_GREEN_R 0
#define COLOR_GREEN_G 30
#define COLOR_GREEN_B 0

#define COLOR_BLUE_R 0
#define COLOR_BLUE_G 0
#define COLOR_BLUE_B 30

#define COLOR_ORANGE_R 30
#define COLOR_ORANGE_G 12
#define COLOR_ORANGE_B 0


// ============================================================================
// ANIMATION TIMING (in milliseconds)
// ============================================================================
#define WAKE_TIMEOUT_MS 900000UL  // 15 minutes until sleep
#define SHORT_PRESS_THRESHOLD_MS 200
#define LONG_PRESS_THRESHOLD_MS 1200
#define BUTTON_DEBOUNCE_MS 50
#define TOUCH_POLL_MS 10


// ============================================================================
// GAME CONFIGURATION
// ============================================================================
#define FIND_SEQUENCE_LENGTH 7
#define FIND_SEQUENCE_STARTING_LIVES 10
#define FIND_SEQUENCE_PREVIEW_MS 3000
#define MEMORY_START_LEVEL 3
#define NUM_SEQUENCE_LEVELS 10


// ============================================================================
// TIMER CONFIGURATION
// ============================================================================
// The timer mode (mode 10) duration is configurable in 5-minute intervals.
// Default duration is stored in EEPROM bits 3-5 (preserves game unlock state).
// 
// To change timer duration on the badge:
//   1. Enter timer mode (mode 10)
//   2. Press wake button while holding BOTH BLUE touch buttons
//   3. Eyes flash cyan showing selected duration:
//      - 1 flash  = 5 minutes
//      - 2 flashes = 10 minutes
//      - 3 flashes = 15 minutes
//      - 4 flashes = 20 minutes
//      - 5 flashes = 25 minutes
//      - 6 flashes = 30 minutes
//   4. Repeat to cycle through durations
//   5. Setting is saved to EEPROM (persists across power cycles)
//
// Note: Timer duration shares EEPROM byte with game unlocks (uses bits 3-5)


// ============================================================================
// HARDWARE PIN DEFINITIONS
// ============================================================================
// LEDs
#define LED_DATA_PIN PIN_PB3
#define LED_POWER_PIN PIN_PB2
#define NUM_LEDS 18
#define LEDS_PER_EYE 9

// Buttons
#define WAKE_BUTTON_PIN PIN_PA3
#define NUM_TOUCH_BUTTONS 6

// Touch button pins
#define TOUCH_PIN_0 PIN_PA4  // Left Blue
#define TOUCH_PIN_1 PIN_PA5  // Left Red
#define TOUCH_PIN_2 PIN_PA6  // Left Green
#define TOUCH_PIN_3 PIN_PA7  // Right Green
#define TOUCH_PIN_4 PIN_PB0  // Right Red
#define TOUCH_PIN_5 PIN_PB1  // Right Blue


// ============================================================================
// CUSTOM ANIMATION PATTERNS (Example)
// ============================================================================
// You can add custom color combinations here for new patterns
#define CUSTOM_PATTERN_1_R 15
#define CUSTOM_PATTERN_1_G 5
#define CUSTOM_PATTERN_1_B 25

#define CUSTOM_PATTERN_2_R 25
#define CUSTOM_PATTERN_2_G 15
#define CUSTOM_PATTERN_2_B 0

// Speed multipliers for animations (1.0 = normal speed)
#define ANIMATION_SPEED_MULTIPLIER 1.0


// ============================================================================
// ADVANCED SETTINGS (modify with caution)
// ============================================================================
#define MAX_BUTTON_HOLD_MS 2000
#define SLEEP_DEBOUNCE_CYCLES 3

// Touch sensor calibration
#define TOUCH_GAIN PTC_GAIN_1
#define TOUCH_PRESCALER PTC_PRESC_DIV4_gc
#define TOUCH_OVERSAMPLES 4
#define TOUCH_THRESHOLD_TOUCH 80
#define TOUCH_THRESHOLD_RELEASE 10

#endif // CONFIG_H
