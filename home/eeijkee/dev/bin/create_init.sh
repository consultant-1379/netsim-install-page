#!/bin/sh
# Creates an init scripts out of some questions
# FIXME: All permission checks is done with current user, not the user who is supposed start NETSim
# Recommention: Run the script by the NETSim user

# if the script is given the argument -a or --auto the init-script will 
# automaticly created 

if [ "$1" = "-a" -o "$1" = "--auto" ] ; then
     USER="netsim"
     USERHOME=`/bin/csh -c "echo ~$USER"`
     NETSIMPATH=`ls -1dr $USERHOME/R??? 2>/dev/null | head -1`
     RELAY="false"
     PATCHPATH="${NETSIMPATH}/PATCHES"
     RCPATH="/etc/init.d/netsim"
     SYMBPATH="/etc/init.d/rc3.d/S99netsim"
#     RCPATH="/home/ehorcar/netsim"
#     SYMBPATH="/home/ehorcar/S99netsim"
else    
    printf "As which user should netsim be started? [`logname`]\n"
    read USER
    if [ "$USER" = "" ] ; then
	USER=`logname`
    fi
    printf "NETSim will be started by user: $USER\n\n"
    
# Gets users home dir
    USERHOME=`/bin/csh -c "echo ~$USER"`
    
# set NETSIMDIR if it not exists, which default is ~/netsimdir/
    NETSIMDIR=${NETSIMDIR-$USERHOME/netsimdir/}
    
    printf "Where is NETSim installed? [${USERHOME:-/home/netsim}/inst]\n"
    OK="false"
    while [ "$OK" = "false" ]; do
	read NETSIMPATH
        # default value
	if [ "$NETSIMPATH" = "" ] ; then
	    NETSIMPATH="${USERHOME:-/home/netsim}/inst"
	fi
        # finns filen? 
	if [ -r $NETSIMPATH/start_netsim ] ; then
	    OK="true"
	else 
	    printf "Could not find \"start_netsim\" in the path, please try again.\n"
	fi
    done
    printf "A NETSim installation found in: $NETSIMPATH\n\n"
    
    printf "Is a firewall portforwarding port 80 to 1080? (If No, relay will be used) [yes/NO]\n"
    read ANSWER
# all lowercase
    ANSWER=`echo $ANSWER | tr "[:upper:]" "[:lower:]"`
    if [ "$ANSWER" = "no" -o "$ANSWER" = "" ] ; then
	RELAY="true"
	printf "Relay will be enabled\n\n"
    else 
	RELAY="false"
	printf "Relay will be disabled\n\n"
    fi
    
# Ask where the patch folder shall be set
    OK="false"
    while [ "$OK" = "false" ] ; do
	printf "Where would you like to have your patch directory? [$NETSIMPATH/PATCHES]\n"
	read PATCHPATH
	if [ "$PATCHPATH" = "" ] ; then
	    PATCHPATH="${NETSIMPATH}/PATCHES"
	fi
	
    # If dir not exist, try to create it
	if [ -d $PATCHPATH ] ; then 
	    OK="true"
	    printf "Your patch directory is: $PATCHPATH\n\n"
	else 
	    mkdir -p $PATCHPATH > /dev/null 2>&1
	    if [ "$?" != "0" ] ; then
		printf "\nFailed to create patch directory, please try again\n"
		OK="false"
	    else
		printf "Your patch directory is: $PATCHPATH\n\n"
		OK="true"
	    fi
	fi
    done
    
    OK="false"
    while [ "$OK" = "false" ] ; do
	printf "Where would you like to put the initscript? [/etc/init.d/]\n"
	read RCPATH
	if [ "$RCPATH" = "" ] ; then
	    RCPATH="/etc/init.d/"
	fi
	
	if [ -w $RCPATH ] ; then 
	    OK="true"
	else 
	    printf "You don't have write premission in the specified location, please try again\n\n"
	fi
    done
# Concat the path with the name netsim
    RCPATH="${RCPATH}/netsim"    
    printf "The script will now be generated to $RCPATH...\n\n"
fi


# Outputs the init file to it's path
cat > $RCPATH <<-EOF
#!/bin/sh
#
#

NETSIMPATH='$NETSIMPATH'
NETSIMUSER='$USER'
RELAY='$RELAY'
PATCHDIR='$PATCHPATH'

