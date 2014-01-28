
	<?php
	    include "lib_functions.php";
	
		function CheckClientInShop($userid)
		{			
			//firstly, check all the users in the shop now
			$bAlreadyExist=0;
			
			$result=ExecuteQuery("SELECT * FROM inshop_users");
			if($result)
			{
				$rows = mysql_num_rows($result);
				if($rows>0)
				{
					for ($j = 0 ; $j < $rows ; $j++)
					{		
						if( strcmp($userid,  mysql_result($result,$j,'userid') )==0)
						{
							$bAlreadyExist=1;
							break;
						}
					}
				}
				
				if($bAlreadyExist==1)
				{
					return 1;
				}
			}
			
			return -1;
		}
		///////////////////////////////////////////////////////////////
		function OutputAppointmentResults($result)
		{
			$resultArray = array();
			
			//get the number of lines we got
			$rows = mysql_num_rows($result);
			//echo "number of rows=" . $rows . "<br/>";
			if($rows!=0)
			{
				for ($j = 0 ; $j < $rows ; ++$j)
				{		
					$arrCol= array();
					$arrCol["staff"]=mysql_result($result,$j,'staff');
					$client_id=mysql_result($result,$j,'client');
					$arrCol["client"]=$client_id;
					//query client's fullname based on client ID
					$client_result=ExecuteQuery("SELECT * FROM personal_info WHERE userid='" . $client_id . "'");
					if($client_result)
					{
						//Output to HTTP request
						$arrCol["client_fullname"]=mysql_result($client_result, 0,'givename') . ' ' .
									mysql_result($client_result, 0,'surname');
						$arrCol["iconfilename"]=mysql_result($client_result, 0,'iconfilename');
					}
					
					//To see if this client is still inshop
					if(CheckClientInShop($client_id)>0)
						$arrCol["inshop"]=1;
					else
						$arrCol["inshop"]=0;
					
					$arrCol["time"]=mysql_result($result,$j,'time');
					$arrCol["description"]= mysql_result($result,$j,'description');
					$arrCol["department"]= mysql_result($result,$j,'department');
					array_push($resultArray,$arrCol);
				}
			}
			
			
			//Output to HTTP request
			
			echo json_encode($resultArray);
		}
		/////////////////////////////////////////////////////////////////////////////////
		if(!connect_to_database()) //connect to SQL database
			return;
			
			
		$userid= $_POST['userid'];
		
			
		//start to execute SQL commands
		$result=ExecuteQuery("SELECT * FROM appointment WHERE staff='" . $userid . "'");
		if(!$result)
		{
			echo "no result followed by this query";
			return;
		}
		else
		{
			//Output to HTTP request
			OutputAppointmentResults($result);
		}
		
		close_database();
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>
