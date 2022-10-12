#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# Occasionally, a job in the print queue on the Mac will get stuck, and nothing will 
# print until it's either deleted or fixed. Print jobs will pile up behind it, and 
# memory and drive space start getting eaten up. The easiest way to fix this situation 
# is by resetting the print queue. Note: In versions of MacOS prior to Catalina (10.15) 
# this requires the GUI.

OSVERSION=$(defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print $1}')

OSMAJOR=$(echo "${OSVERSION}" | cut -d . -f1)
OSMINOR=$(echo "${OSVERSION}" | cut -d . -f2)

if [[ $OSMAJOR -lt 11 ]] && [[ $OSMINOR -lt 15 ]]
then
	echo "Requires MacOS Catalina 10.15 or higher."
	exit 1
else 
	/System/Library/Frameworks/ApplicationServices.framework/Frameworks/PrintCore.framework/Versions/A/printtool --reset -f
fi
