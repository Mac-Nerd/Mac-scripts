#!/bin/bash
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------



Exitcode=0
VALIDArray=(AWS RMM NCENTRAL APPLE MICROSOFT SENTINELONE)

# in case local or ISP DNS is the issue, specify IP of an alternative here, eg google dns "8.8.8.8"
ALTDNS="208.67.222.222"

# Google		8.8.8.8			8.8.4.4
# Quad9			9.9.9.9			149.112.112.112
# OpenDNS Home	208.67.222.222	208.67.220.220
# Cloudflare	1.1.1.1			1.0.0.1
# CleanBrowsing	185.228.168.9	185.228.169.9
# Alternate DNS	76.76.19.19		76.223.122.150
# AdGuard DNS	94.140.14.14	94.140.15.15


# Turn off the progress dots if you prefer
SHOWDOTS=true
#SHOWDOTS=false



# requires at least one parameter
CHECKArray=$*


function DODOTS () {
	if $SHOWDOTS 
	then
		printf "."
	fi
}

function ERROROUT () {
	let Errors++
	Exitcode=1
}

function RUNTEST () {

	Errors=0
	
	echo " -- Running $1 connection tests:"
	
	if [ $1 == "AWS" ]
	then
		echo " -- (see also http://ec2-reachability.amazonaws.com)"
		AWSArray="$(xmllint --html --xpath '//tr/td[3]' <(curl -sL 'http://ec2-reachability.amazonaws.com') 2> /dev/null | sed 's/<\/td><td>/\n/g; s/<td>//g; s/<\/td>//g')"
		for AWSIP in $AWSArray
		do
			# Give me a ping, Vasili. One ping only, please.
			if $( ping -n -c1 -t3 ${AWSIP} &> /dev/null )
			then
				DODOTS
			else
				# unable to ping the host IP
				printf "\n[%s] [ICMP ERROR] \n" $AWSIP
				ERROROUT
			fi	
		
		done		
	else


		eval FQDNArray=(\${$1'Array'[@]})
				
		for FQDN in "${FQDNArray[@]}"
		do

			# does the hostname include a port number?
			NCPORT=$(echo ${FQDN} | awk -F ':' '{print $2}')

			# if blank, set port to 443, otherwise strip the port off the hostname
			[ $NCPORT ] && FQDN=$(echo ${FQDN} | awk -F ':' '{print $1}') || NCPORT=443

			# DNS lookup
			if $( host $FQDN &> /dev/null )
			then 

				# DNS Worked, now netcat

				# NTP uses UDP
				if [ ${NCPORT} -eq 123 ]
				then 
					# Try UDP instead of TCP
					if $( nc -z -u ${FQDN} 123 &> /dev/null ) 
					then
						DODOTS
					else 
						printf "\n[%s:%i] [UNABLE TO CONNECT] \n" $FQDN	$NCPORT
						# host resolves, unable to connect via UDP 123
						ERROROUT
					fi
					
				else
					if $( nc -z -G 3 ${FQDN} ${NCPORT} &> /dev/null )
					then
						DODOTS
					else 
						ERROROUT

						# last chance. try again on TCP port 80 
						if $( nc -z -G 3 ${FQDN} 80 &> /dev/null ) 
						then
							printf "\n[%s] [HTTP GOOD, NO SSL?] \n" $FQDN
							# host resolves, connected TCP 80, unable to connect 443
						else
							printf "\n[%s:%i] [UNABLE TO CONNECT] \n" $FQDN	$NCPORT
							# host resolves, but no connection on 443 or 80
						fi
					fi
				fi

			else
			# no DNS. Sad face.

				if $( host $FQDN $ALTDNS &> /dev/null )
				then
					printf "\n[%s] [LOCAL DNS ERROR?] \n" $FQDN
					# host resolves with alt DNS, but not with local.
				else
					printf "\n[%s] [NO SUCH DOMAIN?] \n" $FQDN
					# host does not resolve with either local or alt DNS

				fi

				ERROROUT
			fi
		done
	
	fi




	echo ""
	echo " -- $1 connectivity check completed with ${Errors} errors."
	

}

