<?php
        // This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
        // Created by Mark Kennedy, July 2008

        include("constants.php");
	include("header.php");
	Include("db_Connect.php");
	$query="SELECT Server, dir, Performed, Approval, Reason FROM BackupInfo WHERE email='" . $_GET['email'] . "' AND RequestID='" . $_GET['code'] . "'";
	$result=mysql_query($query);
	if (mysql_num_rows($result)==1)
	{
		$row = mysql_fetch_assoc($result);
		if ($row['Approval']=="PE")
		{
			echo "1, is Pending Approval";
		}
		else if ($row['Approval']=="NA")
		{
			echo "1,was Not Approved";
		}
		else
		{
			if ($row['Performed']==1)
			{
				echo "1, was Already performed";
			}
			else
			{
				echo "0," . $row['dir'] . ",". $row['Server'] . ",". $row['Reason'];
			}
		}
	}
	else
	{
		echo "1,No record found";
	}
?>
