<?php
	// This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
	// Created by Mark Kennedy, July 2008
	
	include("constants.php");
	include("header.php");
	Include("db_Connect.php");

	$sql=mysql_query("SELECT netsimversion from JumpInfo where servername='".$_GET['server']."' ORDER BY netsimversion DESC");
	echo $_GET['server'].",";
	while($row=mysql_fetch_array($sql))
        {
                echo $row['netsimversion'].",";
        }
?>

