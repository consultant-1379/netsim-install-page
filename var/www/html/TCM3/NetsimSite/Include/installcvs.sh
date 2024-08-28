#!/bin/bash

HOME="/var/www/html/TCM3/NetsimSite"
if [[ $# -ne 1 ]]
then
        echo "Usage: $0 hostname"
        exit 1
fi

HOSTNAME=$1

echo "Checking rsh..."
/usr/bin/rsh -l root -n $HOSTNAME ""  > /dev/null 2>&1;

if [[ $? -ne 0 ]]
then
	echo "ERROR: Could not rsh to machine, exiting setup"
        exit 1
else
	echo "Working Fine"
fi

echo -n "Checking for current installations..."

returned=`/usr/bin/rsh -l root -n $HOSTNAME "rpm -q cvs" 2>/dev/null | grep package`;
if [[ "$returned" != "package cvs is not installed" ]]
then
	echo "ERROR: CVS Already Installed - $returned"
	exit 1
else
	echo "None"
fi

echo -n "Copying package to machine..."
rcp $HOME/CVS/cvs-1.11.18-cvshome.org.9x.1.i386.rpm root@$HOSTNAME:/tmp/cvs-1.11.18-cvshome.org.9x.1.i386.rpm
if [[ $? -ne 0 ]]
then
	echo "Error ftping the cvs file onto the netsim"
	exit 1
fi
echo "Done"

echo -n "Installing CVS.."
/usr/bin/rsh -l root -n $HOSTNAME "rpm -i /tmp/cvs-1.11.18-cvshome.org.9x.1.i386.rpm --nodeps"
echo "Done"

echo -n "Cleaning up temporary files..."
/usr/bin/rsh -l root -n $HOSTNAME "rm -rf /tmp/cvs-1.11.18-cvshome.org.9x.1.i386.rpm"
echo "Done"

returned=`/usr/bin/rsh -l root -n $HOSTNAME "rpm -q cvs" 2>/dev/null`;
if [[ "$returned" != "package cvs is not installed" ]]
then
        echo "Installed completed successfully: $returned"
	exit 0
else
	echo "ERROR: Installation did not complete successfully!"
	exit 1
fi

