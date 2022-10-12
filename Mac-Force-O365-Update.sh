#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Force a full Microsoft 365 update. Useful for doing downloads on your schedule, instead of waiting for the automatic update

# remove the "last updated" time, so the agent thinks it's never been run
defaults delete com.microsoft.autoupdate2 LastUpdate

# kick off the automatic update agent
launchctl start com.microsoft.update.agent

