	<?php
	    include "lib_functions.php";
////////////////////////////////////////////////////////////////////////////////////////
function CheckClientInShop($userid)
{			
	//firstly, check all the users in the shop now
	$bAlreadyExist=0;
	
	$result=ExecuteQuery("SELECT * FROM inshop_users");
	if($result)
	{
		$rows = mysql_num_rows($result);
		if($rows>0)
		{
			for ($j = 0 ; $j < $rows ; $j++)
			{		
				if( strcmp($userid,  mysql_result($result,$j,'userid') )==0)
				{
					$bAlreadyExist=1;
					break;
				}
			}
		}
		
		if($bAlreadyExist==1)
		{
			return 1;
		}
	}
	
	return -1;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////
	
	     $client= $_POST['client'];
	     
	    if(!connect_to_database()) //connect to SQL database
			return;
		
		if(CheckClientInShop($client)>0)
		{
			//output OK message
			$resultArray = array();
			$arrCol["result"]='OK';
			array_push($resultArray,$arrCol);
			//Output to HTTP request
			echo json_encode($resultArray);
		}
	
		close_database();
	?>