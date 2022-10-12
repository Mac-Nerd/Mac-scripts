#!/bin/zsh

# version 2.7, 09-28-2022

# To Do
# - list apps in TCC.db that are no longer installed.
# - offer to clean missing apps from TCC.db with tccutil
# - output report in CSV? JSON?

# !!! Terminal or process running this script will need Full Disk Access

# read the tcc.db and translate the following:
# service
# client
# auth_value
# auth_reason
# indirect_object_identifier
# last_modified

# see also:
# https://www.rainforestqa.com/blog/macos-tcc-db-deep-dive


if [ -z "${ZSH_VERSION}" ]; then
  >&2 echo "ERROR: This script is only compatible with Z shell (/bin/zsh)."
  exit 1
fi



# TCC Translator arrays

# service
typeset -A ServiceArray
ServiceArray[kTCCServiceAddressBook]="Contacts"
ServiceArray[kTCCServiceAppleEvents]="Apple Events"
ServiceArray[kTCCServiceBluetoothAlways]="Bluetooth"
ServiceArray[kTCCServiceCalendar]="Calendar"
ServiceArray[kTCCServiceCamera]="Camera"
ServiceArray[kTCCServiceContactsFull]="Full contacts information"
ServiceArray[kTCCServiceContactsLimited]="Basic contacts information"
ServiceArray[kTCCServiceFileProviderDomain]="Files managed by Apple Events"
ServiceArray[kTCCServiceFileProviderPresence]="See when files managed by client are in use"
ServiceArray[kTCCServiceLocation]="Current location"
ServiceArray[kTCCServiceMediaLibrary]="Apple Music, music and video activity, and media library"
ServiceArray[kTCCServiceMicrophone]="Microphone"
ServiceArray[kTCCServiceMotion]="Motion & Fitness Activity"
ServiceArray[kTCCServicePhotos]="Read Photos"
ServiceArray[kTCCServicePhotosAdd]="Add to Photos"
ServiceArray[kTCCServicePrototype3Rights]="Authorization Test Service Proto3Right"
ServiceArray[kTCCServicePrototype4Rights]="Authorization Test Service Proto4Right"
ServiceArray[kTCCServiceReminders]="Reminders"
ServiceArray[kTCCServiceScreenCapture]="Capture screen contents"
ServiceArray[kTCCServiceSiri]="Use Siri"
ServiceArray[kTCCServiceSpeechRecognition]="Speech Recognition"
ServiceArray[kTCCServiceSystemPolicyDesktopFolder]="Desktop folder"
ServiceArray[kTCCServiceSystemPolicyDeveloperFiles]="Files in Software Development"
ServiceArray[kTCCServiceSystemPolicyDocumentsFolder]="Files in Documents folder"
ServiceArray[kTCCServiceSystemPolicyDownloadsFolder]="Files in Downloads folder"
ServiceArray[kTCCServiceSystemPolicyNetworkVolumes]="Files on a network volume"
ServiceArray[kTCCServiceSystemPolicyRemovableVolumes]="Files on a removable volume"
ServiceArray[kTCCServiceSystemPolicySysAdminFiles]="Administer the computer"
ServiceArray[kTCCServiceWillow]="Home data"
ServiceArray[kTCCServiceSystemPolicyAllFiles]="Full Disk Access"
ServiceArray[kTCCServiceAccessibility]="Control the computer"
ServiceArray[kTCCServicePostEvent]="Send keystrokes"
ServiceArray[kTCCServiceListenEvent]="Monitor input from the keyboard"
ServiceArray[kTCCServiceDeveloperTool]="Run insecure software locally"
ServiceArray[kTCCServiceLiverpool]="Location services"
ServiceArray[kTCCServiceUbiquity]="iCloud"
ServiceArray[kTCCServiceShareKit]="Share features"
ServiceArray[kTCCServiceLinkedIn]="Share via LinkedIn"
ServiceArray[kTCCServiceTwitter]="Share via Twitter"
ServiceArray[kTCCServiceFacebook]="Share via Facebook"
ServiceArray[kTCCServiceSinaWeibo]="Share via Sina Weibo"
ServiceArray[kTCCServiceTencentWeibo]="Share via Tencent Weibo"

# auth_reason 
typeset -A AuthReasonArray
AuthReasonArray[0]="Inherited/Unknown"
AuthReasonArray[1]="Error"
AuthReasonArray[2]="User Consent"
AuthReasonArray[3]="User Set"
AuthReasonArray[4]="System Set"
AuthReasonArray[5]="Service Policy"
AuthReasonArray[6]="MDM Policy"
AuthReasonArray[7]="Override Policy"
AuthReasonArray[8]="Missing usage string"
AuthReasonArray[9]="Prompt Timeout"
AuthReasonArray[10]="Preflight Unknown"
AuthReasonArray[11]="Entitled"
AuthReasonArray[12]="App Type Policy"

