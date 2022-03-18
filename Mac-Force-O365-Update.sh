#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# Force a full Microsoft 365 update. Useful for doing downloads on your schedule, instead of waiting for the automatic update

# remove the "last updated" time, so the agent thinks it's never been run
defaults delete com.microsoft.autoupdate2 LastUpdate

# kick off the automatic update agent
launchctl start com.microsoft.update.agent

