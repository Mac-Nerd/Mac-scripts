#!/bin/bash

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# -----------------------------------------------------------

# Original source: https://github.com/rs1278/macOSinstallers/tree/main/Installers/Nudge

# This script determines the latest version of the Nudge installer, downloads and 
# installs it. The optional LaunchAgent is also installed. The intent is to trigger Nudge
# by use of a scheduled task or script check. See the Getting Started guide for more info:
# https://github.com/macadmins/nudge/wiki/Getting-Started

# For ADM deployment, install the profile "Nudge-configuration.mobileconfig" as well.

# Variables
nudgeLatestURL="https://github.com/macadmins/nudge/releases/latest/"
versionUrl=$(curl "${nudgeLatestURL}" -s -L -I -o /dev/null -w '%{url_effective}')
versionNumber=$(printf "%s" "${versionUrl[@]}" | sed 's@.*/@@' | sed 's/%20/-/g')
versionNumber=${versionNumber:1}

downloadUrl="https://github.com/macadmins/nudge/releases/download/v$versionNumber/Nudge-$versionNumber.pkg"
#header="$(curl -sI "$downloadUrl" | tr -d '\r')"
pkgName=$(printf "%s" "${downloadUrl[@]}" | sed 's@.*/@@' | sed 's/%20/-/g')
pkgPath="/tmp/$pkgName"

downloadUrl2="https://github.com/macadmins/nudge/releases/download/v$versionNumber/Nudge_LaunchAgent-1.0.0.pkg"
pkgName2=$(printf "%s" "${downloadUrl2[@]}" | sed 's@.*/@@' | sed 's/%20/-/g')
pkgPath2="/tmp/$pkgName2"

# Download files
/usr/bin/curl -sL -o "$pkgPath" "$downloadUrl"
/usr/bin/curl -sL -o "$pkgPath2" "$downloadUrl2"

# Install PKGs
installer -pkg "$pkgPath" -target /
installer -pkg "$pkgPath2" -target /

# Delete PKGs
/bin/rm "$pkgPath"
/bin/rm "$pkgPath2"

exit 0

