<?php

	include("header.php");
	Include("db_Connect.php");
	$result=mysql_query("SELECT servername FROM JumpInfo WHERE servername='" . $_GET['s']  ."' AND netsimversion='" . $_GET['v'] ."'");

	if(mysql_num_rows($result)>0)
	{
		//Already in database
		echo "1";
	}
	else
	{
		//Not in database
		echo "0";
	}

?>
