#!/bin/bash
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# Install the Sophos Endpoint standalone version. You will need to supply a URL
# to download the ZIP from, since the installer download is behind a required form
# on the Sophos website. Upload it to a shared drive or other server you can access
# from the device(s), and copy that URL into the command line parameters.

# You can download the latest installer here:
# https://www.sophos.com/en-us/support/downloads/endpoint-client


# Requires the URL to the Sophos Installer ZIP
zipURL=$1


# On successful download, install the PKG
if curl -SsL -f -o "${TMPDIR}SophosInstall.zip" "$zipURL"
then
# Install the PKG
	cd "$TMPDIR" || exit 1
	echo "Installing Sophos Endpoint"
	if unzip -a SophosInstall.zip &> /dev/null
	then
		./Sophos\ Installer.app/Contents/MacOS/tools/InstallationDeployer --install
	else
		echo "There was an error expanding {TMPDIR}SophosInstall.zip"
		exit 1001 # Tell RMM the install failed.
	fi	
else
	echo "ERROR downloading ${zipURL}"
	exit 1001 # Tell RMM the install failed.
fi
