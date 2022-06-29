#!/bin/bash

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
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

