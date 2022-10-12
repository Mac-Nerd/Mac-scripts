#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


if [ -n "$1" ]
then
	MacName=$(echo "$1" | tr -cd "[:alnum:]")
else
	# Set the hostname/ComputerName based on model ID and serial number instead of "username's MacBook":

	# get the model ID without commas (eg, 'MacBookPro161')
	ModelID=$(system_profiler SPHardwareDataType | awk '/Identifier/ {print $3}' | sed 's/,//g')

	# get last 4 digits of the serial number
	SerialNumber=$(system_profiler SPHardwareDataType | awk '/Serial/ {print substr($4,length($4)-3,4)}')
	MacName="$ModelID$SerialNumber"
fi

scutil --set HostName "$MacName"
scutil --set LocalHostName "$MacName"
scutil --set ComputerName "$MacName"
/usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName "$MacName"
dscacheutil -flushcache
