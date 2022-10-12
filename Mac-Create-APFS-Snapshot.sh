#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# Create APFS snapshot of current drive state, in order to "roll back" or restore 
# the drive state later. This requires MacOS High Sierra (10.13) or later, and an SSD
# system drive formatted APFS. Uses tmutil but does not require Time Machine to be
# enabled.

# To restore from this snapshot later, or to recover previous versions of files as stored
# in the snapshot, list the available snapshots with "sudo tmutil listlocalsnapshots" then

#	sudo mkdir /tmp/SNAPSHOT
# 	sudo mount_apfs -s [SNAPSHOT NAME] / /tmp/SNAPSHOT

tmutil localsnapshot
