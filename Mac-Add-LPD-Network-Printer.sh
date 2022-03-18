#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# Add a network printer with LPD protocol and generic printer driver.

PRINTERNAME=[UNIQUE-NAME]
LOCATIONSTRING=["eg, Floor, Building, Room number"]
LPDADDRESS=[lpd://IP.ADDRESS.OR.DNS.NAME]

lpadmin -p $PRINTERNAME -L $LOCATIONSTRING -E -v $LPDADDRESS -m drv:///sample.drv/generic.ppd -o printer-is-shared=false
