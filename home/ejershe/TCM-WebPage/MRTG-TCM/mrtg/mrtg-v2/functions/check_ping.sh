#!/bin/bash
# Script returns ok if machine responds to ping
# Created by Mark Kennedy, June 2008

HOSTNAME=$1

if [[ $# -ne 1 ]]
then
        echo 1>&2 "Usage: $0 hostname"
        exit 1
fi

ping -c1 -w2 $HOSTNAME > /dev/null 2>&1

if [[ $? -ne 0 ]]
then
	exit 1
fi
