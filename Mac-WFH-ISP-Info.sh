#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----


# Uses curl to query ipinfo.io API for additional information about the computer's 
# public IP address. This will typically provide the ISP name (as "org") as well as
# geolocation information. This can often be helpful in troubleshooting remote users'
# connections, or identify routing issues.

curl -f https://ipinfo.io/json && printf "\nCOMPLETE." || printf "\nFAILED."
