#!/bin/bash

HOSTNAME=ftp.athtem.eei.ericsson.se
USER=simadmin
PASSWD=simadmin

#set -n

machine=$1;
directory=$2;

if [[ $directory == "netsim" ]]
then
	fulldirectory="/"
	file="netsim.tar"
else
        if [[ $directory == "exported_items" ]]
        then
		fulldirectory="/netsim/netsimdir/"
		file="exported_items.tar"
        else
		fulldirectory="/netsim/netsimdir/"
		file=$directory.zip
        fi
fi

echo "Getting $file from ftp server, please wait.."

	rsh -l root -n $machine "
ftp  2>&1 -n $HOSTNAME <<SCRIPT
user $USER $PASSWD
cd /sims/GRAN/backup
cd $machine
lcd $fulldirectory
get $file
quit
SCRIPT
" 2> /dev/null

echo "Done" 

if [[ $file == "netsim.tar" ]]
then
	netsim_version_running=`rsh -l root -n $machine 'ps -ef | grep /netsim/.*/platf | grep -v grep | tail -1' | awk -F/ '{print $3}' | tr -d "\n" 2> /dev/null`
	if [[ $netsim_version_running == "" ]]
	then
		netsim_dir=/netsim/inst
	else
		netsim_dir=/netsim/$netsim_version_running
	fi
	echo "Using $netsim_dir as netsim directory"
	echo "Stopping netsim"
	rsh -l netsim -n $machine "$netsim_dir/stop_netsim"
	echo "Moving existing /netsim/ to /netsim.orig/"
	rsh -l root -n $machine "rm -rf /netsim.orig/;mv /netsim/ /netsim.orig/"
	echo "Untarring netsim directory, please wait.."
	rsh -l root -n $machine "cd /;tar -xzf /netsim.tar"
	echo "Restarting netsim"
	rsh -l netsim -n $machine "$netsim_dir/start_netsim"
else
	if [[ $file == "exported_items.tar" ]]
	then
		echo "Moving existing exported_items to exported_items.orig"
		rsh -l netsim -n $machine "rm -rf /netsim/netsimdir/exported_items.orig/;mv /netsim/netsimdir/exported_items/ /netsim/netsimdir/exported_items.orig/"
		echo "Untarring exported items"
		rsh -l netsim -n $machine "cd /;tar -xzf /netsim/netsimdir/exported_items.tar"
	else
		echo "Uncompressing simulation"
		rsh -l netsim -n $machine "echo -e \".uncompressandopen $file $directory force\" | $netsim_dir/netsim_shell" 2> /dev/null
	fi
fi

echo "Cleaning up."
rsh -l root -n $machine "rm $fulldirectory$file"
echo "Done"
