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
# In the normal operation of a Mac, many applications and system services use a local
# cache to speed up operations. Maintenance routines will periodically expire or remove
# older cache files, but sometimes they fail. Cached files that are no longer necessary, 
# or for apps that have been removed, will remain and clutter the cache folders. 
# Ultimately, this will fill up the drive if left unchecked.
# 
# This script checks common cache folders in each user's home directory, as well as 
# the system, to determine if they are larger than an optional maximum parameter 
# (default 2 gigabytes). 
# 

exitCode=1000

MaxCacheSize=$1

if [ -z "$MaxCacheSize" ]
then
	MaxCacheSize=2048		# default max size 2gig
fi

# list all Users' home directories (uses dscl in the rare instance they're not in /Users/*)
UserHomes=$(dscl /Local/Default -list /Users NFSHomeDirectory | awk '$2 ~ /^\/Users/ { print $2 }' )

for UserHome in ${UserHomes} 
do
	# Does the home folder have a Caches folder?
	if [ -d "${UserHome}/Library/Caches" ]
	then

		CacheSizeMegs="$(du -mc ${UserHome}/Library/Caches 2> /dev/null | tail -1 | cut -f1)"
		echo "\n[ ${UserHome} Caches ]: ${CacheSizeMegs} megabytes"
		
		if [ $CacheSizeMegs -ne 0 ]
		then
			echo "Top items:"
			du -h ${UserHome}/Library/Caches/* 2> /dev/null | sort -hr | head -10
			if [ $CacheSizeMegs -gt $MaxCacheSize ]
			then
				((exitCode++))
			fi	
		fi
		
	fi
	
done


sysCacheSizeMegs="$(du -mc /Library/Caches | tail -1 | cut -f1)"
echo "\n[ System Caches ]: ${sysCacheSizeMegs} megabytes"

if [ $sysCacheSizeMegs -ne 0 ]
then
	echo "Top items:"
	du -h /Library/Caches/* | sort -hr | head -10
	if [ $sysCacheSizeMegs -gt $MaxCacheSize ]
	then
		((exitCode++))
	fi	
fi

exit "$exitCode"
