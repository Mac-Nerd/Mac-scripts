#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# Download and install the latest version of Microsoft PowerShell from GitHub
# by querying the repo releases for the latest stable version, and grabbing the 
# proper PKG file to install. Other methods require developer tools (eg, homebrew) but
# the installer has no prerequisites.

# Note: if the last curl step fails, it may be due to the PowerShell developers changing
# the naming scheme of their releases. 


# call the GitHub API to look up the latest stable release version
LATESTVERSION="$(curl -s -H 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/powershell/powershell/releases/latest | grep -i tag_name | cut -d v -f 2 | tr -d '",')"

# determine the CPU architecture of the Mac
UNAME_MACHINE="$(/usr/bin/uname -m)"

# download x64 version by default
ARCH="x64"

# unless on Apple Silicon
if [[ "${UNAME_MACHINE}" == "arm64" ]]
then
	# download ARM/Apple Silicon version
	ARCH="arm64"
fi

# build the download URL for the latest version, proper architecture
PKGURL=$(printf "https://github.com/PowerShell/PowerShell/releases/download/v%s/powershell-%s-osx-%s.pkg" {$LATESTVERSION,$LATESTVERSION,$ARCH})

echo "Downloading version ${LATESTVERSION} of PowerShell from ${PKGURL}"

# make a temp folder for the installer
PKGDIR="/tmp/PowerShell-${LATESTVERSION}/"

mkdir -p "${PKGDIR}"

# download, output error on failure.
curl -L -o "${PKGDIR}/install.pkg" "${PKGURL}" && installer -pkg "${PKGDIR}/install.pkg" -target / || echo "ERROR downloading PowerShell. Check the URL."; exit 1
