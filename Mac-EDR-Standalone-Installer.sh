#!/bin/bash          

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# Installs the latest version of the SentinelOne standalone EDR for Mac. The installation
# token from your SentinelOne console is required.

# The required install token can be hardcoded or provided as optional command line 
# argument. If provided, the token from the CLI has priority.
# It's also possible to install SentinelOne without the token, and register later.
# This command registers SentinelOne with your product token
# /usr/local/bin/sentinelctl set registration-token -- "$installToken"

# For debugging purposes, this script logs its activity to /tmp/SentinelOneInstaller.log


installToken=""

installerPKG="https://sis.n-able.com/SentinelOne/SentinelAgent_macos_latest.pkg"

logFile="/tmp/SentinelOneInstaller.log"


if ! [ -f "$logFile" ]
then
	touch "$logFile"
fi

logToFile(){
	echo "" >> $logFile
	echo "[$(date)] $*" >> $logFile
}


logToFile "======== START ========"

# Check if S1 is already installed?

logToFile "Check if S1 is already installed?"

[[ -f /usr/local/bin/sentinelctl ]] && echo "SentinelOne already installed." && exit 1001


if [ -n "$1" ] # command line parameter
then
	logToFile "using install token $1"
    installToken=$1
fi

logToFile "cd to /tmp"
cd "/tmp/" || exit 1002

# create the token file if not already
logToFile "creating token file"
touch com.sentinelone.registration-token || exit 1003

# put the token into the file
logToFile "put the token into the file"
echo "$installToken" > com.sentinelone.registration-token

#Get Package Download

echo "Downloading SentinelOne Installer from ${installerPKG}"
logToFile "Downloading SentinelOne Installer from ${installerPKG}"
if curl -sSL -o "${TMPDIR}Sentinel.pkg" "${installerPKG}"
then
	#Install Package
	echo "Installing SentinelOne from ${TMPDIR}Sentinel.pkg"
	logToFile "Installing SentinelOne from ${TMPDIR}Sentinel.pkg"

	/usr/sbin/installer -pkg "${TMPDIR}Sentinel.pkg" -target /

	exitcode=0
	
	# Check S1 has Full Disk Access?
	logToFile "Check S1 has Full Disk Access?"
	StatusMessage=$(/usr/local/bin/sentinelctl status --filters agent | grep "Missing")
	
	MissingAuths="*Missing*com.sentinelone*"

	while IFS= read -r StatusLine
	do
		if [[ "$StatusLine" =~ $MissingAuths ]]
		then		
			logToFile "[ WARNING ] SentinelOne missing Full Disk Access permissions."
			echo "[ WARNING ] SentinelOne missing Full Disk Access permissions."
			exitcode=1005
		else 
			logToFile "SentinelOne seems to have proper permissions. Continuing."
		fi
done <<-EOF
$StatusMessage
EOF
	logToFile "$exitcode"
	
	logToFile "======== DONE ========"
	

	exit $exitcode
	
else
	logToFile "Something went wrong downloading $installerPKG"
	echo "Something went wrong downloading $installerPKG"
	exit 1004
fi
