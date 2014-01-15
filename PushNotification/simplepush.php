<?php

function SendPushNotification($token)
{
	// Put your private key's passphrase here:
	$passphrase = 'sush1234';

	// Put your alert message here:
	$message = 'Hajimemashite!';

	////////////////////////////////////////////////////////////////////////////////

	$ctx = stream_context_create();
	stream_context_set_option($ctx, 'ssl', 'local_cert', 'ck.pem');
	stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);

	// Open a connection to the APNS server
	$fp = stream_socket_client(
		'ssl://gateway.sandbox.push.apple.com:2195', $err,
		$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

	if (!$fp)
		exit("Failed to connect: $err $errstr" . PHP_EOL);

	//echo 'Connected to APNS' . PHP_EOL;

	$UserID= $_POST['userid'];

	// Create the payload body
	$body['aps'] = array(
		'alert' => $UserID,
		'sound' => 'default'
		);

	// Encode the payload as JSON
	$payload = json_encode($body);

	// Build the binary notification
	$msg = chr(0) . pack('n', 32) . pack('H*', $token) . pack('n', strlen($payload)) . $payload;

	// Send it to the server
	$result = fwrite($fp, $msg, strlen($msg));


	if (!$result)
		;//echo 'Message not delivered' . PHP_EOL;
	else
		;//echo 'Message successfully delivered' . PHP_EOL;


	// Close the connection to the server
	fclose($fp);
}


// Put your device token here (without spaces):
//Read out the Device Token string saved in the file
$file = 'token.txt';
$iPadToken = file_get_contents($file);

SendPushNotification($iPadToken);


?>