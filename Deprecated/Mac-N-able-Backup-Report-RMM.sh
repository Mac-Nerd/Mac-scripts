#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# This scrips parses and logs the relevant status items from N-able Backup agent. By
# default, the log location is in the Mac_Agent.app path, but can be configured to write
# anywhere that is convenient to report or monitor.

# Default Paths
StatusReport=/Library/Application\ Support/MXB/Backup\ Manager/StatusReport.xml
#SessionReport=/Library/Application\ Support/MXB/Backup\ Manager/SessionReport.xml
ClientTool=/Applications/Backup\ Manager.app/Contents/MacOS/ClientTool

BackupStatusLog=/var/log/com.n-able.backup.log


Separator="----------"


StatusArray[1]="InProcess"
StatusArray[2]="Failed StatusAlert"
StatusArray[3]="Aborted StatusAlert"
StatusArray[5]="Completed"
StatusArray[6]="Interrupted StatusAlert"
StatusArray[7]="NotStarted"
StatusArray[8]="CompletedWithErrors StatusAlert"
StatusArray[9]="InProgressWithFaults StatusAlert"
StatusArray[10]="OverQuota StatusAlert"
StatusArray[11]="NoSelection StatusAlert"
StatusArray[12]="Restarted"

exitcode=0

# Functions
humanReadableBytes() {
	echo "$1" | awk '
		function human(x) {
			if (x<1000) {return x} else {x/=1024}
			s="kMGTEPZY";
			while (x>=1000 && length(s)>1)
				{x/=1024; s=substr(s,2)}
			return int(x+0.5) substr(s,1,1)
	    }
    {sub(/^[0-9]+/, human($1)b); print}'
}

humanReadableSeconds() {
	echo "$1" | awk '
		function human(seconds) {
			if (seconds<60) {
			return $1"s"
			} else {
			minutes=int(seconds/60)
			seconds=seconds%60
			}

			if (minutes<60) {
				printf("%d:%02d", minutes, seconds)
			} else {
			hours=int(minutes/60)
			minutes=minutes%60
				printf("%d:%02d:%02d", hours, minutes, seconds)
			}

	    }
    {sub(/^[0-9]+/, human($1)); print}'
}

numberFormat() {
	printf "%'d" "$1"
}

cleanXML() {
	echo "$1" | sed 's/<[^>]*>/\n/g' | xargs
}

XMLParse() {
	# ex:
	# XMLParse "LastSessionErrorsCount" $StatusReport

	XMLLine=$(xmllint --xpath "/Statistics/Plugin${DSRC}-${1}" "$2")

	cleanXML "$XMLLine"
}

LogStatus() {

	echo "$@" | tee -a "$BackupStatusLog"
}


# logging setup

if [ -f "$BackupStatusLog" ] 
then
	eval $(stat -s "$BackupStatusLog")

	if [ "$st_size" -gt 1000000 ] # log over 1M? roll it.
	then
		LogRename=$(date -r "$BackupStatusLog" "+%Y-%m-%d-%H%M%S")
		mv "$BackupStatusLog" "$BackupStatusLog.$LogRename"
		touch "$BackupStatusLog"
	fi
else # no log? create one.
	echo "Creating $BackupStatusLog"
	touch "$BackupStatusLog"
fi

startTime=$(date)

LogStatus "[ LOG START $startTime ]"



# ClientTool exists?
if ! [ -f "$ClientTool" ]
then
	LogStatus "[ERROR: NotInstalled] N-able Backup is not installed."
	exit 1001
fi

# Backup agent running?
if ! pgrep -q "BackupFP"
then
	LogStatus "[ERROR: NotRunning] N-able Backup is not running."
	exit 1002
fi


# Get agent status

LogStatus "[ Control Status: " $("$ClientTool" control.status.get) "]"

LogStatus "[ Application Status: " $("$ClientTool" control.application-status.get) "]"

errorJSON=$("$ClientTool" control.initialization-error.get)

if [ $(echo "$errorJSON" | tr -Cs "[:alnum:]" " " | xargs | cut -d" " -f2) -ne 0 ]
then
	LogStatus "[ ERROR: InitErrors ]" 
	LogStatus "$errorJSON"
	exitcode=1003

else
	LogStatus "[ Initialization Errors: None ]"
fi


# Get status and statistics for sessions/DataSources

