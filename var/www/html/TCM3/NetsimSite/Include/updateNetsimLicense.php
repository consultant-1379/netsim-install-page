<?php
	// Created by Mark Kennedy, July 2008
	//This php page simply calls the installpatch.sh script which attempts to install a patch onto a given machine

	include("constants.php");
	include("header.php");

	$LOG=$HOME."/log/".$_GET['server']."_license_update.log";
	shell_exec("echo Started > ". $LOG);
        shell_exec("echo ". $_GET['userid'] . " >> " . $LOG);
        shell_exec("echo \"". $_GET['server'] . ": Update of license "." \" >> " . $LOG);

	$Shell_Command=$HOME."/Include/updateNetsimLicense.sh start ".$_GET['filename'] . " " . $_GET['server'] . " >> ". $LOG ." 2>&1; echo -n $?";
	$install = shell_exec($Shell_Command);
	shell_exec("echo \"-done-\" >> ". $LOG);

	echo $_GET['server'].",Update of license ,".$install;
?>

