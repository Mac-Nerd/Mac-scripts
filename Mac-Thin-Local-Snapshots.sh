#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----


# In some situations, processes will show the system drive as too full to continue.
# It's often the case that the space on the drive is taken up by local snapshots created
# by Time Machine or another process. Deleting these can recover space, but APFS
# snapshots are useful in recovering lost files. Instead of deleting them wholesale,
# we opt to "thin" the oldest snapshots to make room.

# This script uses the command tmutil to purge local APFS snapshots from the startup drive, 
# beginning with the oldest and continuing until no purgeable space remains, or 
# 10 gigabytes of space have been recovered, whichever comes first.

tmutil thinlocalsnapshots / 10000000000000 1
