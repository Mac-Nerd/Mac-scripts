#!/bin/bash

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# -----------------------------------------------------------

# Logs to output the type of security hardware (either T2 or, in the case of ARM64 Macs
# the model identifier) and the firmware version.

SecurityHardware=$(system_profiler SPiBridgeDataType)

SOCName=$(echo "$SecurityHardware" | /usr/bin/awk -F ': ' '/Model/ {print $NF}')

FirmwareVersion=$(echo "$SecurityHardware" | /usr/bin/awk -F ': ' '/Firmware Version/ {print $NF}')

echo "$SOCName with firmware version $FirmwareVersion"

