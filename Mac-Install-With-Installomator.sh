#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Installs and updates third-party software using Installomator

# For more information, see: 
# https://scriptingosx.com/2020/05/introducing-installomator/

# This script based on:
# https://github.com/Installomator/Installomator/blob/dev/MDM/App-loop%20script.sh

# Requires parameter(s): software titles to install, separated by commas
# See a full list of available titles here:
#	https://github.com/Installomator/Installomator/blob/dev/Labels.txt

# Updated 11 August, 2022 - comma separated list instead of spaces.


what=$1

if [ -z "$what" ]
then
	echo "ERROR: Required parameter: software titles to install, separated by commas."
	echo "See a full list of available titles here:"
	echo "https://github.com/Installomator/Installomator/blob/dev/Labels.txt"
	exit 1001
fi


# No sleeping
/usr/bin/caffeinate -d -i -m -u &
caffeinatepid=$!
caffexit () {
    kill "$caffeinatepid"
    exit $1
}

# Count errors
errorCount=0

# Verify that Installomator has been installed
destFile="/usr/local/Installomator/Installomator.sh"
if [ ! -e "${destFile}" ]; then
    echo "Installomator not found. Default location is: "
    echo "${destFile}"
    echo "Exiting."
    caffexit 99
fi


IFS=","

for item in $what; do
    #echo $item
    ${destFile} ${item} LOGO="/usr/local/rmmagent/RMM\ Notification\ Service.app/Contents/Resources/Application.icns" BLOCKING_PROCESS_ACTION=tell_user NOTIFY=success #INSTALL=force
    if [ $? != 0 ]; then
        echo "[$(DATE)] Error installing ${item}. Exit code $?"
        let errorCount++
    fi
done

echo
echo "Errors: $errorCount"
echo "[$(DATE)][LOG-END]"

caffexit $errorCount
