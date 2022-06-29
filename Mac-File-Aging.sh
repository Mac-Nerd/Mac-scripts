#!/bin/bash

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# -----------------------------------------------------------

# Mac File Aging - Takes a path and number as arguments. If the file or directory at the
# specified path is OLDER than the specified number in DAYS, the script check fails.

if [ -n "$2" ]
then
	maxDays=$2
	
	if [ -e "$1" ]
	then
		ageInDays=$((($(date +%s) - $(stat -t %s -f %m -- "$1")) / 86400))
		if [ "$ageInDays" -gt "$maxDays" ]
		then
			echo "[WARNING] $1 last modified $ageInDays days ago."
			exit 1001
		else
			echo "$1 last modified $ageInDays days ago."
			exit 0
		fi
	else
		echo "[ERROR] The path specified at $1 does not exist."
		exit 1001	
	fi
	
else
	echo "[ERROR] This script requires two parameters. A path and a number of days."
	exit 1001
fi

	
