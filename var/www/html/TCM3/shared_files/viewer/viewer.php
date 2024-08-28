<script src="http://atrclin2.athtem.eei.ericsson.se/TCM3/shared_files/viewer/viewer.js"></script>
<link type="text/css" rel="stylesheet" href="http://atrclin2.athtem.eei.ericsson.se/TCM3/shared_files/viewer/viewer.css">

<div id="viewer" class="outer">
	<div class="title" id="viewer_title">Installation Status Viewer</div>
	<div class="help" id="viewerhelp">
		The viewer shows recently completed and running installs
	</div>

	<SELECT onchange="changedlog()" size="15" id="loglist">
		<OPTION selected=true id="Page Log">Page Log</OPTION>
	</SELECT>
	<div id="status">
	</div>
	<SELECT onchange="changedTime()" id="viewer_time">
		<OPTION value="60">1 hr</OPTION>
		<OPTION value="120">2 hrs</OPTION>
		<OPTION value="180">3 hrs</OPTION>
		<OPTION value="240">4 hrs</OPTION>
		<OPTION value="480">8 hrs</OPTION>
		<OPTION value="720">12 hrs</OPTION>
		<OPTION value="1440">24 hrs</OPTION>
		<OPTION value="2880">48 hrs</OPTION>
		<OPTION value="4320">72 hrs</OPTION>
		<OPTION value="10080">1 wk</OPTION>
		<OPTION value="40320">4 wks</OPTION>
		<OPTION value="5256000">ALL</OPTION>
	</SELECT>
</div>
