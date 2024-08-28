#!/bin/bash
#
#
#
#
#
#


##
# function is_reachable
#	args: $1 - the hostname/IP to check
#
#	returns: 0 for success > 0 for failure
#
#	example: is_reachable atrcus113
#
function is_reachable
{
	${PING} -c 2 $1 >/dev/null 2>&1
}

##
# function rwall 
#       args: $1 - the hostname/IP to check
#	      $2 - $n the message to be sent
#
#	returns: 0 for success > 0 for failure
#
#       example: rwall atrcus113 some message to be sent to all users on atrcus113
#
#	additional information
#	      The message to be sent to the remote server does not need to be
#	      enclosed in quotes, as this function will pass the message as if
#             it had been quoted. However using quotes will in no way affect the
#             behaviour of the function.
function rwall
{
	REMOTEHOST=$1
	shift
	remote_command ${REMOTEHOST} root "echo \"$*\" | wall -a"
}
##
# function push_file
#       args: $1 - the hostname/IP of the remote system
#             $2 - the path to the local file to be sent
#	    [ $3 ] - the path to the file on the remote system
#
#       returns: 0 for success > 0 for failure
#
#       example: push_file atrcus113 /tmp/dummy	/netsim/dummy
#
#       additional information
#	      The path to the file on the remote system is optional
#             if omitted the remote file will be placed in the same
#             location on the remote system as the original file on
#             the local system.
#             Note: The files will be owned by root as SMS will
#             always run as root.
function push_file
{
	REMOTEHOST=$1
	LOCALFILE=$2
	REMOTEFILE=${3:-${LOCALFILE}}
	USER=${4:-root}
	${RCP} "${LOCALFILE}" "${USER}@${REMOTEHOST}:${REMOTEFILE}"
}

##
# function get_file
#       args: $1 - the hostname/IP of the remote system
#             $2 - the path to the remote file to be copied
#           [ $3 ] - the path to the file on the local system
#
#       returns: 0 for success > 0 for failure
#
#       example: get_file atrcus113 /tmp/dummy /netsim/dummy
#
#       additional information
#             The path to the file on the local system is optional
#             if omitted the local file will be placed in the same
#             location as the file on the remote system.
function get_file
{
	REMOTEHOST=$1
        REMOTEFILE=${2}
        LOCALFILE=${3:-${REMOTEFILE}}
	${RCP} "${REMOTEHOST}:${REMOTEFILE}" "${LOCALFILE}"
}


##
# function send_mail
#       args: $1 - email address of the recipient
#             $2 - The subject for the mail, should be quoted if more than one word
#             $3 - The body of the mail, a file which contains the body can be used
#		   Or the messages can be entered directly, quoted if more than one 
#                  word
#
#       returns: 0 for success > 0 for failure
#
#       example: send_mail hugh.ohare@ericsson.com "Test Message" /tmp/message.txt 
#	    or	 send_mail hugh.ohare@ericsson.com "Test Message" "This is a test Message"
#
function send_mail
{
	RECIPIENT=$1
	SUBJECT=${2:-TCM_SMS}
	BODY=$3
	if [[ -f "$BODY" ]]; then
		${MAIL} -s "${SUBJECT}" ${RECIPIENT} < ${BODY}
	else
		echo "$BODY" | ${MAIL} -s ${SUBJECT} ${RECIPIENT}
	fi
}

##
# function send_mail_attachment
#       args: $1 - email address of the recipient
#             $2 - The subject for the mail, should be quoted if more than one word
#             $3 - The body of the mail, a file which contains the body can be used
#                  Or the messages can be entered directly, quoted if more than one
#                  word
#             $4 - The file to attach
#
#       returns: 0 for success > 0 for failure
#
#       example: send_mail hugh.ohare@ericsson.com "Test Message" /tmp/message.txt /tmp/someLogFile.log
#           or   send_mail hugh.ohare@ericsson.com "Test Message" "This is a test Message" /tmp/someLogFile.log
#
function send_mail_attachment
{
        RECIPIENT=$1
        SUBJECT=$2
	ATTACHMENT=$4
	BODY=$3
	[[ -f $BODY ]] && BODYTXT=$(${CAT} ${BODY}) || BODYTXT=$BODY
	( echo "${BODYTXT}" ; ${UUENCODE} ${ATTACHMENT} ${ATTACHMENT} ) | ${MAIL} -s "${SUBJECT}" ${RECIPIENT} 
}

