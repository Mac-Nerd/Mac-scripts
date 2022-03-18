#!/bin/zsh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----


# Removes Installomator.

# For more information, see: 
# https://scriptingosx.com/2020/05/introducing-installomator/

# This script based on:
# https://github.com/Installomator/Installomator/blob/dev/MDM/RemoveInstallomator.sh

pkgutil --forget "com.scriptingosx.Installomator"
rm /usr/local/Installomator/Installomator.sh
rmdir /usr/local/Installomator
