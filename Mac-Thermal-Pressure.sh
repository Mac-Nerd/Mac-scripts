#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
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
