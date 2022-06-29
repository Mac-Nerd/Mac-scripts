#!/bin/bash

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# -----------------------------------------------------------

# Is the Mac enrolled in MDM? This is useful as a script check - if the MDM check fails,
# trigger the automated task to show the enrollment helper app.


EnrollmentResult=$(profiles status -type=enrollment)

DEPEnrollment=$(echo "$EnrollmentResult" | grep "Enrolled via DEP:" | cut -d':' -f2) # returns "Yes" or "No"

UAMDMEnrollment=$(echo "$EnrollmentResult" | grep "MDM enrollment:" | cut -d':' -f2 | cut -d' ' -f2) # returns "Yes" or "No"

if [ "$DEPEnrollment" = "Yes" ] || [ "$UAMDMEnrollment" = "Yes" ]
then
	echo "Device is MDM enrolled."
	
	if echo "$EnrollmentResult" | grep -q "dm.system-monitor.com"
	then
		echo "Device is enrolled in N-able ADM."
		exit 0
	else
		echo "Device is enrolled in another MDM"
#		exit 1001
	fi
	
else 
	echo "Device is NOT MDM enrolled."
	exit 1001
fi