# Due to parsing errors i tcsh we have to look up some user variables 
# in a rather odd way
PLATFORM=\`uname -s\`
if [ "\$PLATFORM" = "SunOS" ] ; then
   NETSIMDIR=\`su - netsim -cf 'if ( \$?NETSIMDIR == 0 ) echo \\\$HOME/netsimdir'\`
   if [ "\$NETSIMDIR" = "" ] ; then
        NETSIMDIR=\`su - netsim -cf 'echo \\\$NETSIMDIR'\`
   fi
else
   NETSIMDIR=\`su - netsim -c '/bin/bash -c "echo \${NETSIMDIR-\$HOME/netsimdir}"'\`
fi

case "\$1" in
    start)
        echo "Starting NETSim"
        echo "Looking for upgrades..."
        I=0
        for PATCH in \`find \${PATCHDIR} -name P?????_UMTS_*.tar.Z\`
          do
          mv \$PATCH \$NETSIMPATH > /dev/null 2>&1
          I=\`expr \$I + 1\`
        done
	if [ \$I -gt 0 ] ; then
	    echo "Upgrade in progress..."
	    echo "Logging to \${NETSIMDIR}/logfiles/upgrade.log"
	    su - \$NETSIMUSER -c "cd \${NETSIMPATH} && ./Install super echo  > \${NETSIMDIR}/logfiles/upgrade.log &&  echo Upgrade done!"
        else
	    echo "No upgrades found."
	    su - \$NETSIMUSER -c \${NETSIMPATH}/start_netsim
        fi
        if [ \$? = "0" ] ; then
            if [ \$RELAY = "true" ] ; then
		\${NETSIMPATH}/mmlsim_corba/relay/bin/relay start
            fi
	    echo "Starting simulations in background, logging to \${NETSIMDIR}/logfiles/autosimulationstart.log"
            su - \$NETSIMUSER -c "\${NETSIMPATH}/bin/start_all_simne.sh | \${NETSIMPATH}/netsim_pipe > \${NETSIMDIR}/logfiles/autosimulationstart.log &"
        else
            echo "Starting NETSim failed"
            exit 1
        fi
	;;
    
    stop)
        echo "Shutting down NETSim"
        if [ \$RELAY = "true" ] ; then
            \${NETSIMPATH}/mmlsim_corba/relay/bin/relay stop
        fi
        su - \$NETSIMUSER -c \${NETSIMPATH}/stop_netsim
        ;;
    restart)
	\$0 stop
	\$0 start
        ;;
    *)
        echo "Usage: \$0 {start|stop|restart}"
        exit 1
	;;
esac
EOF

chmod +x $RCPATH

if [ "$1" = "-a" -o "$1" = "--auto" ] ; then
    # First remove symb link if exists
    if [ -r $SYMBPATH ] ; then
	rm -f $SYMBPATH 
    fi
    ln -sf $RCPATH $SYMBPATH
else
    printf "Finished successfully!\n\n"
    
    printf "Whould you like to make an symbolic link to a runlevel directory? [YES/no]\n"
    read SYMBL
# convert input to lowercase
    SYMBL=`echo $SYMBL | tr "[:upper:]" "[:lower:]"`
    if [ "$SYMBL" = "" -o "$SYMBL" = "yes" ] ; then
	printf "Where should the symbolic link be placed? [/etc/rc3.d/]\n"
	OK="false"
	while [ "$OK" = "false" ] ; do
	    read SYMBPATH

	    if [ "$SYMBPATH" = "" ] ; then
		SYMBPATH="/etc/rc3.d/"
	    fi
	    if [ -w $SYMBPATH ] ; then
	        # concat dir with filename
		SYMBPATH="${SYMBPATH}/S99netsim"

                # First remove symb link if exists
		if [ -r $SYMBPATH ] ; then
		    rm -f $SYMBPATH 
		fi
	        # creats symb link
		ln -sf $RCPATH $SYMBPATH
		OK="true"
		printf "A symbolic link was placed in $SYMBPATH.\n\n"
	    else 
		printf "You don't have write premission to the specified location, please try again\n"
	    fi
	done
	printf "Congratulations! NETSim should now start upon boot.\n"
    fi
# Skriver ut instruktionerna
    exec $RCPATH
    printf " \n\n"
fi
exit 0 

