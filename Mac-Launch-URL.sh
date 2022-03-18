#!/bin/bash
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----


# Open a URL in the default web browser, as the current logged-in user.
# (eg, to enforce a compliance issue, ask user to log into SSO, etc)

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

echo "Running as ${currentUser}"

if [ "$currentUser" == "loginwindow" ] 
then
	echo "[Error] No logged in user."
	exit 1
fi

# Required parameter: 
URL=$1

# This looks for a valid URL in the form http://example.tld
URLregex='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'

if [ $# -eq 0 ] || [ $# -gt 2 ]
then 
	echo "[Error] Wrong number of arguments. This script requires the URL to open, and optionally the name of the browser to open it with."
	exit 1

else

	if ! [[ $URL =~ $URLregex ]]
	then 		
		echo "[Error] The value you entered is not a valid URL."
		echo " - Make sure to include the protocol (\"http://\" \"https://\" or \"ftp://\")"
	else

		if [ -n "$2" ]
		then
			sudo -u "$currentUser" open -a "${2}" "${URL}" &>/dev/null && echo "Launching ${URL} with browser ${2}" || echo "[Error] Something went wrong. Check the name of the app \"${2}\""; exit 1
		else
			sudo -u "$currentUser" open "${URL}" && echo "Launching ${URL} with default browser" || echo "[Error] Something went wrong."; exit 1	
		fi
	fi
fi
