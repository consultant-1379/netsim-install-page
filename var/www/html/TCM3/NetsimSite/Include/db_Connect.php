<?php

        if($db = mysql_connect("localhost","root",""))
        {}
        else
        {
                echo "<b>Error in Database Connection- Report To TEP(TCM)</b>";
                exit;
        }
        if(mysql_select_db("Netsim",$db))
        {}
        else
        {
                echo "Error in database<br>";
        }
?>
