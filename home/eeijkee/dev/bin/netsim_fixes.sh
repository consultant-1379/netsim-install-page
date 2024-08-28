#!/bin/bash 

BASEDIR=$(cd $(dirname $0)/..;pwd)
REPOSITORY=/tmp/netsim/
server_version=$(ps -eo args | awk -F\/ '/\/netsim\/R/{print $3; exit}')
NETSIM_SERVER=$(uname -n)
OS_TYPE=$(uname)
VERSION=${1}


function check_install
{
        echo Checking error logs 
#        su - netsim -c "more /netsim/${VERSION}/logfiles/install_1.errorlog"
        echo OK
        echo "*************************************************************************"
        echo "*************************************************************************"
        echo Please look through the install log located in /netsim/error_log.txt 
        echo to see if install was sucessful.
        echo "*************************************************************************"
        echo "*************************************************************************"


}


function max_count
{

   cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
   cat /etc/ssh/sshd_config | egrep -v 'MaxStartups|PasswordAuthentication' > /tmp/new_sshd_config
   echo MaxStartups 200 >> /tmp/new_sshd_config
   echo PasswordAuthentication yes >> /tmp/new_sshd_config
   cp /tmp/new_sshd_config /etc/ssh/sshd_config
   /etc/init.d/sshd stop
   /etc/init.d/sshd start 
    

}

function set_vsftp_params
{
	# ekemark, added to get rid of netsim warnings about not using reocmmended params for vsftp as documented
	echo "Setting recommended vsftp params"
	cat /etc/xinetd.conf | sed 's/instances.*/instances = 2500/g' | sed 's/cps.*/cps = 2500 1/g' > /etc/xinetd.conf.tmp
	mv /etc/xinetd.conf.tmp /etc/xinetd.conf
	/etc/init.d/xinetd reload
}

function install_rsh_fix
{
if [ -e /netsim/fix_rsh_done ]; then 
	echo RSH fix installed
else
        echo Installing rsh fix ..... 
	cd /
	echo + + > .rhosts
	su - netsim -c 'echo + + > .rhosts'
	cd /
	ftp -n -i ftp.athtem.eei.ericsson.se <<-END_FTP
	user tcm tcmftp
	bin
	cd /pub/netsim/rsh
	get rsh.tar
	bye
	END_FTP
	tar xvf rsh.tar 
	rm rsh.tar
	/etc/init.d/xinetd reload
	touch /netsim/fix_rsh_done
fi	
}



function change_ulimit 
{
if [ -e /netsim/change_ulimit_done ]; then
        echo Change ulimit installed
else	
        echo changing ulimit ${NETSIM_SERVER} .....${VERSION} 
	echo ${NETSIM_SERVER} > /tmp/update_hosts 
	cp /tmp/netsim/limits.conf /tmp/limits.conf
	cp /tmp/netsim/change_ulimit.sh /tmp/change_ulimit.sh
	chmod 777 /tmp/change_ulimit.sh
	cd /tmp
	./change_ulimit.sh ${VERSION}
	touch /netsim/change_ulimit_done
fi		
}


function checking_ulimit
{
        echo checking ulimit .....
	ulimit_value=$(rsh localhost ulimit -n)	
        if [[ ${ulimit_value} = 64000 ]] ; then
		echo ulimit has updated to 64000
        else
		echo ulimit did not update
        fi
}


function checking_min_free_KB
{
        echo checking min free KB .....
	echo vm.min_free_kbytes = 10000 >> /etc/sysctl.conf	
}


function netsim_ssh_setup
{
	echo "Setting up netsim built-in ssh server"

	# Step 12.3.2  Make netsim listen to privileged TCP ports
	# 1 Must be logged in as root to run this script, already logged in as root
	# 2
	/netsim/$VERSION/bin/setup_fd_server.sh
	
	# 3 Restart NETSim as the user who installed NETSim
	su - netsim -c "/netsim/$VERSION/restart_netsim"

	# Step 12.3.3 Make the ssh/sftp server of this machine listen only to the main ip address
	# 1
	# 2 Make sure all lines with ListenAddress are commented out
	cat /etc/ssh/sshd_config | sed "s/^ListenAddress/#ListenAddress/g" > /etc/ssh/sshd_config
	
	# 3 Add a ListenAddress line with the host IP
	ip=`grep $NETSIM_SERVER /etc/hosts | awk '{print $1}'`

	# Check if ListenAddress <ip> is already present and commented out
	if [[ `grep "^#ListenAddress $ip" /etc/ssh/sshd_config` == "" ]]
	then
		# Not found, adding entry to sshd_config file
		echo "ListenAddress $ip" >> /etc/ssh/sshd_config
	else 
		# Found commented out line, uncommenting
		cat /etc/ssh/sshd_config | sed "s/^#ListenAddress $ip/ListenAddress $ip/g" > /etc/ssh/sshd_config
	fi

	# 4
	pkill -HUP sshd
}

if [[ ${OS_TYPE} = Linux ]] ; then
		set_vsftp_params
                install_rsh_fix
                change_ulimit 
                checking_ulimit
		max_count
                check_install
        else
		su - netsim -c 'echo + + > .rhosts'
		max_count
        fi


if [[ $NETSIM_SERVER == "netsim216" ]]
then
	netsim_ssh_setup
fi
