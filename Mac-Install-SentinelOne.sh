#! /bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

PKGPATH=[PATH_TO_PKG]
TOKEN=["Your Site Token"]

# Install SentinelOne from a downloaded PKG file.
/usr/sbin/installer -pkg $PKGPATH -target / 
sleep 3 

# Registers SentinelOne with your product token
/usr/local/bin/sentinelctl set registration-token -- $TOKEN

