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
/////////////////////////////////////////////////////////////////////////////////////////
	
	     $client= $_POST['client'];
	     $staff= $_POST['staff'];
	     $plannedtime= $_POST['time'];
	     $description= $_POST['description'];
	     
		/////////////////////////////////////////////////////////////////////////////////
		if(!connect_to_database()) //connect to SQL database
			return;
		
		$id=time(); //set timestamp as id
		//start to execute SQL commands
		$querystr="INSERT INTO appointment VALUES ('"
								. $id . "', '" .
								$client . "', '" . 
								$staff . "', '" . 
		                        $plannedtime . "', '" . 
								$description . "')";
		//echo $querystr;
		$result=ExecuteQuery($querystr);
		if(!$result)
		{
			echo "no result followed by this query";
			return;
		}
		else
		{
			//Output to HTTP request
			//OutputStaffInfoResults($result);
			SendAppointmentNotificationToStaff($id, $staff);
			
		}
		
		close_database();
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>