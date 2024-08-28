<?php
        // Created by Mark Kennedy, July 2008

        include("constants.php");
	include("header.php");

	Include("db_Connect.php");
	$query="SELECT servername FROM ServerInfo WHERE servername='" . $_GET['server'] . "'";
	$sql=mysql_query($query);
	if (mysql_num_rows($sql)>0)
	{
		echo $_GET['server'] . " already exists.";
	}
	else
	{
		exec("/var/www/html/TCM/NetsimSite/Include/NetsimWebInfo.sh ". $_GET['server']);
		if (exec("rsh -l root -n ". $_GET['server'] ." id"))
        	{
			echo "Rsh is working on this machine.";
		}
		else
		{
			echo "Rsh is not working on this machine. Add below if necessary.";
		}
	}
	echo "Finished"
?>
