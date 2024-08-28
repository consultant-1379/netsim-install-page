#!/bin/bash
#
# SCRIPT: Netsim install script 
# AUTHOR: eeijkee 
# DATE:   12/09/05
# REV:    PA1
#
# PLATFORM:  Solaris 
#                  
#
#     
#    
#
# REV LIST: PA1 12/09/05 first draft
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
BASEDIR=$(cd $(dirname $0)/..; pwd)
SCRIPTNAME=$(basename $0)

# source global commands and functions
[[ -f ${BASEDIR}/etc/commands.lib.$(uname) ]] && . ${BASEDIR}/etc/commands.lib.$(uname)
[[ -f ${BASEDIR}/etc/functions.sh ]] && . ${BASEDIR}/etc/functions.sh


##########################################################
########### DEFINE FILES AND VARIABLES HERE ##############
##########################################################
LOGFILE=${BASEDIR}/log/${SCRIPTNAME}.log   #default LOGFILE name is "<scriptname>.log"
#LOGTO="FILEONLY"   #uncomment to disable screen output
HOST=${1}
NETSIM_VERSION=${2}
email=${3}


##########################################################
############### DEFINE FUNCTIONS HERE ####################
##########################################################



##########################################################
################ BEGINNING OF MAIN #######################
##########################################################

push_file ${HOST} /home/eeijkee/dev/bin/netsim/check_netsim_user.sh /check_netsim_user.sh root
remote_command ${HOST} root chmod 777 /check_netsim_user.sh
remote_command ${HOST} root /check_netsim_user.sh
push_file ${HOST} /home/eeijkee/dev/bin/netsim_install_main.sh /netsim/netsim_install_main.sh root
push_file ${HOST} /home/eeijkee/dev/bin/netsim_fixes.sh /netsim/netsim_fixes.sh root
remote_command ${HOST} root chmod 777 /netsim/netsim_install_main.sh        
remote_command ${HOST} root chmod 777 /netsim/netsim_fixes.sh
remote_command ${HOST} root /netsim/netsim_install_main.sh ${NETSIM_VERSION} ${email}
push_file ${HOST} /home/eeijkee/dev/bin/create_init.sh /netsim/${NETSIM_VERSION}/bin/create_init.sh root
remote_command ${HOST} root /netsim/${NETSIM_VERSION}/bin/create_init.sh -a


# End of script

