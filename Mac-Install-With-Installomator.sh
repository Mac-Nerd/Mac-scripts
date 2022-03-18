#!/bin/zsh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# Installs and updates third-party software using Installomator

# For more information, see: 
# https://scriptingosx.com/2020/05/introducing-installomator/

# This script based on:
# https://github.com/Installomator/Installomator/blob/dev/MDM/App-loop%20script.sh

# Requires parameter(s): software titles to install, separated by spaces
# See a full list of available titles here:
#	https://github.com/Installomator/Installomator/blob/dev/Labels.txt


what=$* 

if [ -z "$what" ]
then
	echo "ERROR: Required parameter: software titles to install, separated by spaces."
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
