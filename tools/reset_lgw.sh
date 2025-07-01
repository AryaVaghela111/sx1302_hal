#!/bin/sh

# New reset script using libgpiod (gpioset) instead of deprecated /sys/class/gpio
# This script is compatible with modern Raspberry Pi OS using libgpiod

# GPIO pin numbers (BCM)
SX1302_RESET_PIN=23     # SX1302 reset
SX1302_POWER_EN_PIN=18  # SX1302 power enable
SX1261_RESET_PIN=22     # SX1261 reset (LBT / Spectral Scan)
AD5338R_RESET_PIN=13    # AD5338R reset (full-duplex CN490 reference design)

# Helper to pulse a pin (set to 1 then 0)
pulse_pin() {
    CHIP=0
    PIN=$1
    gpioset gpiochip$CHIP $PIN=1
    sleep 0.1
    gpioset gpiochip$CHIP $PIN=0
    sleep 0.1
}

reset() {
    echo "CoreCell reset through GPIO$SX1302_RESET_PIN..."
    echo "SX1261 reset through GPIO$SX1261_RESET_PIN..."
    echo "CoreCell power enable through GPIO$SX1302_POWER_EN_PIN..."
    echo "CoreCell ADC reset through GPIO$AD5338R_RESET_PIN..."

    CHIP=0

    # Enable power
    gpioset gpiochip$CHIP $SX1302_POWER_EN_PIN=1
    sleep 0.1

    # Pulse reset for SX1302
    pulse_pin $SX1302_RESET_PIN

    # Pulse reset for SX1261
    pulse_pin $SX1261_RESET_PIN

    # Pulse reset for ADC
    pulse_pin $AD5338R_RESET_PIN
}

case "$1" in
    start)
    reset
    ;;
    stop)
    echo "Stop does nothing now. GPIO states are not reverted."
    ;;
    *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
