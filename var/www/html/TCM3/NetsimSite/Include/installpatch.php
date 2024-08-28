<?php
	// Created by Mark Kennedy, July 2008
	//This php page simply calls the installpatch.sh script which attempts to install a patch onto a given machine

	include("constants.php");
	include("header.php");

	$LOG=$HOME."/log/".$_GET['machine']."_".$_GET['p'].".log";
	shell_exec("echo Started > ". $LOG);
        shell_exec("echo ". $_GET['userid'] . " >> " . $LOG);
        shell_exec("echo \"". $_GET['machine'] . ": Patch " .$_GET['p']. " Install\" >> " . $LOG);

	$Shell_Command=$HOME."/Include/installpatch.sh ".$_GET['machine'] . " " . $_GET['v'] . " " . $_GET['p'] . " >> ". $LOG ." 2>&1; echo -n $?";
	$install = shell_exec($Shell_Command);
	shell_exec("echo \"-done-\" >> ". $LOG);

	echo $_GET['machine'].",".$_GET['v'].",Installation of patch ". $_GET['p']  .",".$install;
?>

