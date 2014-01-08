

	<?php
	    include "lib_functions.php";
		
		$userid="";
		$password="";
		
		$resultArray = array();
		$arrCol= array();
		
		
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
			{
				echo "connect to database failed";
				return;
			}
			
			if(CheckUserAccount($userid, $password))
			{
				$arrCol["result"]="OK";
				//start to execute SQL commands Get the fullname
				$result=ExecuteQuery("SELECT * FROM personal_info WHERE userid='" . $userid . "'");
				if($result)
				{
					$rows = mysql_num_rows($result);
					if($rows>0)
					{
						$arrCol["userid"]=mysql_result($result,0,'userid');
						$arrCol["surname"]=mysql_result($result,0,'surname');
						$arrCol["givename"]=mysql_result($result,0,'givename');
						$arrCol["gender"]= mysql_result($result,0,'gender');
						$arrCol["age"]= mysql_result($result,0,'age');
					}
				}
			}
			else
			{
				$arrCol["result"]="ERROR ". $userid . $password;
			}
			
			array_push($resultArray,$arrCol);
			echo json_encode($resultArray);
		}
		else
			echo "No parameter set";
	?>
