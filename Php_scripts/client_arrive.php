<?php
include "lib_functions.php";

//Add the client the the table of 'inshop_users', showing all the existing users in the shop.
function AddClientInShop($userid)
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
		
		if($bAlreadyExist!=1)
		{
			//Add this to the inshop_users table
			$querystr="INSERT INTO inshop_users VALUES ('" .
								$userid . "')";
		    //echo $querystr;
		    ExecuteQuery($querystr);
		}
	}
}
////////////////////////////////////////////////////////////////////////////////////////
	function SendAppointmentNotificationToStaff($appointment_id, $staff_id)
	{
		//get the staff's token first
		$querystr="SELECT token from staff_info WHERE userid='" . $staff_id . "'";
		
		$staff_token='';
		
		//echo $querystr;
		$result=ExecuteQuery($querystr);
		if(!$result)
		{
			echo "no result followed by this query";
			return;
		}
		else
		{	
			//get the number of lines we got
			$rows = mysql_num_rows($result);
			//echo "number of rows=" . $rows . "<br/>";
			if($rows!=0)
			{
				$staff_token=mysql_result($result, 0,'token');
				
				//Send notification to the specified staff
				
				$url = 'http://experiment.sandbox.net.nz/beacon/simplepush.php';
				$fields = array(
							'device_type'=>urlencode("staff"),
				            'userid'=>urlencode($appointment_id),
				    		'token'=>urlencode($staff_token),
				    		'event'=>urlencode("meeting_due")
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
			}
		}
		
		
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	function SendAppointmentNotificationToClient($appointment_id, $client_id)
	{
		//get the client's token first
		$querystr="SELECT token from personal_info WHERE userid='" . $client_id . "'";
		
		$staff_token='';
		//echo $querystr;
		$result=ExecuteQuery($querystr);
		if(!$result)
		{
			echo "no result followed by this query";
			return;
		}
		else
		{	
			//get the number of lines we got
			$rows = mysql_num_rows($result);
			//echo "number of rows=" . $rows . "<br/>";
			if($rows!=0)
			{
				$client_token=mysql_result($result, 0,'token');
				
				//Send notification to the specified staff
				$url = 'http://experiment.sandbox.net.nz/beacon/simplepush.php';
				$fields = array(
							'device_type'=>urlencode("client"),
				            'userid'=>urlencode($appointment_id),
				    		'token'=>urlencode($client_token),
				    		'event'=>urlencode("meeting_due")
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
			}
		}
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
function CheckAppointmentDue($userid)
{
	//start to execute SQL commands
	$result=ExecuteQuery("SELECT * FROM appointment WHERE client='" . $userid . "'");

	if($result)
	{
		date_default_timezone_set("Pacific/Auckland");
		//get the number of lines we got
		$rows = mysql_num_rows($result);
		//echo "number of rows=" . $rows . "<br/>";
		if($rows!=0)
		{
			for ($j = 0 ; $j < $rows ; ++$j)
			{		
				$appointment_id=mysql_result($result,$j,'id');
				$staff=mysql_result($result,$j,'staff');
				$client=mysql_result($result,$j,'client');
				$timestr=mysql_result($result,$j,'time');
				
				//convert the string into time format
				$appointment_time=strtotime($timestr);
				$current_time=time(); //get current time;
				$diff=round(($appointment_time - $current_time) / 60,2);
				//echo "appointment_time=" . $timestr;
				//echo "diff=" . $diff;
				
				if($diff>0.0 && $diff< 30.0) //if meeting will start within 30 min
				{
					//Notify both the client and staff for the meeting
					SendAppointmentNotificationToClient($appointment_id, $client);
					SendAppointmentNotificationToStaff($appointment_id, $staff);
				}
			}
		}
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

$userid= $_POST['userid'];	

//Send notification to iPad
$url = 'http://experiment.sandbox.net.nz/beacon/simplepush.php';
$fields = array(
			'device_type'=>urlencode("ipad"),
            'userid'=>urlencode($userid),
    		'event'=>urlencode("in"),
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

if(!connect_to_database()) //connect to SQL database
		return;

//Add this user into the inshop_user table in the DB
AddClientInShop($userid);

//Check if there's any appointment related to this client due
CheckAppointmentDue($userid);

close_database();



//Send back a result to ask client to input new appoint info 
$resultArray = array();
			
//echo "number of rows=" . $rows . "<br/>";
$arrCol= array();
$arrCol["result"]="add_new"; //require client to input info for new appointment
$arrCol["shop_info"]="Federal Bureau of Investigation";
array_push($resultArray,$arrCol);
			
//Output to HTTP request
echo json_encode($resultArray);

?>

