#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# Uses curl to query ipinfo.io API for additional information about the computer's 
# public IP address. This will typically provide the ISP name (as "org") as well as
# geolocation information. This can often be helpful in troubleshooting remote users'
# connections, or identify routing issues.

curl -f https://ipinfo.io/json && printf "\nCOMPLETE." || printf "\nFAILED."
