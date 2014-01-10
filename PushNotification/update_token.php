<?php

// Put your device token here (without spaces):
$deviceToken = $_POST['token'];

$file = 'token.txt';
// Write the contents back to the file
file_put_contents($file, $deviceToken);

?>