#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------
#
#
# Name: macOS_SentinelOne_Status.sh
# Desc: macOS SentinelOne monitoring
# 
# Extended by Where To Start and Time <Hack> Scripts, see below
#
# .Disclaimer
#    No warranties.  Use at your own risk. Where To Start is not responsible for any damage this script/material may cause.
#    This script and any accompanying or associated code and/or materials are to be used at your own risk and NO warranties
#    are expressed or implied.  It is expected that anyone who is using this script understands Shell, the Operating
#    System(s), the software, and the environment being impacted and by utilizing (executing or causing to be executed)
#    this script (or any part thereof) constitutes full acceptance by the end-user of any and all associated risks and results.
#
# .Copywrite & Use
#    Copyright 2022 Where To Start Inc. All rights reserved.
#
#    All brands, logos, original copyrights, and trademarks are the properties of their respective holders.
#    This script and any associated code and/or materials are for use exclusively within the business that has purchased
#    and been granted a license for its use.
#
#    Where possible Where To Start has acknowledged and given credit for the source of the ideas we have based our code upon.
#
# .Credit
#    Based upon: https://success.n-able.com/kb/nable_rmm/Mac-EDR-Monitoring-for-RMM
#
# .Versions:
#    20220428	AJH	Original public release of WTS’s version
#


ErrFound=0
exitcode=0
scriptv="20220428"
thishost=$(hostname -s | sed -e 's/^[^.]*\.//')

startTime=$(date)
S1_Status=""
StatusLine=""
S1_Threats=""
S1_quarantine=""

# Agent and log paths
# for n-able N-central
# S1_Log="/Applications/Mac_Agent.app/Contents/Daemon/var/log/sentinelctl.log"
# for n-able RMM
S1_Log="/Library/Logs/RMM Advanced Monitoring Agent/sentinelctl.log"

if [ ! -f "/usr/local/bin/sentinelctl" ]
then
	echo "WARNING: SentinelOne is NOT installed"
	echo "NOTE: It is also posible the script is not being run with admin rights."
	echo ""
	echo "$(date +%F_%T), Exit Code: $exitcode, (v. $scriptv) on $thishost"
	exit $exitcode
fi

if [ -f "$S1_Log" ] 
then
	eval $(stat -s "$S1_Log")

	if [ $st_size -gt 1000000 ] # if log over 1M? regen a new one after copying the previous one.
	then
		LogRename=$(date -r "$S1_Log" "+%Y-%m-%d-%H%M%S")
		mv "$S1_Log" "S1_Log.$LogRename"
		touch "$S1_Log"
	fi
else # no log - lets create one.
	touch "$S1_Log"
fi

echo "[ $startTime ]" >> "$S1_Log"

S1_Status=$(/usr/local/bin/sentinelctl status --filters agent  2>/dev/null | tee -a "$S1_Log" ) || echo "WARNING: SentinelOne is NOT installed" | tee -a "$S1_Log"  
S1_Threats=$(/usr/local/bin/sentinelctl show-threats 2>/dev/null | tee -a "$S1_Log" ) || echo "OK: NO Threats found" | tee -a "$S1_Log"
S1_quarantine=$(/usr/local/bin/sentinelctl quarantine list 2>/dev/null | tee -a "$S1_Log" ) || echo "OK: Unable to get quarantined items" | tee -a "$S1_Log"

S1protectionDisabled="*Protection:*disabled*"
S1missingAuth="*Missing*com.sentinelone*"
S1readyNo="*Ready:*no*"
S1infectedYes="*Infected:*yes*"
S1fwDisabled="*FW*disabled*"
S1notInstalled="*No such file or directory*"

while IFS= read -r StatusLine
do
	case "$StatusLine" in
		$S1protectionDisabled )
				echo "WARNING: SentinelOne Protection DISABLED"
				exitcode=1001
				;;
		$S1missingAuth )
				echo "ERR: SentinelOne MISSING Authorizations"
				exitcode=1002
				;;
		$S1readyNo )
				echo "ERR: SentinelOne NOT Ready"
				exitcode=1003
				;;
		$S1fwDisabled )
				echo "ERR: FIREWALL Not Ready"
				exitcode=1004
				;;
		$S1infectedYes )
				echo "ERR: INFECTION DETECTED"
				exitcode=1024
				;;		
	esac
done <<-EOF
EOF

if grep -q "No groups quarantined" <<< "$S1_quarantine"
then
	S1_quarantine="No items have been quarantined"
else 
	exitcode=1025
fi

if grep -q "no threats detected since last agent restart" <<< "$S1_Threats"
then
	S1_Threats="No threats have been detected"
else 
	exitcode=1026
fi

if [ $exitcode -eq 0 ]
then
	echo "OK: SentinelOne is NORMAL"
else
	echo "ERR: SentinelOne needs ATTENTION "
fi

echo ""
echo "$S1_Status"
echo ""
echo "Quarantined Items:"
echo "$S1_quarantine"
echo ""
echo "Threats:"
echo "$S1_Threats"
echo ""
echo "$(date +%F_%T), Exit Code: $exitcode, (v. $scriptv) on $thishost"

exit $exitcode
