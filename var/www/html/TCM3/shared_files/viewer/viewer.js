var LOG_DIR=""
var SCRIPT_DIR=""
var logTimer;
var t;
var previousSelID;
var previousSelType;	
var logRunningCount=0;
var logFinishedCount=0;
var recent_time=60;

function AJAXInteraction(url, callback,asynch) {

        var req = init();
        req.onreadystatechange = processRequest;

        function init() {
                if (window.XMLHttpRequest) {
                        return new XMLHttpRequest();
                } else if (window.ActiveXObject) {
                        return new ActiveXObject("Microsoft.XMLHTTP");
                }
        }

        function processRequest () {
                // readyState of 4 signifies request is complete
                if (req.readyState == 4) {
                        // status of 200 signifies sucessful HTTP call
                        if (req.status == 200) {
                                if (callback)
                                {
                                        callback(req.responseText);
                                }
                        }
                }
        }
        this.seturl = function(inurl)
        {
                url=inurl;
        };
        this.doGet = function() {
                // make a HTTP GET request to the URL asynchronously
                req.open("GET", url, asynch);
                req.send(null);
                if (!asynch)
                {
                        if (callback)
                        {

                                return req.responseText;
                                //callback(req.responseText);
                        }
                }
        };
}

function load_viewer(log,script)
{
	LOG_DIR=log;
	SCRIPT_DIR=script;
	clearInterval(logTimer);
        logTimer=setInterval(getLogList,4000);

        clearInterval(t);
        t=setInterval(refreshLog,500);
	document.getElementById("loglist").selectedIndex=0;
	document.getElementById("viewer_time").selectedIndex=0;
	getLogList();
	changedlog();
}
// This function is used by a timer to refresh the status viewer. It is only necesary to repeatedly read the log if we are viewing the last item in the log list

function refreshLog()
{
        var loglist = document.getElementById("loglist");
        if (loglist.selectedIndex>2+logFinishedCount)
        {
                changedlog();
        }
}
function changedTime()
{
	var viewer_time=document.getElementById("viewer_time");
	recent_time=viewer_time.value;
	getLogList()
}
function getLogList()
{
        var url="http://atrclin2.athtem.eei.ericsson.se/TCM3/shared_files/viewer/getLogList.php?logdir=" + LOG_DIR + "&recent_time=" + recent_time;
        var ajax = new AJAXInteraction(url, validate_get_log_list,true);
        ajax.doGet();
}
var lastLogList="";

function validate_get_log_list(responseText)
{
	if (lastLogList==responseText)
	{
		return;
	}
	lastLogList=responseText;
        var response_array=responseText.split(",");
        var i=1;
        var doingRunning=false;
        logRunningCount=0;
        logFinishedCount=0;

        if (response_array[0]=="Finished")
        {
                var loglist=document.getElementById("loglist");

                //remember what was selected before
                if (loglist.selectedIndex>=0)
                {
                        previousSelID=loglist.options[loglist.selectedIndex].getAttribute("id");
			if (loglist.selectedIndex>(2+logFinishedCount))
                        {
				previousSelType="Running";
			}
			else
			{
				previousSelType="Finished";
			}
                }
                loglist.innerHTML="";
                var newopt = new Option("-- Page Log --","-- Page Log --");
                newopt.setAttribute("id","-- Page Log --");
                loglist.options[loglist.options.length]=newopt;

                var newopt = new Option("-- COMPLETED --","-- COMPLETED --");
                newopt.setAttribute("id","COMPLETED");
                loglist.options[loglist.options.length]=newopt;

                while (i<1000)
                {
                        if (response_array[i]=="Running")
                        {
                                i++;
                                doingRunning=true;
                                var newopt = new Option("-- RUNNING --  ","-- RUNNING --");
                                newopt.setAttribute("id","RUNNING");
                                loglist.options[loglist.options.length]=newopt;
                        }
                        if (response_array[i]=="done")
                        {
                                break;
                        }

                        var filename=response_array[i];
                        i++;
                        var log_creator=response_array[i];
                        i++;
                        var description=response_array[i];
                        i++;
                        if (doingRunning)
                        {
                                logRunningCount++;
                        }
                        else
                        {
                                logFinishedCount++;
                        }

                        //var netsim_userid = document.getElementById("netsim_userid");
                        //if (netsim_userid.value==log_creator)
                        //{
                        //        description="* " + description;

                        //}
                        description="---- " + description;
                        var newopt = new Option(description,description);
                        newopt.setAttribute("id",filename);
                        loglist.options[loglist.options.length]=newopt;
                }
		if (document.getElementById(previousSelID)!=null)
                {
			document.getElementById("loglist").selectedIndex=document.getElementById(previousSelID).index;
			var newType="";
                        if (loglist.selectedIndex>(2+logFinishedCount))
                        {
				newType="Running";
                                //Running
                        }
                        else
                        {
				newType="Finished";
				//Finished
                        }
			if (newType!=previousSelType)
			{
				changedlog();
			}

                }
                else
                {
                        document.getElementById("loglist").selectedIndex=0;
                        changedlog();
                }
        }
}
// This function is used to update the status viewer with the appropriate output
// It often calls the getlog.php page which retrieves the installation log of a machine during execution

