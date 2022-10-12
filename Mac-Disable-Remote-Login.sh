#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# This *disables* remote login to the Mac via ssh. 

# In order to connect to the remote Mac with ssh, create and run a task for the script 
# "Mac-Enable-Remote-Login" first to enable ssh login.


systemsetup -f -setremotelogin off
