
	<?php
	    include "lib_functions.php";
		/////////////////////////////////////////////////////////////////////////////////
		if(!connect_to_database()) //connect to SQL database
			return;
			
			
		$userid= $_POST['userid'];
		$token= $_POST['token'];
		
		
		echo "UPDATE staff_info set token='" . $token . "' WHERE userid='" . $userid . "'";
		//start to execute SQL commands
		$result=ExecuteQuery("UPDATE staff_info set token='" . $token . "' WHERE userid='" . $userid . "'");
		
		if(!$result)
		{
			echo "no result followed by this query";
			return;
		}
		
		close_database();
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>
