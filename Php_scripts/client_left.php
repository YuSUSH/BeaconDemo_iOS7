<?php
include "lib_functions.php";


//Remove the client from the table of 'inshop_users', showing all the existing users in the shop.
function RemoveClientInShop($userid)
{
	if(!connect_to_database()) //connect to SQL database
			return;
			
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
			//Add this to the inshop_users table
			$querystr="DELETE FROM inshop_users WHERE userid='" .  $userid . "'";
		    //echo $querystr;
		    ExecuteQuery($querystr);
		}
	}
		
	close_database();
}


$userid= $_POST['userid'];	

//Send notification to iPad
$url = 'http://experiment.sandbox.net.nz/beacon/simplepush.php';
$fields = array(
			'device_type'=>urlencode("ipad"),
            'userid'=>urlencode($userid),
    		'event'=>urlencode("out"),
    		'alert_msg'=>urlencode("A client has left the shop.")
        );

//url-ify the data for the POST
foreach($fields as $key=>$value) { $fields_string .= $key.'='.$value.'&'; }
rtrim($fields_string,'&');

//open connection
$ch = curl_init();

//set the url, number of POST vars, POST data
curl_setopt($ch,CURLOPT_URL,$url);
curl_setopt($ch,CURLOPT_POST,count($fields));
curl_setopt($ch,CURLOPT_POSTFIELDS,$fields_string);

//execute post
$result = curl_exec($ch);
//print $result;

RemoveClientInShop($userid); //remove the user from the current inshop user table in the DB




/*
//Send back a result to ask client to input new appoint info 
$resultArray = array();
			
//echo "number of rows=" . $rows . "<br/>";
$arrCol= array();
$arrCol["result"]="add_new"; //require client to input info for new appointment
array_push($resultArray,$arrCol);
			
//Output to HTTP request
echo json_encode($resultArray);
*/

?>

