// Created by Mark Kennedy, July 2008
// This javascript contains functions used by the patches page

// This variable stores text describing page actions and page status, e.g. Loading patches
var status="";

// This variable stores a reference to a setInterval object which can be set / cleared. This interval is used to update the log viewer as commands execute
var t;

var previousSelID;
var logRunningCount=0;
var logFinishedCount=0;
var logTimer;
// This variable stores the status of the queue, installing or not. It is used to disable / enable appropriate buttons
var installingQueue=false;

// This variable determines whether an installation of a queue is allowed continue or not. Defaults to true but the stop queue button resets its to false
var allowedInstallQueue=true;


// FUNCTIONS


// This function is called when the page loads
// It calls getallpatches() to get the list of patches for the page

function replaceButtonText(buttonId, text)
{
  if (document.getElementById)
  {
    var button=document.getElementById(buttonId);
    if (button)
    {
      if (button.childNodes[0])
      {
        button.childNodes[0].nodeValue=text;
      }
      else if (button.value)
      {
        button.value=text;
      }
      else //if (button.innerHTML)
      {
        button.innerHTML=text;
      }
    }
  }
}

function loadedpage()
{

	//setup hidden divs
	var contents = document.getElementById("contents");
	var login = document.getElementById("login");
	contents.style.visibility="hidden";
	login.style.visibility="visible";
	//consistency
	document.getElementById("backup_type").selectedIndex=0;
	document.getElementById("simulations").disabled="true";
	document.getElementById("restore_type").selectedIndex=0;
	document.getElementById("restore_simulations").disabled="true";
	document.getElementById("select_function").selectedIndex=0;
	selectedFunction();
	//scroll page
	window.scroll(0,0); // horizontal and vertical scroll targets

	//load lists
	status="";
	getallpatches();
	getmachinelist();
	detectBrowser();
	document.getElementById("useridlogin").focus();
	load_viewer("/var/www/html/TCM3/NetsimSite/log/","Include/");

	if ( ! get_cookie ( "username" ) )
	{
	}
	else
	{
	  var username = get_cookie ( "username" );
          var email = get_cookie("email");
	  logged_in_fine(username,email);
	}

}



function getmachinelist()
{
	var url="Include/getmachines.php";
	var ajax = new AJAXInteraction(url, validate_get_machines,true);
	ajax.doGet();
}

// This takes the response from the getmachinelist method
// Fill the machinelist div, only if each machine is not in the second machinelist div.

function validate_get_machines(responseText)
{
	var machinelist1=document.getElementById("machinelist");
	var machinelist2=document.getElementById("reinstall_netsim_machinelist");
	var machinelistto=document.getElementById("machinelistto");

	machinelist1.innerHTML="";
	machinelist2.innerHTML="";

	var newopt = new Option("Choose Machine","Choose Machine");
	machinelist2.options[machinelist2.options.length]=newopt;

	var response_array=responseText.split(",");
	for ( var i=0; i<response_array.length-1; i++ ){

		//make sure not to add one thats in selected machines section
		var found=false;
		for ( var x=0; x<machinelistto.options.length; x++ ){
			if (machinelistto.options[x].text==response_array[i])
			{
				found=true;
				break;
			}
		}
		if(!found)
		{
			var newopt = new Option(response_array[i],response_array[i]);
			newopt.setAttribute("id",response_array[i]);

			machinelist1.options[machinelist1.options.length]=newopt;
		}

		var newopt = new Option(response_array[i],response_array[i]);
		newopt.setAttribute("id",response_array[i]);
		machinelist2.options[machinelist2.options.length]=newopt;	
	}
}

// This function works with the machinelist <SELECT> and gets the netsim version of selected machines
// Its callback method is validategetversions

function getversions ()
{
	var list = document.getElementById('machinelistto');

	//Loop through machine list

	for ( var i=0; i<list.options.length; i++ ){


		//var existing=document.getElementById(list.options[i].text+"_patch");

		//check if it already exists in patchlist before sending request
		//if (existing==null)
		//	{
		var url="Include/getversion.php?machine="+ list.options[i].text;
		var ajax = new AJAXInteraction(url, validategetversions,true);
		ajax.doGet();
		//	}
	}

	//check existing patchlist machines to see if they are in machine selection, remove if not
	for (var num=0;num<3;num++)
	{
		var patchlistmachines = document.getElementById("a"+num+"_machine");
		for (var i=0; i<patchlistmachines.options.length; i++ ){
			var element=document.getElementById(patchlistmachines.options[i].text+"_machinelistto");
			if(element==null)
			{
				patchlistmachines.remove(i);
				i--;
			}
		}
	}
}

function signout ()
{
	delete_cookie("username");
	delete_cookie("email");
	window.location.reload()
}

// This is the callback method for getversions
// If a valid version is returned, then the machine is moved from the machine list, to the appropriate list in the patch selection area

