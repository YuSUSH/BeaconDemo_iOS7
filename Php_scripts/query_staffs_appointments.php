
	<?php
	    include "lib_functions.php";
		///////////////////////////////////////////////////////////////
		function OutputPersonalInfoResults($result)
		{
			$resultArray = array();
			
			//get the number of lines we got
			$rows = mysql_num_rows($result);
			//echo "number of rows=" . $rows . "<br/>";
			if($rows!=0)
			{
				for ($j = 0 ; $j < $rows ; ++$j)
				{		
					$arrCol= array();
					$arrCol["staff"]=mysql_result($result,$j,'staff');
					$arrCol["client"]=mysql_result($result,$j,'client');
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
			
			
		$userid= $_POST['userid'];
		
			
		//start to execute SQL commands
		$result=ExecuteQuery("SELECT * FROM appointment WHERE staff='" . $userid . "'");
		if(!$result)
		{
			echo "no result followed by this query";
			return;
		}
		else
		{
			//Output to HTTP request
			OutputPersonalInfoResults($result);
		}
		
		close_database();
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>
