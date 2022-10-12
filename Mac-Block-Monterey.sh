#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Download the Monterey Blocker package from github:
curl -sSL -f -o /tmp/montereyblocker.pkg https://github.com/Theile/montereyblocker/releases/download/v20210611/montereyblocker-20210611.pkg

  if [ "$?" == "0" ]; then
	# Install the PKG
	installer -pkg /tmp/montereyblocker.pkg -target /
  fi
