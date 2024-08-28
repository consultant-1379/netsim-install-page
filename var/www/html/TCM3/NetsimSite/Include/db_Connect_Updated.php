<?php
//Created by: ebildun
//the new PHP way of connecting to databases (i.e. no MySQL functions)
//use this db connection instead of db_Connect.php for any further code modifications or enhancements to application

$updated_dsn='mysql:host=localhost;dbname=Netsim';
$updated_username='root';
$updated_password='';

try
{
    $updated_db=new PDO($updated_dsn,$updated_username,$updated_password);
    //echo '<p>Connected to the database successfully.</p>';
}
catch (PDOException $updated_err)
{
    //grab the error message in case it needs to be used
	$updated_error_message=$updated_err->getMessage();
    echo '<p>Error in database.</p>';
	exit;
}
?>

