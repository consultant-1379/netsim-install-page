#!/bin/bash
# Created by	: Billy Dunne
# Created on	: 18.03.14
##
### VERSION HISTORY
# Ver1			: Created for Netsim Install Page
# Purpose		: Preparing for NEs Using Privileged Ports
# Description	: These commands need to be run as part of the Netsim Install page
# Date			: 18 March 2014
# Who			: Billy Dunne
#########################################################################

# Declare Constants
SYS_OS=`uname`

# Check that the current user is root depending on OS
if [ $SYS_OS = "SunOS" ]
then
	tmp=`who am i`
else
	tmp=`whoami`
fi

whoami=`echo $tmp | awk '{print $1}'`

if [[ $whoami != "root" ]]
then
	echo "You must be root user!"
	exit
fi

# Declare Constants
NETSIM_DIR=/netsim
INST_DIR=inst
BIN_DIR=bin
SETUP_FD_FILE=setup_fd_server.sh
NETSIM_USER=netsim
PIPE_BIN=netsim_pipe
MMLSCRIPT=$0".mml"
PWD=`pwd`

# Declare Variables

# Declare Functions

check_dir()
{
	# See if the directory is there, if not, create it
	if [[ ! -d $1 ]]
	then
	mkdir -p $1
	fi
}

copy_file()
{

	# Save the file if it is there, in case there is a problem
	if [ -f $1 ]
	then
	cp $1 $1".save"
	fi
}

check_before_add()
{

	# Check to see if this line is present already
	# Keeps file clean as possible if someone runs script again
	if grep -Fxq "$1" $2
	then
    		echo "$1 seems to be already in $2"
	else
    		echo $1  >>  $2
	fi
}

check_before_replace()
{

	# Check to see if this line is present already
	# Keeps file clean as possible if someone runs script again
	if grep -Fxq "$1" $2
	then
    		echo "$1 seems to be already in $2"
	else
    		sed -i "s/$3/$1\n&/" $2
	fi
}

configure_solaris_service()
{

	# Bind the service to an interface and enable
	inetadm -m $1 bind_addr="$2"
	svcadm enable $1

}

comment_out()
{

	# Find a pattern in a file and comment it out (if found)
	#if grep -Exq "$1" $2
	#then
		sed -i "s/$1/$3&/" $2
	#fi
}


#########################################
#
# SETUP FD SERVER
#
#########################################

echo "Configure FD Server SetUp"

# Copy the MML script file if it exists
copy_file "$PWD/$MMLSCRIPT"

#########################################
#
# MAKE MML SCRIPT
#
#########################################

echo "Making MML Script"

cat > $MMLSCRIPT << _MMLSCRIPT_
.server stop all
_MMLSCRIPT_

# Stop running sims
sudo -u $NETSIM_USER $NETSIM_DIR/$INST_DIR/$PIPE_BIN < $MMLSCRIPT

# Kill the fdsrv process
pkill fdsrv

# Configure FD Server Setup
$NETSIM_DIR/$INST_DIR/$BIN_DIR/$SETUP_FD_FILE


#########################################
#
# RESTART NETSIM
#
#########################################

echo "Restarting Netsim"

# Restart Netsim  - need to do this as the netsim user
sudo -u $NETSIM_USER $NETSIM_DIR/$INST_DIR/restart_netsim

#fi

