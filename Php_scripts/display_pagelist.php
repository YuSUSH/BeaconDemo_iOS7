
<html>
	<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
	<head><title>Display pages</title></head>
	<body>Display pages <br/>
	<form name="form1" method="post" action="">
	<label>
	
	<?php
		//echo $to_time= date('Y-m-d H:i');
		date_default_timezone_set("Pacific/Auckland");
		$to_time= time();
		echo $to_time . ' ' ;
		$from_time = strtotime("2014-01-20 14:30");
		$diff=round(abs($to_time - $from_time) / 60,2);
		echo $diff. " minute";
		

	    include "lib_functions.php";
		
		session_start();
		if(isset($_SESSION['login_success']))
		{
			if($_SESSION['login_success'])
				echo "Hi, I'm ". $_SESSION['user_fullname'];
			if(!connect_to_database()) //connect to SQL database
				return;
		}
		
		//search for all the main pages (rather than replies)
		$result=ExecuteQuery("SELECT * FROM pages WHERE referpage=0");
		if(!$result)
			return false;
		$rows = mysql_num_rows($result);
		if($rows>0)
		{
			echo "<table border=\"1\">";
			//print out the first line of the table (titles)
			echo "<tr>";
			echo "<td width=100 >" . "Poster" . "<td/>";
			echo "<td width=600>" . "Title" . "<td/>";
			echo "<td width=60>" . "Time" . "<td/>";
			echo "<tr/>";
				
			//display page titles
			for ($i = 0 ; $i < $rows ; $i++)
			{
				$poster_name=GetFullName(mysql_result($result,$i,'poster')) . 
								"(" . mysql_result($result,$i,'poster') . ")";
				echo "<tr>";
				echo "<td>" . $poster_name . "<td/>"; //poster
				echo "<td> <a href=\"display_topic.php?id=" .
					mysql_result($result,$i,'pageid') . "\" target=\"_blank\">" .
					mysql_result($result,$i,'title') . "</a> <td/>";
				echo "<td>" . shortdate(mysql_result($result,$i,'time')) . "<td/>"; //post time
				echo "<tr/>";
			}
			
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