#!/bin/bash

HOSTNAME=ftp.athtem.eei.ericsson.se
USER=simadmin
PASSWD=simadmin

if [[ $# -ne 1 ]]
then
	echo "Usage: $0 machine"
	exit 1
fi

machine=$1

ftp -n > /tmp/$machine.$$ 2> /dev/null $HOSTNAME <<SCR
user $USER $PASSWD
cd /sims/GRAN/backup/
ls $machine
quit
SCR

exported_items=`cat /tmp/$machine.$$ | awk '{print $9}' | grep "^exported_items.tar$"`
netsimdir=`cat /tmp/$machine.$$ | awk '{print $9}' | grep "^netsim.tar$"`
simulations=`cat /tmp/$machine.$$ | awk '{print $9}' | grep -v "^netsim.tar$" | grep -v "^exported_items.tar$" | grep zip$ | awk -F. '{print $1}'`

exp_found=0

if [[ $exported_items != "" ]]
then
	exp_found=1
fi

netsimdir_found=0

if [[ $netsimdir != "" ]]
then
	netsimdir_found=1
fi

echo -n $exp_found,$netsimdir_found
cat /tmp/$machine.$$ | awk '{print $9}' | grep -v "^netsim.tar$" | grep -v "^exported_items.tar$" | grep zip$ | awk -F. '{print $1}' | while read line
do
	echo -n ,$line
done

rm /tmp/$machine.$$
