#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----


# If your Mac uses Time Machine to perform backups, this will tell you if the backup
# process is idle or working, and if it's working, the percentage completed.


if [ "$(defaults read /Library/Preferences/com.apple.TimeMachine AutoBackup)" -eq 0 ] 
then
	echo "Time Machine backups are disabled."
	exit 1
fi

tmutil latestbackup

currentPhase="$(tmutil currentphase)"

case "$currentPhase" in

	BackupNotRunning)
		echo "Time Machine is idle."
		exit 0
	;;

	MountingBackupVol | MountingBackupVolForHealthCheck | DeletingOldBackups | ThinningPreBackup | Starting)
		echo "Time Machine is starting."
		exit 0
	;;

	Copying)
		echo "Time Machine is copying files to backup."
	;;

	Finishing | ThinningPostBackup)
		echo "Time Machine is finishing the backup process."
		exit 0
	;;

	HealthCheckCopyHFSMeta | HealthCheckFsck) 
		echo "Time Machine is verifying and checking your backups."
		exit 0
	;;

	*)
		echo "An unknown error ocurred."
		echo "tmutil returned:"
		echo "$currentPhase"
		exit 1
	;;
esac

# get status, look for "Percent=" line, strip anything non numerical or decimal point, truncate at decimal.
percentComplete="$(tmutil status | grep -m1 Percent | tr -cd '0-9.' | cut -f1 -d '.')"

# if empty, percent = 0
[ "$percentComplete" ] || percentComplete=0


echo "Percent Completed: $percentComplete%"
