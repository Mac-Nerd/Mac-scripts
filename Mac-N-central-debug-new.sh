#!/bin/bash

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# -----------------------------------------------------------

if [ -n "$1" ]
then
	serverName=$1
else
	serverName="sis.n-able.com"
fi

logFile="/tmp/N-central-debug.log"

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


logToFile $(NewSection "Ping:")

ping -c5 "$serverName" >> $logFile

logToFile $(NewSection "SSL connect:")
nc -v -z "$serverName" 443 2>> $logFile


if [ -d "/Applications/Mac_Agent.app" ]
then
	outputString="[ Error ] Legacy Mac Agent still installed in /Applications/"	
	echo "$outputString"
	logToFile "$outputString"
fi

if ! [ -d "/Library/N-central Agent/" ]
then
	outputString="[ Error ] New Mac Agent not properly installed."	
	echo "$outputString"
	logToFile "$outputString"
	exit 1
fi

if [ -f "/Library/LaunchDaemons/com.n-central.agent.plist" ]
then
	cat /Library/LaunchDaemons/com.n-central.agent.plist >> $logFile
else 
	outputString="[ Error ] LaunchDaemon not properly installed."	
	echo "$outputString"
	logToFile "$outputString"
fi


logToFile $(NewSection "Agent process:")
ps ax | grep "N-central" >> $logFile


logToFile $(NewSection "nagent.conf:")
if [ -f "/Library/N-central Agent/nagent.conf" ]
then
	cat "/Library/N-central Agent/nagent.conf" >> $logFile
else 
	outputString="[ Error ] Agent config missing."	
	echo "$outputString"
	logToFile "$outputString"
fi



logToFile $(NewSection "install.log:")
tail -100 /Library/Logs/N-central\ Agent/install.log >> $logFile

logToFile $(NewSection "nagent.log:")
tail -100 /Library/Logs/N-central\ Agent/nagent.log >> $logFile

logToFile $(NewSection "xmpp.log:")
tail -100 /Library/Logs/N-central\ Agent/xmpp.log >> $logFile

logToFile $(NewSection "launchctl list:")
launchctl list >> $logFile

logToFile $(NewSection "launchctl print:")
launchctl print system/com.n-central.agent >> $logFile


endTime=$(date)


logToFile $(NewSection "END")

logToFile "[ END $endTime ]"
