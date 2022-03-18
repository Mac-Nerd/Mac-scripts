#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----


##########################################################################################
# source: https://mrmacintosh.com/macos-upgrade-to-big-sur-failed-stuck-progress-bar-fix-prevention/
# "MacOS Big Sur currently has an upgrade issue. In certain situations, the upgrade will 
# fail and then get stuck with a neverending progress bar." [...] 
# "If you are upgrading from macOS High Sierra, Mojave, or Catalina to Big Sur your 
# upgrade could fail if it matches a very particular condition."
# 
# This script should remedy one of the common causes - too many files in specific folders
# Should be run with admin (sudo) permissions.
# !!!NOTE!!! This may take a *long* time to complete. When you deploy this via your RMM
# be sure to set a long timeout before assuming failure. If it does time out, you should 
# be safe to run it again - the process will have already deleted part of the caches.

# count files in .../com.apple.metadata.mdworker - safe to skip this step
# MDWORKERS=$(find /private/var/folders/*/*/C/com.apple.metadata.mdworker -type d | wc -l)


OSMAJOR=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print $1}' | cut -d . -f1` ; echo $OS
if [[ $OSMAJOR -lt 11 ]]; then

	# safe to delete any mdworker cache files even if there's not more than 20,000
	find /private/var/folders/*/*/C/com.apple.mdworker.bundle -mindepth 1 -delete
	find /private/var/folders/*/*/C/com.apple.metadata.mdworker -mindepth 1 -delete 

	# remove all the items in /private/var/folders/ - they will be recreated as applications 
	# register after the update
	rm -Rf /private/var/folders/*

else 
	echo "This script is only necessary for versions of MacOS prior to Big Sur."
	exit -1

fi
	exit 0
