<?php
	// This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
	// Created by Mark Kennedy, July 2008
	
	include("constants.php");
	include("header.php");

	$Shell_Command=$HOME."/Include/getlog.sh ".$_GET['s'];
	$log = shell_exec($Shell_Command);

	echo $_GET['s']."_:_".$log;
?>

