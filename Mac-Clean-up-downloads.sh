#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# For each local user on the Mac, move any files that have not been accessed in more than
# n days (default 14) to a separate "CLEANUP" folder for them to delete or archive.
# 
# You can alternately deposit old files in the user's Trash. 
# *** Only use this option after suitably warning your users *** 



DESTINATION="Downloads/CLEANUP"  
# DESTINATION=".Trash/CLEANUP"	


# requires a number of days, otherwise defaults to 14
if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null
then 
	echo "RANGE = ${1} DAYS"
	DAYS="$1"
else
	echo "DEFAULT RANGE = 14 DAYS"
	DAYS=14	
fi


# list all Users' home directories (uses dscl in the rare instance they're not in /Users/*)
USERHOMES=$(dscl /Local/Default -list /Users NFSHomeDirectory | awk '$2 ~ /^\/Users/ { print $2 }' )

for USERHOME in ${USERHOMES} 
do
	# Does the home folder have a Downloads folder?
	if [ -d "${USERHOME}/Downloads" ]
	then

# Whose downloads?
		USERNAME=$(stat -f %Su "${USERHOME}")
		echo "Doing Downloads cleanup for $USERNAME"

# Create a "CLEANUP" folder if one doesn't already exist
		if [ ! -d "${USERHOME}/${DESTINATION}" ]
		then
			echo "Creating CLEANUP directory for $USERNAME"

			mkdir "${USERHOME}/${DESTINATION}"

			chown "${USERNAME}" "${USERHOME}/${DESTINATION}"
		
			echo "Setting CLEANUP directory owner to $USERNAME"

		fi



# Move any files in Downloads that have not been accessed in > 14 days to the CLEANUP folder.		
		find "${USERHOME}/Downloads" -atime +${DAYS}d -depth 1 -type f -exec mv {} "${USERHOME}/${DESTINATION}" \;


# Count how	many were moved, and how much disk space they take up
		CLEANUPFILES=$(find "${USERHOME}/${DESTINATION}" -maxdepth 1 -type f | wc -l)
		CLEANUPSIZE=$(du -hs "${USERHOME}/${DESTINATION}" | awk -F ' ' '{print $1}')
				echo "${USERNAME} can save ${CLEANUPSIZE} by deleting ${CLEANUPFILES} files in their ${DESTINATION} folder."
				echo "--"

	fi
	
	
done

