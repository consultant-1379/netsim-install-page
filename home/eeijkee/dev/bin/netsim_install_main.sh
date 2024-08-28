#!/bin/bash 

BASEDIR=$(cd $(dirname $0)/..;pwd)
REPOSITORY=/tmp/netsim/
server_version=$(ps -eo args | awk -F\/ '/\/netsim\/R/{print $3; exit}')
NETSIM_SERVER=$(uname -n)
OS_TYPE=$(uname)
VERSION=${1}
email=${2}
PATH=/netsim/${VERSION}/bin:$PATH


function mount_server 
{
	if [ -d /tmp/netsim ] ; then
		echo /tmp/netsim already exists 
	else
		mkdir /tmp/netsim
	fi
        if [ -d /tmp/netsim/R* ] ; then
		echo already mounted 
		return 2
	else
        	if [[ ${OS_TYPE} = Linux ]] ; then 
       			mount -t nfs atrclin2:/export/sms/netsim /tmp/netsim
        	else
	        	mount -f nfs -o vers=2 atrclin2:/export/sms/netsim /tmp/netsim
        	fi
	fi

}


function mount_info_server
{
        if [ -d /tmp/netsim_info ] ; then
                echo /tmp/netsim_info already exists
        else
                mkdir /tmp/netsim_info
        fi
        if [ -d /tmp/netsim_info/net* ] ; then
                echo netsim_info already mounted
                return 2
        else
                if [[ ${OS_TYPE} = Linux ]] ; then
                        mount -t nfs atrclin2:/export/netsim_info /tmp/netsim_info
                fi
        fi

}




function umount_server
{
	echo unmounting /tmp/netsim 
	cd /netsim
	#/netsim/${VERSION}/bin/relay start
        /netsim/${VERSION}/bin/relay restart
        umount /tmp/netsim
}




function umount_info_server
{
        echo unmounting /tmp/netsim_info
        umount /tmp/netsim_info > /dev/null

	#Change password for netsim
	echo "Changing netsim password to netsim..."

	hostname=`hostname`
	password="netsim"

	if [[ $hostname == netsimlin* ]]
	then
		echo "This is an Linux machine."
		autopasswd 'netsim' netsim
	else
        	echo "This is an Unix machine."
		autopasswd 'netsim' netsim

	fi
}




function check_user
{
	if [[ $(id | sed 's/.*[(]\(.*\)[)].*[)]/\1/g') != "root" ]] ; then
		echo "This script can only be run as the user \"root\""function mount_server
{
        if [ -d /tmp/netsim ] ; then
                echo /tmp/netsim already exists
        else
                mkdir /tmp/netsim
        fi
        if [ -d /tmp/netsim/R* ] ; then
                echo already mounted
                return 2
        else
                if [[ ${OS_TYPE} = Linux ]] ; then
                        mount -t nfs atrclin2:/export/sms/netsim /tmp/netsim
                else
                        mount -f nfs -o vers=2 atrclin2:/export/sms/netsim /tmp/netsim
                fi
        fi

}

		exit 3
	fi
}


function check_server
{
	if [[ ${server_version} = R* ]] ; then	 
		echo "There is a NETSIM Server running"
		echo "Stopping NETSIM Server"
		su - netsim -c "/netsim/${server_version}/stop_netsim"
	else	
		echo "There is no NETSIM Server running"
		return 2
	fi

}


function check_symbolic_link
{
        echo Checking symboilc links 
	cd /usr/lib
	if [[ -f /usr/lib/libcrypto.so.4 ]] ; then
		echo Done
		return 2
	else	
		ln -s libcrypto.so.0.9.7 libcrypto.so.4
		ln -s libssl.so.0.9.7 libssl.so.4
	fi

}



function install_netsim_fix 
{
        echo Installing netsim fix ..... 
	echo the version is ${VERSION}
	if [[ ${VERSION} = R10A ]] ; then
		su - netsim -c "zcat /netsim/${VERSION}/netsim-* | tar xfvp -"
		su - netsim -c Install
	else	
		echo Done
		return 2
	fi
}


function install
{

        echo Netsim ${OS_TYPE} box ${NETSIM_SERVER} about to be installed with ${VERSION}

        if [[ ! -d ${REPOSITORY}/${VERSION} ]] ; then
                echo ${REPOSITORY}/${VERSION} does not exist.
                return 2
        fi



	if [[ ! -d /netsim/${VERSION} ]] ; then
		su netsim -c "mkdir /netsim/${VERSION}"
	else
		echo /netsim/${VERSION} already exists.
		return 2
	fi


	cp ${REPOSITORY}/${VERSION}/* /netsim/${VERSION}
        if [[ `echo "${VERSION}" | grep "R25"` ]]
        then
                cp ${REPOSITORY}/license/6.5_license/* /netsim/${VERSION}
       
	elif [[ `echo "${VERSION}" | grep "R23"` ]]
	then
		cp ${REPOSITORY}/license/6.3_license/* /netsim/${VERSION}
	
	elif [[ `echo "${VERSION}" | grep "R22"` ]] 
	then

		cp ${REPOSITORY}/license/6.2_license/* /netsim/${VERSION}
	
 	else [[ `echo "${VERSION}" | grep "R24"` ]]	
		cp ${REPOSITORY}/license/6.4_license/* /netsim/${VERSION}
	fi	

	cd /netsim/${VERSION}
	chmod +x Unbundle.sh
	install_netsim_fix 
	echo starting unbundle...........	
	su - netsim -c "cd /netsim/${VERSION}; ./Unbundle.sh quick AUTO"
	/netsim/${VERSION}/bin/create_init.sh -a
	/netsim/netsim_fixes.sh ${VERSION}
	su netsim -c "mkdir /netsim/${VERSION}/PATCHES"
        cp ${REPOSITORY}/${VERSION}/PATCHES/* /netsim/${VERSION}/PATCHES
	umount_server 

}

mount_server 
mount_info_server
check_user
check_server
check_symbolic_link
install
#sleep 300
sleep 30
if [[ ${OS_TYPE} = Linux ]] ; then
	mount -t nfs atrclin2:/export/netsim_info /tmp/netsim_info
        echo "${email}" > /tmp/netsim_info/${NETSIM_SERVER}
        echo stage2 "${email} and  ${NETSIM_SERVER}"
else
	echo "${email}" > /net/atrclin2/export/netsim_info/${NETSIM_SERVER}
	echo stage2 "${email} and  ${NETSIM_SERVER}"
fi
umount_info_server
reboot










