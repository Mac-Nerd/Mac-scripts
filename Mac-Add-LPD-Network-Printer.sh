#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Add a network printer with LPD protocol and generic printer driver.

PRINTERNAME=[UNIQUE-NAME]
LOCATIONSTRING=["eg, Floor, Building, Room number"]
LPDADDRESS=[lpd://IP.ADDRESS.OR.DNS.NAME]

lpadmin -p $PRINTERNAME -L $LOCATIONSTRING -E -v $LPDADDRESS -m drv:///sample.drv/generic.ppd -o printer-is-shared=false
