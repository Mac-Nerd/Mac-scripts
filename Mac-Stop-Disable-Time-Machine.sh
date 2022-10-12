#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# Stop any running backup before disabling Time Machine
tmutil stopbackup

# Disable Time Machine - prevents new backups and stops the schedule until started manually
tmutil disable