function validategetversions(responseText)
{
	var response_array=responseText.split(",");
	if (response_array[1].length!=4)
	{
		//alert("ERROR: Could not get netsim version from " + response_array[0] + " for patch selection. Please check if netsim is running on this machine.");
	}
	else
	{
		var to_m = document.getElementsByName("M"+response_array[1])[0];
		if (to_m==null)
		{
			//updateStatus("ERROR: " + response_array[0] + " is using netsim version " + response_array[1] + " which is not listed on this page for patch installation.",true);
			//alert ("ERROR: " + response_array[0] + " is using netsim version " + response_array[1] + " which is not listed on this page for patch installation.");
		}
		else
		{
			//recheck if its still in list before adding and not in any other patch list
			if (document.getElementById(response_array[0]+"_machinelistto")!=null )
			{

				//remove from patch lists if there
				for (var num=0;num<3;num++)
				{
					var patchlistmachines = document.getElementById("a"+num+"_machine");
					for (var i=0; i<patchlistmachines.options.length; i++ ){
						if(patchlistmachines.options[i].value==response_array[0]+"_patch")
						{
							patchlistmachines.remove(i);
							i--;
						}
					}
				}
				var newopt = new Option(response_array[0],response_array[0]+"_patch");
				newopt.setAttribute('id',response_array[0]+'_patch');
				to_m.options[to_m.options.length]=newopt;


			}
		}
	}
}

// This function gets a list of patches using the getpatches.php page. This php file calls a shell script which parses the netsim page to get the patch list
// Its callback method is validategetallpatches

function getallpatches()
{	
	var url="Include/getpatches.php";
	var ajax = new AJAXInteraction(url, validategetallpatches,true);
	ajax.doGet();
}

// This is the callback method for getallpatches
// The returned text is comma delimited, and in the format netsim_version patch1 patch2 patchn : netsim_version2 patch1 patch2 patchn

function validategetallpatches(responseText)
{
	var response_array=responseText.split(",");
	var to_m = document.getElementsByName("P"+response_array[0])[0];
	for ( var i=0; i<response_array.length; i++ ){
		if (response_array[i]==":")
		{
			to_m = document.getElementsByName("P"+response_array[i+1])[0];
			i++;
		}
		else
		{
			var opt = new Option(response_array[i],response_array[i]);
			to_m.options[to_m.options.length]=opt;
		}
	}
	updateStatus("Page Loaded",false,true);

}

// This function takes a text and value string which is used to create a new option in the queue
// The value is used to store the php script and arguments as one string

function addtoqueue(text,value,id)
{
	var queuelist = document.getElementById("queue");
	// Check if this pair already exists in queue

	var found=false;

	for (var q=0; q<queuelist.options.length; q++)
	{
		if (queuelist.options[q].text==text)
		{
			found=true;
			break;
		}
	}
	if (!found)
	{
		// Add this pair to the queue

		var newopt = new Option(text,value);
		newopt.setAttribute("id",id);
		queuelist.options[queuelist.options.length]=newopt;
	}
	updateQueueButtons();
	if (!installingQueue)
	{
		installqueue();
	}
}

// This function adds a patch to the queue
// v is used to decide which of the 3 patch area install buttons was clicked

function addtoqueue_patch(v)
{
	var machlist = document.getElementsByName("M"+v)[0];
	var patchlist = document.getElementsByName("P"+v)[0];
	var netsim_userid = document.getElementById("netsim_userid");

	// loop through machine list and patchlist to get pairs

	patchlist.style.backgroundColor="white";
	document.getElementById("machinelistto").style.backgroundColor="white";

	var patchCount=0;

	//check for patches
	for (var p=0; p<patchlist.options.length; p++)
	{
		if (patchlist.options[p].selected)
		{
			patchCount=1;
			break;
		}
	}
	if (patchCount==0)
	{
		inlineMsg(patchlist.getAttribute('id'),'No patches have been selected for installation',2);
		patchlist.style.backgroundColor="orange";
		return;
	}

	var machCount=0;

	//check for machines

	if (machlist.options.length==0)
	{
		inlineMsg('machinelistto','No machines have been selected for installation',2);
		document.getElementById("machinelistto").style.backgroundColor="orange";
		return;
	}


	for ( var m=0; m<machlist.options.length; m++ ){
		for (var p=0; p<patchlist.options.length; p++)
		{
			if (patchlist.options[p].selected)
			{

				// Create text and value for a new option based on this machine, patch pair
				var text=machlist.options[m].text + ": Patch " + patchlist.options[p].text + " installation";
				var id=machlist.options[m].text + "_" + patchlist.options[p].text;
				var value="installpatch.php?machine=" + machlist.options[m].text + "&v=" + v + "&p=" + patchlist.options[p].text + "&userid=" + netsim_userid.value;

				addtoqueue(text,value,id);
			}
		}
	}
}

// This function manages whether the buttons to control the queue should be enabled disabled
// It uses the installingQueue variable aswell as the length of the queue to decide

function updateQueueButtons()
{
	var queuelist = document.getElementById("queue");
	var queueinstall = document.getElementById("queueinstall");
	var stopqueueinstall = document.getElementById("stopqueueinstall");

	if (!installingQueue && queuelist.options.length>0)
	{
		queueinstall.disabled=false;
	}
	else
	{
		queueinstall.disabled=true;
	}

	if (installingQueue)
	{
		stopqueueinstall.disabled=false;
	}
	else
	{
		stopqueueinstall.disabled=true;
	}
}

// This function is used by a timer to refresh the status viewer. It is only necesary to repeatedly read the log if we are viewing the last item in the log list

// This function begins installing the queue when the user clicks on a button
// It starts an interval which updates the status viewer with output from the installation at regular intervals

function installqueue()
{
	allowedInstallQueue=true;
	continueinstallqueue();
}



