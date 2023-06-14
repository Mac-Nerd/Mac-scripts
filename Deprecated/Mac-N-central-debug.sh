#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

if [ -n "$1" ]
then
serverName=$1
else
serverName="sis.n-able.com"
fi

#logFile="$HOME/Desktop/N-central-debug.log"
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


if ! [ -d "/Applications/Mac_Agent.app" ]
then
	outputString="[ Error ] Mac Agent not installed in /Applications/"	
	echo "$outputString"
	logToFile "$outputString"
	exit 1
fi


logToFile $(NewSection "Agent process:")
ps ax | grep -i Mac_ >> $logFile



logToFile $(NewSection "nagent.conf:")


if [ -f "/Applications/Mac_Agent.app/Contents/Daemon/etc/nagent.conf" ]
then
	cat "/Applications/Mac_Agent.app/Contents/Daemon/etc/nagent.conf" >> $logFile
else
	outputString="[ Warning ] Unable to locate nagent.conf"	
	echo "$outputString"
	logToFile "$outputString"
fi


logToFile $(NewSection "nagent.log:")
tail -100 /private/var/log/N-able/N-agent/nagent.log >> $logFile

logToFile $(NewSection "xmpp.log:")
tail -100 /private/var/log/N-able/N-agent/xmpp.log >> $logFile

logToFile $(NewSection "launctl list:")
launchctl list >> $logFile

logToFile $(NewSection "launctl print:")
launchctl print system/com.n-able.agent-macos10_4ppc >> $logFile


endTime=$(date)


logToFile $(NewSection "END")

logToFile "[ END $endTime ]"
