#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Logs to output the type of security hardware (either T2 or, in the case of ARM64 Macs
# the model identifier) and the firmware version.

SecurityHardware=$(system_profiler SPiBridgeDataType)

SOCName=$(echo "$SecurityHardware" | /usr/bin/awk -F ': ' '/Model/ {print $NF}')

FirmwareVersion=$(echo "$SecurityHardware" | /usr/bin/awk -F ': ' '/Firmware Version/ {print $NF}')

echo "$SOCName with firmware version $FirmwareVersion"

