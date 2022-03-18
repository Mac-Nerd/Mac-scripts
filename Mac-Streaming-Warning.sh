#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# Warns user if they are running bandwidth-hungry apps (eg, Spotify, Pandora, Soundcloud) with a system dialog box.

# search process list
pgrep -q [RESTRICTED APP NAME]; if [[ $? -eq 0 ]]; then 
# display warning if present
	osascript -e 'display dialog "Streaming music apps are restricted while connected to this network. Please quit [APPLICATION NAME]" buttons {"I Understand"} default button 1 with icon caution'
fi
