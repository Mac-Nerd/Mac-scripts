#!/bin/zsh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# This script is intended to install N-able RMM agent via an existing RMM or remote access
# platform (eg, Mosyle)

# Four parameters are required.
# -u your server URL, without the leading https:// example: "www.am.remote.management"
# -a your RMM API key, instructions https://documentation.remote.management/remote-management/userguide/Content/api_key.htm
# -c the client ID
# -s the site ID

# Client and Site ID can be retreived by calling the RMM API. This requires the API key (see above) and server URL.
# 
# The clients list is returned by this URL:
# https://[SERVER URL]/api/?apikey=[YOUR API TOKEN]&service=list_clients
# 
# With the proper client ID, the sites can be listed with this URL:
# https://[SERVER URL]/api/?apikey=[YOUR API TOKEN]&service=list_sites&clientid=[CLIENT ID]


if [ -z "${ZSH_VERSION}" ]; then
  >&2 echo "ERROR: This script is only compatible with Z shell (/bin/zsh)."
  exit 1
fi


# Command line options
zparseopts -D -E -F -K u:=serverURL a:=apiKEY c:=clientID s:=siteID

serverURL=$serverURL[-1] # example: "www.am.remote.management"
apiKEY=$apiKEY[-1]
clientID=$clientID[-1]
siteID=$siteID[-1]

if [ -z $serverURL ] || [ -z $apiKEY ] || [ -z $clientID ] || [ -z $siteID ]
then
	echo "Usage: -u \"server URL\" -a \"API key\" -c clientID -s siteID"
	echo "All four arguments must be included."
	exit 1
fi

# clean up server address if necessary
serverURL=$( echo "${serverURL}" | awk -F "://" '{if($2) print $2; else print $1;}' )
serverURL=${serverURL%/} 	# strip trailing slash

apiurl="https://$serverURL/api?apikey=$apiKEY&service=get_site_installation_package&endcustomerid=$clientID&siteid=$siteID&os=mac&type=remote_worker"

echo $apiurl


echo "Downloading RMM agent."
# On successful download, install the PKG
if curl -Lf -o "${TMPDIR}RMMInstaller.zip" "$apiurl"
then
	# Install the PKG
	cd "$TMPDIR" || exit 1
	if unzip -a RMMInstaller.zip &> /dev/null
	then
	
	echo "Installing RMM Agent."
	# install PKG
	installer -pkg "/tmp/RMMInstaller/Install.pkg" -target /

	else
		echo "ERROR expanding ${TMPDIR}RMMInstaller.zip"
		exit 1 # Install failed.
	fi	
else
	echo "ERROR downloading ${apiurl}"
	exit 1 # Install failed.
fi
