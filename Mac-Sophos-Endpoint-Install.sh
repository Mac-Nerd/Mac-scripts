#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Install the Sophos Central Endpoint. You will need to supply a URL
# to download the ZIP from, since the installer download is behind a required form
# on the Sophos website. Upload it to a shared drive or other server you can access
# from the device(s), and copy that URL into the command line parameters.

# Instructions to download the latest installer are here:
# https://support.sophos.com/support/s/article/KB-000035045?language=en_US

# Requires the URL to the Sophos Installer ZIP
zipURL=$1


# On successful download, install the PKG
if curl -L -f -o "${TMPDIR}SophosInstall.zip" "$zipURL"
then
	# Install the PKG
	cd "$TMPDIR" || exit 1
	echo "Installing Sophos Endpoint"
	if unzip -a SophosInstall.zip &> /dev/null
	then

		chmod a+x ${TMPDIR}Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
		chmod a+x ${TMPDIR}Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper	
		./Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --install	

	else
		echo "There was an error expanding ${TMPDIR}SophosInstall.zip"
		exit 1001 # Tell RMM the install failed.
	fi	
else
	echo "ERROR downloading ${zipURL}"
	exit 1001 # Tell RMM the install failed.
fi
