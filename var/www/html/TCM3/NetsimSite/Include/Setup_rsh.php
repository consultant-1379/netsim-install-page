<?php
        // This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
        // Created by Mark Kennedy, July 2008

        include("constants.php");
	include("header.php");

        $Shell_Command=$HOME."/Include/Setup_rsh_suse11.sh root ".$_GET['password']. " " . $_GET['machine']. " >/dev/null 2>&1 ;echo $?";
        $response = shell_exec($Shell_Command);

        echo $response;
?>
