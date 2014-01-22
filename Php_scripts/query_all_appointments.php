
	<?php
	    include "lib_functions.php";
		///////////////////////////////////////////////////////////////
		function OutputAppointmentResults($result)
		{
			$resultArray = array();
			
			//get the number of lines we got
			$rows = mysql_num_rows($result);
			//echo "number of rows=" . $rows . "<br/>";
			if($rows!=0)
			{
				for ($j = 0 ; $j < $rows ; $j++)
				{		
					$arrCol= array();
					$arrCol["id"]=mysql_result($result,$j,'id');
					$arrCol["staff"]=mysql_result($result,$j,'staff');
					$client_id=mysql_result($result,$j,'client');
					$arrCol["client"]=$client_id;
					$arrCol["time"]=mysql_result($result,$j,'time');
					$arrCol["description"]= mysql_result($result,$j,'description');
					array_push($resultArray,$arrCol);
				}
			}
			
			
			//Output to HTTP request
			
			echo json_encode($resultArray);
		}
		/////////////////////////////////////////////////////////////////////////////////
		if(!connect_to_database()) //connect to SQL database
			return;
			
		
			
		//start to execute SQL commands
		$result=ExecuteQuery("SELECT * FROM appointment");
		if(!$result)
		{
			echo "no result followed by this query";
			return;
		}
		else
		{
			//Output to HTTP request
			OutputAppointmentResults($result);
		}
		
		close_database();
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>
