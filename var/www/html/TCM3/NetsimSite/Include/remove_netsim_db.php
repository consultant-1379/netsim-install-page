<?php
	// This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
	// Created by Mark Kennedy, July 2008
	
	include("constants.php");
	include("header.php");

	Include("db_Connect.php");

	mysql_query("DELETE FROM JumpInfo where servername='" . $_GET['server'] . "' AND netsimversion='" .$_GET['version']. "'",$db);
?>

