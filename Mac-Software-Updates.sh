#!/bin/bash

# This script attempts to get a list of updates available from Apple via softwareupdate.
# The list is parsed and stripped of any updates that require a reboot, then those remaining 
# labels are passed along to the softwareupdate command (if the optional parameter passed
# to the script is "true")

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----






# Check your privilege
if [ "$(whoami)" != "root" ]; then
    echo "This script must be run with root/sudo privileges."
    exit 1
fi

ListOfSoftwareUpdates="/tmp/ListOfSoftwareUpdates"

# Function definition:
checkForSoftwareUpdates(){
	echo "Refreshing available updates."

# Restart the softwareupdate daemon to ensure latest updates are being picked up
    /bin/launchctl kickstart -k system/com.apple.softwareupdated
# Allow a few seconds for daemon to startup
    /bin/sleep 3
# Store list of software updates in /tmp which gets cleared periodically by the OS and on restarts
    /usr/sbin/softwareupdate -l > "$ListOfSoftwareUpdates" 2>&1

}

# is the list already there?
if [ -f $ListOfSoftwareUpdates ]
then
#	echo "$ListOfSoftwareUpdates exists."
# if it's there, how old is it?

	ListAge=$((($(date +%s) - $(date -r "$ListOfSoftwareUpdates" +%s))/60 ))
#	echo "$ListAge minutes old."

	if [ $ListAge -ge 60 ]
	then
	# older than an hour
		echo "Older than 1 hour, checking for updates again."
		checkForSoftwareUpdates
	fi

else
	# doesn't exist
	echo "$ListOfSoftwareUpdates does not exist. Checking for updates."
	checkForSoftwareUpdates
fi

# check the list for updates requiring restart
RestartRequired=$(grep -B1 -i restart "$ListOfSoftwareUpdates")	# updates requiring restart
echo "NOTICE: There are updates that require a restart. These will not be installed:"
printf "%s\n\n" "$RestartRequired"

# if not empty, then strip out "Restart required" leaving only "Recommended" updates. Otherwise, just get the list of updates that are "recommended"
if [[ $RestartRequired ]] 
then
	AllUpdates=$(grep -B1 -i recommended "$ListOfSoftwareUpdates" | grep -v -F "$RestartRequired")
else 
	AllUpdates=$(grep -B1 -i recommended "$ListOfSoftwareUpdates")
fi

if [ -n "$AllUpdates" ]
then
# finally, remove the information lines and the "label" text, leaving only the list of update packages to install
	UpdatesNoRestart=$(echo "$AllUpdates" | grep -v -e "--" | grep -B1 -i recommended | grep -i "Label" | cut -d : -f 2 )
# send this to softwareupdate -i 

	# trims whitespace
	UpdatesNoRestart=$(echo "$UpdatesNoRestart" | xargs)


# needs quotes, since some updates have spaces in name.
	echo "The following updates are available to install:"
	echo "$UpdatesNoRestart"
else 
	echo "No updates available."
	exit 0
fi


if [[ $1 =~ ["true"|"True"] ]]
then

	echo "Installing updates."
	/usr/sbin/softwareupdate -i --verbose "$UpdatesNoRestart" 

fi
