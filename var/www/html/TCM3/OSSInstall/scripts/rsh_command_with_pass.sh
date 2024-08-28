#/bin/bash

MACHINE=$1
PASS=$2
COMMAND=$3
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

        spawn rsh -l root $MACHINE
                        expect {
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
        if {\$loggedin == "0"} {
		set timeout -1
		
                send "$COMMAND;exit\r"
                expect eof {}
        } else {
                send_user "\nERROR: Failed to auto login.\n"
                exit 1
        }

EOF
