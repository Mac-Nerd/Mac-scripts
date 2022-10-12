#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Point Microsoft 365 automatic update process to download installers from local cache. Allows admins to manage which updates are available to install, and reduces bandwidth use.
# Requires a web server to act as the MAU Cache Server. See https://macadmins.software/docs/MAU_CachingServer.pdf for instructions

# URL should end with /
CACHESERVER=[YOUR SERVER URL INCLUDING HTTP://] 

defaults write com.microsoft.autoupdate2 UpdateCache -string '$CACHESERVER'
