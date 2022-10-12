#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# Most Mac applications can be installed from the command line via .pkg file. This script
# requires the location of a .pkg (either as http://, https://, ftp:// or a local file://
# URL), then downloads it and installs it.

# To create your own payloads to install in this way, see 
# https://autopkg.github.io/autopkg and https://github.com/lindegroup/autopkgr



# Required parameter: 
PKGTOINSTALL=$1

# This looks for a valid URL to a .pkg
# This is an example of how regular expressions can be either beautiful or hideous. Or both.
URLregex='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[\.pkg|\.PKG]$'

PKGPath=$(date "+%Y%m%d.%H%M")

if [ $# -gt 1 ]
then 
	echo "[Error] Too many arguments. This script can only process one URL at a time."
	exit 1
elif [ -n "$PKGTOINSTALL" ]
then
	if ! [[ $PKGTOINSTALL =~ $URLregex ]]
	then 
		
		echo "[Error] The value you entered is not a valid URL."
		echo " - Make sure to include the protocol (\"http://\" \"https://\" or \"ftp://\")"
		echo " - URL must point to a .pkg file."
	else
		echo "Downloading $PKGTOINSTALL to /tmp/$PKGPath/"

		mkdir "/tmp/${PKGPath}/"
		cd "/tmp/${PKGPath}/" || exit 2
		
		PKGFile=$(curl -sSL -f -O "${PKGTOINSTALL}" -w %{filename_effective})

		echo "Installing ${PKGFile}"
		
		installer -pkg "/tmp/${PKGPath}/${PKGFile}" -target /

	fi
else

	echo "[Error] This script requires one argument: the URL of a PKG file to install."
	exit 1
fi