// This function starts the installation of the topmost item in the queue
// Its callback function is validateinstallqueue

function continueinstallqueue()
{
	var queuelist = document.getElementById("queue");
	var pic = document.getElementById("wait");

	if (queuelist.options.length>0 && allowedInstallQueue)
	{
		// display the wait.gif animation to indicate activity

		pic.style.left="495";

		// Update the queue buttons

		installingQueue=true;
		updateQueueButtons();

		// Update the standard log to indicate we are installing
		addDashes();
		updateStatus ("Starting " + queuelist.options[0].text,false,true);

		// Start the ajax installation and add a new item to the log list so we can view the progress of installation
		var url="Include/"+queuelist.options[0].value;
		queuelist.removeChild(queuelist.options[0]);

		var ajax = new AJAXInteraction(url, validateinstall,true);
		ajax.doGet();
	}
	else
	{
		// If we are finished installing the queue, we must stop the interval timer, update the buttons and stop the animated gif which indicated activity
		installingQueue=false;
		updateQueueButtons();
		pic.style.left="-500";
	}

}

// This is the callback function used to retrieve the exit status of an installation

function validateinstall(responseText)
{

	// The responseText is again comma delmited, with the 4th element being the exit code of the installation
	var response_array=responseText.split(",");
	if (response_array[3]==0)
	{
		updateStatus(response_array[2] + " on " +response_array[0] + " finished. Please check log for errors.",false,true);
		addDashes();
		//update page
		get_db_entries();
		getversions();
		continueinstallqueue();
	}
	else
	{
		// A non zero return code was found, if the halt on error option is selected, we stop the queue installation

		updateStatus(response_array[2] + " on " +response_array[0] + " finished unsuccessfully. Check log for more details",true,true);
		addDashes();
		var halt=document.getElementById("halt");
		if (halt.checked)
		{
			updateStatus("Stopping queue progression",true,true);
			addDashes();
			stopqueue();
			continueinstallqueue();
		}
		else
		{
			continueinstallqueue();
		}
	}
}

// This function is used to update the status viewer with the appropriate output
// It often calls the getlog.php page which retrieves the installation log of a machine during execution


// This function sets the allowedInstallQueue variable to false which in turn stops the queue after the current patch installation exits

function stopqueue()
{
	allowedInstallQueue=false;
}


// This function loops through items in the queue and removes selected ones

function removeQueueItems()
{
	var queuelist = document.getElementById("queue");
	for ( var i=0; i<queuelist.options.length; i++ ){
		if(queuelist.options[i].selected)
		{
			queuelist.remove(i);
			i--;
		}
	}
}


// This function enables/disables the sim_file drop-down list

function toggleSimFile()
{
	if ((document.getElementById("sim_file_bypass").checked))
	{
		document.getElementById("sim_file").disabled=true;
	}
	else
	{
		document.getElementById("sim_file").disabled=false;
		document.getElementById("sim_file").focus();
	}
}


// This function adds a netsim install to the queue

function addtoqueue_netsim()
{
	var netsim_machinelist_to = document.getElementById("machinelistto");
	var machineselected=netsim_machinelist_to.options.length;

	var netsim_email = document.getElementById("netsim_email");
	var netsim_userid = document.getElementById("netsim_userid");
	var netsim_project = document.getElementById("netsim_project");

	var netsim_version = document.getElementById("netsim_version");
	var netsim_testing_type = document.getElementById("netsim_testing_type");
	var setup_ssh=document.getElementById("setup_ssh");

	netsim_version.style.backgroundColor="white";
	netsim_testing_type.style.backgroundColor="white";
	netsim_project.style.backgroundColor="white";
	netsim_machinelist_to.style.backgroundColor="white";

	if (machineselected==0)
	{
		netsim_machinelist_to.style.backgroundColor="orange";
		inlineMsg('machinelistto','Please select a machine',2);	
		return
	}
	if (! /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(netsim_email.value))
	{
		inlineMsg('netsim_email','Please enter valid email address',2);
		return
	}
	if (netsim_userid.value=="")
	{
		inlineMsg('netsim_userid','Please login in again, invalid userid',2);
		return
	}
	if (netsim_project.value=="")
	{	
		inlineMsg('netsim_project','Type a project name',2);
		netsim_project.style.backgroundColor="orange";
		return
	}
	if (netsim_testing_type.selectedIndex==0)
	{
		inlineMsg('netsim_testing_type','Please select test type machines',2);
		netsim_testing_type.style.backgroundColor="orange";
		return
	}
	if (netsim_version.selectedIndex==0)
	{
		inlineMsg('netsim_version','Please select Netsim Version',2);
		netsim_version.style.backgroundColor="orange";
		return
	}
	
	if (netsim_version.selectedIndex!=0 && machineselected!=0)
	{
		var url="";
		var ajax = new AJAXInteraction(url, validateit,false);
		var response;
		for ( var i=0; i<netsim_machinelist_to.options.length; i++ ){
			url="Include/check_netsimver_db.php?s="+ netsim_machinelist_to.options[i].text +"&v="+ netsim_version.value;
			ajax.seturl(url);
			response = ajax.doGet();
			if (response!="0")
			{
				inlineMsg('netsim_version',netsim_version.value + " already installed on " + netsim_machinelist_to.options[i].text+ ". Use the Remove Entry function first",2);
				return
			}

			url="Include/check_netsim_rsh.php?s="+ netsim_machinelist_to.options[i].text;
			ajax.seturl(url);
			response = ajax.doGet();
			response="0";
			if (response!="0")
			{
				inlineMsg('netsim_version','Rsh not working on ' + netsim_machinelist_to.options[i].text + ', please use special functions at the bottom of this page to Setup Rsh. No TEP Ticket Required',2);
				return
			}
		}
	}
	for ( var i=0; i<netsim_machinelist_to.options.length; i++ ){
		var text=netsim_machinelist_to.options[i].text+": Netsim " + netsim_version.value + " installation";
		var id=netsim_machinelist_to.options[i].text+"_"+netsim_version.value;
		var value="installnetsim.php?machine=" + netsim_machinelist_to.options[i].text + "&userid=" + URLEncode(netsim_userid.value) + "&p=" + URLEncode(netsim_project.value)  + "&v=" + netsim_version.value + "&t=" + URLEncode(netsim_testing_type.value) +"&e=" + netsim_email.value + "&ssh=" + setup_ssh.checked;
		//alert(value);
		addtoqueue(text,value,id);
	}
}

