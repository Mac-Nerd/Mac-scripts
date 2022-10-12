#!/bin/bash

# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# check SentinelOne agent status, append to log file.
# alert on specific status

SentinelLog="/var/log/sentinelctl.log"

if [ -f "$SentinelLog" ] 
then
	eval $(stat -s "$SentinelLog")

	if [ $st_size -gt 1000000 ] # log over 1M? roll it.
	then
		LogRename=$(date -r "$SentinelLog" "+%Y-%m-%d-%H%M%S")
		mv "$SentinelLog" "SentinelLog.$LogRename"
		touch "$SentinelLog"
	fi
else # no log? create one.
	echo "Creating $SentinelLog"
	touch "$SentinelLog"
fi

startTime=$(date)

echo "[ $startTime ]" >> "$SentinelLog"

StatusMessage=$(/usr/local/bin/sentinelctl status --filters agent 2>/dev/null | tee -a "$SentinelLog" ) || echo "[ ERROR ] SentinelOne not installed." | tee -a "$SentinelLog"

ProtectionDisabled="*Protection:*disabled*"
MissingAuths="*Missing*com.sentinelone*"
ReadyNo="*Ready:*no*"
InfectedYes="*Infected:*yes*"
FWDisabled="*FW*disabled*"

exitcode=0

while IFS= read -r StatusLine
do
	case "$StatusLine" in

		$ProtectionDisabled )
				echo "[ WARNING ] SentinelOne Protection Disabled" | tee -a "$SentinelLog"
				exitcode=1
				;;
		$MissingAuths )
				echo "[ ERROR ] SentinelOne Missing Authorizations" | tee -a "$SentinelLog"
				exitcode=2
				;;
		$ReadyNo )
				echo "[ ERROR ] SentinelOne Not Ready" | tee -a "$SentinelLog"
				exitcode=3
				;;
		$FWDisabled )
				echo "[ ERROR ] Firewall Not Ready" | tee -a "$SentinelLog"
				exitcode=4
				;;
		$InfectedYes )
				echo "[ ERROR ] INFECTION DETECTED" | tee -a "$SentinelLog"
				exitcode=255
				;;		  
	esac
done <<-EOF
$StatusMessage
EOF

exit $exitcode
