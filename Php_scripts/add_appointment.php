	<?php
	    include "lib_functions.php";
	
	     $client= $_POST['client'];
	     $staff= $_POST['staff'];
	     $plannedtime= $_POST['time'];
	     $description= $_POST['description'];
	     
	     echo 'client=' . $client . " staff=" . $staff . "time=" . $plannedtime . " description=" . $description;
		/////////////////////////////////////////////////////////////////////////////////
		if(!connect_to_database()) //connect to SQL database
			return;
		
			
		//start to execute SQL commands
		$querystr="INSERT INTO appointment VALUES ('" .
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
			OutputStaffInfoResults($result);
		}
		
		close_database();
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>