#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----


# This *disables* remote login to the Mac via ssh. 

# In order to connect to the remote Mac with ssh, create and run a task for the script 
# "Mac-Enable-Remote-Login" first to enable ssh login.


systemsetup -f -setremotelogin off
