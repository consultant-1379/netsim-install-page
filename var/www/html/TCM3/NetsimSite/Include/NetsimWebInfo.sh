#!/bin/bash
#
# SCRIPT: logoff script 
# AUTHOR: eeijkee 
# DATE:   24/03/06
# REV:    PA1
#
# PLATFORM:  Solaris 
#                  
#
# PURPOSE: 
#     
#    
#
# REV LIST: PA1 24/03/06 first draft
#     
#        
#        
#
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script 
#         
##########################################################
########### GLOBAL SETTINGS HERE            ##############
##########################################################
BASEDIR="/home/eeijkee/dev/"
SCRIPTNAME=$(basename $0)

# source global commands and functions
[[ -f ${BASEDIR}/etc/commands.lib.$(uname) ]] && . ${BASEDIR}/etc/commands.lib.$(uname)
[[ -f ${BASEDIR}/etc/functions.sh ]] && . ${BASEDIR}/etc/functions.sh


##########################################################
########### DEFINE FILES AND VARIABLES HERE ##############
##########################################################
LOGFILE=${BASEDIR}/log/${SCRIPTNAME}.log   #default LOGFILE name is "<scriptname>.log"
#LOGTO="FILEONLY"   #uncomment to disable screen output

#HOST=${1}

##########################################################
############### DEFINE FUNCTIONS HERE ####################
##########################################################



##########################################################
################ BEGINNING OF MAIN #######################
##########################################################

for HOST in $*
do
INTERFACE=$(remote_command ${HOST} root "netstat -i" | awk '/'$HOST'[ \t]/{print $1}')
HOSTID=$(remote_command ${HOST} root hostid)
IP=$(remote_command ${HOST} root getent hosts ${HOST} | awk '{print $1}')
if [[ ${HOST} == netsimlin* ]] ; then
	MAC=NA
	MAC=$(remote_command ${HOST} root /sbin/ifconfig  | grep -e eth | awk '{print $5}' | head -n 1) 
	HWtype=ProliantDL145
else
	INTERFACE=$(remote_command ${HOST} root "netstat -i" | awk '/'$HOST'[ \t]/{print $1}')
	MAC=$(remote_command ${HOST} root ifconfig ${INTERFACE} | awk '{ field = $NF }; END{ print field }')
	HWtype=$(remote_command ${HOST} root uname -i)
fi
OSversion=$(remote_command ${HOST} root uname -r)
mysql --user=jkroot --password=jkroot << EOF
	use Netsim;
	INSERT INTO ServerInfo VALUES ("$HOST", "$HOSTID", "$IP", "$MAC", "$OSversion", "$HWtype"); 
EOF

done
# End of script

