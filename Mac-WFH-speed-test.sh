#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------



if [ "$1" ]
then
	minimumspeed="$1"
else
	minimumspeed=5120		# default minimum ~5 megabits.
fi


# Runs a speed test via fast.com API. Takes one parameter of kilobytes per second. 
# If bandwidth reports less than that minimum, the check fails.

tempFile="/tmp/speedcheck.txt"
token=$(curl -s https://fast.com/app-ed402d.js | grep -E -om1 'token:"[^"]+' | cut -f2 -d'"')

url=$(curl -s "https://api.fast.com/netflix/speedtest?https=true&token=$token&urlCount=1" | grep -E -o 'https[^"]+')

testURL=${url/speedtest/speedtest\/range\/0-10000}; 

if curl -H 'Referer: https://fast.com/' -H 'Origin: https://fast.com' "$testURL" -o /dev/null 2>&1 | tr -u '\r' '\n' > $tempFile
then
	averageDL=$(grep -E '^100' "$tempFile" | tr -u -s "[:space:]" | cut -d ' ' -f7)
	echo "Speed reported: $averageDL K/s"
	
	if [ "$averageDL" -lt "$minimumspeed" ]
	then
		echo "[WARNING] Bandwidth detected less than minimum $minimumspeed K/s"
		exit 1001
	else
#		echo "Bandwidth sufficient."
		exit 0
	fi
				
else
	echo "[ERROR] Unable to reach fast.com"
	exit 1002
fi
