<?php

function ldap($eid)
{

$ds=ldap_connect("ecd.ericsson.se");

if ($ds)
{
	$r=ldap_bind($ds, "uid=LDAPKBEN,ou=Users,ou=Internal,o=ericsson","zx12\$RFV!qaz");     // this is an "anonymous" bind, typically
	if($sr=ldap_search($ds, "o=ericsson", "uid=$eid"))
	{
		$info = ldap_get_entries($ds, $sr);

		for ($i=0; $i<$info["count"]; $i++)
		{
			//echo "" . $info[$i]["mail"][0] . "";
			return $info[$i]["mail"][0];
			$count=1;
		}
	    	if($count!=1)
	    	{
	    		return "";
	    	}

    		ldap_close($ds);
	}
	else
	{
	   	return "";
	}

}
}
?>
