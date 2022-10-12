#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Install Installomator.sh from scriptingosx.com via GitHub

# For more information, see: 
# https://scriptingosx.com/2020/05/introducing-installomator/

# 8 Feb, 2022 - updated to version 9.0


# No sleeping
/usr/bin/caffeinate -d -i -m -u &
caffeinatepid=$!
caffexit () {
    kill "$caffeinatepid"
    exit "$1"
}

# Download the Installomator release PKG from github.
downloadURL="https://github.com/Installomator/Installomator/releases/download/v9.0/Installomator-9.0.pkg" ;\
downloadTarget="Installomator-9.0.pkg" ;\


# On successful download, install the PKG
  if curl -SsL -f -o /tmp/"${downloadTarget}" "${downloadURL}"
  then
	# Install the PKG
	echo "Installing ${downloadTarget}"
	installer -pkg /tmp/${downloadTarget} -target /
  else
  	echo "ERROR downloading ${downloadURL}"
	exit 1001 # Tell RMM install failed.
  fi

echo "[$(DATE)][LOG-END]"
caffexit 0
