#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
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



