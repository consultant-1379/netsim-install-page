#!/bin/bash

#set -n

HOSTNAME=ftp.athtem.eei.ericsson.se
USER=simadmin
PASSWD=simadmin

machine=$1;
directory=$2
readme=$3

check_free_space_machine()
{
	## Check if directory exists ##
	dir_exists=`rsh -l netsim -n $machine "if [ -d $directory ]; then echo 1; fi"`
	if [[ $dir_exists != "1" ]]
	then
		echo "Directory $directory not found on $machine"
		exit 1
	fi
	required_space=`rsh -l netsim -n $machine "du -s $directory" 2> /dev/null | awk '{print $1}'`

	## Free space checks #######
	echo -n "Checking for free space.."
	free_space=`rsh -l netsim -n $machine "df -k / | grep -v Filesystem" 2> /dev/null | awk '{print $4}'`
	echo "done"

	echo "Free space: $free_space kb";
	echo "Approx. required space: <= $required_space kb";

	## Compare free space vs required space
	if [[ $free_space -lt $required_space ]]
	then
        	echo "Warning: Free space on $machine may not be sufficient for creating backup"
	fi

	######

}

create_compressed_sim()
{
	dir=$1
	# Create compressed backup on machine
	echo -n "Creating compressed backup of simulation.."

	output=`rsh -l netsim -n $machine "rm /netsim/netsimdir/$dir.zip > /dev/null 2>&1;echo -e \".open $dir\n.saveandcompress $dir force\" | /netsim/inst/netsim_shell > /dev/null 2>&1;if [ -f /netsim/netsimdir/$dir.zip ]; then echo 0;fi" 2> /dev/null`

	if [[ $output != "0" ]]
        then
                echo "ERROR while compressing simulation, may be out of space."
                exit 1;
        else
                echo "done"
        fi

	#####################
}
copy_files()
{
	dir=$1
	file=$2
	# Copy compressed backup and readme to ftp server

        echo -n "Copying compressed backup and readme to ftp server.."

        # Ftp compressed backup to ftp server ##

        rsh -l netsim -n $machine "
ftp > /dev/null 2>&1 -n $HOSTNAME <<SCRIPT
user $USER $PASSWD
cd /sims/GRAN/backup
mkdir $machine
cd $machine
lcd $dir
put $file
quit
SCRIPT
" 2> /dev/null

        # Ftp readme.txt to ftp server ##

        ftp > /dev/null 2>&1 -n $HOSTNAME <<SCRIPT
user $USER $PASSWD
cd /sims/GRAN/backup
cd $machine
lcd /tmp
put readme.txt.$$ ${file}_readme.txt
quit
SCRIPT

        echo "done";


        echo -n "Removing temporary files.."

        rm /tmp/readme.txt.$$
        rsh -l netsim -n $machine "rm $dir$file" 2> /dev/null

        echo "done"
	echo "Backup created successfully"
}

tar_dir()
{
	sourcedir=$1
	target=$2
	echo -n "Creating tar of $sourcedir at $target, please wait.."
	output=`rsh -l root -n $machine "tar -czf $target $sourcedir > /dev/null 2>&1;echo \\$?" 2> /dev/null`
	if [[ $output != "0" ]]
	then
		echo "ERROR while creating $target"
		exit 1;
	else
		echo "done"
	fi
}


## Main functions that are called from user interface

backup()
{
	check_free_space_machine
	echo -e $readme > /tmp/readme.txt.$$
	if [[ $directory == "/netsim/" ]]
	then
		tar_dir /netsim/ /netsim.tar
		copy_files / netsim.tar
	elif [[ $directory == "/netsim/netsimdir/exported_items/" ]]
	then
		tar_dir /netsim/netsimdir/exported_items/ /netsim/netsimdir/exported_items.tar
		copy_files /netsim/netsimdir/ exported_items.tar
	else
		sim=`echo $directory | awk -F\/ '{print $4}'`
		create_compressed_sim $sim
		copy_files /netsim/netsimdir/ $sim.zip
	
	fi
}

backup
