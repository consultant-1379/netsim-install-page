#/bin/bash

MACHINE=$1
PASS=$2
COMMAND=$3
ssh-keygen -R "$MACHINE" >/dev/null 2>&1
. /net/attemjump220/export/tep/expect_functions
$EXPECT - <<EOF
        set timeout 20 
	#set prompt ".*(%|#|\\$|>):? $"
	set prompt ".*(%|#|\\$|>)  *:? $"
        # set login variables before attempting to login
        set loggedin "0"
        set entered_password "0"
        set exited_unexpectedly "0"
        set timedout_unexpectedly "0"

        spawn ssh -l root $MACHINE
                        expect {
				"Are you sure" {
                		        send "yes\r"
 		                       exp_continue -continue_timer
                		}
                               "Password:" {
                                        send "$PASS\r"
                                        set entered_password "1"
                                        exp_continue -continue_timer
                                }
				"Login incorrect" {
				}
                                -re \$prompt {
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
		set timeout -1
		
                send "$COMMAND;exit\r"
                expect eof {}
        } else {
                send_user "\nERROR: Failed to auto login.\n"
                exit 1
        }

EOF
