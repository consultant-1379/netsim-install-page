#/bin/bash 
# Created by Mark Kennedy, June 2008
#This script takes a machine name as argument, and tries to check if snmp is running correctly. If not it attempts to fix this.

# Arguments
# If -showoutput is given as a second argument, the script echos output to screen, not into the log
# If -showexitcode is given as a second argument, the script echos out the following error codes for use in php scripts
#	0 : snmp seems to be working fine
#	1 : snmpwalk failed, even after attempted fix
#	2 : Cannot ping the machine, it may be down
#	3 : Cannot rsh to machine to attempt fix
#	4 : Machine not found in mrtg database

# Logging
# By default a temporary log file (.temp_log.$HOSTNAME) is used to store output from this script (if any).
# The ERROR_FOUND variable is set to 1 at various places in the script if anything needs to be logged, e.g. an error. 
# At the end of the script, the contents of the temporary log file are sent to the log.mrtg file if errors were found.

HOSTNAME=$1
SECOND=$2
ERROR_FOUND=0
EXIT_CODE=0
export TERM=xterm

if [ $# -lt 1 -o $# -gt 2 ]
then
	echo -e 1>&2 "Usage: $0 hostname\nor\nUsage: $0 hostname -showoutput"
	exit 1
fi

# This is the name of the temporary log file for this machine as it is being checked
temp_log="/home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/.temp_log.$HOSTNAME"

# This is the temporary log file that is used to hold all temporary machine logs before possible addition to the final log
temp_log_complete="/home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/.temp_log.mrtg"

# Functions

check_invalid_machine()
{
	# This function checks to see if the machine is listed in mrtg database
	output=`mysql -s -s -e "use mrtg;select Name from netsimlin where Name='$HOSTNAME'"`
	if [[ "$output" == '' ]]
	then
	        echo -e "ERROR:\tMachine not found in mrtg database" >> $temp_log
        	return 1
	fi

}

check_pingable()
{
	# This function checks to see if a machine is pingable, if not we cannot check for other problems
	/home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/functions/check_ping.sh $HOSTNAME

	if [ $? -ne 0 ]
	then
	        echo -e "ERROR:\tCould not ping machine" >> $temp_log
        	return 1
	fi
	
}

check_rshable()
{
	# Must change this when auto login in rsh works
#	if [[ ! `echo $HOSTNAME | grep lin` ]]
#	then
#		return 1
#	fi
	output="`/var/www/html/TCM3/OSSInstall/scripts/rsh_command_with_pass.sh $HOSTNAME dummy hostname`"
	#/home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/functions/check_rsh.sh $HOSTNAME
        if [[ $? -ne 0 ]]
        then
                echo -e "ERROR:\trsh attempt failed, when checking rshable" >> $temp_log
		echo "$output" >> $temp_log
                return 1
        fi
}

check_snmp_process()
{
        # This function checks to see if the snmp process is running on the machine
	# If so the process is killed
	# The process is started at the end of the function regardless

        snmp_process_id=`/usr/bin/rsh -l root -n $HOSTNAME "ps -ef  | grep snmpd | grep -v grep" | awk '{print \$2}'`;

        if [[ "$snmp_process_id" != '' ]]
        then
                echo -e "INFO:\tShutting down snmp process">> $temp_log
                /usr/bin/rsh -l root -n $HOSTNAME "kill -9 $snmp_process_id"
        else
                echo -e "ERROR:\tsnmp process is not running" >> $temp_log
        fi

        echo -e "INFO:\tStarting snmp service" >> $temp_log
 #       /usr/bin/rsh -l root -n $HOSTNAME "`which snmpd` -c /etc/snmpd.conf -r -A -Lf /var/log/net-snmpd.log -p /var/run/snmpd.pid > /dev/null 2>&1" > /dev/null 2>&1
	/usr/bin/rsh -l root -n $HOSTNAME "/usr/sbin/snmpd -c /etc/snmpd.conf -r -A -Lf /var/log/net-snmpd.log -p /var/run/snmpd.pid > /dev/null 2>&1" > /dev/null 2>&1
	sleep 10
}

check_conf_file()
{
	# This function checks to see if the snmpd configuration file /etc/snmpd.conf exists on the host
	# If found it is checked against a working copy
	# If not, a working copy is copied to the machine

        snmpd_conf_exists=`/usr/bin/rsh -l root -n $HOSTNAME "if [ -f /etc/snmpd.conf ]; then echo exists;else echo not; fi"`;


	# If the file doesn't exist we report it missing and copy over the working copy
	if [[ $? -eq 0 ]]
	then
		if [[ "$snmpd_conf_exists" == 'not' ]]
		then
			echo -e "ERROR:\t/etc/snmpd.conf file missing" >> $temp_log
			rcp /var/www/html/TCM/MRTG-TCM/mrtg/snmpd-Works.conf root@$HOSTNAME:/etc/snmpd.conf 2> /dev/null
			echo -e "INFO:\tCreated /etc/snmpd.conf from working example" >> $temp_log
		elif [[ "$snmpd_conf_exists" == 'exists' ]]
		then

			# The file exists so we must check it against the working copy
			rcp /var/www/html/TCM/MRTG-TCM/mrtg/snmpd-Works.conf root@$HOSTNAME:/etc/snmpd-Works.conf 2> /dev/null
			snmpd_conf_comparison=`/usr/bin/rsh -l root -n $HOSTNAME "cmp /etc/snmpd-Works.conf /etc/snmpd.conf"`

			if [[ $? -eq 0 ]]
			then
			# If the file on the machine does not match the working copy, we replace it with the working copy.
				if [[ "$snmpd_conf_comparison" != '' ]]
				then
					echo -e "ERROR:\t/etc/snmpd.conf did not match working example" >> $temp_log
					echo -e "DIFFERENCE:\t$snmpd_conf_comparison" >> $temp_log
					rcp /var/www/html/TCM/MRTG-TCM/mrtg/snmpd-Works.conf root@$HOSTNAME:/etc/snmpd.conf 2> /dev/null
					echo -e "INFO:\tCreated new /etc/snmpd.conf from working example" >> $temp_log
				fi
			else
				echo -e "ERROR:\trsh attempt failed, when comparing snmp.conf files" >> $temp_log
			fi
		fi
	else
		echo -e "ERROR:\trsh attempt failed, when checking snmp.conf file" >> $temp_log
	fi
}

check_snmpwalk_output()
{
	# Trying an snmpwalk on the machine to see if snmp is working. If it is not working we return an error code 1
	snmpwalk_output=`/usr/bin/snmpwalk $HOSTNAME -c public -v 2c 2>/dev/null | head -n 1`

	if [[ "$snmpwalk_output" == '' ]]
	then
		return 1
	else
		return 0
	fi
}

check_snmp_boottime()
{
	/home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/snmp_boottime.sh $HOSTNAME
}

exit_script()
{
	# If we found errors throughout the running of the script that merit logging,
	# the temporary log file is cat into the permanent one
	
	if [[ ERROR_FOUND -eq 1 ]]
	then
		echo "" >> $temp_log
	       	cat $temp_log >> $temp_log_complete
               #cat $temp_log
	fi
	
	if [[ "$SECOND" == "-showoutput" ]]
        then
		cat $temp_log
	fi

	# Finally remove the temporary log file
	rm $temp_log

	if [[ "$SECOND" == "-showexitcode" ]]
	then
		echo $EXIT_CODE
	fi
	exit $EXIT_CODE
}

# This is the begging of the main workings of the code


# This is the heading of the temporary log file for this machine
echo -e "\t-----------------------" > $temp_log
echo -e "\t$HOSTNAME: snmp status log" >> $temp_log
echo -e "\t-----------------------" >> $temp_log



# exit if invalid machine

check_invalid_machine
if [[ $? -ne 0 ]]
then
	EXIT_CODE=4
	ERROR_FOUND=1
	exit_script
fi



# exit if machine unpingable

check_pingable
if [[ $? -ne 0 ]]
then
	EXIT_CODE=2
	ERROR_FOUND=1
	exit_script
fi



# Trying an snmpwalk on the machine
check_snmp_boottime
check_snmpwalk_output
# If there was no output from snmpwalk we run through the checks, checking the /etc/snmpd.conf file, then checking the snmp process
# Finally another snmpwalk is performed to check if what we have changed has fixed the problem or not

if [[ $? -ne 0 ]]
then
	ERROR_FOUND=1
        echo -e "ERROR:\tsnmpwalk failed" >> $temp_log
	
	check_rshable
	if [[ $? -ne 0 ]]
	then
		EXIT_CODE=3
	        ERROR_FOUND=1
        	exit_script
	fi

        check_conf_file
        check_snmp_process
	check_snmpwalk_output	# check snmpwalk output after changes to see if it helped
	if [[ $? -eq 1 ]]
	then
		echo -e "ERROR:\tsnmpwak failed after attempted fix" >> $temp_log
		EXIT_CODE=1
	else
		echo -e "INFO:\tsnmpwalk working after fix" >> $temp_log
		EXIT_CODE=0
	fi
else
	if [[ "$SECOND" == "-showoutput" ]]
	then
		echo "snmpwalk working fine.." >> $temp_log
		EXIT_CODE=0
	fi

fi

exit_script
