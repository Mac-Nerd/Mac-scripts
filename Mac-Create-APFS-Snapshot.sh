#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----


# Create APFS snapshot of current drive state, in order to "roll back" or restore 
# the drive state later. This requires MacOS High Sierra (10.13) or later, and an SSD
# system drive formatted APFS. Uses tmutil but does not require Time Machine to be
# enabled.

# To restore from this snapshot later, or to recover previous versions of files as stored
# in the snapshot, list the available snapshots with "sudo tmutil listlocalsnapshots" then

#	sudo mkdir /tmp/SNAPSHOT
# 	sudo mount_apfs -s [SNAPSHOT NAME] / /tmp/SNAPSHOT

tmutil localsnapshot
