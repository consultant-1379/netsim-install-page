#!/bin/sh


####################################
#
# Ver1: Created for Netsim License Update
# Ver2: Modified accordingto work on Solaris machine too bt changing wget to rcp 
#
####################################

if [ "$#" -ne 3  ]
then
cat<<HELP

NOTE: Ensure that script and license file are located in the same directory 
      Insert license file_name manually into script

Usage: $0 start <license_file>  <netsim_meachine>

Example: $0 start eei_special_jumpstart.337.3.netsim6_1_licence.tar.Z  netsimlin144

HELP
 exit 1
fi

LICENSE=$2
#LICENSE=/.Fatih/Licenses/R21_Licences/eei_special_jumpstart.337.4.netsim6_1_licence.tar.Z


echo ""
echo "NETSIM LICENSE UPGRADE IS STARTING"
echo ""

SERVERLIST=$3

for SERVER in $SERVERLIST
do
    echo '****************************************************'
    echo "$SERVER is upgrading to new license"
    echo '****************************************************'
   
    # wget was used before due to permission denied but rcp still works
    #   /usr/bin/rsh -l netsim $SERVER "wget -nc http://atrclin2.athtem.eei.ericsson.se/TCM3/NetsimSite/Include/$LICENSE -P/netsim/inst/"
    rcp $LICENSE netsim@$SERVER:/netsim/inst/
    /usr/bin/rsh -l netsim -n $SERVER echo ".install license "$LICENSE" | /netsim/inst/netsim_shell"
    /usr/bin/rsh -l netsim -n $SERVER echo ".e 'intcmdlib:delete_stream_field(importedlicenses).' | /netsim/inst/netsim_shell"

    echo '****************************************************'
    echo "$SERVER is upgraded to new license"
    echo '****************************************************'
    echo ""
done

echo "NETSIM LICENSE UPGRADE FINISHED"
 echo ""
