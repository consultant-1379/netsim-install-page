<?php
	// This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
	// Created by Mark Kennedy, July 2008
	
	include("constants.php");
	include("header.php");
	Include("db_Connect.php");

	$result=mysql_query("SELECT DISTINCT servername FROM ServerInfo ORDER BY servername");
	while($row=mysql_fetch_array($result))
        {
                echo $row['servername'].",";
        }
?>

