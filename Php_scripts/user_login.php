
<html>
	<head><title>A quick test</title></head>
	<body>A quick test <br/>
	
	<?php
	    include "lib_functions.php";
		
		$userid="";
		$password="";
		
		if(isset($_POST['userid']) && isset($_POST['password']))
		{
			$userid=$_POST['userid'];
			$password=$_POST['password'];
		
			if($userid=="" || $password=="" )
			{
				echo "userid or password can't be empty.";
				return;
			}
			
			/////////////////////////////////////////////////////////////////////////
			if(!connect_to_database()) //connect to SQL database
				return;
			
			if(CheckUserAccount($userid, $password))
			{
				echo "Login successfully.";
				
				//Set session variables
				session_start();
				$_SESSION['userid']=$userid;
				$_SESSION['login_success']=1;
				$_SESSION['user_fullname']= GetFullName($userid);
				echo "////////////" . $_SESSION['userid'];
				//After login, Redirect to display_pagelist.php
				header("Location:display_pagelist.php");
				return;
			}
			else
			{
				echo "The userid seems inconsistent with the password or doesn't exist.";
			}
		}
		
		
		
		echo "This is ";
		echo "<br/>"; //new line
		echo longdate(time());
	?>

	
	<form name="register_form" method="post" action="user_login.php" enctype="multipart/form-data">
	   <div style="width: 253px; height: 28px; height :30px; line-height:30px;">
        UserID    :<input type="text" name="userid" id="userid"></div><br/>
       <div style="width: 253px; height: 28px; height :30px; line-height:30px;">
        Passwrod   :<input type="password" name="password" id="password"></div><br/>
      <label>
	    <input type="submit" name="login" id="login" value="Login">
      </label>
    </form>
    </body>
</html>
