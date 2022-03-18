#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# Installs the N-central Mac agent without requiring user interaction. Suitable for 
# distribution via an existing RMM or other remote control solution. Intended to be
# run as root or via sudo
# 
# Thanks to the following partners for their assistance developing and testing:
# 
#  Adam Gossett, Henry Bonath, Jason Hanschu - https://www.thinkcsc.com/
# 


SERVERURL="example.n-able.com" 
# without the HTTPS:// e.g: example.n-able.com

JWT="JSON Web Token"
# instructions to generate a JSON Web Token here:
# https://documentation.n-able.com/N-central/userguide/Content/User_Management/Role%20Based%20Permissions/role_based_permissions_JSON_webtoken.htm

CUSTOMERID=000
# Find this by clicking on "customers" in the Administration tab in your N-central dashboard. The Customer ID is in the column "Access Code"



#### No edits necessary below this line. ####

# Check your privilege
if [ $(whoami) != "root" ]; then
    echo "This script must be run with root/sudo privileges."
    exit 1
fi

# clean up server address if necessary
SERVERURL=$( echo "${SERVERURL}" | awk -F "://" '{if($2) print $2; else print $1;}' )
SERVERURL=${SERVERURL%/} 	# strip trailing slash

echo "SERVER URL: $SERVERURL"


# generate URL for API access
APIURL="$SERVERURL/dms2/services2/ServerEI2"
echo "API URL $APIURL"

# build the URL for the DMG and install script
NCVERSION=$(curl -s --header 'Content-Type: application/soap+xml; charset="utf-8"' --header 'SOAPAction:POST' \
--data '<Envelope xmlns="http://www.w3.org/2003/05/soap-envelope"><Body><versionInfoGet xmlns="http://ei2.nobj.nable.com/"><credentials><password>'$JWT\
'</password></credentials></versionInfoGet></Body></Envelope>' $APIURL | sed 's,</value>,\n,g' | grep -m1 -i Product\ Version | awk -F'</key><value>' '{print $2}')

echo "N-CENTRAL VERSION: $NCVERSION"





SCRIPTURL=$(printf "https://%s/download/%s/macosx/N-central/dmg-install.sh.tar.gz" "$SERVERURL" "$NCVERSION")

echo "SCRIPT URL: $SCRIPTURL"

DMGURL=$(printf "https://%s/download/%s/macosx/N-central/MacAgentInstallation.dmg" "$SERVERURL" "$NCVERSION")

echo "DMG URL: $DMGURL"


# fetch the registration token and customer name for the specified customer ID
RESPONSE=$(curl -s --header 'Content-Type: application/soap+xml; charset="utf-8"' --header 'SOAPAction:POST' --data '<Envelope xmlns="http://www.w3.org/2003/05/soap-envelope"><Body><customerList xmlns="http://ei2.nobj.nable.com/"><password>'$JWT'</password><settings><key>listSOs</key><value>false</value></settings></customerList></Body></Envelope>' \
$APIURL | sed s/\<return\>/\\n\<return\>/g | grep customerid\</key\>\<value\>$CUSTOMERID\< )

if [ $? -gt 0 ] || [ -z "$RESPONSE" ]
then
	echo "ERROR FETCHING REGISTRATION TOKEN FROM $APIURL \n CONFIRM JWT AND CUSTOMER ID."
	echo "RESPONSE: $RESPONSE"
	exit 1
fi




CUSTOMERNAME=$(echo $RESPONSE | sed s/\>customer/\\n/g | grep -m1 customername | cut -d \> -f 3 | cut -d \< -f 1)

echo "CUSTOMER NAME: $CUSTOMERNAME"

TOKEN=$(echo $RESPONSE | sed s/customer./\\n/g | grep -m1 registrationtoken | cut -d \> -f 3 | cut -d \< -f 1)


echo "REGISTRATION TOKEN: $TOKEN"

if [ ! -d "/tmp/NCENTRAL/" ] ;
then
	echo "Creating temp download directory."
	mkdir "/tmp/NCENTRAL/"
fi
	

# get the installer pieces
if [ ! -f "/tmp/NCENTRAL/MacAgentInstallation.dmg" ];
then 
	echo "Downloading DMG"
	curl -o "/tmp/NCENTRAL/MacAgentInstallation.dmg" -s $DMGURL
	if [ $? -gt 0 ]
	then
		echo "ERROR DOWNLOADING $DMGURL"
		exit 1
	fi
fi

if [ ! -f  "/tmp/NCENTRAL/dmg-install.sh.tar.gz" ];
then
	echo "Downloading install script"
	curl -o "/tmp/NCENTRAL/dmg-install.sh.tar.gz" -s $SCRIPTURL
	if [ $? -gt 0 ]
	then
		echo "ERROR DOWNLOADING $SCRIPTURL"
		exit 1
	fi
fi

# expand the installer script
echo "Decompressing install script"
tar -C /tmp/NCENTRAL/ -xz -f /tmp/NCENTRAL/dmg-install.sh.tar.gz

# run the installer script
cd /tmp/NCENTRAL/ || return

/bin/bash dmg-install.sh -s "$SERVERURL" -c "$CUSTOMERNAME" -i "$CUSTOMERID" -t "$TOKEN"
