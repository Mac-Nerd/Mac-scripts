#!/bin/bash
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----


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
