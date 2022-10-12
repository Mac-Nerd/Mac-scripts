#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# Uninstall Gruntwork without deleting the RMM Agent by deleting the 
# .gruntwork-did-enrollment flag that triggers RMM uninstall

if [ -f "/usr/local/rmmagent/.gruntwork-did-enrollment" ] && [ -f "/Library/Mac-MSP/Gruntwork/gruntWorker.sh" ]
then
	rm -f /usr/local/rmmagent/.gruntwork-did-enrollment
	echo "Successfully removed RMM trigger, uninstalling Gruntwork"
	# now tell Gruntwork to self destruct
	/Library/Mac-MSP/Gruntwork/gruntWorker.sh selfdestruct
else
	echo "Gruntwork not found. Cancelling."
	exit 2
fi

exit 0
