<?php
        // This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
        // Created by Mark Kennedy, July 2008

        include("constants.php");
	include("header.php");
	Include("db_Connect.php");

	$query = 'INSERT INTO BackupInfo (email,Reason,Server, dir, RequestID, DateRequested, Performed, Approval) VALUES ("' . urldecode($_GET["email"]). '","' . urldecode($_GET["reason"]) . '","' . urldecode($_GET["server"]). '","' . urldecode($_GET["dir"]) . '","","' . time() . '","false",\'PE\')';

        mysql_query($query);

	$query = "SELECT RequestID from BackupInfo  WHERE email='" . $_GET["email"] . "' ORDER BY RequestID DESC LIMIT 1";
	$result=mysql_query($query);
	$row = mysql_fetch_assoc($result);

	$to      = $_GET["email"];
	$subject = 'Backup Request Confirmation';
	$message = "This is to confirm your request for a backup of " . $_GET["dir"]. " on " . $_GET["server"] . ".\n\nYour request code is: " . $row["RequestID"];
	$headers = 'From: netsim_backup@ericsson.com' . "\r\n";

	mail($to, $subject, $message, $headers);


	$to      = 'mark.a.kennedy@ericsson.com';
        $subject = 'Backup Requested';
        $message = "<html><body>" .
	"This is to inform you of a request for a backup of " . $_GET["dir"]. " on " . $_GET["server"] . " from " . $_GET["email"] .
	".</br>" .
	".</br>" .
	"Reason: " . urldecode($_GET["reason"]) .
	".</br>" .
	"The request code is: " . $row["RequestID"] . 
	"</br></br>" .
	"Click <a href='http://atrclin2.athtem.eei.ericsson.se/TCM3/NetsimSite/Include/approve_backup.php?id=" . $row["RequestID"] . "&approval=AP'>here</a> to confirm." .
	"</br>" .
	"Click <a href='http://atrclin2.athtem.eei.ericsson.se/TCM3/NetsimSite/Include/approve_backup.php?id=" . $row["RequestID"]  . "&approval=NA'>here</a> to deny.</body></html>";
        $headers = 'From: netsim_backup@ericsson.com' . "\r\n" .
	'MIME-Version: 1.0\n' . "\r\n" .
	'Content-type: text/html; charset=iso-8859-1' . "\r\n" ;

        mail($to, $subject, $message, $headers);

        $to      = 'jerome.sheerin@ericsson.com';
        $subject = 'Backup Requested';
        $message = "<html><body>" .
        "This is to inform you of a request for a backup of " . $_GET["dir"]. " on " . $_GET["server"] . " from " . $_GET["email"] .
        ".</br>" .
        ".</br>" .
        "Reason: " . urldecode($_GET["reason"]) .
        ".</br>" .
        "The request code is: " . $row["RequestID"] .
        "</br></br>" .
        "Click <a href='http://atrclin2.athtem.eei.ericsson.se/TCM3/NetsimSite/Include/approve_backup.php?id=" . $row["RequestID"] . "&approval=AP'>here</a> to confirm." .
        "</br>" .
        "Click <a href='http://atrclin2.athtem.eei.ericsson.se/TCM3/NetsimSite/Include/approve_backup.php?id=" . $row["RequestID"]  . "&approval=NA'>here</a> to deny.</body></html>";
        $headers = 'From: netsim_backup@ericsson.com' . "\r\n" .
        'MIME-Version: 1.0\n' . "\r\n" .
        'Content-type: text/html; charset=iso-8859-1' . "\r\n" ;

        mail($to, $subject, $message, $headers);



	 $to      = 'paul.pearson@ericsson.com';
        $subject = 'Backup Requested';
        $message = "<html><body>" .
        "This is to inform you of a request for a backup of " . $_GET["dir"]. " on " . $_GET["server"] . " from " . $_GET["email"] .
        ".</br>" .
        ".</br>" .
        "Reason: " . urldecode($_GET["reason"]) .
        ".</br>" .
        "The request code is: " . $row["RequestID"] .
        "</br></br>" .
        "Click <a href='http://atrclin2.athtem.eei.ericsson.se/TCM3/NetsimSite/Include/approve_backup.php?id=" . $row["RequestID"] . "&approval=AP'>here</a> to confirm." .
        "</br>" .
        "Click <a href='http://atrclin2.athtem.eei.ericsson.se/TCM3/NetsimSite/Include/approve_backup.php?id=" . $row["RequestID"]  . "&approval=NA'>here</a> to deny.</body></html>";
        $headers = 'From: netsim_backup@ericsson.com' . "\r\n" .
        'MIME-Version: 1.0\n' . "\r\n" .
        'Content-type: text/html; charset=iso-8859-1' . "\r\n" ;

        mail($to, $subject, $message, $headers);

?>
