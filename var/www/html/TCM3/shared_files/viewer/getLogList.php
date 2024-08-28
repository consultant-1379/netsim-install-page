<?php
	// Created by Mark Kennedy, July 2008
	//This php page returns the output from getpatches.sh
	include("header.php");
	$Shell_Command="./getLogList.sh " . $_GET['logdir'] . " " . $_GET['recent_time'];
	$logs = shell_exec($Shell_Command);
	echo $logs;
?>

