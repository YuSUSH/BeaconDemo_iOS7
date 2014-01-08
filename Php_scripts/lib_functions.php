	
	<?php
	    //info about database connection	
		$db_hostname="mysql3.openhost.net.nz";
		$db_database="ble_sql";
		$db_username="ble_sql_user";
		$db_password="xerox350";
		$db_server="";
		
		
		///////////////////////////////////////////////////////////////
		function connect_to_database()
		{
			global $db_hostname;
			global $db_database;
			global $db_username;
			global $db_password;
			global $db_server;
		
			$db_server=mysql_connect($db_hostname, $db_username, $db_password);
			
			if(!$db_server)
			{
				die("Unable to connecto to MySQL :" . mysql_error());
				return false;
			}
		
			//select a database from an existing db connection
			$db=mysql_select_db($db_database);
			if(!$db)
			{
				die("Unable to connecto to database :" . mysql_error());
				return false;
			}
			

			
			return true;
		}
		///////////////////////////////////////////////////////////
		function longdate($timestamp)
		{
		return date("l F jS Y", $timestamp);
		}
		//////////////////////////////////////////////////////////////
		function shortdate($timestamp)
		{
		return date("s F jS Y", $timestamp);
		}
		////////////////////////////////////////////////////////////////////////
		function ExecuteQuery($QueryStr)
		{
			$result=mysql_query($QueryStr);
		
			if(!$result)
			{
				echo "SQL query error" . "<br>";
				return 0;
			}
			else
			{
				return $result;
			}
		}
		//////////////////////////////////////////////////////////////////////////
		function IfStringColumnExistInTable($column, $table, $value)
		{
			$result=ExecuteQuery("SELECT * FROM " . $table .
								 " WHERE " . $column . " = '". $value . "'" );
			if($result)
			{
				$rows = mysql_num_rows($result);
				if($rows>0)
					return true;
			}
			
			return false;
		}
		/////////////////////////////////////////////////////////////////////////
		function close_database()
		{
			global $db_server;
			mysql_close($db_server);
		}
		/////////////////////////////////////////////////////////////////////////
		function upload_image_file($saved_path, $filename)
		{
			//save uploaded icon file
			if (($_FILES["file"]["type"] == "image/gif")
				|| ($_FILES["file"]["type"] == "image/jpeg")
				|| ($_FILES["file"]["type"] == "image/png"))
				//&& ($_FILES["file"]["size"] < 20000))
	  		{
	  			if ($_FILES["file"]["error"] > 0)
	    		{
	    			echo "Return Code: " . $_FILES["file"]["error"] . "<br />";
	    			return false;
	    		}
	  			else
	    		{
	    			echo "Upload: " . $_FILES["file"]["name"] . "<br />";
	    			echo "Type: " . $_FILES["file"]["type"] . "<br />";
	    			echo "Size: " . ($_FILES["file"]["size"] / 1024) . " Kb<br />";
	    			echo "Temp file: " . $_FILES["file"]["tmp_name"] . "<br />";

	    			if (file_exists("upload/" . $_FILES["file"]["name"]))
	    			{
	      				echo $_FILES["file"]["name"] . " already exists. ";
	      				return false;
	      			}
	    			else
	      			{
	      				//determine the extension file name from file type
	      				if($_FILES["file"]["type"] == "image/gif")
	      					$ext_filename=".gif";
	      				if($_FILES["file"]["type"] == "image/jpeg")
	      					$ext_filename=".jpg";
	      				if($_FILES["file"]["type"] == "image/png")
	      					$ext_filename=".png";
	      				move_uploaded_file($_FILES["file"]["tmp_name"],
	      									$saved_path . $filename . $ext_filename);
	      				echo "Stored in: " . $saved_path . $filename . $ext_filename;
	      				
	      				return $filename . $ext_filename; //return full filename of the uploaded image
	      			}
	    		}
	  		}
			else
			{
	  			echo "Invalid file";
	  			return false;
	  		}
	  	}
	  	//////////////////////////////////////////////////////////////////////////////////////
		function GetFullName($userid)
		{
	  	   $result=ExecuteQuery("SELECT * FROM personal_info WHERE userid='"
					 . $userid . "'");
			$full_name="";
			if($result)
			{
				$num = mysql_num_rows($result);
				if($num>0)
					$full_name= mysql_result($result, 0,'givename') . " " . //given name
									mysql_result($result, 0,'surname'); //surname
			}
			
			return $full_name;
		}
		///////////////////////////////////////////////////////////////////////////////////
		function CheckUserAccount($userid, $password)
		{			
			//start to execute SQL commands
			$result=ExecuteQuery("SELECT * FROM personal_info WHERE userid='" . $userid . "'");
			if(!$result)
			{
				return false;
			}
			else
			{
				$rows = mysql_num_rows($result);
				if($rows!=0)
				{
					if(mysql_result($result, 0,'password') == $password)
						return true;
					else
						return false;
				}
				else
					return false;
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////////////////
		function CheckUseridExist($userid)
		{
			return IfStringColumnExistInTable("userid", "personal_info", $userid);
		}
	?>