function validateit()
{

}

// This function emulates the urlencode feature in php, It makes sure strings with spaces and special characters can be placed in a url like in addtoqueue_netsim
function URLEncode (clearString) {
	var output = '';
	var x = 0;
	clearString = clearString.toString();
	var regex = /(^[a-zA-Z0-9_.]*)/;
	while (x < clearString.length) {
		var match = regex.exec(clearString.substr(x));
		if (match != null && match.length > 1 && match[1] != '') {
			output += match[1];
			x += match[1].length;
		} else {
			if (clearString[x] == ' ')
				output += '+';
			else {
				var charCode = clearString.charCodeAt(x);
				var hexVal = charCode.toString(16);
				output += '%' + ( hexVal.length < 2 ? '0' : '' ) + hexVal.toUpperCase();
			}
			x++;
		}
	}
	return output;
}

// This function highlights the netsim tab when selected

function clicked_netsim_tab()
{
	var patchlist = document.getElementById("patchlist");
	patchlist.style.visibility="hidden";

	var netsim_div = document.getElementById("install_netsim_div");
	netsim_div.style.visibility="visible";

	var patchtitle = document.getElementById("patchtitle");
	var netsimtitle = document.getElementById("netsim_title");

	patchtitle.setAttribute((document.all ? 'className' : 'class'),"deselected")
		netsimtitle.setAttribute((document.all ? 'className' : 'class'),"selected")
}

// This function highlights the patch tab when selected

function clicked_patch_tab()
{
	var patchlist = document.getElementById("patchlist");
	patchlist.style.visibility="visible";

	var netsim_div = document.getElementById("install_netsim_div");
	netsim_div.style.visibility="hidden";

	var patchtitle = document.getElementById("patchtitle");
	var netsimtitle = document.getElementById("netsim_title");

	patchtitle.setAttribute((document.all ? 'className' : 'class'),"selected");
	netsimtitle.setAttribute((document.all ? 'className' : 'class'),"deselected");
}


// This function moves machines from one list to another,f and t being the names of the div's from and to

	function move_selected(f,t) {
		var from = document.getElementById(f)
			var to = document.getElementById(t)
			for (var i = 0; i < from.options.length; i++)
			{
				if (from.options[i].selected)
				{
					var newopt = new Option(from.options[i].text,from.options[i].text+"_"+t);
					newopt.setAttribute("id",from.options[i].text+"_"+t);
					to.options[to.options.length]=newopt;
					from.remove(i);

					//to.add(from.options[i],null);
					i--
				}
			}
		getversions()
	}

// This function calls adds an entry to the queue to install mrtg.
function addtoqueue_mrtg()
{
	var machine=document.getElementById("reinstall_netsim_machinelist");
	var netsim_email = document.getElementById("netsim_email");
	var netsim_userid = document.getElementById("netsim_userid");

	if (! /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(netsim_email.value))
	{
		inlineMsg('netsim_email','Invalid Email Address',2);
		return
	}
	var text=machine.value+": MRTG Setup";
	var id=machine.value+"_mrtg";
	var value="install_mrtg.php?machine=" + machine.value + "&e=" +  netsim_email.value + "&userid=" + netsim_userid.value;
	addtoqueue(text,value,id);
}

function addtoqueue_cvs()
{
	var machine=document.getElementById("reinstall_netsim_machinelist");
	var netsim_userid = document.getElementById("netsim_userid");

	var text=machine.value+": CVS Installation";
	var id=machine.value+"_cvs";
	var value="install_cvs.php?machine=" + machine.value + "&userid=" + netsim_userid.value;
	addtoqueue(text,value,id);
}

// This function calls a script to validate that this is a valid ericsson id and retrieve the users email
function enteredLogin()
{
	var login_error=document.getElementById("login_error");
	login_error.innerHTML="Logging in, please wait...";
	var eid=document.getElementById("useridlogin").value;

	var idRegex=/^[0-9a-zA-Z]+$/;
	if (eid.match(idRegex))
	{
		var url="Include/login.php?e="+ eid;
		var ajax = new AJAXInteraction(url, validatelogin,true);
		ajax.doGet();
	}
	else
	{
		login_error.innerHTML="Invalid Ericsson ID, please try again";
	}
}

