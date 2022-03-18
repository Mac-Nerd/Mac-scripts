#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# Point Microsoft 365 automatic update process to download installers from local cache. Allows admins to manage which updates are available to install, and reduces bandwidth use.
# Requires a web server to act as the MAU Cache Server. See https://macadmins.software/docs/MAU_CachingServer.pdf for instructions

# URL should end with /
CACHESERVER=[YOUR SERVER URL INCLUDING HTTP://] 

defaults write com.microsoft.autoupdate2 UpdateCache -string '$CACHESERVER'
