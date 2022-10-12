#! /bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

PKGPATH=[PATH_TO_PKG]
TOKEN=["Your Site Token"]

# Install SentinelOne from a downloaded PKG file.
/usr/sbin/installer -pkg $PKGPATH -target / 
sleep 3 

# Registers SentinelOne with your product token
/usr/local/bin/sentinelctl set registration-token -- $TOKEN