StatusTimeStamp=$(date -r $(cleanXML $(xmllint --xpath "/Statistics/TimeStamp" "$StatusReport")))

LogStatus "$Separator [ Status as of $StatusTimeStamp ] $Separator"


# list datasources
DataSources=$("$ClientTool" control.selection.list | grep "Inclusive" | cut -d" " -f1)



for DSRC in $DataSources
do

	LogStatus "[ DataSource: $DSRC ]"
	LastSessionTimestamp=$(XMLParse "LastSessionTimestamp" "$StatusReport")
	LogStatus "Last Session Start: $(date -r $LastSessionTimestamp)"
	
	SessionDuration=$(XMLParse "SessionDuration" "$StatusReport")
	LogStatus "Last Session Duration: $(humanReadableSeconds $SessionDuration)"
	
	
	LastSessionStatus=$(XMLParse "LastSessionStatus" "$StatusReport")
	
	if ! [[ "$LastSessionStatus" =~ (1|5|7|12) ]]
	then
		exitcode=1004
	fi
	
	
	LogStatus "Last Session Status: ${StatusArray[$LastSessionStatus]}"


	SessionErrors=$(XMLParse "LastSessionErrorsCount" "$StatusReport")
	if [ "$SessionErrors" -gt 0 ]
	then
		LogStatus "[ERROR: SessionErrors]"
		exitcode=1004
	fi	
		
	LogStatus "Session Errors: $(numberFormat $SessionErrors)"
	
	"$ClientTool" control.session.error.list -datasource "$DSRC" -no-header

	
	LogStatus "$Separator"

	LastSessionSelectedCount=$(XMLParse "LastSessionSelectedCount" "$StatusReport")
	LastSessionProcessedCount=$(XMLParse "LastSessionProcessedCount" "$StatusReport")
	
	LogStatus "Files Selected: $(numberFormat $LastSessionSelectedCount)"
	LogStatus "Files Processed: $(numberFormat $LastSessionProcessedCount)"

	LastSessionSelectedSize=$(XMLParse "LastSessionSelectedSize" "$StatusReport")
	LastSessionProcessedSize=$(XMLParse "LastSessionProcessedSize" "$StatusReport")
	LastSessionSentSize=$(XMLParse "LastSessionSentSize" "$StatusReport")


	
	LogStatus "Selected File Size: $(humanReadableBytes $LastSessionSelectedSize)"
	LogStatus "Processed File Size: $(humanReadableBytes $LastSessionProcessedSize)"
	LogStatus "Sent Data: $(humanReadableBytes $LastSessionSentSize)"
	
	LogStatus "$Separator"

	PreRecentSessionSelectedCount=$(XMLParse "PreRecentSessionSelectedCount" "$StatusReport")
	PreRecentSessionSelectedSize=$(XMLParse "PreRecentSessionSelectedSize" "$StatusReport")
	LogStatus "Previous Selected Count: $(numberFormat $PreRecentSessionSelectedCount) "
	LogStatus "Previous Selected Size: $(humanReadableBytes $PreRecentSessionSelectedSize)"

	LogStatus "$Separator"

	LastSuccessfulSessionStatus=$(XMLParse "LastSuccessfulSessionStatus" "$StatusReport")
	LastSuccessfulSessionTimestamp=$(XMLParse "LastSuccessfulSessionTimestamp" "$StatusReport")
	LogStatus "Last Successful Session: $(date -r $LastSuccessfulSessionTimestamp)"
	LogStatus "Last Successful Status: ${StatusArray[$LastSuccessfulSessionStatus]}"
	
	LogStatus "$Separator"

	LastCompletedSessionStatus=$(XMLParse "LastCompletedSessionStatus" "$StatusReport")
	LastCompletedSessionTimestamp=$(XMLParse "LastCompletedSessionTimestamp" "$StatusReport")
	LogStatus "Last Completed Session: $(date -r $LastCompletedSessionTimestamp)"
	LogStatus "Last Completed Status: ${StatusArray[$LastCompletedSessionStatus]}"


	LogStatus "[ END DataSource: $DSRC ]"
	LogStatus "$Separator$Separator$Separator"
 
done


	LogStatus "[ LOG END ]$Separator$Separator"
	LogStatus "$Separator$Separator$Separator"

exit $exitcode

