<?php
        // This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
        // Created by Mark Kennedy, July 2008

        include("constants.php");
	include("header.php");

	Include("db_Connect.php");

	$query = "update BackupInfo set Approval='". $_GET["approval"]  . "' where RequestID='" . $_GET["id"] . "'";

	mysql_query($query);

	$query = "select email, Server, dir from BackupInfo where RequestID='" . $_GET["id"] . "'";

	$result=mysql_query($query);

	$row=mysql_fetch_assoc($result);

	$to      = $row["email"];
        $headers = 'From: netsim_backup@ericsson.com' . "\r\n";
	$message="The backup request of " . $row["dir"]. " on " . $row["Server"] . " has been ";

	if ( $_GET["approval"] == "NA" )
	{
		echo "Backup Request Denied. Notification email has been sent.";
		$subject = 'Backup Request Denied';
		$message=$message."denied.";
	}
	else
	{
		echo "Backup Request Approved. Notification email has been sent.";
		$subject = 'Backup Request Approved';
		$message=$message."approved. Please type the following code into the netsim page backup section to proceed: " . $_GET["id"];
	}
	mail($to, $subject, $message, $headers);
?>
