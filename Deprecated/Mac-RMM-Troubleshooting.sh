#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# RMM troubleshooting script
# Places a file called "RMM-Troubleshooting.log" and a compressed file
# "RMM-Diagnostics-xxxxxxx.tgz" in /Users/Shared/

# Thanks to Gary Chaplin for his assistance in creating and testing this script.

logFile="/Users/Shared/RMM-Troubleshooting.log"


if ! [ -f "$logFile" ]
then
	touch "$logFile"
fi


logToFile(){
	echo "" >> $logFile
	echo "$@" >> $logFile
}


NewSection() {
	separator="=================================================="
	printf "\n[ %s ] %s\n" "$1" "$separator"
}

startTime=$(date)

logToFile "[ START $startTime ]"


LogsList=("/Library/Logs/RMM Advanced Monitoring Agent/rmmagentd.log" \
"/Library/Logs/DeviceManagementHelper/controller-0.log" \
"/Library/Logs/DeviceManagementHelper/service-0.log" \
"/Library/Managed Installs/ManagedInstallReport.plist" \
"/Library/Managed Installs/InstallInfo.plist" \
"/Library/Managed Installs/Logs/ManagedSoftwareUpdate.log" \
"/Library/Managed Installs/Logs/errors.log" \
"/Library/Managed Installs/Logs/warnings.log")

for logItem in "${LogsList[@]}"
do
	logToFile $(NewSection)
	logToFile "$logItem"
	if [ -f "$logItem" ]
	then
		tail -100 "$logItem" >> $logFile
	else
		logToFile "[NOTICE] No such file: $logItem"	
	fi
done


find /Library/Logs/MSP\ Anywhere\ Agent\ TakeControl/*.log -type f -print0 2> /dev/null | tee -a "$logFile" | xargs -0 -n1 tail -100 >> "$logFile"


# list all Users' home directories (uses dscl in the rare instance they're not in /Users/*)
USERHOMES=$(dscl /Local/Default -list /Users NFSHomeDirectory | grep -v "/var/empty" | awk '$2 ~ /^\// { print $2 }' )

for USERHOME in $USERHOMES
do
	find ${USERHOME}/Library/Logs/MSP\ Anywhere\ Agent\ TakeControl/*.log -type f -print0 2> /dev/null | tee -a "$logFile" | xargs -0 -n1 tail -100 >> "$logFile"
done


tar -zcvf "/Users/Shared/RMM-Diagnostics-$startTime.tgz" "/Library/Logs/DiagnosticReports"

