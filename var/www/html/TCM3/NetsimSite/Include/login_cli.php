
<?php
        // This php page uses the getlog.sh script to get the contents of the log file, defined by $_GET['s']
        // Created by Mark Kennedy, July 2008

        include("constants.php");

        Include("/var/www/html/TCM3/ldap.php");
        if ($argv[1]!="")
        {
                echo ldap($argv[1]);
        }
?>
