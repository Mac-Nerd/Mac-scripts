#!/bin/bash

# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----

# check SentinelOne agent status, append to log file.
# Alert on specific status.

SentinelLog="/Applications/Mac_Agent.app/Contents/Daemon/var/log/sentinelctl.log"

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

StatusMessage=$(/usr/local/bin/sentinelctl status --filters agent 2>/dev/null | tee -a "$SentinelLog" ) || echo "[ ERROR: NotInstalled ] SentinelOne not installed." | tee -a "$SentinelLog"

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
				echo "[ WARNING: ProtectionDis ] SentinelOne Protection Disabled" | tee -a "$SentinelLog"
				exitcode=1001
				;;
		$MissingAuths )
				echo "[ ERROR: MissingAuth ] SentinelOne Missing Authorizations" | tee -a "$SentinelLog"
				exitcode=1002
				;;
		$ReadyNo )
				echo "[ ERROR: NotReady ] SentinelOne Not Ready" | tee -a "$SentinelLog"
				exitcode=1003
				;;
		$FWDisabled )
				echo "[ ERROR: NoFirewall ] Firewall Not Ready" | tee -a "$SentinelLog"
				exitcode=1004
				;;
		$InfectedYes )
				echo "[ ERROR: INFECTION ] INFECTION DETECTED" | tee -a "$SentinelLog"
				exitcode=1024
				;;		  
	esac
done <<-EOF
$StatusMessage
EOF

exit $exitcode
