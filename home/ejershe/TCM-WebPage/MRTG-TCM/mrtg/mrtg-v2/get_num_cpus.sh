#!/bin/bash

HOSTNAME=$1

rsh -l root -n $HOSTNAME "ls -d  /sys/devices/system/cpu/*/" 2> /dev/null | wc -l
