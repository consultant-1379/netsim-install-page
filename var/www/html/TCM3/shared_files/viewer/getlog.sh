#!/bin/bash
# Created by Mark Kennedy, July 2008
# This script outputs the contents of a filename given as an argument, replacing newlines with <br> for use in html pages

if [[ $# -ne 2 ]]
then
	echo "Usage: $0 logname logdir"
	exit 1
fi

FILENAME=$1
LOG_DIR=$2
cat $LOG_DIR$FILENAME  |  sed 's/.\x08//g' 
#cat $LOG_DIR$FILENAME | sed ':a;N;$!ba;s/\n/<br>/g'
