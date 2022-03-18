#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# Download the Monterey Blocker package from github:
curl -sSL -f -o /tmp/montereyblocker.pkg https://github.com/Theile/montereyblocker/releases/download/v20210611/montereyblocker-20210611.pkg

  if [ "$?" == "0" ]; then
	# Install the PKG
	installer -pkg /tmp/montereyblocker.pkg -target /
  fi
