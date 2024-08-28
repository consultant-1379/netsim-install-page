<?php
	// Created by Mark Kennedy, July 2008
	//This php page simply calls the installpatch.sh script which attempts to install a patch onto a given machine

	include("constants.php");
	include("header.php");
	$LOG=$HOME."/log/Restore_".$_GET['machine'].".log";
        shell_exec("echo Started > ". $LOG);
        shell_exec("echo ". $_GET['userid'] . " >> " . $LOG);
        shell_exec("echo \"". $_GET['machine'] . ": Restore of " .$_GET['directory']. "\" >> " . $LOG);	

	$Shell_Command=$HOME."/Include/restore_backup.sh ".$_GET['machine'] . " " . $_GET['directory'] . " >> ". $LOG ." 2>&1; echo -n $?";
	$restore = shell_exec($Shell_Command);
	shell_exec("echo \"-done-\" >> ". $LOG);

	echo $_GET['machine'].",".$_GET['directory'].",Restoring of ". $_GET['directory'] .",".$restore;
?>

