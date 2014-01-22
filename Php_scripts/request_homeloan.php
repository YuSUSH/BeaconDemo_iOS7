	<?php
	    include "lib_functions.php";
////////////////////////////////////////////////////////////////////////////////////////
	
	function SendHomeloanRequestToiPad($client_id)
	{	
		//Send notification to the specified staff
		$url = 'http://experiment.sandbox.net.nz/beacon/simplepush.php';
		$fields = array(
					'device_type'=>urlencode("ipad"),
		            'userid'=>urlencode($client_id),
		    		'event'=>urlencode("homeloan_request")
		        );

		//url-ify the data for the POST
		foreach($fields as $key=>$value) { $fields_string .= $key.'='.$value.'&'; }
		rtrim($fields_string,'&');

		//open connection
		$ch = curl_init();

		//set the url, number of POST vars, POST data
		curl_setopt($ch,CURLOPT_URL,$url);
		curl_setopt($ch,CURLOPT_POST,count($fields));
		curl_setopt($ch,CURLOPT_POSTFIELDS,$fields_string);

		//execute post
		$result = curl_exec($ch);
	}
/////////////////////////////////////////////////////////////////////////////////////////
	
	     $client= $_POST['client'];
	     
		
		SendHomeloanRequestToiPad($client);
			
		
		//output OK message
		$resultArray = array();
		$arrCol["result"]='OK';
		array_push($resultArray,$arrCol);
		//Output to HTTP request
		echo json_encode($resultArray);
		
		//echo "<br/>"; //new line
		//echo longdate(time());
	?>