function RUNALLTESTS () {
	for Target in  "${VALIDArray[@]}"
	do
		RUNTEST $Target
	done
	
}






# https://documentation.n-able.com/remote-management/userguide/Content/dashboard_urls.htm
# https://documentation.n-able.com/remote-management/userguide/Content/web_requirements_and_permissions.htm
# https://documentation.n-able.com/remote-management/userguide/Content/nd_upload_urls.htm
# https://documentation.n-able.com/remote-management/userguide/Content/mav_urls.htm

RMMArray=(
"avery-ap-southeast-2-cdn.logicnow.us"
"avery-ap-southeast-2-svc.logicnow.us"
"avery-eu-central-1-cdn.logicnow.us"
"avery-eu-central-1-svc.logicnow.us"
"avery-eu-west-1-cdn.logicnow.us"
"avery-eu-west-1-svc.logicnow.us"
"avery-us-west-2-cdn.logicnow.us"
"avery-us-west-2-svc.logicnow.us"
"ap-southeast-2.breckenridge.remote.management"
"eu-central-1.breckenridge.remote.management"
"eu-west-1.breckenridge.remote.management"
"us-west-2.breckenridge.remote.management"
"breck-ap-southeast-2-svc.logicnow.us"
"breck-eu-central-1-svc.logicnow.us"
"breck-eu-west-1-svc.logicnow.us"
"breck-files.logicnow.us"
"breck-update.logicnow.us"
"breck-us-west-2-svc.logicnow.us"
"cannonball-ap-southeast-2-push.logicnow.us"
"cannonball-eu-central-1-push.logicnow.us"
"cannonball-eu-west-1-push.logicnow.us"
"cannonball-us-west-2-push.logicnow.us"
"checks-api.apac.system-monitor.com"
"checks-api.emea.system-monitor.com"
"checks-api.us.system-monitor.com"
"data.cdn-sw.net"
"dg5bj97jvb67q.cloudfront.net"
"rm-downloads-apac.logicnow.com"
"rm-downloads-us.logicnow.com"
"rm-downloads.logicnow.com"
"upload1.am.remote.management"
"upload1.system-monitor.com"
"upload1.systemmonitor.co.uk"
"upload1.systemmonitor.us"
"upload1asia.system-monitor.com"
"upload1europe1.systemmonitor.eu.com"
"upload1france.systemmonitor.eu.com"
"upload1france1.systemmonitor.eu.com"
"upload1germany1.systemmonitor.eu.com"
"upload1ireland.systemmonitor.eu.com"
"upload1poland1.systemmonitor.eu.com"
"upload2.am.remote.management"
"upload2.system-monitor.com"
"upload2.systemmonitor.co.uk"
"upload2.systemmonitor.us"
"upload2asia.system-monitor.com"
"upload2europe1.systemmonitor.eu.com"
"upload2france.systemmonitor.eu.com"
"upload2france1.systemmonitor.eu.com"
"upload2germany1.systemmonitor.eu.com"
"upload2ireland.systemmonitor.eu.com"
"upload2poland1.systemmonitor.eu.com"
"upload3.am.remote.management"
"upload3.system-monitor.com"
"upload3.systemmonitor.co.uk"
"upload3.systemmonitor.us"
"upload3asia.system-monitor.com"
"upload3europe1.systemmonitor.eu.com"
"upload3france.systemmonitor.eu.com"
"upload3france1.systemmonitor.eu.com"
"upload3germany1.systemmonitor.eu.com"
"upload3ireland.systemmonitor.eu.com"
"upload3poland1.systemmonitor.eu.com"
"upload4.am.remote.management"
"upload4.system-monitor.com"
"upload4.systemmonitor.co.uk"
"upload4.systemmonitor.us"
"upload4asia.system-monitor.com"
"upload4europe1.systemmonitor.eu.com"
"upload4france.systemmonitor.eu.com"
"upload4france1.systemmonitor.eu.com"
"upload4germany1.systemmonitor.eu.com"
"upload4ireland.systemmonitor.eu.com"
"upload4poland1.systemmonitor.eu.com"
"sis.n-able.com"
)


