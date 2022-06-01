#!/bin/bash
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# -----------------------------------------------------------

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
