#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Converts current logged-in admin user to a standard account.


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
	/usr/sbin/dseditgroup -o edit -d "$currentUser" admin
	echo "$currentUser admin privileges removed."
else
	echo "$currentUser is not an administrator."
fi
