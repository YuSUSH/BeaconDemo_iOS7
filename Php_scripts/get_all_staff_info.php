	<?php
	    include "lib_functions.php";
		///////////////////////////////////////////////////////////////
		function OutputStaffInfoResults($result)
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
					$arrCol["userid"]=mysql_result($result,$j,'userid');
					$arrCol["surname"]=mysql_result($result,$j,'surname');
					$arrCol["givename"]=mysql_result($result,$j,'givename');
					$arrCol["gender"]= mysql_result($result,$j,'gender');
					$arrCol["age"]= mysql_result($result,$j,'age');
					$arrCol["iconfilename"]= mysql_result($result,$j,'iconfilename');
					
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
		$result=ExecuteQuery("SELECT * FROM staff_info ORDER BY givename ASC");
		if(!$result)
		{
			echo "no result followed by this query";
			return;
		}
		else
		{
			//Output to HTTP request
			OutputStaffInfoResults($result);
		}
		
		close_database();
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>