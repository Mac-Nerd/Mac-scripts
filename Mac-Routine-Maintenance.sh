#!/bin/zsh

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# -----------------------------------------------------------


# This script will determine if it is necessary to run the Mac's built-in maintenance 
# scripts. These normally run every day, week, and month - but sometimes are prevented
# or delayed. If the daily scripts haven't run in 2 days, the weekly in 8 days, or the 
# monthly in 33 days, then the script triggers them automatically.

# Alternately, set the first command line parameter to "true" to force the maintenance
# routines to run immediately, regardless of when they were last run.

# For more detail about the periodic maintenance scripts, see:
# https://www.unix.com/man-page/mojave/8/PERIODIC/

forceRun="$1"

# if daily.out is older than 2 days
if [ -f "/var/log/daily.out" ]
then
	dailyOutAge=$((($(date +%s) - $(stat -t %s -f %m -- "/var/log/daily.out")) / 86400))
else
	dailyOutAge=99
fi
echo "Daily last run ${dailyOutAge} days ago."

# weekly.out older than 1 week
if [ -f "/var/log/weekly.out" ]
then
	weeklyOutAge=$((($(date +%s) - $(stat -t %s -f %m -- "/var/log/weekly.out")) / 86400))
else
	weeklyOutAge=99
fi
echo "Weekly last run ${weeklyOutAge} days ago."

# monthly.out older than 1m
if [ -f "/var/log/monthly.out" ]
then
	monthlyOutAge=$((($(date +%s) - $(stat -t %s -f %m -- "/var/log/monthly.out")) / 86400))
else
	monthlyOutAge=99
fi
echo "Monthly last run ${monthlyOutAge} days ago."


if [ $dailyOutAge -gt 2 ] || [[ "${forceRun:l}" == "true" ]]
then
	echo "Running daily maintenance."
	periodic daily
fi

if [ $weeklyOutAge -gt 8 ] || [[ "${forceRun:l}" == "true" ]]
then
	echo "Running weekly maintenance."
	periodic weekly
fi

if [ $monthlyOutAge -gt 33 ] || [[ "${forceRun:l}" == "true" ]]
then 
	echo "Running monthly maintenance."
	periodic monthly
fi