function changedlog()
{
        var loglist = document.getElementById("loglist");
        var info = document.getElementById('status');


        // If topmost item, just display standard log, which is stored in variable status
        if (loglist.selectedIndex==0)
        {
		lastinfo=status;
                info.innerHTML=status;
                info.scrollTop=info.scrollHeight;
        }
        else
        {
                // If we have selected the last element in the loglist and we are installing this item, just get the tail of the output, otherwise read the whole log

                if (loglist.selectedIndex==1 || loglist.selectedIndex==(2+logFinishedCount))
                {
                        var info = document.getElementById('status');
			lastinfo="";
                        info.innerHTML="";
                }
                else if (loglist.selectedIndex>(2+logFinishedCount))
                {
                        var url="http://atrclin2.athtem.eei.ericsson.se/TCM3/shared_files/viewer/getlogtail.php?log="+loglist.options[loglist.selectedIndex].getAttribute("id")+"&logdir="+LOG_DIR;
                        var ajax = new AJAXInteraction(url, validategetlog,true);
                        ajax.doGet();
                }
                else
                {
			document.getElementById("status").innerHTML="Loading..."
			lastinfo="Loading..."
                        var url="http://atrclin2.athtem.eei.ericsson.se/TCM3/shared_files/viewer/getlog.php?log="+loglist.options[loglist.selectedIndex].getAttribute("id")+"&logdir="+LOG_DIR;
                        var ajax = new AJAXInteraction(url, validategetlog,true);
                        ajax.doGet();
                }
        }

}
// This is the callback function of the ajaxinteraction started in changedlog()
// The responseText is simply the contents of the log file
var lastinfo="";
function validategetlog(responseText)
{
        var info = document.getElementById('status');
        var loglist = document.getElementById("loglist");
        var response_array=responseText.split("_:_",2);

        // Make sure we only update the status viewer with this response if we still have that item selected
        if (loglist.options[loglist.selectedIndex].getAttribute("id")==response_array[0])
        {
		if (lastinfo != response_array[1])
                {
                        info.innerHTML=response_array[1];
                        info.scrollTop=info.scrollHeight;
                        lastinfo=response_array[1];
                }
        }

}

function updateStatus(input,error,time)
{

        if (error)
        {
                status=status+"<div class=\"error\">";
        }
        else
        {
                status=status+"<div>";
        }

        if (time)
        {
                var currentTime = new Date();
                var hours = currentTime.getHours();
                var minutes = currentTime.getMinutes();
                var seconds = currentTime.getSeconds();

                if (minutes < 10)
                {
                        minutes = "0" + minutes;
                }
                if (seconds < 10)
                {
                        seconds = "0" + seconds;
                }
                status=status+"["+ hours + ":"+minutes + ":" + seconds +"]: ";
        }

        status=status+input+"</div>";
        var loglist = document.getElementById("loglist");

        loglist.selectedIndex=0;
        // Call changedlog() which updates the status viewer
        changedlog();
}
function addDashes()
{
        updateStatus("<HR />",false,false);
}
