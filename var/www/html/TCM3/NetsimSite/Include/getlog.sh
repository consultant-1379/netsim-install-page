#!/bin/bash
# Created by Mark Kennedy, July 2008
# This script outputs the contents of a filename given as an argument, replacing newlines with <br> for use in html pages

HOME=/var/www/html/TCM3/NetsimSite

if [[ $# -ne 1 ]]
then
	echo "Usage: $0 logname"
	exit 1
fi

FILENAME=$1

cat $HOME/log/$FILENAME | sed ':a;N;$!ba;s/\n/<br>/g'