##
# function remote_command
#       args: $1 - IP/Hostname of the remote system
#             $2 - The username on the remote host
#          $3-$n - The command to run, it does not need to be quoted
#
#       returns: 0 for success > 0 for failure
#
#	example: remote_command atrcus113 root ls /tmp
#       
#       additional information:
#             quotes in the command, while not needed, are in no way harmful
#	
function remote_command
{
    set -x
    REMOTEHOST=$1
    REMOTE_USER=$2
    shift 2
    ${RSH} -n -l ${REMOTE_USER} ${REMOTEHOST} "$*"

}

##
# function remote_command
#       args: $1 - IP/Hostname of the remote system
#           [ $2 ] - The number of files to be found default is 10
#           [ $3 ] - The base directory default is /
#
#       returns: 0 for success > 0 for failure
#
#       example: get_large_files atrcus113 10 /tmp
#
#
function get_large_files
{
    REMOTEHOST=$1
    NUMFILES=${2:-10}
    STARTFROM=${3:-/}
    remote_command ${REMOTEHOST} root "find ${STARTFROM} -type f -ls" | \
	${AWK} '{print $7" "$11}' | \
	${SORT} -rn | ${HEAD} -${NUMFILES}
}

###############LOGGING FUNCTIONALITY######################
#   ERRORS and WARNINGS are sent to stderr and/or log file
#   MESSAGES are sent to stdout and/or log file
#
#   ENVIRONMENT VARIBALES:
#	LOGFILE: The full path to the logfile to be used
#                If defined output is sent to this file
#                AND/OR to the screen (see LOGTO)
#       LOGTO:   If set to FILE_ONLY then no output
#                is sent to the screen
#


##
# function log_error
#       args: $1 - SEVERITY
#             $2 - MESSAGE
#
function log_error
{

    SEVERITY=$1
    MESSAGE=$2
    if [[ ! -z $LOGFILE ]] ; then 
	printf "%-9s %-11s %s\n" "ERROR" "::$SEVERITY" "$MESSAGE" >> $LOGFILE  
    fi
    if [[ $LOGTO != "FILE_ONLY" ]] ; then
	printf "%-9s %-11s %s\n" "ERROR" "::$SEVERITY" "$MESSAGE" 1>&2 
    fi
}

##
# function log_warning
#       args: $1 - SEVERITY
#             $2 - MESSAGE
#
function log_warning
{

    SEVERITY=$1
    MESSAGE=$2
    if [[ ! -z $LOGFILE ]] ; then 
	printf "%-9s %-11s %s\n" "WARNING" "::$SEVERITY" "$MESSAGE" >> $LOGFILE
    fi
    if [[ $LOGTO != "FILE_ONLY" ]] ; then
	printf "%-9s %-11s %s\n" "WARNING" "::$SEVERITY" "$MESSAGE" 1>&2
    fi
}

##
# function log_message
#       args: $1 - MESSAGE
#
function log_message
{

    MESSAGE=$1
    if [[ ! -z $LOGFILE ]] ;then
	printf "%-9s %-11s %s\n" "MESSAGE" "::" "$MESSAGE" >> $LOGFILE
    fi
    if [[ $LOGTO != "FILE_ONLY" ]] ; then
	printf "%-9s %-11s %s\n" "MESSAGE" "::" "$MESSAGE"
    fi
}

##
# function new_log
#	create a new log file, and move the old one to ${LOGFILE}.bck
#       args: - none
#
function new_log
{
    ${MV} -f $LOGFILE ${LOGFILE}.bck 2>&1
    ${TOUCH} $LOGFILE
}


#
#
#  TESTS FOR THE VARIOUS FUNCTIONS
#
#
function test 
{
    . /export/sms/dev/etc/commands.lib.Linux
    new_log
    log_message "Test Message"
    log_error BASIC "Test Error"
    log_warning WARN "Test Warning"
    remote_command atrcus113 root ls
    get_large_files atrcus113 5 /var/tmp
}
    

#test