# N-central
# https://documentation.n-able.com/N-central/userguide/Content/Administration/NetworkSetup/Networking%20Requirements.htm
NCENTRALArray=(
"send.n-able.com:21"
"sis.n-able.com"
"update.n-able.com"
"feeds.n-able.com"
"servermetrics.n-able.com"
"licensing.n-able.com"
"push.n-able.com"
"scep.n-able.com"
"www.updatewarranty.com"
"microsoft.com"
#"keybox.n-able.com"
"keybox.solarwindsmsp.com"
"mothership.n-able.com"
"mothership2.n-able.com"
"ui.netpath.n-able.com"
"api.ecosystem-middleware.eu-central-1.prd.esp.system-monitor.com"
"api.ecosystem-middleware.eu-west-1.prd.esp.system-monitor.com"
"api.ecosystem-middleware.us-west-2.prd.esp.system-monitor.com"
"api.ecosystem-middleware.ap-southeast-2.prd.esp.system-monitor.com"
"ui.ecosystem-middleware.prd.esp.system-monitor.com"
"api.ecosystem-middleware.eu-east-1.prd.esp.system-monitor.com"
"api.ecosystem-middleware.us-west-1.prd.esp.system-monitor.com"
"rest.ecosystem.ap-southeast-2.prd.esp.system-monitor.com"
"rest.ecosystem.eu-east-1.prd.esp.system-monitor.com"
"rest.ecosystem.eu-west-1.prd.esp.system-monitor.com"
"rest.ecosystem.us-west-1.prd.esp.system-monitor.com"
"grpc.ecosystem.ap-southeast-2.prd.esp.system-monitor.com"
"grpc.ecosystem.eu-east-1.prd.esp.system-monitor.com"
"grpc.ecosystem.eu-west-1.prd.esp.system-monitor.com"
"grpc.ecosystem.us-west-1.prd.esp.system-monitor.com"
"swi-rc.cdn-sw.net"
"www.beanywhere.com"
"mspa.n-able.com"
"pubnub.com"
"submit.bitdefender.com"
"update-solarwinds.2d585.cdn.bitdefender.net"
"upgrade.bitdefender.com"
"lv2.bitdefender.com"
"v1.bdnsrt.org:53"
"vc-fu.nimbus.bitdefender.net"
"elam-fu.nimbus.bitdefender.net"
"nimbus.bitdefender.net"


)

# SentinelOne
# https://success.alienvault.com/s/article/SentinelOne-System-Requirements
SENTINELONEArray=(
"usea1-007.sentinelone.net"
"usea1-008.sentinelone.net"
"usea1-009.sentinelone.net"
"usea1-011.sentinelone.net"
"usea1-012.sentinelone.net"
"usea1-014.sentinelone.net"
"usea1-015.sentinelone.net"
"euce1-100.sentinelone.net"
"euce1-102.sentinelone.net"
"euce1-103.sentinelone.net"
"euce1-104.sentinelone.net"
"apne1-1001.sentinelone.net"
"dv-us-prod.sentinelone.net"
"starlight-gw-prod.sentinelone.net"
"ioc-gw-prod-cp-us.sentinelone.net"
"ioc-gw-prod-us-1a.sentinelone.net"
"ioc-gw-prod-us-1b.sentinelone.net"
"dv-eu-prod.sentinelone.net"
"ioc-gw-eu.sentinelone.net"
"ioc-gw-cp-eu.sentinelone.net"
"ioc-gw-prod-eu-1a.sentinelone.net"
"ioc-gw-prod-eu-1b.sentinelone.net"
"ioc-gw-prod-eu-1c.sentinelone.net"
"dv-ap-prod.sentinelone.net"
"ioc-gw-prod-ap-1a.sentinelone.net"
"ioc-gw-prod-ap-1c.sentinelone.net"
"cloudgateway-prod.sentinelone.net"
"cloudgateway-prod-eu.sentinelone.net"
"cloudgateway-prod-ap.sentinelone.net"
"ioc-qgw-us.sentinelone.net"
"ioc-qgw-eu.sentinelone.net"
"ioc-qgw-ap.sentinelone.net"
)