// This is the enteredLogin callback function and retrieves the email of the user if it is a valid id
function validatelogin(responseText)
{
	var response_array=responseText.split(",");
	if (response_array[0]=="")
	{
		var login_error=document.getElementById("login_error");
		login_error.innerHTML="Invalid Ericsson ID, please try again";
	}
	else
	{
		logged_in_fine(response_array[1],response_array[0]);

            var current_date = new Date;
            var cookie_year = current_date.getFullYear ( ) + 1;
            var cookie_month = current_date.getMonth ( );
            var cookie_day = current_date.getDate ( );
            set_cookie ( "username", response_array[1], cookie_year, cookie_month, cookie_day );
	    set_cookie ( "email", response_array[0], cookie_year, cookie_month, cookie_day );	
	}
}
function logged_in_fine(username, email)
{
	replaceButtonText("sign_out","Sign Out ("+username+")");

	var netsim_email = document.getElementById("netsim_email");
        var netsim_userid = document.getElementById("netsim_userid");
        var contents = document.getElementById("contents");
        var login = document.getElementById("login");
	netsim_email.value=email;
	netsim_userid.value=username;
	contents.style.visibility="visible";
	login.style.visibility="hidden";
}
function delete_cookie ( cookie_name )
{
  var cookie_date = new Date ( );  // current date & time
  cookie_date.setTime ( cookie_date.getTime() - 1 );
  document.cookie = cookie_name += "=; expires=" + cookie_date.toGMTString();
}
function get_cookie ( cookie_name )
{
  var results = document.cookie.match ( '(^|;) ?' + cookie_name + '=([^;]*)(;|$)' );

  if ( results )
    return ( unescape ( results[2] ) );
  else
    return null;
}
function set_cookie ( name, value, exp_y, exp_m, exp_d, path, domain, secure )
{
  var cookie_string = name + "=" + escape ( value );

  if ( exp_y )
  {
    var expires = new Date ( exp_y, exp_m, exp_d );
    cookie_string += "; expires=" + expires.toGMTString();
  }

  if ( path )
        cookie_string += "; path=" + escape ( path );

  if ( domain )
        cookie_string += "; domain=" + escape ( domain );
  
  if ( secure )
        cookie_string += "; secure";
  
  document.cookie = cookie_string;
}

// This function calls a script which attempts to setup rsh on a machine
function setup_rsh()
{
	var password = document.getElementById("root_password");
	var machine = document.getElementById("reinstall_netsim_machinelist");
	password.style.backgroundColor="white";
	if (password.value.length==0)
	{
		password.style.backgroundColor="orange";
		inlineMsg('password','Please type a root password',2);
	}
	else
	{
		addDashes();
		updateStatus("Setting up rsh on " + machine.value + ". Please wait...",false,true);
		var url="Include/Setup_rsh.php?password="+ password.value + "&machine=" + machine.value;
		var ajax = new AJAXInteraction(url, validatesetuprsh,true);
		ajax.doGet();
	}
}

// This function takes the return code from the rsh setup and updates the page with information whether it passed or encountered a problem
function validatesetuprsh(responseText)
{
	if (responseText==0)
	{
		updateStatus("Finished setting up rsh",false,true);
	}
	else
	{
		updateStatus("Encountered a problem setting up rsh",true,true);
	}
	addDashes();
}

function special_machine_changed()
{
	get_db_entries();
	get_simulation_dirs();
	//
	var backup_type = document.getElementById("backup_type");
	backup_type.selectedIndex=0;
	changed_backup_type();
	//
	get_backups();
	//
	var restore_type = document.getElementById("restore_type");
	restore_type.selectedIndex=0;
	changed_restore_type();
	//
	selectedFunction()
}

// This function reads the netsim installation records from the database for this machine
function get_db_entries()
{
	var server = document.getElementById("reinstall_netsim_machinelist").value;
	var url="Include/get_db_entries.php?server="+ server;
	var ajax = new AJAXInteraction(url, validate_get_db_entries,true);
	ajax.doGet();
}

// This function udpates the list of netsim versions installed on the selected machine
function validate_get_db_entries(responseText)
{
	var netsim_version=document.getElementById("reinstall_netsim_version");
	netsim_version.innerHTML="";
	var response_array=responseText.split(",");
	for ( var i=1; i<response_array.length-1; i++ ){
		var newopt = new Option(response_array[i],response_array[i]);
		netsim_version.options[netsim_version.options.length]=newopt;
	}
}
function get_backups()
{
	var server = document.getElementById("reinstall_netsim_machinelist").value;
	var url="Include/get_backups.php?machine="+ server;
	var ajax = new AJAXInteraction(url, validate_get_backups,true);
	ajax.doGet();
}
function validate_get_backups(responseText)
{
	var response_array=responseText.split(",");
	var server = document.getElementById("reinstall_netsim_machinelist").value;
	var restore_type=document.getElementById("restore_type");
	var restore_simulations=document.getElementById("restore_simulations")
		if (response_array[0] == server)
		{
			restore_type.innerHTML="";
			restore_simulations.innerHTML="";

			var newopt = new Option("Choose Type","Choose Type");
			restore_type.options[restore_type.length]=newopt;		

			if (response_array.length>3)
			{
				var newopt = new Option("Simulation","Simulation");
				restore_type.options[restore_type.length]=newopt;
				for ( var i=3; i<response_array.length; i++ ){
					var newopt = new Option(response_array[i],response_array[i]);
					restore_simulations.options[restore_simulations.length]=newopt;
				}
			}
			if (response_array[2]==1)
			{
				var newopt = new Option("/netsim/","netsim");
				restore_type.options[restore_type.length]=newopt;
			}

			if (response_array[1]==1)
			{
				var newopt = new Option("Exported Items","exported_items");
				restore_type.options[restore_type.length]=newopt;
			}
		}
}

