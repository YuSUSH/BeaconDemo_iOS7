	<?php
	    include "lib_functions.php";
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
/////////////////////////////////////////////////////////////////////////////////////////
	
	     $client= $_POST['client'];
	     $staff= $_POST['staff'];
	     $appointment= $_POST['appointment'];
	     
		/////////////////////////////////////////////////////////////////////////////////
		if(!connect_to_database()) //connect to SQL database
			return;
		
		//SendAppointmentNotificationToStaff($id, $staff);
		SendAppointmentNotificationToClient($appointment, $client);
			
		
		close_database();
		
		//output OK message
		$resultArray = array();
		$arrCol["result"]='OK';
		array_push($resultArray,$arrCol);
		//Output to HTTP request
		echo json_encode($resultArray);
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>