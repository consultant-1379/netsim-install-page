<?php

	include("header.php");

	Include("db_Connect.php");
	Include("constants.php");

	$query = 'INSERT INTO JumpInfo (servername, userid, managerid, netsimversion, testtype, date, emailaddress) VALUES ("' . urldecode($_GET["machine"]). '","' . urldecode($_GET["userid"]) . '","' . urldecode($_GET["p"]). '","' . urldecode($_GET["v"]) . '","' .urldecode($_GET["t"]). '","' . date ("Y-m-d H:i:s") . '","' . urldecode($_GET["e"]) .'")';

	mysql_query($query);

?>
