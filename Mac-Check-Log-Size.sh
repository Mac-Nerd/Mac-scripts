#!/bin/bash

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# -----------------------------------------------------------
# 
# When applications start having problems, often the first sign is that the error log
# for that application fills up with messages. This can also lead to slower performance
# overall, as the system is spending its time writing out errors to increasingly large
# log files. Ultimately, this will fill up the drive if left unchecked.
# 
# To detect this situation, an easy check to run is the size of the log files on the 
# machine. This script checks the log folders in each user's home directory, as well as 
# the system, to determine if they are larger than an optional maximum parameter 
# (default 500 Megs). 
# 

exitCode=1000

MaxLogSize=$1

if [ -z "$MaxLogSize" ]
then
	MaxLogSize=500		# default max size 500M
fi



# list all Users' home directories (uses dscl in the rare instance they're not in /Users/*)
UserHomes=$(dscl /Local/Default -list /Users NFSHomeDirectory | awk '$2 ~ /^\/Users/ { print $2 }' )

for UserHome in ${UserHomes} 
do
	# Does the home folder have a Logs folder?
	if [ -d "${UserHome}/Library/Logs" ]
	then

		logSizeMegs="$(du -mc ${UserHome}/Library/Logs | tail -1 | cut -f1)"
		echo "\n[ ${UserHome} Logs ]: ${logSizeMegs} megabytes"
		
		if [ $logSizeMegs -ne 0 ]
		then
			echo "Top items:"
			du -h ${UserHome}/Library/Logs/* | sort -hr | head -10
			if [ $logSizeMegs -gt $MaxLogSize ]
			then
				((exitCode++))
			fi	
		fi
		
	fi
	
done


syslogSizeMegs="$(du -mc /Library/Logs | tail -1 | cut -f1)"
echo "\n[ System Logs ]: ${syslogSizeMegs} megabytes"

if [ $syslogSizeMegs -ne 0 ]
then
	echo "Top items:"
	du -h /Library/Logs/* | sort -hr | head -10
	if [ $syslogSizeMegs -gt $MaxLogSize ]
	then
		((exitCode++))
	fi	
fi

varlogSizeMegs="$(du -mc /var/log | tail -1 | cut -f1)"
echo "\n[ /var/log ]: ${varlogSizeMegs} megabytes"

if [ $varlogSizeMegs -ne 0 ]
then
	echo "Top items:"
	du -h /var/log/* | sort -hr | head -10
	if [ $varlogSizeMegs -gt $MaxLogSize ]
	then
		((exitCode++))
	fi	
fi

exit "$exitCode"
