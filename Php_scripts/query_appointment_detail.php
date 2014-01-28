
	<?php
	    include "lib_functions.php";
		///////////////////////////////////////////////////////////////
		function OutputAppointmentResults($result)
		{
			$resultArray = array();
			
			//get the number of lines we got
			$rows = mysql_num_rows($result);
			//echo "number of rows=" . $rows . "<br/>";
			if($rows>0)
			{
	
				$arrCol= array();
				$staff_id=mysql_result($result, 0,'staff');
				$arrCol["staff"]=$staff_id;
				$client_id=mysql_result($result, 0,'client');
				$arrCol["client"]=$client_id;
				
				//query client's fullname based on client ID
				$client_result=ExecuteQuery("SELECT * FROM personal_info WHERE userid='" . $client_id . "'");
				if($client_result)
				{
					//Output to HTTP request
					$arrCol["client_fullname"]=mysql_result($client_result, 0,'givename') . ' ' .
									mysql_result($client_result, 0,'surname');
				}
				
				//query staff's fullname based on client ID
				$staff_result=ExecuteQuery("SELECT * FROM staff_info WHERE userid='" . $staff_id . "'");
				if($staff_result)
				{
					//Output to HTTP request
					$arrCol["staff_fullname"]=mysql_result($staff_result, 0,'givename') . ' ' .
									mysql_result($staff_result, 0,'surname');
				}
					
				$arrCol["time"]=mysql_result($result,$j,'time');
				$arrCol["description"]= mysql_result($result,$j,'description');
				$arrCol["department"]= mysql_result($result,$j,'department');
				array_push($resultArray,$arrCol);

			}
			
			
			//Output to HTTP request
			
			echo json_encode($resultArray);
		}
		/////////////////////////////////////////////////////////////////////////////////
		if(!connect_to_database()) //connect to SQL database
			return;
			
			
		$appointment_id= $_POST['appointment_id'];
		
			
		//start to execute SQL commands
		$result=ExecuteQuery("SELECT * FROM appointment WHERE id='" . $appointment_id . "'");
		if($result)
		{
			//Output to HTTP request
			OutputAppointmentResults($result);
		}
		
		close_database();
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>
