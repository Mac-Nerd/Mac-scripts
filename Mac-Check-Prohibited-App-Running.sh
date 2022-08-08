#!/bin/bash

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# -----------------------------------------------------------

# This script will attempt to determine if a particular app or process is running. If so,
# the script will exit in a failed state, so you can trigger a task to quit the process if needed.

AppToKill=$1

if [ -n "$AppToKill" ]
then
	echo "[NOTICE] This script requires the name of an app or process."
	exit 0		# exit quietly without triggering an alert.
fi

currentUser=$(stat -f "%S"u /dev/console)
currentUID=$(/usr/bin/id -u "$currentUser")

if [ "$currentUser" == "LoginWindow" ]
then
	echo "[NOTICE] No logged in user."
	exit 0		# exit quietly without triggering an alert.

else
	# is the specified application or process running?
	if [ $(pgrep -ilf "$AppToKill") ] || [ $(pgrep -ilf "$AppToKill".app) ]
	then
		echo "Found $AppToKill."
		/bin/launchctl asuser "$currentUID" /usr/bin/osascript -e "tell application \"${AppToKill}\" to quit"
	
		exit 1001		# exit and alert/fail. Trigger the "force quit prohibited app" task.
	
	fi	
		
fi



