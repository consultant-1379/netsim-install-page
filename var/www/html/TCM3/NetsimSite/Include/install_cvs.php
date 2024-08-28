<?php
	// This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
	// Created by Mark Kennedy, July 2008
	include("header.php");
	include("constants.php");
	$LOG=$HOME."/log/".$_GET['machine']."_cvs.log";

	shell_exec("echo Started > ". $LOG);
	shell_exec("echo ". $_GET['userid'] . " >> " . $LOG);
	shell_exec("echo \"". $_GET['machine'] . ": CVS Installation\" >> " . $LOG);

	$Shell_Command=$HOME."/Include/installcvs.sh ".$_GET['machine'] . " >> ". $LOG ." 2>&1; echo -n $?";

	#$Shell_Command="sudo /home/ejershe/TCM-WebPage/MRTG-TCM/mrtg/mrtg-v2/netsim_install_snmp.sh ".$_GET['machine']. " " . $_GET['e'] . " >> ". $LOG . " 2>&1; echo -n $?";
	$exitcode = shell_exec($Shell_Command);

	shell_exec("echo \"-done-\" >> ". $LOG);
	echo $_GET['machine'] . ",x,CVS Installation,".$exitcode;

?>

