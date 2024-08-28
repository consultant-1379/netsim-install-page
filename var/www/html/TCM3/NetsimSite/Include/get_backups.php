<?php
	// Created by Mark Kennedy, July 2008
	//This php page returns the output from getpatches.sh
	include("constants.php");
	include("header.php");

	$Shell_Command=$HOME."/Include/get_backups.sh " . $_GET['machine'];
	$results = shell_exec($Shell_Command);
	echo $_GET['machine'].",".$results;
?>

