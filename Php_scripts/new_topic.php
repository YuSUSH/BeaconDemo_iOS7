
<html>
	<head><title>New Topic</title></head>
	<body>Display pages <br/>
	<form name="form1" method="post" action="new_topic.php">
	<label>
	
	<?php
	    include "lib_functions.php";
		$userid="";
		session_start();
		if(isset($_SESSION['login_success']))
		{
			if($_SESSION['login_success'])
				$userid=$_SESSION['userid'];
			else
			{
				echo "You haven't loged in.";
				return;
			}
			if(!connect_to_database()) //connect to SQL database
				return;
		}
		else
		{
			echo "You haven't loged in.";
			return;
		}
		
		
		if(isset($_POST['title']) && isset($_POST['title'])) //when the submit button has been clicked
		{
			$title=$_POST['title'];
			$content=$_POST['content'];
			
			if(!connect_to_database()) //connect to SQL database
				return;
			
			//search for all the pages as well as its replies
			$result=ExecuteQuery("SELECT * FROM pages ORDER BY pageid DESC");
			if(!$result)
				return false;
			$rows = mysql_num_rows($result);
			if($rows>0)
			{
				//get the max pageid among the existing pages (number 0)
				$max_id=mysql_result($result, 0, 'pageid');
				$max_id++;
				$query="INSERT INTO pages VALUES ( " . $max_id . "," .
												"'" . $userid . "'," .
												"'" . $title . "', '" .
												$content . "', 0, '" .
												time() . "' )";
				//echo $query;
				if(ExecuteQuery($query))
					header("Location:display_pagelist.php");
				else
					echo "SQL insert operation failed!";
			
			}
			
			close_database();
			return;
		}
	?>
	
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td>Topic Title<td/>
			<td><input type="text" name="title" style="width:500px;" /> <td/>
		<tr/>
		<tr>
			<td>Topic Content<td/>
			<td><textarea name="content" rows="20" cols="40">
			</textarea><td/>
		<tr/>
		<table/>
		<input type="submit" name="kkk" id="kkk" value="Submit This Topic">
      </label>
    </form>
    
    </body>
</html>