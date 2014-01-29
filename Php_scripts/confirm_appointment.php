<?php
include "lib_functions.php";

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
				    		'event'=>urlencode("confirm_meeting"),
				    		'alert_msg'=>urlencode("The staff has confirmed an appointment.")
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

$appointment= $_POST['appointment'];
$client= $_POST['client'];	


if(!connect_to_database()) //connect to SQL database
		return;

SendAppointmentNotificationToClient($appointment, $client);

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

