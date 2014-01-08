
<html>
	<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
	<head><title>Display Topic</title></head>
	<body>Display pages <br/>
	<form name="form1" method="post" action="">
	<label>
	
	<?php
	    include "lib_functions.php";
	
		if(!isset($_GET['id'])) //if "Delete Row" button has been clicked
			return; //if page id hasn't been specified
		
		$topic_id=$_GET['id'];
		
		if(!connect_to_database()) //connect to SQL database
			return;
		
		//search for all the this topic page as well as its replies
		$result=ExecuteQuery("SELECT * FROM pages WHERE pageid=" . $topic_id);
		if(!$result)
			return false;
		$rows = mysql_num_rows($result);
		if($rows>0)
		{
			//search for the info of the poster
			$poster_id=mysql_result($result, 0,'poster');
			$poster_name= GetFullName($poster_id) . " (" . $poster_id . ")";
			
			echo "<table border=\"1\">";
			//print out the first line of the table (titles)
			echo "<tr>";
			echo "<td width=60>" . $poster_name .  "<td/>";
			echo "<td width=600>" . mysql_result($result, 0,'title') . "<td/>";
			echo "<tr/>";
			
			//show content of the topic page	
			echo "<tr>";
			echo "<td>" . longdate(mysql_result($result, 0,'time')) . "<td/>";
			
			$content=mysql_result($result, 0,'content');
			echo "<td>" . nl2br($content) . "<td/>"; //To replace the '\n' into <br/> to show new line
			echo "<tr/>";
			
			echo "<table/>";
		}
		
		close_database();
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>
      </label>
    </form>
    
    </body>
</html>