#!/bin/bash
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# Installs the XCode Command Line Tools from developer.apple.com
# These developer tools are required for many command-line applications, and include
# version control tools, compilers, and libraries for a number of programming languages
# not present on a default system.

# Check your privilege
if [ "$(whoami)" != "root" ]; then
    echo "This script must be run with root/sudo privileges."
    exit 1
fi


OSVERSION=$(defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print $1}')

OSMAJOR=$(echo "${OSVERSION}" | cut -d . -f1)
OSMINOR=$(echo "${OSVERSION}" | cut -d . -f2)

if [[ $OSMAJOR -lt 11 ]] && [[ $OSMINOR -lt 13 ]]
then
	echo "Requires MacOS 10.13 or higher."
	exit 1
else 

	# creates a temporary file to allow swupdate to list and install the command line tools
	TMPFILE="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
	touch ${TMPFILE}

	echo "Checking availability of Command Line Tools."
	CLTAVAILABLE=$(/usr/sbin/softwareupdate -l | grep -B 1 -E 'Command Line Tools' | awk -F'*' '/^ *\\*/ {print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | sort -V | tail -n1)

	if [[ -n ${CLTAVAILABLE} ]]
	then
		echo "Installing ${CLTAVAILABLE}"

		/usr/sbin/softwareupdate -i "${CLTAVAILABLE}"

		rm -f ${TMPFILE}

		/usr/bin/xcode-select --switch /Library/Developer/CommandLineTools

	else 
		echo "Command Line Tools already installed and up to date."
		exit 0
	fi
					  
fi
