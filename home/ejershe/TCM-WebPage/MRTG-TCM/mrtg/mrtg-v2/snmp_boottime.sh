#!/bin/bash
# Created by Mark Kennedy, July 2008
# A script to add snmp daemon to the startup scripts on netsim machines
# Adds an entry to the /etc/rc.d/boot.local file

if [[ $# -ne 1 ]]
then
	echo "Usage $0 hostname"
fi

HOSTNAME=$1

# First checking if this machine is reachable, if not we cannot add the entry in the boot file
        /home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/functions/check_ping.sh $HOSTNAME
        if [ $? -ne 0 ]
        then
                echo "$HOSTNAME unreachable"
        else
		/var/www/html/TCM3/OSSInstall/scripts/rsh_command_with_pass.sh $HOSTNAME dummy hostname
                #/home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/functions/check_rsh.sh $HOSTNAME
                if [ $? -ne 0 ]
                then
                        echo "Could not rsh to $HOSTNAME"
                else


                        # First we check if the entry already exists in the /etc/rc.d/boot.local file
                        # If not we add it

                        boot_entry_exists=`/usr/bin/rsh -l root -n $HOSTNAME "grep \"/usr/sbin/snmpd -c /etc/snmpd.conf -r -A -Lf /var/log/net-snmpd.log -p /var/run/snmpd.pid &\" /etc/rc.d/boot.local"`
                        if [[ $boot_entry_exists == '' ]]
                        then
                                echo "No boot entry for $HOSTNAME, adding now"
                                /usr/bin/rsh -l root -n $HOSTNAME "echo \"/usr/sbin/snmpd -c /etc/snmpd.conf -r -A -Lf /var/log/net-snmpd.log -p /var/run/snmpd.pid &\" >> /etc/rc.d/boot.local"
                        fi
                fi
        fi
