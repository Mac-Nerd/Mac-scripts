#!/bin/bash

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
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
