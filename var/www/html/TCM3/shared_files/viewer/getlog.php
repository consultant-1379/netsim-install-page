<?php
	// This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
	// Created by Mark Kennedy, July 2008
	
	include("header.php");

	$Shell_Command="./getlog.sh ".$_GET['log']." " .$_GET['logdir'];
	$log = htmlspecialchars(shell_exec($Shell_Command));
	$log=str_replace("\n","<br>",$log);

	echo $_GET['log']."_:_".$log;
?>

