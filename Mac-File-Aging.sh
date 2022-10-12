#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
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

	
