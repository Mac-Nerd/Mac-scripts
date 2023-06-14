#!/bin/sh

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# If your Mac uses Time Machine to perform backups, this will tell you if the backup
# process is idle or working, and if it's working, the percentage completed.
#
# .Name: macOS_TimeMachine_Status.sh
# .Desc: macOS Monitors Time Machine backups
# 
# Extended by Where To Start and Time <Hack> Scripts, see below
#
# .Disclaimer
#    No warranties.  Use at your own risk. Where To Start is not responsible for any damage this script/material may cause.
#    This script and any accompanying or associated code and/or materials are to be used at your own risk and NO warranties
#    are expressed or implied.  It is expected that anyone who is using this script understands Shell, the Operating
#    System(s), the software, and the environment being impacted and by utilizing (executing or causing to be executed)
#    this script (or any part thereof) constitutes full acceptance by the end-user of any and all associated risks and results.
#
# .Copywrite & Use
#    Copyright 2022 Where To Start Inc. All rights reserved.
#
#    All brands, logos, original copyrights, and trademarks are the properties of their respective holders.
#    This script and any associated code and/or materials are for use exclusively within the business that has purchased
#    and been granted a license for its use.
#
#    Where possible Where To Start has acknowledged and given credit for the source of the ideas we have based our code upon.
#
# .Credit
#    Based upon: https://success.n-able.com/kb/nable_n-central/Mac-Time-Machine-Backup-Status
#
# .Versions:
#    20220629	AJH	Original public release
#    20220709	AJH Added "have not had a backup in X days"
#    20220717	AJH Added new TM Statuses
#

ErrFound=0
exitcode=0
scriptv="20220717"

lastBackupDateString=""

critMinutes=1440   # minutes in a day
currentDateSeconds=$(date +%s)  > /dev/null 2>&1

thishost=$(hostname -s | sed -e 's/^[^.]*\.//')

# Number of days to go without a backup
# https://stackoverflow.com/questions/21407235/null-empty-string-comparison-in-bash#21407325
if [ -z $1 ]; then
	DayzBack=5
else 
	DayzBack=$1
fi

#get the name of this host
thishost=$( scutil --get ComputerName )

# Check your privilege level
if [ $(whoami) != "root" ]; then
    echo "ERR: This script must be run with root/sudo privileges."
	echo "\n$(date +%F_%T), Exit Code: 1001, (v.$scriptv) on $thishost"
#    exit 1001
fi

# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
if [ "$(defaults read /Library/Preferences/com.apple.TimeMachine AutoBackup)" -eq 0 ] 
then
	echo "WARNING: Time Machine backups are disabled."
	echo "\n$(date +%F_%T), Exit Code: $exitcode, (v.$scriptv) on $thishost"
	exit 0
fi

currentPhase="$(tmutil currentphase)"
case "$currentPhase" in
	BackupNotRunning)
		echo "Time Machine is currently idle."
		ErrFound=0
	;;
	MountingBackupVol | MountingBackupVolForHealthCheck | DeletingOldBackups | ThinningPreBackup | Starting | FindingChanges | PreparingSourceVolumes)
		echo "Time Machine is getting ready."
		ErrFound=0
	;;
	Copying)
		echo "Time Machine is copying files to the Time Machine."
		ErrFound=0
	;;
	Finishing | ThinningPostBackup)
		echo "Time Machine is finishing the backups process."
		ErrFound=0
	;;
	HealthCheckCopyHFSMeta | HealthCheckFsck) 
		echo "Time Machine is verifying your backups."
		ErrFound=0
	;;
	FindingBackupVol )
		echo "WARNING: The Time Machine drive can not be located."
		ErrFound=0
	;;
	DeletingOldBackups | LazyThinning )
		echo "Time Machine is removing older backups to make room for new ones."
		ErrFound=0	
	;;
	*)
		echo "ERR: An unknown error ocurred."
		echo "tmutil returned:"
		echo "$currentPhase"
		ErrFound=1
	;;
esac

# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
if [ $ErrFound -eq 0 ]
then
	lastBackupDateString=`tmutil latestbackup 2>/dev/null | grep -E -o "[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}"` #2>/dev/null
	if [ -z $lastBackupDateString ]
	then 
		echo "\tCould not verify the LAST backup date, also check\n\tto make sure the terminal app has full disk access."
	else
		echo "\tThe last Time Machine Backup was: $lastBackupDateString"
	fi
	
	critSeconds=$(($DayzBack * $critMinutes * 60))
	lastBackupDateSeconds=$(date -j -f "%Y-%m-%d-%H%M%S" $lastBackupDateString "+%s" 2>/dev/null )
	DiffTMsecResult=$?
	if [ $DiffTMsecResult = 0 ]
	then 
		TMdiff=$(($currentDateSeconds - $lastBackupDateSeconds ))
		DiffTMresult=$?
		if [ $DiffTMresult = 0 ]
		then
			critSeconds=$(($DayzBack * $critMinutes * 60))
			if [ $TMdiff -gt $critSeconds ]; then
				echo "\nCAUTION: A Time Machine backups have NOT been taken since $lastBackupDateString"
				echo "Frequent backups need to be taken for your safety (we are looking for a backup at least every $DayzBack days)"
				exitcode=1001
			else 
				echo "\tGOOD: Recent Time Machine backups has been completed within the last $DayzBack days"
			fi
		else 
			exitcode=1001
		fi
	fi
	
	tmutil status 2>/dev/null | awk '/BackupPhase/ {print $3}' | awk '{ print "\tAction being performed: " $1 }' 2>/dev/null
	tmutil status 2>/dev/null | awk '/_raw_Percent/ {print $3}' | grep -o '[0-9].[0-9]\+' | awk '{ print "\tTime Machine Backup is "$1*100 "% Complete" }' 2>/dev/null

	echo "\nPrevious Time Machine backups according to the available log files (in UTC time):"
	defaults read "/Library/Preferences/com.apple.TimeMachine.plist" Destinations  2>/dev/null | \
		sed -n '/SnapshotDates/,$p' | grep -e '[0-9]' | awk -F '"' '{print $2}' | awk 'NF' | sort -r | \
		cut -d" " -f1,2 
		
	echo "\nTimeMachine Storage Locations:"
	tmutil destinationinfo 
else
	exitcode=1001
	echo ""
fi

echo "\n$(date +%F_%T), Exit Code: $exitcode, (v.$scriptv) on $thishost"

exit $exitcode
