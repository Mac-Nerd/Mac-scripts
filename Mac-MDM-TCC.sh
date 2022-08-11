#!/bin/zsh

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# !!! Terminal or process running this script will need Full Disk Access

# Reads the /Library/Application Support/com.apple.TCC/MDMOverrides.plist for TCC
# entries set by MDM profiles, and generates a human-readable report.

# see also:
# https://www.rainforestqa.com/blog/macos-tcc-db-deep-dive


if [ -z "${ZSH_VERSION}" ]; then
  >&2 echo "ERROR: This script is only compatible with Z shell (/bin/zsh)."
  exit 1
fi



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


# MDM profile overrides

if [ -f "/Library/Application Support/com.apple.TCC/MDMOverrides.plist" ]
then
	echo "======== [ MDM TCC Profiles ]"

	FullMDMOverrides=$(plutil -convert xml1 -o - /Library/Application\ Support/com.apple.TCC/MDMOverrides.plist)

	MDMOverrides=$(echo $FullMDMOverrides | xmllint --xpath "/*/dict[*]/key" - | sed 's/<[^>]*>/^/g')

	Index=1

	for Identifier in ${(s:^:)MDMOverrides}
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



