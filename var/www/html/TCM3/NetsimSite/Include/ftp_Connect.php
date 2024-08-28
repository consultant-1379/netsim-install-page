<?php
	$ftp_server="ftp.athtem.eei.ericsson.se";
	//$default_ftp_dir="/sims/13A/SystemTest/LTE/LATEST/";
	$default_ftp_dir="/sims/O14/SystemTest/14.1.8/LTE/LATEST/";
	$ftp_user="simadmin";
	$ftp_pass="simadmin1";
	$ftp_conn = ftp_connect($ftp_server) or die("Could not connect to $ftp_server");
	if ($login = ftp_login($ftp_conn, $ftp_user, $ftp_pass))
	{
		// get list of files in directory
		$file_list = ftp_nlist($ftp_conn, "$default_ftp_dir");
	}
	else
	{
		echo "Could not login to $ftp_server";
		exit;
	}
?>
