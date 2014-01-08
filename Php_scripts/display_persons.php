
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
				echo "<td>" . "Icon" . "<td/>";
				echo "<td>" . "User ID" . "<td/>";
				echo "<td>" . "Surname" . "<td/>";
				echo "<td>" . "Given Name" . "<td/>";
				echo "<td>" . "Gender" . "<td/>";
				echo "<td>" . "Age" . "<td/>";
				echo "<td>" . "Register Date" . "<td/>";
				echo "<tr/>";
			
				for ($j = 0 ; $j < $rows ; ++$j)
				{
					echo "<tr>";
					echo "<td>" . "<img src=\"upload_image/" . 
								mysql_result($result,$j,'iconfilename') . "\"> <td/>";
					echo "<td>" . mysql_result($result,$j,'userid') . "<td/>";
					echo "<td>" . mysql_result($result,$j,'surname') . "<td/>";
					echo "<td>" . mysql_result($result,$j,'givename') . "<td/>";
					echo "<td>" . mysql_result($result,$j,'gender') . "<td/>";
					echo "<td>" . mysql_result($result,$j,'age') . "<td/>";
					echo "<td>" . longdate(mysql_result($result,$j,'registerdate')) . "<td/>";
					//add a check box to specify each line, using userid as the value of checkbox
					echo "<input type=\"checkbox\" name=\"chosenrows[]\" value=\"".
									 mysql_result($result,$j,'userid') . "\">"; 
					echo "<tr/>";
				}
				echo "<table/>";
			}
		}
		/////////////////////////////////////////////////////////////////////////////////
		if(!connect_to_database()) //connect to SQL database
			return;
			
			
		//Deal with the delete operation
		if(isset($_POST['chosenrows'])) //if "Delete Row" button has been clicked
		{
			foreach( $_POST["chosenrows"] as $i=>$userid )
  			{
  				$querystr="DELETE FROM personal_info WHERE userid = '" .
  							$userid . "'";
  				//echo $querystr;
  				ExecuteQuery($querystr);
  			}
		}
		
			
		//start to execute SQL commands
		$result=ExecuteQuery("SELECT * FROM personal_info order by surname asc");
		if(!$result)
		{
			echo "no result followed by this query";
			return;
		}
		else
		{
			//Output the query results as a table
			OutputPersonalInfoResults($result);
		}
		
		close_database();
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>
	    <input type="submit" name="deleterow" id="deleterow" value="Delete Selected Row">
      </label>
    </form>
    
    </body>
</html>
