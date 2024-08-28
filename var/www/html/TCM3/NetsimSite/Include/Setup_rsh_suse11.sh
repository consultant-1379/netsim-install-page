#!/bin/bash

. /net/attemjump220/export/tep/expect_functions
#Script to config RSH on netsim machines via web interface
USERNAME=$1
PASSWORD=$2
HOSTNAME=$3

ping -c1 -w2 $HOSTNAME > /dev/null 2>&1
if [[ $? -ne 0 ]]
then
	echo "Machine unpingable, exiting rsh setup"
        exit 1
fi

/usr/bin/rsh -l root -n $HOSTNAME "id"  > /dev/null 2>&1;

if [[ $? -eq 0 ]]
then
	echo "Rsh already setup on $HOSTNAME"
 #       exit 1
fi









$EXPECT - <<EOF
set force_conservative 1
set timeout 5

# autologin variables
set prompt ".*(%|#|\\$|>):? $"



# set login variables before attempting to login
set loggedin "0"
set entered_password "0"
set exited_unexpectedly "0"
set timedout_unexpectedly "0"

        spawn rsh -l root $HOSTNAME
        expect {
                "Password:" {
                        send "$PASSWORD\r"
                        set entered_password "1"
                        exp_continue -continue_timer
                }
                "~ #"  {
                        set loggedin "1"
                }
                timeout {
                        set timedout_unexpectedly "1"
                }
                eof {
                        set exited_unexpectedly "1"
                }
        }
        if {\$loggedin == "1"} {
                send "echo \"+ +\" >> /root/.rhosts;echo \"+ +\" > /.rhosts;mv /etc/pam.d/rlogin /etc/pam.d/rlogin.backup;mv /etc/pam.d/rsh /etc/pam.d/rsh.backup;wget -nc http://atrclin2.athtem.eei.ericsson.se/TCM3/NetsimSite/Include/rlogin.suse11 -P/etc/pam.d/;/etc/pam.d/rsh; mv /etc/pam.d/rlogin.suse11 /etc/pam.d/rlogin;wget -nc http://atrclin2.athtem.eei.ericsson.se/TCM3/NetsimSite/Include/rsh.suse11 -P/etc/pam.d/;mv /etc/pam.d/rsh.suse11 /etc/pam.d/rsh;service xinetd restart\r"
                expect -re \$prompt
        } else {
                send_user "Something went wrong rshing"
                exit 1
        }
EOF

/usr/bin/rsh -l root -n $HOSTNAME "ls"  > /dev/null 2>&1;

if [[ $? -eq 0 ]]
then
	echo "Finished setting up rsh on $HOSTNAME"
	exit 0;
else
	echo "Encountered a problem setting up rsh on $HOSTNAME"
	exit 1;
fi
