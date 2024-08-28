#!/bin/bash
# Created by Mark Kennedy, July 2008
# This script takes three arguments, the hostname, version and patch
# It attempts to download the patch from the netsim patches page, upload that onto the machine specified
# and finally install that patch onto the machine

if [[ $# -ne 3 ]]
then
	echo "Usage: $0 hostname version patch" 
	exit 1
fi

HOSTNAME=$1
VERSION=$2
PATCH=$3
HOME=/var/www/html/TCM3/NetsimSite

if [[ ! -f $HOME/patches/$PATCH ]]
then
	echo "Downloading $PATCH"
       	if [[ `echo "$VERSION" | grep "R27"` != "" ]]
	then
		netsim_version="6.7"
	elif [[ `echo "$VERSION" | grep "R26"` != "" ]]
	then
		netsim_version="6.6"	
	elif [[ `echo "$VERSION" | grep "R25"` != "" ]]
        then
                netsim_version="6.5"
	elif [[ `echo "$VERSION" | grep "R24"` != "" ]]
        then
                netsim_version="6.4"
        elif [[ `echo "$VERSION" | grep "R23"` != "" ]]
        then
                netsim_version="6.3"
        else
                netsim_version="6.2"
        fi
	/usr/bin/wget --no-proxy -O "$HOME/patches/$PATCH" "http://netsim.lmera.ericsson.se/tssweb/netsim$netsim_version/released/NETSim_UMTS.$VERSION/Patches/$PATCH" 

	if [[ $? -ne 0 ]]
	then
		echo "Error downloading patch" 
        	exit 1
	fi
else
	echo "$HOME/patches/$PATCH already exists, not downloading" 
fi

echo "Copying patch to machine now.." 
rcp $HOME/patches/$PATCH root@$HOSTNAME:/tmp/

if [[ $? -ne 0 ]]
then
	echo "Error ftping patch to machines tmp directory" 
        echo "1"
        exit 1
fi

echo "Installing patch now.." 
rsh -l netsim  -n $HOSTNAME "echo \".install patch /tmp/$PATCH force\" | /netsim/inst/netsim_shell" 

output=`rsh -l netsim -n $HOSTNAME "echo \".show patch $PATCH\" | /netsim/inst/netsim_shell | grep $PATCH > /dev/null 2>&1; echo \\$?"`

if [[ $output != "0" ]]
then
	echo "Patch may not have installed successfully"
	exit 1	
fi

echo "Patch installed successfully" 
