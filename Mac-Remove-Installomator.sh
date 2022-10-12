#!/bin/zsh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# Removes Installomator.

# For more information, see: 
# https://scriptingosx.com/2020/05/introducing-installomator/

# This script based on:
# https://github.com/Installomator/Installomator/blob/dev/MDM/RemoveInstallomator.sh

pkgutil --forget "com.scriptingosx.Installomator"
rm /usr/local/Installomator/Installomator.sh
rmdir /usr/local/Installomator
