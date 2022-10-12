#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Warns user if they are running bandwidth-hungry apps (eg, Spotify, Pandora, Soundcloud) with a system dialog box.

# search process list
pgrep -q [RESTRICTED APP NAME]; if [[ $? -eq 0 ]]; then 
# display warning if present
	osascript -e 'display dialog "Streaming music apps are restricted while connected to this network. Please quit [APPLICATION NAME]" buttons {"I Understand"} default button 1 with icon caution'
fi
