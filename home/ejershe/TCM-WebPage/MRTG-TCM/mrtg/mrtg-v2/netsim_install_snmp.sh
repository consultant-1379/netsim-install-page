#!/bin/bash
# Created by Mark Kennedy, June 2008
# This script sets up mrtg settings on atrclin2 and snmp installation on a netsim machine for monitoring

MRTG2_DIR=/home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2

# Command line input checking

if [ $# -ne 2 ]
then
        echo -e 1>&2 "Usage: $0 hostname email"
        exit 1
fi

HOSTNAME=$1
EMAIL=$2

lockfile=/tmp/.mrtg_lock
TRY_NO=1
TRY_ACQUIRE_LOCK=20
DONE=0
SPECIAL="_+_+_+"
PROMPTS_ALLOWED=20

# Functions

check_database()
{
        # This function checks to see if the machine is already listed in mrtg database

	output=`mysql -s -s -e "use mrtg;SELECT Name from netsimlin where Name='$HOSTNAME'"`
	if [[ "$output" != '' ]]
	then
		return 0
	else
		return 1
	fi
}

check_ping()
{
	`$MRTG2_DIR/functions/check_ping.sh $HOSTNAME`
	if [ $? -ne 0 ]
	then
		return 1
	fi
}

check_rsh()
{
 #       `$MRTG2_DIR/functions/check_rsh.sh $HOSTNAME`
	/var/www/html/TCM3/OSSInstall/scripts/rsh_command_with_pass.sh $HOSTNAME dummy hostname
        if [ $? -ne 0 ]
        then
                return 1
        fi
}

check_rsh_with_login()
{
	`$MRTG2_DIR/functions/check_rsh_with_login.sh $HOSTNAME $PASSWORD`
        if [ $? -ne 0 ]
        then
                return 1
        fi
}

# This is the beginning of the main part of the script

# check for "lin" in name?

while [[ $DONE -ne 1 && $TRY_NO -lt $TRY_ACQUIRE_LOCK ]]
do
        if ( set -C; echo "$$" > "$lockfile") 2> /dev/null;
        then
                trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
echo "Acquired lockfile. Starting installation"
echo -n "Checking for machine entry in mrtg database.."
check_database

# If the machine is not present in mrtg database, add it

if [[ $? -ne 0 ]]
then
		echo "not found, adding.."

                # get generation

                generation=`mysql -s -e "use suse_netsimlin;SELECT generation from suse_netsimlin where hostname='$HOSTNAME'"`
                if [[ "$generation" == '' ]]
                then
                        generation=1
                fi

                # add to database

                mysql -s -e "use mrtg;INSERT INTO netsimlin (Id, Name, OS, email, generation) VALUES ( '', '$HOSTNAME', 'Linux', '$EMAIL', '$generation' )";
                echo "Added to mrtg database"
		echo "Creating new mrtg cfg file, please wait.."
		/var/www/html/TCM/MRTG-TCM/mrtg/makeCfg /data/stats/netsim/netsim-cfg.cfg
		echo "Created new mrtg cfg file"
else
	echo "OK"
fi


check_ping

# If the machine is unpingable we do not proceed any further

if [[ $? -ne 0 ]]
then
	echo "Could not ping machine, cannot continue"
	exit 1
fi

if [ $# -eq 2 ]
then
	check_rsh
else
	#check_rsh_with_login
	:
fi


# If rsh doesn't work on the machine, we exit the script

if [[ $? -ne 0 ]]
then
	echo "Could not rsh to machine, cannot continue"
	exit 1
fi

# check if snmp already exists on machine, rsh might not work on password protected machine

echo -n "Checking snmp installation.."
#result=`/usr/bin/rsh -l root -n $HOSTNAME "if [ \"\`which snmpd | grep snmpd\$\`\" != \"\" ]; then echo \"Exists\"; fi"`
result=`/usr/bin/rsh -l root -n $HOSTNAME "if [ -f /usr/sbin/snmpd ]; then echo \"Exists\"; fi"`
if [[ "$result" == "Exists" ]]
then
        echo "OK"
else
        echo "installing now, please wait.."
        /home/eeijkee/dev/bin/mrtg-install.sh $HOSTNAME
	echo "Done installing snmp"
fi

# Make snmp service start when machine boots up

echo -n "Making sure snmp service starts at boot time.."
/home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/snmp_boottime.sh $HOSTNAME
echo "done"

echo "Checking snmp status for $HOSTNAME please wait.."
# Run snmp checker status_snmp.sh
/home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/status_snmp.sh $HOSTNAME -showoutput

                rm -f "$lockfile"
                trap - INT TERM EXIT
                set +C
                DONE=1
		exit 0
        else
                # Could not acquire lock, incrementing try number and sleeping
		echo "Waiting to get lockfile.. $lockfile"
                TRY_NO=$(( $TRY_NO+1 ))
                sleep 5
        fi
done

echo -n "1,Could not acquire lockfile after $TRY_ACQUIRE_LOCK attempts"
