#!/bin/zsh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Organizes a directory of files with different extensions into separate folders, one
# for each extension. e.g. all PNG files into a folder named "PNG", JPEGs into a folder
# named "JPEG" etc. All new directories are created in UPPER case, to avoid case 
# sensitive confusion between file.ext and file.EXT

# command line parameter: path to folder to organize
CLEANUPPATH=$1

echo "Cleaning up $CLEANUPPATH"

if [ -n "$CLEANUPPATH" ]; then

	FILECOUNT=0
	# For each file in the provided directory
	for FILENAME in $CLEANUPPATH/*.*

	do 
	# get the extension (everything after the last .)
		((FILECOUNT++))
		# Set the EXT variable to the extension
		EXT=${FILENAME##*.}

		EXT=${EXT:u}		# optional: makes the extension all UPPER case
		
		# If a directory with that extension does not already exist
		if ! test -d "$CLEANUPPATH/$EXT"; then
			mkdir "$CLEANUPPATH/$EXT"
			(($?)) && echo "Unable to create $CLEANUPPATH/$EXT." && exit 2
		fi

		mv "$FILENAME" "$CLEANUPPATH/$EXT"
		(($?)) && echo "Unable to move $FILENAME to $CLEANUPPATH/$EXT." && exit 3

	done
	
	echo "$FILECOUNT files organized."
	exit 0

else 

	echo "Please provide the path for a folder to organize. (e.g. ~/Desktop/)"
	exit 1

fi
