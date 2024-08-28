#!/bin/bash
# Created by Mark Kennedy, July 2008
# This script gets the latest 3 netsim versions from the Netsim database and proceeds to grab the list of patches from each versions netsim page

mysql -s -s -e "use Netsim;SELECT R_version from R_version ORDER BY R_version DESC LIMIT 3" | while read line
do
	if [[ `echo "$line" | grep "R27"` != "" ]]
	then
		netsim_version="6.7"
	elif [[ `echo "$line" | grep "R26"` != "" ]]
        then
                netsim_version="6.6"		
	elif [[ `echo "$line" | grep "R25"` != "" ]]
        then
                netsim_version="6.5"
	elif [[ `echo "$line" | grep "R24"` != "" ]]
        then
		netsim_version="6.4"
	elif [[ `echo "$line" | grep "R23"` != "" ]]
	then
		netsim_version="6.3"
	else
		netsim_version="6.2"
	fi
	echo -n :,$line,
	/usr/bin/wget -q -O - --no-proxy http://netsim.lmera.ericsson.se/tssweb/netsim$netsim_version/released/NETSim_UMTS.$line/Patches/index.html | /bin/grep -e P*\.zip\< -e P*tar\.Z\< | awk -F\" '{print $2 ","}' | tr -d '\n'
done
