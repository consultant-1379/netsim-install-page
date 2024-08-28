#!/bin/bash
# Created by Mark Kennedy, July 2008
# This script attempts to get the netsim version currently in use by the hostname given as argument

if [[ $# -ne 1 ]]
then
	echo "Usage: $0 hostname"
fi


HOSTNAME=$1
/home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/functions/check_ping.sh $HOSTNAME

if [[ $? -ne 0 ]]
then
	echo -n 0
	exit 1
fi

rsh -l netsim -n $HOSTNAME "cd /netsim/netsimdir;ls  | while read line; do if [ -f /netsim/netsimdir/\${line}/simulation.netsimdb  ]; then echo \$line,; fi;done;" 2> /dev/null
