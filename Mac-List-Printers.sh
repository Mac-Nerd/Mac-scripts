#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Mac Printer List - Returns a list of the printers configured on the computer, with the
# printer name and PPD for each

system_profiler SPPrintersDataType | grep -E ':$|PPD'
