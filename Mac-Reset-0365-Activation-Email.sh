#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Reset Office365 activation email address. Useful when installation fails, or user's SSO email changes.

defaults delete com.microsoft.office OfficeActivationEmailAddress
