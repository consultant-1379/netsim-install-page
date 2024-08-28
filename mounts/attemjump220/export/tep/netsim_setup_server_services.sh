#!/bin/bash
# Created by	: Billy Dunne
# Created on	: 18.03.14
##
### VERSION HISTORY
# Ver1			: Created for Netsim Install Page
# Purpose		: Prepare server services for Netsim install
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

#Configure internal ssh on server

# Declare Constants

if [ $SYS_OS = "SunOS" ]
then
	IP=`/sbin/ifconfig -a | grep inet | grep -v '127.0.0.1' | awk '{ print $2}'`
else
	IP=`hostname -i`
fi

LOCAL_IP="127.0.0.1"

PAM_DIR=/etc/pam.d
RLOGIN_FILE=rlogin
RSH_FILE=rsh

RLOGIN_STRING="#%PAM-1.0\nsession\trequired\tpam_limits.so\nauth\trequired\tpam_rhosts.so\tpromiscuous\nauth\trequired\tpam_nologin.so\naccount\trequired\tpam_unix2.so\npassword\trequired\tpam_unix2.so\nsession\trequired\tpam_unix2.so\tnone\n"
RSH_STRING="#%PAM-1.0\nsession\trequired\tpam_limits.so\nauth\trequired\tpam_rhosts.so\tpromiscuous\nauth\trequired\tpam_nologin.so\naccount\trequired\tpam_unix2.so\npassword\trequired\tpam_unix2.so\nsession\trequired\tpam_unix2.so\tnone"

SNMP_FILE=/etc/snmp/snmpd.conf
SNMP_FILE1=/etc/snmp/conf/snmpd.conf
SNMP_FILE2=/etc/sma/snmp/snmpd.conf
SNMP_STRING="agentaddress $IP:161,localhost:161"

INTERFACE_STRING="interface = $IP"
SERVICES_PATTERN="}"
TELNET_FILE=/etc/xinetd.d/telnet

FTP_FILE1=/etc/xinetd.d/vsftpd
FTP_FILE2=/etc/xinetd.d/pure-ftpd
VSFTP_CONFIG_FILE=/etc/vsftpd.conf
VSFTP_STRING="listen_address=$IP"

SSH_FILE=/etc/ssh/sshd_config
SSH_STRING1="ListenAddress $IP"
SSH_STRING2="ListenAddress $LOCAL_IP"
SSH_STRING3="^[[:space:]]*ListenAddress 0.0.0.0"
SSH_STRING4="^[[:space:]]*ListenAddress ::"
HCHAR="#"

#Daemons
SNMP_DAEMON=snmpd
TELNET_DAEMON=telnet
XINET_DAEMON=/etc/init.d/xinetd
FTP_DAEMON=ftp
XINET_DAEMON=/etc/init.d/xinetd
VSFTP_DAEMON=/etc/init.d/vsftpd
SSH_DAEMON=sshd


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
# Configure RLOGIN
#
#########################################

echo "Configure RLogin correctly"


if [ -f $PAM_DIR/$RLOGIN_FILE ]
then
	mv $PAM_DIR/$RLOGIN_FILE $PAM_DIR/$RLOGIN_FILE.save
fi

echo -e $RLOGIN_STRING > $PAM_DIR/$RLOGIN_FILE

#fi RLOGIN

#########################################
#
# Configure RSH
#
#########################################

echo "Configure RSH correctly"

if [ -f $PAM_DIR/$RSH_FILE ]
then
	mv $PAM_DIR/$RSH_FILE $PAM_DIR/$RSH_FILE.save
fi

echo -e $RSH_STRING > $PAM_DIR/$RSH_FILE

#fi RSH

#########################################
#
# Configure SNMP
#
#########################################

echo "Configure SNMP service"

if [ $SYS_OS = "SunOS" ]
then
	# call the function that copies the config file
	copy_file "$SNMP_FILE1"
	# call the function that copies the config file
	copy_file "$SNMP_FILE2"

	check_before_add "$SNMP_STRING" "$SNMP_FILE1"
	check_before_add "$SNMP_STRING" "$SNMP_FILE2"
else
	# call the function that copies the config file
	copy_file "$SNMP_FILE"

	check_before_add "$SNMP_STRING" "$SNMP_FILE"
fi

# Restart the daemon / service
pkill -HUP $SNMP_DAEMON

#netsim needs to be restarted (handled in installnetsim.php page)

#fi SNMP

#########################################
#
# Configure Telnet
#
#########################################

echo "Configure Telnet service"

if [ $SYS_OS = "SunOS" ]
then
	# Call the function that configures the service on Solaris
	configure_solaris_service "$TELNET_DAEMON" "$IP"
else
	# call the function that copies the config file
	copy_file "$TELNET_FILE"

	check_before_replace "$INTERFACE_STRING" "$TELNET_FILE" "$SERVICES_PATTERN"

	# Restart the daemon / service
	$XINET_DAEMON restart
fi

#netsim needs to be restarted (handled in installnetsim.php page)

#fi Telnet

#########################################
#
# Configure FTP
#
#########################################

echo "Configure FTP service"

if [ $SYS_OS = "SunOS" ]
then
	# Call the function that configures the service on Solaris
	configure_solaris_service "$FTP_DAEMON" "$IP"
else
	# Call the function that copies the file (the function handles if the file is not present)
	copy_file "$FTP_FILE1"
	# Call the function that copies the file (the function handles if the file is not present)
	copy_file "$FTP_FILE2"

	# Only change this file if it is actually present
	if [ -f $FTP_FILE1 ]
	then
		check_before_replace "$INTERFACE_STRING" "$FTP_FILE1" "$SERVICES_PATTERN"
	fi

	# Only change this file if it is actually present
	if [ -f $FTP_FILE2 ]
	then
		check_before_replace "$INTERFACE_STRING" "$FTP_FILE2" "$SERVICES_PATTERN"
	fi

	# Restart the daemon / service
	$XINET_DAEMON restart

	copy_file "$VSFTP_CONFIG_FILE"

	check_before_add "$VSFTP_STRING" "$VSFTP_CONFIG_FILE"

	# Restart the daemon / service
	$VSFTP_DAEMON restart
fi

#netsim needs to be restarted (handled in installnetsim.php page)

#fi FTP

#########################################
#
# Configure SSH
#
#########################################

echo "Configure SSH service"

# call the function that copies the config file
copy_file "$SSH_FILE"

check_before_add "$SSH_STRING1" "$SSH_FILE"
check_before_add "$SSH_STRING2" "$SSH_FILE"
comment_out "$SSH_STRING3" "$SSH_FILE" "$HCHAR"
comment_out "$SSH_STRING4" "$SSH_FILE" "$HCHAR"

# Restart the daemon / service
# pkill option works for both Solaris and Linux
if [ $SYS_OS = "SunOS" ]
then
	pkill -HUP $SSH_DAEMON
else
	/etc/init.d/$SSH_DAEMON restart
fi

#fi SSH

#fi
