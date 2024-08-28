#!/bin/bash
# Created by Mark Kennedy, July 2008
# This script outputs the contents of a filename given as an argument, replacing newlines with <br> for use in html pages


if [[ $# -lt 2 ]]
then
	echo "Usage: $0 logname logdir"
	exit 1
fi

FILENAME=$1
LOG_DIR=$2
TAIL_SIZE=$3
if [[ "$TAIL_SIZE" == "" ]]
then
	TAIL_SIZE=20
fi
tail -$TAIL_SIZE $LOG_DIR$FILENAME  |  sed 's/.\x08//g'
#tail -20 $LOG_DIR$FILENAME |  sed 's/.\x08//g'
