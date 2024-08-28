<?php
	//This page returns the output from the getVersion.sh script which gets the netsim version in use on the machine defined by $_GET['m']
	// Created by Mark Kennedy, July 2008

	include("constants.php");
	include("header.php");

	$Shell_Command=$HOME."/Include/get_simulation_dirs.sh ".$_GET['server'];
	$sims = shell_exec($Shell_Command);

	echo $_GET['server'].",".$sims
?>