# auth_value
typeset -A AuthValueArray
AuthValueArray[0]="Denied"
AuthValueArray[1]="Unknown"
AuthValueArray[2]="Allowed"
AuthValueArray[3]="Limited"

CurrentClient=""


processRow() {
	TCCRow=$1
	RawClient=$(echo $TCCRow | cut -d',' -f1)
	
	ClientType=$(echo $TCCRow | cut -d',' -f2)
	if [ $ClientType -eq 0 ]
	then
		Client=$(mdfind "kMDItemCFBundleIdentifier = $RawClient" | head -1)
		if [ -z $Client ]
		then
			Client=$RawClient
		fi
	else
		Client=$RawClient
	fi
		
	ServiceName=$(echo $TCCRow | cut -d',' -f3)
	AuthVal=$(echo $TCCRow | cut -d',' -f4)
	AuthReason=$(echo $TCCRow | cut -d',' -f5)
	DateAuthEpoch=$(echo $TCCRow | cut -d',' -f6)

	DateAuth=$(date -r $DateAuthEpoch +"%d %h, %Y")
	
	if [ "$Client" != "$CurrentClient" ]
	then
		CurrentClient=$Client
		ShortClient=$(basename $Client) # clean up paths a bit
		printf "--- \n\n%s\n" $ShortClient
		CurrentAuthVal=""
	fi
 
	if [ "$AuthVal" != "$CurrentAuthVal" ]
	then
		CurrentAuthVal=$AuthVal
		printf "\t%s:\n" $AuthValueArray[$AuthVal]
	fi
 
	printf "\t\t%s (%s - %s)\n"	 $ServiceArray[$ServiceName] $AuthReasonArray[$AuthReason] $DateAuth
}




# start with the system defaults:

echo "======== [System Default Permissions]"

sqlite3 /Library/Application\ Support/com.apple.tcc/tcc.db -csv -noheader -nullvalue '-' \
'select client, client_type, service, auth_value, auth_reason, last_modified from access order by client, auth_value' \
| while read -r TCCRow
do
	processRow "$TCCRow"
done


echo "======== [Per-user Permissions Overrides]"


# list all Users' home directories (uses dscl in the rare instance they're not in /Users/*)
USERHOMES=$(dscl /Local/Default -list /Users NFSHomeDirectory | grep -v "/var/empty" | awk '$2 ~ /^\// { print $2 }' )

for USERHOME in ${=USERHOMES}
do

	if [ -f "${USERHOME}/Library/Application Support/com.apple.tcc/tcc.db" ]
	then
	
		echo "================ [ ${USERHOME} ]"

		sqlite3 ${USERHOME}/Library/Application\ Support/com.apple.tcc/tcc.db -csv -noheader -nullvalue '-' \
		'select client, client_type, service, auth_value, auth_reason, last_modified from access order by client, auth_value' \
		| while read -r TCCRow
		do
			processRow "$TCCRow"
		done
		
	fi

done


# MDM profile overrides

if [ -f "/Library/Application Support/com.apple.TCC/MDMOverrides.plist" ]
then
	echo "======== [ MDM TCC Profiles ]"

	FullMDMOverrides=$(plutil -convert xml1 -o - /Library/Application\ Support/com.apple.TCC/MDMOverrides.plist)

	MDMOverrides=$(echo $FullMDMOverrides | xmllint --xpath "/*/dict[*]/key" - | sed 's/<[^>]*>/ /g')

	Index=1

	for Identifier in ${=MDMOverrides}
	do
		printf "--- \n%s\n" $Identifier
		
		IdentifierXML=$(echo $FullMDMOverrides | xmllint --xpath "/*/dict[*]/dict[$Index]" -)

		AllServiceNames="$(echo $IdentifierXML | xmllint --xpath '/dict[1]/key' - | sed 's/<[^>]*>/\n/g')"

		ServiceIndex=1
		
		for ServiceName in ${=AllServiceNames}
		do
			if [ $ServiceName = "kTCCServiceAppleEvents" ]
			then			
				if $(echo $IdentifierXML | xmllint --xpath "/dict[$ServiceIndex]//true" - &> /dev/null)
				then
					AuthVal="Allowed"
				else
					AuthVal="Denied"
				fi
			else 
				AuthVal="$(echo $IdentifierXML | xmllint --xpath "/dict/dict[$ServiceIndex]/key[1]" - | sed 's/<[^>]*>//g')"	
			fi

			printf "\t%s:\n" $AuthVal
			printf "\t\t%s\n" $ServiceArray[$ServiceName]
			((ServiceIndex++))

		done

		((Index++))
	done


else 
	echo "======== [ No MDM TCC Profiles found ]"
fi	

