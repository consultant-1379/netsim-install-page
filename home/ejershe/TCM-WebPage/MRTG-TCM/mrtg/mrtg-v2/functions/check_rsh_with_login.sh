#!/bin/bash
# Created by Mark Kennedy, June 2008
# This script uses the expect script rsh_login.exp to automate entering a password while rshing to a machine
# A return code of 0 is returned if the login went ok (a # shell prompt was found in output)
# A return code of 1 is returned if there was some problem with the auto login

HOSTNAME=$1
PASSWORD=$2

if [[ $# -lt 1 ]]
then
        echo 1>&2 -e "Usage: $0 hostname\nor\nUsage: $0 hostname password"
        exit 1
fi

# The rsh_login_execute.exp expect script is called which automates the login procedure.

output=`/home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/functions/rsh_login.exp $HOSTNAME $PASSWORD`

# If a # was found in the output, then we can assume the login was successful

if [[ `echo $output | grep "#"` ]]
then
	exit 0
else
	exit 1
fi
