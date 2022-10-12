#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Logs to output whether the current logged-in user is a local user on the device, 
# or an Active Directory domain user. Fails if there is no logged in user.


currentUser=$(stat -f "%S"u /dev/console )

if [ "$currentUser" == "LoginWindow" ]
then
	echo "No logged in user."
	exit 1001
else
	if dscl . -read "/Users/$currentUser" OriginalNodeName 2>&1 | grep -q "No such key"
	then
	  accountType="Local User"
	else
	  accountType="Domain User"
	fi
	
	echo "$currentUser account type: $accountType"

fi

