<?php
	// This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
	// Created by Mark Kennedy, July 2008
	
	include("constants.php");
	include("header.php");

	$server="153.88.188.227";

	Include("ldap.php");
	$value=ldap($server, "ekemark");
	echo $value;
?>
