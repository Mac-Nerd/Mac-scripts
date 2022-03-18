#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----


# Checks and optionally installs Rosetta 2 on Apple Silicon (M1) Macs.

# Usage: run with option "true" to install Rosetta 2 on M1 devices that do not already
# have it installed. Otherwise, with no options to just run the check.


if [ "$(sysctl -in hw.optional.arm64)" != "1" ]
then
		# Not running on Apple ARM Silicon
		echo "Error: This Mac is not running an Apple Silicon (M1) CPU."
		exit 1
else
		if arch -x86_64 /usr/bin/true 2> /dev/null
		then
				# Running Intel code on ARM, so Rosetta2 already installed.
				echo "Error: Rosetta 2 is already installed and running."
				exit 0
		elif [ "$1" = "true" ]
		then
				# install Rosetta2
				echo "Installing Rosetta 2:"
				/usr/sbin/softwareupdate --install-rosetta --agree-to-license
		else
				echo "Rosetta 2 not installed. Exiting."
				exit 0
	   fi
fi

