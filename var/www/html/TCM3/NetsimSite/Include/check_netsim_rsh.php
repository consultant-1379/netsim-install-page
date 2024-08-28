<?php

	include("header.php");

        if (exec("rsh -l root -n ". $_GET['s'] . " id"))
        {
                echo "0";
        }
        else
        {
                echo "1";
        }
?>