# Microsoft updates
# https://docs.microsoft.com/en-us/windows-server/administration/windows-server-update-services/deploy/2-configure-wsus
MICROSOFTArray=(
"c.microsoft.com"
"ctldl.windowsupdate.com"
"dl.delivery.mp.microsoft.com"
"download.update.microsoft.com"
"download.windows.com"
"download.windowsupdate.com"
"fe2.update.microsoft.com"
"tlu.dl.delivery.mp.microsoft.com"
"update.microsoft.com"
"update.windows.com"
"windows.com"
"windowsupdate.com"
"windowsupdate.microsoft.com"
"wustat.windows.com"
)



# Apple device and certificate hostnames
# https://support.apple.com/en-us/HT210060

APPLEArray=(
"time.apple.com:123"
"time-macos.apple.com:123"
"time-ios.apple.com:123"
"albert.apple.com"
"iprofiles.apple.com"
"captive.apple.com"
"gs.apple.com"
"humb.apple.com"
"static.ips.apple.com"
"sq-device.apple.com"
"tbsc.apple.com"
"api.push.apple.com"
#"gateway.push.apple.com"
#"feedback.push.apple.com"
"0-courier.push.apple.com"
"1-courier.push.apple.com"
"2-courier.push.apple.com"
"3-courier.push.apple.com"
"4-courier.push.apple.com"
"5-courier.push.apple.com"
"6-courier.push.apple.com"
"7-courier.push.apple.com"
"8-courier.push.apple.com"
"9-courier.push.apple.com"
"deviceenrollment.apple.com"
"deviceservices-external.apple.com"
"gdmf.apple.com"
"identity.apple.com"
"mdmenrollment.apple.com"
"setup.icloud.com"
"vpp.itunes.apple.com"
"business.apple.com"
"appldnld.apple.com"
"configuration.apple.com"
"gg.apple.com"
"gnf-mdn.apple.com"
"gnf-mr.apple.com"
"ig.apple.com"
"mesu.apple.com"
"ns.itunes.apple.com"
"oscdn.apple.com"
"osrecovery.apple.com"
"skl.apple.com"
"swcdn.apple.com"
"swdist.apple.com"
"swdownload.apple.com"
"swscan.apple.com"
"updates-http.cdn-apple.com"
"updates.cdn-apple.com"
"xp.apple.com"
"itunes.apple.com"
"apps.apple.com"
"mzstatic.com"
"ppq.apple.com"
"lcdn-registration.apple.com"
"suconfig.apple.com"
"xp-cdn.apple.com"
"lcdn-locator.apple.com"
"serverstatus.apple.com"
#"appattest.apple.com"
"data.appattest.apple.com"
"diagassets.apple.com"
"doh.dns.apple.com"
"certs.apple.com"
"crl.apple.com"
"crl.entrust.net"
"crl3.digicert.com"
"crl4.digicert.com"
"ocsp.apple.com"
"ocsp.digicert.cn"
"ocsp.digicert.com"
"ocsp.entrust.net"
"ocsp2.apple.com"
"valid.apple.com"
)



if [ -z "$CHECKArray" ]
then
	echo "Error: Requires one or more targets."
	echo "Usage: ./Mac-Connectivity-Test.sh [target (target ...) | all]"
	echo "Valid targets are AWS, RMM, NCENTRAL, APPLE, MICROSOFT, SENTINELONE"
	exit 1
else
	# make case insensitive, convert string to array
	CHECKArray=( $(echo $CHECKArray | tr '[:lower:]' '[:upper:]') )

	# shortcut for checking ALL
	if [ "$CHECKArray" == "ALL" ]
	then
		echo "Checking all targets. This will take a few minutes."

		RUNALLTESTS
	else
	
		# check array of target inputs
		for Target in  "${CHECKArray[@]}"
		do
			# is target in the array of valid options?
			if [[ ! " ${VALIDArray[*]} " =~ "${Target}" ]]
			# if not, then
			then
				echo "Error: Unknown target value: \"${Target}\""
				echo "Valid targets are AWS, RMM, NCENTRAL, APPLE, MICROSOFT, SENTINELONE, or ALL"
				exit 2
			fi
		done
	fi

fi

for Target in  "${CHECKArray[@]}"
do
	RUNTEST $Target
done

exit 0



echo "Connectivity check complete."

exit $Exitcode
