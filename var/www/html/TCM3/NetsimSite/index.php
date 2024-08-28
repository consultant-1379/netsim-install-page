<html>
   <head>
 <title>Netsim Install Page</title>
    

    <script src="functions.js"></script>
    <link type="text/css" rel="stylesheet" href="style.css">
    <body onload="loadedpage()">
	
	
	<div id="contents" style="visibility:hidden">
		<?php
                Include("/var/www/html/TCM3/shared_files/viewer/viewer.php");
        ?>    
	    <a href="javascript:show_hide_special();" id="morefunctions">+ Special Functions</a>
	    <img src="Include/arrow.gif" id="arrow">
	    <img src="Include/wait.gif"  id="wait">
	    <div id="install_netsim_div" class="outer">
		<div class="help" id="netsimhelp">
		    Complete details below and click install to install netsim.
		</div>
		<div id="inner_netsim_install">
		    
		    <div id="netsim_version_title">Netsim Version:</div>
		    <SELECT id="netsim_version">
			<OPTION>Choose Version</OPTION>
			
			<?php
				Include("Include/db_Connect.php");
				
				$sql=mysql_query("SELECT * FROM R_version ORDER BY R_version DESC");
				while($row=mysql_fetch_array($sql))
				{
					echo "<option value='".$row['R_version']."'>".$row['R_version']."</option>";
				}
			?>
			
		    </SELECT>
		    
		    <div id="netsim_testing_type_title">Test Type:</div>
		    <SELECT id="netsim_testing_type">
			<option value="">Choose Type</option>
			<option value="FT">FAT</option>
			<option value="ST">System Test</option>
			<option value="BT">Design/Basic Test</option>
			<option value="RT">Regression Test</option>
		    </SELECT>
		    
		    <div id="netsim_userid_title">User ID:</div>
		    <input type="text" disabled id="netsim_userid"></input>
		    <div id="netsim_email_title">Email Address:</div>
		    <input type="text" disabled id="netsim_email"></input>
		    <div id="netsim_project_title">Netsim Project:</div>
		    <input type="text" id="netsim_project"></input>
			<div id="setup_ssh_title">Internal ssh:</div>
                    <input type="checkbox" id="setup_ssh"  checked="checked" disabled="disabled" />
			<?php
				//determine the latest NETSim release in use
				//read in from the database so the page will always be relevant without having to rewrite content
				//use the new PHP way of connecting to databases (i.e. no MySQL functions)
				Include("Include/db_Connect_Updated.php");
				$release_length=3;
				$select_statement_release_version="SELECT MAX(LEFT(R_version,$release_length)) FROM R_version";
				$latest_release_result=$updated_db->query($select_statement_release_version);
				$latest_release_array=$latest_release_result->fetch();
				$latest_release_id=$latest_release_array[0];
			?>
			<!--
			<div id="warning_title">Please Note: R23* No longer supported, upgrade to R24X</div>
			-->
			<div class="help" id="warning_title">Please Note: Only <?php echo "$latest_release_id" ?>* is currently supported by NETSim</div>
		    <a href="javascript:addtoqueue_netsim();" class="button" id="buttonOK"><span class="icon">Install</span></a>
		</div>
		
		
	    </div>
	    
	    <div id="queuediv" class="outer">
		<div class="title">Installation Queue</div>
		<div class="help" id="queuehelp">
		    The queue shows pending netsim and patch installations.
		</div>
		
		<SELECT  size="30" id="queue" multiple>
		</SELECT>
		<BUTTON id="queueinstall" disabled onclick="installqueue()">Continue</BUTTON>
		<BUTTON id="removequeueitems" onclick="removeQueueItems()">Remove</BUTTON>
		<BUTTON id="stopqueueinstall" disabled onclick="stopqueue()">Pause</BUTTON>
		<div id="haltdiv">
		    <input type="checkbox" checked="yes" id="halt" />Pause on error
		</div>
	    </div>
	    
	    <div id="machinediv" class="outer">
		<div class="title">1) Machine Selection</div>
		<div class="help" id="machinehelp">
		    Select desired machines below and proceed to installation area.
		</div>
		
		<div id="innermachinediv">
		    <div id="machine_list_title">
			Machine List
		    </div>
		    
		    <div id="selected_machine_title">
			Selected Machines
		    </div>
		    <SELECT size="15" multiple id="machinelist">
			
		    </SELECT>
		    
		    <SELECT size="15" multiple id="machinelistto">
			
		    </SELECT>
		    <BUTTON id="moverightbtn" onclick="move_selected('machinelist','machinelistto')">></BUTTON>
		    <BUTTON id="moveleftbtn" onclick="move_selected('machinelistto','machinelist')"><</BUTTON>
		</div>
	    </div>
	    
	    <div id="patchlist" class="outer">
		<div class="help" id="patchhelp">
		    Select desired netsim patches and click install when ready.
		</div>
		<?php
		    $num=0;
		    $versions_list = mysql_query("SELECT R_version from R_version ORDER BY R_version DESC LIMIT 3",$db);
		    while ($versions_row=mysql_fetch_array($versions_list))
		    {
			echo '<div class="innerpatchlist" id="a'.$num .'">';
			$version=$versions_row['R_version'];
								
			echo '<div class="netsimversion">';
			echo $version;
			//		$pos=strpos($version,"R22");
			//
			if(strpos($version,"R27") !== false) {
				$netsim_version="6.7";
			}
			elseif(strpos($version,"R26") !== false) {
				$netsim_version="6.6";
			}
			elseif(strpos($version,"R25") !== false) {
                                $netsim_version="6.5";
                        }
			elseif(strpos($version,"R24") !== false) {
				$netsim_version="6.4";
			}
			elseif (strpos($version,"R23") !== true) {
                                $netsim_version="6.3";
                        }
			else {
				$netsim_version="6.2";
			}
			echo "<a target=\"_blank\" href=\"http://netsim.lmera.ericsson.se/tssweb/netsim". $netsim_version ."/released/NETSim_UMTS." . $version . "/Patches/\"> Patches</a><br>";
			echo '</div>';
								
			echo '<SELECT class="machinepatch" size="8" disabled=true name="M' . $version  . '"id="a'.$num .'_machine">';
			echo "</SELECT>";
								
			echo '<SELECT class="patchlistpatch" size="8" multiple name="P' . $version  . '"id="a'.$num .'_patch">';
								
			echo "</SELECT>";
			echo "<BR>";
			echo '<a href="javascript:addtoqueue_patch(\'' . $version. '\');" class="button" id="buttonOK"><span class="icon">Install</span></a>';
								
			echo "<br>";
			echo '</div>';
			$num++;
		    }
		?>
	    </div>
		<a href="javascript:clicked_netsim_tab();" class="selected" id="netsim_title">2) Netsim Installation</a>
		<a href="javascript:clicked_patch_tab();" class="deselected" id="patchtitle">2) Patch Installation</a>

    	<div id="specialfunctionsdiv" style="visibility:hidden" class="outer">
		<div class="title" id="special_functions_title">Special Functions</div>
		<div class="help" id="specialhelp">
		    Chose a machine to perform special functions on.
		</div>
		
		    <SELECT  onchange="special_machine_changed()" disabled id="reinstall_netsim_machinelist">
		    </SELECT>
		    <div class="label" id="reinstall_netsim_machinelist_title">Select Machine:</div>
			<div class="label" id="select_function_title">Select Function:</div>
		<SELECT  onchange="selectedFunction()"id="select_function">
			<option value="">Choose Function</option>
			<option value="reinstall_function">Remove Database Entry</option>
			<option value="setup_rsh_div">Setup Rsh</option>
			<option value="add_to_mrtgdiv">Add to MRTG</option>
			<option value="install_cvs_div">Install CVS</option>
			<option id ="request_backup_div_option" value="request_backup_div">Request Backup</option>
			<option value="backup_login_div">Perform Backup</option>
			<option value="restore_backup_div">Restore Backup</option>
			<option value="add_server">Add New Server</option>
			<option value="update_license">Update Netsim License</option> 

                    </SELECT>
	    </div>
		<div class="functiondiv" id="add_server">
                    <div class="help">
                        Use this section to add a new server to the netsim database.
                    </div>
                    <div class="label"id="add_server_title">Server Name:</div>
                    <input type="text" id="server_to_add"></input>
                    <button onclick="add_server()" id="add_server_button">Add Server</button>
                </div>
			<div class="functiondiv" id="reinstall_function">
                    <div class="help">
                        To reinstall netsim, first remove its entry from our database here.
                    </div>

                    <SELECT id="reinstall_netsim_version">
                        <?php
                            $sql=mysql_query("SELECT * FROM R_version ORDER BY R_version DESC");
                            while($row=mysql_fetch_array($sql))
                            {
                                echo "<option value='".$row['R_version']."'>".$row['R_version']."</option>";
                            }
                        ?>
                    </SELECT>

                    <button onclick="remove_netsim_db()" id="remove_netsim_db">Remove Entry</button>
                    <div id="reinstall_netsim_version_title">Netsim Version:</div>
                </div>

		<div class="functiondiv" id="setup_rsh_div">
                    <div class="help">
                        Use this section to attempt to setup rsh on a machine.
                    </div>
                    <div  class="label" id="root_password_title">Root Password:</div>
                    <input type="password" id="root_password"></input>
                    <button onclick="setup_rsh()" id="setup_rsh_button">Setup Rsh</button>
                </div>

		<div class="functiondiv" id="add_to_mrtgdiv">
                    <div class="help">
                        This section adds a machine to the <a target=\"_blank\" href="http://atrclin2.athtem.eei.ericsson.se/TCM/index.php?Page=MRTG&List=list">mrtg</a> page for monitoring stats.
                    </div>
                    <button onclick="addtoqueue_mrtg()" id="add_to_mrtg_button">Add To Mrtg</button>
                </div>
		<div class="functiondiv" id="install_cvs_div">
                    <div class="help">
                        This section installs a CVS.
                    </div>
                    <button onclick="addtoqueue_cvs()" id="install_cvs_button">Install</button>
                </div>

		<div class="functiondiv" id="backup_login_div">
                                <div class="help" >
                                        Type your backup approval code and proceed.
                                </div>

                                <input type="text" id="backup_login_code"></input>
                                <div class="label" id="backup_login_code_title">Code:</div>
                                <button onclick="backup_login()" id="backup_login_button">Proceed</button>
                                <a href="javascript:changeFunctionIndex('request_backup_div_option');" id="needacode">Need a code?</a>

                        </div>

                        <div class="functiondiv"id="request_backup_div" >
                            <div class="help" >
                                Request a backup
                            </div>
                                <SELECT onchange="changed_backup_type()" id="backup_type">
                                        <option value="">Choose Type</option>
                                        <option value="SM">Simulation</option>
                                        <option value="ND">/netsim/</option>
                                        <option value="EX">Exported Items</option>
                                </SELECT>

                                <SELECT disabled id="simulations">
                                </SELECT>

                                <input type="text" id="reason_box"></input>
                                <div class="label" id="backup_type_title">Backup Type:</div>
                                <div class="label" id="simulations_title">Simulation:</div>
                                <div class="label" id="reason_box_title">Reason:</div>
                            <button onclick="request_backup()" id="request_backup_button">Request</button>
                       </div>

                        <div class="functiondiv" id="perform_backup_div"  >
                                <div class="help">
                                        Enter details below and click backup.
                                </div>
                                <input type="text" disabled id="backup_machine"></input>
                                <input type="text" disabled id="backup_path"></input>
                                <input type="text" disabled id="backup_reason"></input>
                                <input type="text" id="backup_project"></input>
                                <input type="text" id="backup_assoc_machines"></input>
                                <input type="text" id="backup_assoc_oss"></input>
                                <input type="text" id="backup_assoc_smrs"></input>
                                <div class="label" id="backup_machine_title">Server:</div>
                                <div class="label" id="backup_path_title">Backup Dir:</div>
                                <div class="label" id="backup_reason_title">Reason:</div>
                                <div class="label" id="backup_project_title">Project Name:</div>
                                <div class="label" id="backup_assoc_machines_title">Netsim Servers:</div>
                                <div class="label" id="backup_assoc_oss_title">Assoc OSS:</div>
                                <div class="label" id="backup_assoc_smrs_title">Assoc SMRS:</div>
                                <button onclick="addtoqueue_backup()" id="addtoqueue_backup_button">Backup</button>
                        </div>

			<div class="functiondiv" id="restore_backup_div"  >
				<div class="help">
					Restore a netsim backup here.
                                </div>

				<SELECT onchange="changed_restore_type()" id="restore_type">
                                </SELECT>

                                <SELECT disabled id="restore_simulations">
                                </SELECT>

				<div class="label" id="restore_type_title">Restore Type:</div>
                                <div class="label" id="restore_simulations_title">Simulation:</div>

				<button onclick="addtoqueue_restore()" id="addtoqueue_restore_button">Restore</button>
			</div>
			<div class="functiondiv" id="update_license"  >
                                <div class="help">
					Use this section to update the license
                                </div>
				<SELECT id="update_license_version">
					<option value="eei_special_jumpstart.337.6.netsim6_3_licence.zip">R23*</option>
					<option value="eei_special_jumpstart.337.5.netsim6_4_licence.zip">R24*</option>
					<option value="eei_special_jumpstart.337.6.netsim6_5_licence.zip">R25*</option>
					<option value="eei_special_jumpstart.337.16.netsim6_6_licence.zip">R26*</option>
					<option value="eei_special_jumpstart.337.15.netsim6_7_licence.zip">R27*</option>
        		            </SELECT>
	
                    <button onclick="update_license()" id="update_license_button">Update</button>
                    <div id="update_license_title">Netsim Version:</div>

                        </div>
		<button onclick="signout()" id="sign_out">Sign Out</button>
	</div>
	<div id="login">
	    <div id="login_text">
		Please enter your Ericsson ID to continue.
	    </div>
	    <div id="login_userid_title">
		Ericsson ID:
	    </div>
	<a href="javascript:enteredLogin();" id="login_button"><img src="Include/go.gif"></a>
	    <form  id="form" action="javascript: enteredLogin()">
		<input type="text" id="useridlogin" />
		<div id="login_error" class="error"></div>
		
	    </form>
	</div>
    </body>
</html>