// This function removes a netsim installation entry from the database
function remove_netsim_db()
{
	var netsim_version=document.getElementById("reinstall_netsim_version").value;
	var server = document.getElementById("reinstall_netsim_machinelist").value;
	addDashes();
	updateStatus("Removing database entry for " + server + " and " + netsim_version,false,true);
	var url="Include/remove_netsim_db.php?server="+ server + "&version=" + netsim_version;
	var ajax = new AJAXInteraction(url, validate_remove_netsim_db,true);
	ajax.doGet();
}
function update_license()
{
        var server = document.getElementById("reinstall_netsim_machinelist").value;
	var filename = document.getElementById("update_license_version").value;
        addDashes();
        updateStatus("Updating license for " + server,false,true);
        var url="Include/updateNetsimLicense.php?server="+ server + "&filename=" + filename;
        var ajax = new AJAXInteraction(url, validate_update_license,true);
        ajax.doGet();
}

function validate_update_license(responseText)
{
	updateStatus("License updated",false,true);
        addDashes();
}
// This function must retrieve the database entries for this machine again as the removal was completed
function validate_remove_netsim_db(responseText)
{
	get_db_entries();
	updateStatus("Removed from database successfully",false,true);
	addDashes();
}


// This function allows adding a new server to the netsim database
function add_server()
{
	var server=document.getElementById("server_to_add");
	server.style.backgroundColor="white";
	if (server.value=="")
	{
		server.style.backgroundColor="orange";
		inlineMsg('server_to_add','Please type a server name to be added',2);
	}
	else
	{
		updateStatus("Adding " + server.value + " to database. Please wait...",false);
		var url="Include/AddNewServer.php?server="+ server.value;
		var ajax = new AJAXInteraction(url, validate_add_server,true);
		ajax.doGet();
	}
}

// After a machine is added to the database, we must retrieve the machine list again
function validate_add_server(responseText)
{
	updateStatus(responseText,false);
	getmachinelist();
}

// This function shows / hides the special functions div
function show_hide_special()
{
	var specialdiv = document.getElementById("specialfunctionsdiv");
	if (specialdiv.style.visibility=="visible")
	{
		specialdiv.style.visibility="hidden"
			window.scroll(0,0); // horizontal and vertical scroll targets
	}
	else
	{
		specialdiv.style.visibility="visible"
			window.scroll(0,1000); // horizontal and vertical scroll targets
	}
}
function request_backup()
{
	var netsim_email = document.getElementById("netsim_email");
	var netsim_userid = document.getElementById("netsim_userid");
	var server = document.getElementById("reinstall_netsim_machinelist").value;

	var backup_type = document.getElementById("backup_type");
	var reason = document.getElementById("reason_box");
	var backup_dir=""

		reason.style.backgroundColor="white";
	backup_type.style.backgroundColor="white";
	document.getElementById("simulations").style.backgroundColor="white";


	if (backup_type.selectedIndex==0)
	{
		backup_type.style.backgroundColor="orange";
		inlineMsg('backup_type','Invalid Backup Type Selected',2);
		return
	}
	else if (backup_type.selectedIndex==1)
	{
		var simulations = document.getElementById("simulations");
		if (simulations.value!="")
		{
			backup_dir="/netsim/netsimdir/"+simulations.value+"/";
		}
		else
		{
			simulations.style.backgroundColor="orange";
			inlineMsg('simulations','Please select a simulation',2);
			return
		}
	}
	else if (backup_type.selectedIndex==2)
	{
		backup_dir="/netsim/";
	}
	else
	{
		backup_dir="/netsim/netsimdir/exported_items/";
	}
	if (reason.value=="")
	{
		reason.style.backgroundColor="orange";
		inlineMsg('reason_box','Please type a reason for this backup',2);
		return
	}
	addDashes();
	updateStatus("Sending backup request..",false,true);
	var url="Include/request_backup.php?server="+ server + "&email=" + netsim_email.value + "&dir=" + backup_dir + "&reason=" + URLEncode(reason.value);
	var ajax = new AJAXInteraction(url, validate_request_backup,true);
	ajax.doGet();
	finishedFunction()
}
function validate_request_backup(responseText)
{
	updateStatus("Backup Request Complete. Confirmation email sent.",false,true);
	addDashes();
}
function finishedFunction()
{
	document.getElementById("select_function").selectedIndex=0;
	selectedFunction();
}
function backup_login()
{
	var code=document.getElementById("backup_login_code");
	var netsim_email = document.getElementById("netsim_email").value;

	code.style.backgroundColor="white";

	if (code.value=="")
	{
		code.style.backgroundColor="orange";
		inlineMsg('backup_login_code','Please enter a code before proceeding',2);
		return
	}
	addDashes();	
	updateStatus("Logging in to perform backup",false,true);
	var url="Include/backup_login.php?email=" + netsim_email + "&code=" + code.value;
	var ajax = new AJAXInteraction(url, validate_backup_login,true);
	ajax.doGet();
}
function validate_backup_login(responseText)
{
	var response_array=responseText.split(",");
	if (response_array[0]==0)
	{
		document.getElementById("backup_machine").value=response_array[2];
		document.getElementById("backup_path").value=response_array[1];
		document.getElementById("backup_reason").value=response_array[3];
		selectedFunctionName("perform_backup_div");
		updateStatus("Logged in successfully",false,true);
	}
	else
	{
		inlineMsg('backup_login_code',"This backup "+response_array[1],2);
	}
	addDashes();
}
function changed_backup_type()
{
	var backup_type = document.getElementById("backup_type");
	var simulations = document.getElementById("simulations");
	if (backup_type.selectedIndex==1)
	{
		simulations.disabled=false;
	}
	else
	{
		simulations.disabled=true;
	}
}
function changed_restore_type()
{
	var restore_type = document.getElementById("restore_type");
	var simulations = document.getElementById("restore_simulations");
	if (restore_type.value=="Simulation")
	{
		simulations.disabled=false;
	}
	else
	{
		simulations.disabled=true;
	}
}

