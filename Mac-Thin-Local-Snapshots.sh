#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# In some situations, processes will show the system drive as too full to continue.
# It's often the case that the space on the drive is taken up by local snapshots created
# by Time Machine or another process. Deleting these can recover space, but APFS
# snapshots are useful in recovering lost files. Instead of deleting them wholesale,
# we opt to "thin" the oldest snapshots to make room.

# This script uses the command tmutil to purge local APFS snapshots from the startup drive, 
# beginning with the oldest and continuing until no purgeable space remains, or 
# 10 gigabytes of space have been recovered, whichever comes first.

tmutil thinlocalsnapshots / 10000000000000 1
