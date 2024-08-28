#!/bin/bash

#Author:ejershe
#Date:Feb 2008
#Description: Install snmp on all netsimlin machine and edit the conf file

#DOwnload snmp Package from atrclin2
echo "Installing net-snmp for MRTG Monitor"
HOSTNAME=$1
cd /

rcp /var/www/html/TCM/MRTG-TCM/net-snmp-5.5.tar.gz root@$HOSTNAME:/tmp/net-snmp-5.5.tar.gz 2> /dev/null
rcp /var/www/html/TCM/MRTG-TCM/mrtg/snmpd-Works.conf root@$HOSTNAME:/etc/snmpd.conf 2> /dev/null
/usr/bin/rsh -l root $HOSTNAME "cd /tmp; /usr/bin/gunzip -d net-snmp-5.5.tar.gz; /bin/tar -xf net-snmp-5.5.tar"

/usr/bin/rsh -l root $HOSTNAME "cd /tmp/net-snmp-5.5;./configure --prefix=/usr/local --bindir=/usr/local/sbin --with-defaults ;make;make install"

/usr/bin/rsh -l root $HOSTNAME "/usr/local/sbin/snmpd -c /etc/snmpd.conf -r -A -Lf /var/log/net-snmpd.log -p /var/run/snmpd.pid &"
/usr/bin/rsh -l root $HOSTNAME "/usr/sbin/snmpd -c /etc/snmpd.conf -r -A -Lf /var/log/net-snmpd.log -p /var/run/snmpd.pid &"



