<?php
	// Created by Mark Kennedy, July 2008
	//This php page simply calls the installpatch.sh script which attempts to install a patch onto a given machine

	include("constants.php");
	Include("db_Connect.php");
	include("header.php");
	$LOG=$HOME."/log/Backup_".$_GET['machine'].".log";
	shell_exec("echo Started > ". $LOG);
        shell_exec("echo ". $_GET['userid'] . " >> " . $LOG);
        shell_exec("echo \"". $_GET['machine'] . ": Backup of" .$_GET['dir'] . "\" >> " . $LOG);

	mysql_query("UPDATE BackupInfo set Performed='1' where RequestID='". $_GET['id'] ."'" );

	$readme1=urldecode($_GET['readme']);
	$readme=str_replace('\'', '', $readme1);

	$Shell_Command=$HOME."/Include/create_backup.sh ".$_GET['machine'] . " " . urldecode($_GET['dir']) . " '" . $readme . "' >> ". $LOG ." 2>&1; echo -n $?";
	$result = shell_exec($Shell_Command);
	shell_exec("echo \"-done-\" >> ". $LOG);



	echo $_GET['machine'].",".$_GET['dir'].",Backup of ". $_GET['dir']  . ",".$result;
	if ( $result !== "0" )
	{
		mysql_query("UPDATE BackupInfo set Performed='0' where RequestID='". $_GET['id'] ."'" );
	}
?>

