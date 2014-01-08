
<html>
	<head><title>A quick test</title></head>
	<body>A quick test <br/>
	
	<?php
	    include "lib_functions.php";
		
		
		if(isset($_POST['textbox']))
			$name=$_POST['textbox'];
		else
			$name="none-name";
		/////////////////////////////////////////////////////////////////////////
		
		if(!connect_to_database()) //connect to SQL database
			return;
			
		//start to execute SQL commands
		$result=ExecuteQuery("SELECT * FROM personal_info");
		if(!$result)
		{
			echo "no result followed by this query";
			return;
		}
		else
		{
			//OutputLinesAsTable($result);
		}
		
		
		
		
		echo "This is ";
		echo $name;
		echo "<br/>"; //new line
		echo longdate(time());
	?>

	
	<form name="register_form" method="post" action="save_newuser.php" enctype="multipart/form-data">
	   <div style="width: 253px; height: 28px; height :30px; line-height:30px;">
        UserID    :<input type="text" name="userid" id="userid"></div><br/>
       <div style="width: 253px; height: 28px; height :30px; line-height:30px;">
        Passwrod   :<input type="password" name="password" id="password"></div><br/>
       <div style="width: 253px; height: 28px; height :30px; line-height:30px;">
        Surname   :<input type="text" name="surname" id="surname"></div><br/>
      <div style="width: 253px; height: 28px; height :30px; line-height:30px;">
        Given Name:<input type="text" name="givename" id="givename"></div><br/>
      <div style="width: 253px; height: 28px; height :30px; line-height:30px;">
        Gender    :<select name="gender" id="gender">
        			<option value="Male">Male</option>
        			<option value="Female">Female</option>
        			<select/> </div><br/>
      <div style="width: 253px; height: 28px; height :30px; line-height:30px;">
        Age       :<select name="age" id="age">
       <?php
        			for($i=1;$i<101;$i++)
        				echo "<option value=" . $i . ">" . $i. "</option>";
        ?>
        			<select/></div><br/>
        <label>Upload Icon (.gif;.jpg;,png):<label/>
        <input type="file" name="file" id="file" /><br/><br/><br/>
      <label>
	    <input type="submit" name="kkk" id="kkk" value="Register These Personal Info">
      </label>
    </form>
    </body>
</html>
