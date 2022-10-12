#!/bin/sh

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Forces the Mac to unbind from the current Active Directory domain. Fails if the 
# computer is not bound to AD.

if dsconfigad -remove -username "-" -password "-" -force
then 
	echo "Successfully unbound."
else
	echo "This computer is not Bound to Active Directory."	
	exit 1001
fi
