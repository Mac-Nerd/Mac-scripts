#!/bin/zsh

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

UsersList=$(dscl /Local/Default -list /Users | egrep  -v '^_.+|root')

for UserName in ${=UsersList}
do 
    if dseditgroup -o checkmember -m "$UserName" "staff" 1>/dev/null
    then    	
        StaffList=$(printf "%s %s" "$StaffList" "$UserName")
    fi
done




# This will reset the user-approved or -denied PPPC settings for the system. It will not 
# affect MDM overridden TCC profiles.

# The following service names are available to reset with TCC Utility:

#	All
#	Accessibility
#	AddressBook
#	AlwaysAllowedService.AppleEvents
#	AppleEvents
#	BluetoothAlways
#	BluetoothPeripheral
#	BluetoothWhileInUse
#	Calendar
#	Calls
#	Camera
#	ContactsFull
#	ContactsLimited
#	DeveloperTool
#	ExposureNotification
#	ExposureNotificationRegion
#	FaceID
#	Facebook
#	FallDetection
#	FileProviderDomain
#	FileProviderPresence
#	FocusStatus
#	GameCenterFriends
#	KeyboardNetwork
#	LinkedIn
#	ListenEvent
#	Liverpool
#	MSO
#	MediaLibrary
#	Microphone
#	Motion
#	NearbyInteraction
#	Photos
#	PhotosAdd
#	PostEvent
#	Prototype3Rights
#	Prototype4Rights
#	Reminders
#	ScreenCapture
#	SensorKitAmbientLightSensor
#	SensorKitBedSensing
#	SensorKitBedSensingWriting
#	SensorKitDeviceUsage
#	SensorKitElevation
#	SensorKitFacialMetrics
#	SensorKitForegroundAppCategory
#	SensorKitKeyboardMetrics
#	SensorKitLocationMetrics
#	SensorKitMessageUsage
#	SensorKitMotion
#	SensorKitMotionHeartRate
#	SensorKitOdometer
#	SensorKitPedometer
#	SensorKitPhoneUsage
#	SensorKitSoundDetection
#	SensorKitSpeechMetrics
#	SensorKitStrideCalibration
#	SensorKitWatchAmbientLightSensor
#	SensorKitWatchFallStats
#	SensorKitWatchForegroundAppCategory
#	SensorKitWatchHeartRate
#	SensorKitWatchMotion
#	SensorKitWatchOnWristState
#	SensorKitWatchPedometer
#	SensorKitWatchSpeechMetrics
#	ShareKit
#	SinaWeibo
#	Siri
#	SpeechRecognition
#	SystemPolicyAllFiles
#	SystemPolicyDesktopFolder
#	SystemPolicyDeveloperFiles
#	SystemPolicyDocumentsFolder
#	SystemPolicyDownloadsFolder
#	SystemPolicyNetworkVolumes
#	SystemPolicyRemovableVolumes
#	SystemPolicySysAdminFiles
#	TencentWeibo
#	Twitter
#	Ubiquity
#	UserAvailability
#	UserTracking
#	WebKitIntelligentTrackingPrevention
#	Willow

ServiceNames="All Accessibility AddressBook AlwaysAllowedService.AppleEvents AppleEvents BluetoothAlways BluetoothPeripheral BluetoothWhileInUse Calendar Calls Camera ContactsFull ContactsLimited DeveloperTool ExposureNotification ExposureNotificationRegion FaceID Facebook FallDetection FileProviderDomain FileProviderPresence FocusStatus GameCenterFriends KeyboardNetwork LinkedIn ListenEvent Liverpool MSO MediaLibrary Microphone Motion NearbyInteraction Photos PhotosAdd PostEvent Prototype3Rights Prototype4Rights Reminders ScreenCapture SensorKitAmbientLightSensor SensorKitBedSensing SensorKitBedSensingWriting SensorKitDeviceUsage SensorKitElevation SensorKitFacialMetrics SensorKitForegroundAppCategory SensorKitKeyboardMetrics SensorKitLocationMetrics SensorKitMessageUsage SensorKitMotion SensorKitMotionHeartRate SensorKitOdometer SensorKitPedometer SensorKitPhoneUsage SensorKitSoundDetection SensorKitSpeechMetrics SensorKitStrideCalibration SensorKitWatchAmbientLightSensor SensorKitWatchFallStats SensorKitWatchForegroundAppCategory SensorKitWatchHeartRate SensorKitWatchMotion SensorKitWatchOnWristState SensorKitWatchPedometer SensorKitWatchSpeechMetrics ShareKit SinaWeibo Siri SpeechRecognition SystemPolicyAllFiles SystemPolicyDesktopFolder SystemPolicyDeveloperFiles SystemPolicyDocumentsFolder SystemPolicyDownloadsFolder SystemPolicyNetworkVolumes SystemPolicyRemovableVolumes SystemPolicySysAdminFiles TencentWeibo Twitter Ubiquity UserAvailability UserTracking WebKitIntelligentTrackingPrevention Willow"

if [ -z "$1" ]
then
	echo "Service name or \"All\" required. Note: Service name is case sensitive."
	exit 1
fi

if [[ $ServiceNames =~ "$1" ]]
then
	if [ -z "$2" ]
	then
	# resets the TCC database for $service
		tccutil reset "$1"
		for LocalUser in ${=StaffList}
		do
			sudo -u "$LocalUser" tccutil reset "$1" > /dev/null
		done
	else
		tccutil reset "$1" "$2"
		for LocalUser in ${=StaffList}
		do
			sudo -u "$LocalUser" tccutil reset "$1" "$2" > /dev/null
		done
	fi
else
	echo "Unrecognized service name: $1"
	exit 1
fi
