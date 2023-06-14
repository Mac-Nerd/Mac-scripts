#!/bin/bash

# Prompt user to reboot if there are updates pending, or if the Mac
# has been online for more than X/2 days. If uptime is > X days, 
# the script will force a restart. Default X=14

if [ -n "$1" ]
then
	maxUptime=$1
else
	maxUptime=14
fi
	
timeout=60 # seconds until restart

OSVERSION=$(defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print $1}')

OSMAJOR=$(echo "${OSVERSION}" | cut -d . -f1)
#OSMINOR=$(echo "${OSVERSION}" | cut -d . -f2)


if pgrep "RMM Notification Service"
then
	AppName="RMM Notification Service"
elif pgrep -f "Mac_Agent.app"
then
	AppName="Mac_Agent"
else
	AppName="Finder"
fi

echo "Using $AppName"

niceRestart(){ # thanks to https://community.jamf.com/t5/user/viewprofilepage/user-id/73522

	echo "Restarting system now."
	osascript <<EOF
tell application "System Events" to set quitapps to name of every application process whose visible is true and name is not "Finder"
repeat with closeall in quitapps
	try
		with timeout of ${timeout} seconds
			quit application closeall
		end timeout
	end try
end repeat
with timeout of ${timeout} seconds
	tell application "Finder" to restart
end timeout
EOF
 	shutdown -r now
}

warningPrompt(){
	promptResponse=$( osascript <<EOF
tell application "$AppName"
	activate
	set buttonResponse to button returned of (display alert "Restart Warning" message "Please restart your Mac soon. It has been online for $uptimeDays days without rebooting." buttons {"Restart Now", "Restart Later"} default button "Restart Later")
end tell
return buttonResponse
EOF
)
	if [[ "$promptResponse" = "Restart Now" ]]
	then
		echo "Trying a \"nice\" restart."

		niceRestart
	fi	
}

tooLatePrompt(){
	osascript <<EOF
tell application "$AppName"
activate
	display alert "Restarting Your Computer" message "Your Mac has been online for more than the allowed maximum $maxUptime days without rebooting. It will restart in $timeout seconds. " buttons {"Restart Now"} default button "Restart Now" giving up after $timeout
end tell
EOF
	niceRestart
}


installPrompt(){
	promptResponse=$( osascript <<EOF
tell application "$AppName"
	activate
	set buttonResponse to button returned of (display alert "Restart Warning" message "Please restart. There are updates for your Mac that are waiting on a restart to complete." buttons {"Restart Now", "Restart Later"} default button "Restart Later")
end tell
return buttonResponse
EOF
)
	if [[ "$promptResponse" = "Restart Now" ]]
	then
		echo "Trying a \"nice\" restart."

		niceRestart
	fi	
}



# check pending updates
if [[ $OSMAJOR -lt 11 ]]
then
	# 10x
	pendingUpdates=$(defaults read /Library/Updates/index.plist InstallAtLogout | grep -c [A-Za-z0-9])
else 
	# >10 - number of assets downloaded
	pendingUpdates=$(find /System/Library/AssetsV2/com_apple_MobileAsset_MacSoftwareUpdate/ -type d -d 1 | grep -c -i asset)
fi


uptimeRaw="$(uptime | grep day)"
#echo $uptimeRaw

if [[ -n "$uptimeRaw" ]]
then
    uptimeDays=$(echo "$uptimeRaw" | awk '{print $3}')
else
    uptimeDays=0
fi

echo "Mac uptime: $uptimeDays days."
echo "Warning days: $((maxUptime/2))"
echo "Force days: $maxUptime"

if [ $uptimeDays -ge $maxUptime ] 
then
	tooLatePrompt		# force reboot
elif [ $uptimeDays -ge $((maxUptime/2)) ]
then 
	warningPrompt		# give a warning
elif [ $pendingUpdates -gt 0 ]
then
	installPrompt		# offer to reboot for pending updates
fi

