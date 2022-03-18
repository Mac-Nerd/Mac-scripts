#!/bin/bash
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

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