function get_simulation_dirs()
{
	var backup_type = document.getElementById("backup_type");
	var server = document.getElementById("reinstall_netsim_machinelist").value;
	var simulations = document.getElementById("simulations");

	simulations.innerHTML="";

	simulations.disabled=false;
	var url="Include/get_simulation_dirs.php?server="+ server;
	var ajax = new AJAXInteraction(url, validate_get_simulation_dirs,true);
	ajax.doGet();
}
function validate_get_simulation_dirs(responseText)
{
	var server = document.getElementById("reinstall_netsim_machinelist").value;
	var simulations = document.getElementById("simulations");
	var response_array=responseText.split(",");

	//make sure talking about correct machine
	if (response_array[0]==server)
	{
		for ( var i=1; i<response_array.length-1; i++ ){
			var newopt = new Option(response_array[i],response_array[i]);
			simulations.options[simulations.options.length]=newopt;
		}

	}
}
function addtoqueue_backup()
{
	var machine=document.getElementById("backup_machine");
	var path=document.getElementById("backup_path");
	var project=document.getElementById("backup_project");
	var assoc_machines=document.getElementById("backup_assoc_machines");
	var oss=document.getElementById("backup_assoc_oss");
	var smrs=document.getElementById("backup_assoc_smrs");
	var code=document.getElementById("backup_login_code");
	var reason=document.getElementById("backup_reason");

	var netsim_email = document.getElementById("netsim_email");
	var netsim_userid = document.getElementById("netsim_userid");

	project.style.backgroundColor="white";
	assoc_machines.style.backgroundColor="white";
	oss.style.backgroundColor="white";
	smrs.style.backgroundColor="white";

	if (project.value=="")
	{
		project.style.backgroundColor="orange";
		inlineMsg('backup_project','Please enter a project',2);
		return
	}

	if (assoc_machines.value=="")
	{
		assoc_machines.style.backgroundColor="orange";
		inlineMsg('backup_assoc_machines','"Please enter associated machines list',2);
		return
	}

	if (oss.value=="")
	{
		oss.style.backgroundColor="orange";
		inlineMsg('backup_assoc_oss','Please enter an oss name',2);
		return
	}

	if (smrs.value=="")
	{
		smrs.style.backgroundColor="orange";
		inlineMsg('backup_assoc_smrs','Please enter an smrs',2);
		return
	}

	//Make Readme
	var readme="Date: " + Date() +
		"\\nOwner ID: " + netsim_userid.value +
		"\\nReason: " + reason.value +
		"\\nMachine Name: " + machine.value + 
		"\\nProject Name: " + project.value +
		"\\nBackup Directory: " + path.value +
		"\\nNetsim Servers: " + assoc_machines.value +
		"\\nAssociated OSS: " + oss.value +
		"\\nAssociated SMRS: " + smrs.value;

	var id="Backup_" + machine.value;
	var text=machine.value + ": Backup of " + path.value;
	var value="create_backup.php?machine=" + machine.value + "&dir=" + URLEncode(path.value)+"&readme=" + URLEncode(readme) + "&id=" + code.value + "&userid=" + netsim_userid.value;


	addtoqueue(text,value,id);
	finishedFunction();
}

function addtoqueue_restore()
{
	restore_type=document.getElementById("restore_type")
		simulation=document.getElementById("restore_simulations")
		machine=document.getElementById("reinstall_netsim_machinelist");
	var netsim_userid = document.getElementById("netsim_userid");

	if (restore_type.selectedIndex==0)
	{
		inlineMsg('restore_type',"Please select a restore type",2);
		return
	}
	if (restore_type.value=="Simulation" && simulation.value=="")
	{
		inlineMsg('restore_simulation',"Please select a valid simulation",2);
		return
	}
	var value="restore_backup.php?machine="+machine.value+ "&userid=" + netsim_userid.value + "&directory=";
	if (restore_type.value=="Simulation")
	{
		value=value+simulation.value;
		var text=machine.value+": Restore of " + simulation.value
	}
	else
	{
		value=value+restore_type.value;
		var text=machine.value+": Restore of " + restore_type.value
	}
	var id="Restore_"+machine.value;
	addtoqueue(text,value,id);

	finishedFunction();
}

