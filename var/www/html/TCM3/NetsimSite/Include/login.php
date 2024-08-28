<?php
	// This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
	// Created by Mark Kennedy, July 2008
	
	include("constants.php");
	include("header.php");

	Include("/var/www/html/TCM3/ldap.php");
	if ($_GET['e']!="")
	{
		$email_addr=ldap($_GET['e']);
	}
	echo $email_addr.",".$_GET['e'].",";
	shell_exec("echo " . $_GET['e'] . " " . date("d_m_Y-H_i_s") ." >> /var/www/html/TCM3/NetsimSite/login_log.log");
?>
