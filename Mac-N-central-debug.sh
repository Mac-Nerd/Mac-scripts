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

logFile="$HOME/Desktop/N-central-debug.log"

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
