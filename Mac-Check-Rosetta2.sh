#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


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

