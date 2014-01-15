<?php
include "lib_functions.php";

$userid= $_POST['userid'];	

$url = 'http://experiment.sandbox.net.nz/beacon/simplepush.php';
$fields = array(
            'userid'=>urlencode($userid),
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
//print $result;





//Send back a result to ask client to input new appoint info 
$resultArray = array();
			
//echo "number of rows=" . $rows . "<br/>";
$arrCol= array();
$arrCol["result"]="add_new"; //require client to input info for new appointment
array_push($resultArray,$arrCol);
			
//Output to HTTP request
echo json_encode($resultArray);

?>

