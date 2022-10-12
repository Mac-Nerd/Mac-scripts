#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# System Integrity Protection (SIP) is integral to the security of macOS. The system
# prevents unauthorized tampering with protected files in various locations on the boot
# volume. Disabling SIP is not recommended, and requires physical access to the machine
# and specific intent to remove the security it provides. It's not something that can be
# done accidentally. 
#
# https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection
# 
# This script will alert if SIP has been disabled on the Mac, and immediately enable it,
# which requires rebooting. Use with caution, as a sudden reboot can result in the user
# losing any unsaved work.

# Thanks to Mike Lambert from the MacAdmins Slack for the inspiration and collaboration.



OSVERSION=$(defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print $1}')

OSMAJOR=$(echo "${OSVERSION}" | cut -d . -f1)
OSMINOR=$(echo "${OSVERSION}" | cut -d . -f2)

if [[ $OSMAJOR -lt 11 ]] && [[ $OSMINOR -lt 11 ]] # don't run on anything less than 10.11
then
	echo "[ERROR] SIP is only compatible with El Capitan (macOS 10.11) and newer."
	exit 1002
fi



RestartTimeout=30

SIPResult=$(csrutil status | awk '{ print $5 }' | tr -d '.')

if [[ "$SIPResult" == "enabled" ]]; then
	echo "SIP is already enabled. Nothing to do."
	exit 0

else

	echo "[WARNING]: SIP has been disabled. Enabling SIP and restarting now."
	/usr/bin/csrutil clear
	# functionally the same as csrutil enable, but shouldn't require booting into Recovery mode.

osascript <<EOF
tell application "System Events" to set quitapps to name of every application process whose visible is true and name is not "Finder"
repeat with closeall in quitapps
	try
		with timeout of ${RestartTimeout} seconds
			quit application closeall
		end timeout
	end try
end repeat
with timeout of ${RestartTimeout} seconds
	tell application "Finder" to restart
end timeout
EOF
 	shutdown -r now

	exit 1001

fi
