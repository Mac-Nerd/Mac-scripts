#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Every app installed on the Mac should be signed by its developer in order to run.
# And each developer or software vendor has a unique Developer ID, with which all of
# their apps are signed. Occasionally, a developer will be found to have been breached
# or their apps found to be malicious or otherwise insecure. Apple will usually pull 
# the affected apps from the App Store, or add them to an exclusion list in Gatekeeper 
# or XProtect. This often takes some time, and may not effectively block or remove 
# installers distributed outside the App Store.

# This script identifies all the apps currently installed on a Mac, and checks their 
# Developer IDs agains a list of developers that have been identified as potentially 
# malicious. The default list is inspired by this article:
# https://privacyis1st.medium.com/abuse-of-the-mac-appstore-investigation-6151114bb10e
 
# You can research and add your own exclusions by downloading ane examining an installer 
# PKG or DMG or an already-installed app with this command:
# codesign -d -v path/to/pkg/or/app

# Example, to block multiplayer games published on Steam: 
# Steam.app, by Valve Corporation: MXGJJ98X76

# Add the ID MXGJJ98X76 to the list "RestrictedDevs"


RestrictedDevs=(WJMTXR4JNU 6N53BTGWL7 QL99V46A4M B2MV8Q5A9K 33CT73RPKY 9ZXZ48W276)



exitcode=0

# identify apps installed on system
AllApps=$(system_profiler SPApplicationsDataType)

old_ifs="$IFS"
IFS=$'\n'

# for each, get the teamidentifier for the signing developer

while read -r TeamID 
do
# compare to list of "suspicious" teamids
	
	if [[ "${RestrictedDevs[*]}" =~ ${TeamID} ]]
	then
		echo "$AllApps" | grep -E "$TeamID" -A 1
		((exitcode++))
	fi
	
	
done <<< "$(echo "$AllApps" | grep -E 'Signed.+\(.+\)' | awk -F'[()]' '{print $2 "\n"}')"

IFS="$old_ifs"

exit "$exitcode"
