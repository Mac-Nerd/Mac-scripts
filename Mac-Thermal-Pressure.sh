#!/bin/bash

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# -----------------------------------------------------------

# Mac Thermal Pressure - Instead of reporting specific temperatures and alerts, Apple's
# APIs will return a "pressure" status message. From least to most thermal pressure:
#
#	Nominal 
#	Moderate
#	Heavy
#	Trapping 
#	Sleeping 
 
ThermalPressure=$(powermetrics --samplers thermal -n1 | grep "Current pressure level" | awk 'NF>1{print $NF}')
 
case $ThermalPressure in
	Nominal | Moderate)
		echo "Thermal pressure is $ThermalPressure"
		exit 0
	;;

	Heavy | Trapping | Sleeping)
		echo "[WARNING] CPU temperature too high: Pressure $ThermalPressure"
		exit 1001
	;;

	*)
		echo "[ERROR] Unknown error."
		exit 1002
esac
