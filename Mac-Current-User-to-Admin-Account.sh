#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Converts current logged-in standard user to an admin account.


# Check your privilege
if [ $(whoami) != "root" ]; then
    echo "This script must be run with root/sudo privileges."
    exit 1002
fi

currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/  { print $3 }')

if [ "$currentUser" == "LoginWindow" ]
then
	echo "No current user."
	exit 1001
fi	

if /usr/bin/dscl . -read "/groups/admin" GroupMembership | /usr/bin/grep -q "$currentUser"
then
	echo "$currentUser is already an administrator."
else
	/usr/bin/dscl . -append "/groups/admin" GroupMembership "$currentUser"
	echo "$currentUser now has administrator privileges."
fi
