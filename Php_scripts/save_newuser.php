
<html>
	<head><title>A quick test</title></head>
	<body>A quick test <br/>
	
	<?php
	    include "lib_functions.php";
		
		if(isset($_POST['userid']))
			$userid=$_POST['userid'];
		else
			$userid="none-name";
		
		if(isset($_POST['password']))
			$password=$_POST['password'];
		else
			$password="none-name";
		
		if(isset($_POST['surname']))
			$surname=$_POST['surname'];
		else
			$surname="none-name";
		
		if(isset($_POST['givename']))
			$givename=$_POST['givename'];
		else
			$givename="none-name";
		
		if(isset($_POST['gender']))
		{
			$gender=$_POST['gender'];
			echo "gender =" . $gender;
		}
		else
		{
			$gender="none-name";
			echo "No gender specified";
		}
		
		if(isset($_POST['age']))
			$age=$_POST['age'];
		else
			$age="none-name";
		
		echo $surname . $givename . $gender . $age;
		
		if(!connect_to_database()) //connect to SQL database
			return;
			
		//ensure that the userid doesn't exist
		if(IfStringColumnExistInTable("userid", "personal_info", $userid))
		{
			echo "userid :" . $userid . " already exists." . "<br/>";
			return;
		}
		
		//process the uploaded icon image file
		$iconfilename=upload_image_file("./upload_image/" , $userid); //name the uploaded image file with the userid of the person
		if(!$iconfilename)
		{
			echo "uploading image file error";
			return;
		}
		
		/////////////////////////////////////////////////////////////////////////
		//Save this row into the personal_info table

			
		//start to execute SQL commands
		$querystr="INSERT INTO personal_info VALUES ('" .
								$userid . "', '" . 
								$password . "', '" . 
		                       $surname . "', '" . 
		                       $givename . "', '" .
		                       $gender . "', " . 
								$age . ", '" .
								time() . "', '" .
								$iconfilename . "', '')";
		//echo $querystr;
		$result=ExecuteQuery($querystr);
		
		if(!$result)
		{
			close_database();
			echo "no result followed by this query";
			return;
		}
		else
		{
			close_database();
		}
		
		
		//Finally, Redirect to display_persons.php
		header("Location:display_persons.php");
		
	?>
    </body>
</html>
