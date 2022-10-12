#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Check your privilege
if [ $(whoami) != "root" ]; then
    echo "This script must be run with root/sudo privileges."
    exit 1002
fi

convertAccount="$1"

if ! id "$convertAccount" 2> /dev/null || [ -z "$1" ]
then
	echo "[ERROR] No such user: $convertAccount"
	exit 1001
fi

if /usr/bin/dscl . -read "/groups/admin" GroupMembership | /usr/bin/grep -q "$convertAccount"
then
	if /usr/sbin/dseditgroup -o edit -d "$convertAccount" admin
	then
		echo "$convertAccount admin privileges removed."
	else
		echo "[ERROR] Could not remove administrator privileges from $convertAccount."
		exit 1003	
	fi	
else
	echo "$convertAccount is not an administrator."
fi
