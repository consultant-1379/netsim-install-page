<?php

	include("header.php");

	Include("db_Connect.php");
	Include("constants.php");
	$LOG=$HOME."/log/" . $_GET['machine'] . "_" . $_GET['v'] . ".log";
	
        shell_exec("echo Started > ". $LOG);
        shell_exec("echo ". $_GET['userid'] . " >> " . $LOG);
        shell_exec("echo \"". $_GET['machine'] . ": Netsim " . $_GET['v'] . " install\" >> " . $LOG);

	$query = 'INSERT INTO JumpInfo (servername, userid, managerid, netsimversion, testtype, date, emailaddress) VALUES ("' . urldecode($_GET["machine"]). '","' . urldecode($_GET["userid"]) . '","' . urldecode($_GET["p"]). '","' . urldecode($_GET["v"]) . '","' .urldecode($_GET["t"]). '","'. date("Y-m-d H:i:s") .'","' . urldecode($_GET["e"]) .'")';

	mysql_query($query);


	$Shell_Command="nohup nice -n 0 /home/eeijkee/dev/bin/NetsimManagmentSys_web.sh ". urldecode($_GET["machine"]) ." ". urldecode($_GET["v"]) ." ". urldecode($_GET["e"]) ." >> " . $LOG . " 2>&1; echo -n $?";

	$install=shell_exec($Shell_Command);

	// user: ebildun
	// date: 18032014
	// extra functionality added to netsim install page to configure services on server
	shell_exec("echo \"- Now Setting ALL Server services so Netsim can install correctly\" >> ". $LOG);
	shell_exec("/var/www/html/TCM3/OSSInstall/scripts/rsh_command_with_pass.sh ".urldecode($_GET["machine"]). " shroot \"mount attemjump220:/export/tep/ /mnt/;/mnt/netsim_setup_server_services.sh;umount attemjump220:/export/tep/\" >> ". $LOG . " 2>&1; echo -n $?");
	//shell_exec("/var/www/html/tcm3_simnet/OSSInstall/scripts/rsh_command_with_pass_ebildun.sh ".urldecode($_GET["machine"]). " shroot \"mount attemjump220:/export/tep/ /mnt/;/mnt/netsim_setup_server_services.sh;umount attemjump220:/export/tep/\" >> ". $LOG . " 2>&1; echo -n $?");
	
	// restart netsim
	shell_exec("echo \"- Preparing netsim to use privileged ports and restarting netsim on server \" >> ". $LOG);
	shell_exec("/var/www/html/TCM3/OSSInstall/scripts/rsh_command_with_pass.sh ".urldecode($_GET["machine"]). " shroot \"mount attemjump220:/export/tep/ /mnt/;/mnt/netsim_setup_privports_restart.sh;umount attemjump220:/export/tep/\" >> ". $LOG . " 2>&1; echo -n $?");
	//shell_exec("/var/www/html/tcm3_simnet/OSSInstall/scripts/rsh_command_with_pass_ebildun.sh ".urldecode($_GET["machine"]). " shroot \"mount attemjump220:/export/tep/ /mnt/;/mnt/netsim_setup_privports_restart.sh;umount attemjump220:/export/tep/\" >> ". $LOG . " 2>&1; echo -n $?");
	// end user: ebildun
	
	shell_exec("echo \"-done-\" >> ". $LOG);

	echo $_GET['machine'].",".$_GET['v'].",Installation of netsim version ". $_GET['v'] .",".$install;
?>