document.getElementsByClassName = function(cl) {
	var retnode = [];
	var myclass = new RegExp('\\b'+cl+'\\b');
	var elem = this.getElementsByTagName('*');
	for (var i = 0; i < elem.length; i++) {
		var classes = elem[i].className;
		if (myclass.test(classes)) retnode.push(elem[i]);
	}
	return retnode;
}; 

function hideFunctions()
{
	var list=document.getElementsByClassName("functiondiv");
	for ( var i=0; i<list.length; i++ ){
		list[i].style.left="-1500";
	}
}

function selectedFunction()
{
	hideFunctions();
	var selectfunction = document.getElementById("select_function");
	var machinelist=document.getElementById("reinstall_netsim_machinelist");
	if (selectfunction.selectedIndex==0 || selectfunction.value=="add_server" || selectfunction.value=="backup_login_div" )
	{
		machinelist.disabled=true;

		if (selectfunction.selectedIndex!=0)
		{
			selectedFunctionName(selectfunction.value)
		}
	}
	else
	{
		machinelist.disabled=false;
		if (machinelist.selectedIndex>0)
		{
			selectedFunctionName(selectfunction.value);
		}
	}
}
function selectedFunctionName(functionName)
{
	hideFunctions();
	document.getElementById(functionName).style.left="560";
}
function changeFunctionIndex(optionid)
{
	document.getElementById("select_function").selectedIndex=document.getElementById(optionid).index;
	selectedFunction();
}

// START OF MESSAGE SCRIPT //


// build out the divs, set attributes and call the fade function //
function inlineMsg(target,string,autohide) {
	var msg;
	var msgcontent;
	if(!document.getElementById('msg')) {
		msg = document.createElement('div');
		msg.id = 'msg';
		msgcontent = document.createElement('div');
		msgcontent.id = 'msgcontent';
		document.body.appendChild(msg);
		msg.appendChild(msgcontent);
		msg.style.filter = 'alpha(opacity=0)';
		msg.style.opacity = 0;
		msg.alpha = 0;
	} else {
		msg = document.getElementById('msg');
		msgcontent = document.getElementById('msgcontent');
	}
	msgcontent.innerHTML = string;
	msg.style.display = 'block';
	var msgheight = msg.offsetHeight;
	var targetdiv = document.getElementById(target);
	targetdiv.focus();
	var targetheight = targetdiv.offsetHeight;
	var targetwidth = targetdiv.offsetWidth;
	var topposition = topPosition(targetdiv) - ((msgheight - targetheight) / 2);
	var leftposition = leftPosition(targetdiv) + targetwidth + MSGOFFSET;
	msg.style.top = topposition + 'px';
	msg.style.left = leftposition + 'px';
	clearInterval(msg.timer);
	msg.timer = setInterval("fadeMsg(1)", MSGTIMER);
	if(!autohide) {
		autohide = MSGHIDE;  
	}
	window.setTimeout("hideMsg()", (autohide * 1000));
}

// hide the form alert //
function hideMsg(msg) {
	var msg = document.getElementById('msg');
	if(!msg.timer) {
		msg.timer = setInterval("fadeMsg(0)", MSGTIMER);
	}
}

// face the message box //
function fadeMsg(flag) {
	if(flag == null) {
		flag = 1;
	}
	var msg = document.getElementById('msg');
	var value;
	if(flag == 1) {
		value = msg.alpha + MSGSPEED;
	} else {
		value = msg.alpha - MSGSPEED;
	}
	msg.alpha = value;
	msg.style.opacity = (value / 100);
	msg.style.filter = 'alpha(opacity=' + value + ')';
			if(value >= 99) {
			clearInterval(msg.timer);
			msg.timer = null;
			} else if(value <= 1) {
			msg.style.display = "none";
			clearInterval(msg.timer);
			}
			}

			// calculate the position of the element in relation to the left of the browser //
			function leftPosition(target) {
			var left = 0;
			if(target.offsetParent) {
			while(1) {
			left += target.offsetLeft;
			if(!target.offsetParent) {
			break;
			}
			target = target.offsetParent;
			}
			} else if(target.x) {
				left += target.x;
			}
			return left;
			}

// calculate the position of the element in relation to the top of the browser window //
function topPosition(target) {
	var top = 0;
	if(target.offsetParent) {
		while(1) {
			top += target.offsetTop;
			if(!target.offsetParent) {
				break;
			}
			target = target.offsetParent;
		}
	} else if(target.y) {
		top += target.y;
	}
	return top;
}

// preload the arrow //
if(document.images) {
	arrow = new Image(7,80); 
	arrow.src = "Include/msg_arrow.gif"; 
}
function detectBrowser()
{
	var browser=navigator.appName;
	var b_version=navigator.appVersion;
	var version=parseFloat(b_version);
	if ((browser=="Microsoft Internet Explorer")
			&& (version>=4))
	{
		MSGTIMER = 20;
		MSGSPEED = 500;
		MSGOFFSET = 3;
		MSGHIDE = 3;
	}
	else
	{
		MSGTIMER = 20;
		MSGSPEED = 5;
		MSGOFFSET = 3;
		MSGHIDE = 3;
	}
}
