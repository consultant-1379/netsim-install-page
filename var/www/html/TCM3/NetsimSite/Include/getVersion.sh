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

# old /netsim/inst way
#rsh -l root -n $HOSTNAME "ls -al /netsim/inst | awk -F' ' '{print \$11}' | awk -F/ '{print \$NF}'" | tr -d "\n" 2> /dev/null

rsh -l root -n $HOSTNAME "ps -ef | grep /netsim/.*/platf | grep -v grep | tail -1 | awk -F/ '{print \$3}'" | tr -d "\n" 2> /dev/null
