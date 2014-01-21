
<html>
	<head><title>A quick test</title></head>
	<body>A quick test <br/>
	<form name="form1" method="post" action="">
	<label>
	
	<?php
	    include "lib_functions.php";
		///////////////////////////////////////////////////////////////
		function OutputPersonalInfoResults($result)
		{
			//get the number of lines we got
			$rows = mysql_num_rows($result);
			echo "number of rows=" . $rows . "<br/>";
			if($rows!=0)
			{
				echo "<table border=\"1\">";
				//print out the first line of the table (titles)
				echo "<tr>";
				echo "<td>" . "User ID" . "<td/>";
				echo "<td>" . "Surname" . "<td/>";
				echo "<td>" . "Given Name" . "<td/>";
				echo "<tr/>";
			
				for ($j = 0 ; $j < $rows ; $j++)
				{
					$userid= mysql_result($result,$j,'userid');
					$user_result=ExecuteQuery("SELECT * FROM personal_info WHERE userid='" . $userid . "'");
					$surname="";
					$givename="";
					if($user_result)
					{
						$surname=mysql_result($user_result, 0,'surname');
						$givename=mysql_result($user_result, 0,'givename');
					}
					
					echo "<tr>";
					echo "<td>" . mysql_result($result,$j,'userid') . "<td/>";
					echo "<td>" . $surname . "<td/>";
					echo "<td>" . $givename. "<td/>";
					//add a check box to specify each line, using userid as the value of checkbox
					echo "<tr/>";
				}
				echo "<table/>";
			}
		}
		/////////////////////////////////////////////////////////////////////////////////
		if(!connect_to_database()) //connect to SQL database
			return;
		
			
		//start to execute SQL commands
		$result=ExecuteQuery("SELECT * FROM inshop_users");
		if($result)
		{
			//Output the query results as a table
			OutputPersonalInfoResults($result);
		}
		
		close_database();
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>
      </label>
    </form>
    
    </body>
</html>
