#!/bin/bash 


function check_netsim_user
{
        echo Checking netsim_user
        if [[ -f /netsim ]] ; then
                echo Done
                return 2
        else
		groupadd netsim
		mkdir /netsim
		useradd -d /netsim -g netsim netsim
		chown netsim:netsim /netsim
        fi

}

check_netsim_user
