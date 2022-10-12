#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# This script will return the number of cycles recorded for a Mac laptop's battery.
# For desktop Macs, the result is 0.

# With an optional number as parameter, the script will alert if the battery cycles
# exceed that maximum value.


batteryCycles=$(/usr/sbin/system_profiler SPPowerDataType | grep "Cycle Count")

if [ -n "$batteryCycles" ]
then
	batteryCycles=$(echo "$batteryCycles" | cut -d":" -f2 | xargs)
else 	
	batteryCycles=0
	echo "N/A"
	exit 0
fi

if [ -n "$1" ] && [ "$batteryCycles" -gt "$1" ]
then 
	echo "[NOTICE] Battery cycles exceeds ${1}: ${batteryCycles}"
	exit 1001
else 
	echo "Battery Cycles: ${batteryCycles}"

fi
