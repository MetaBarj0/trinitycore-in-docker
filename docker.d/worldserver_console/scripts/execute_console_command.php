<?php
if ($argc < 2) {
    echo "Usage: lsphp83 execute_console_command.php '<cmd>'\n";

    exit(1);
}

$command  = $argv[1];

$client = new SoapClient($wsdl = null, [
    'location' => 'http://worldserver:7878',
    'uri' => 'urn:TC',
    'login' => 'TC_ADMIN',
    'password' => 'TC_ADMIN',
]);

try {
    $result = $client->executeCommand(new SoapParam($command, 'command'));
} catch (Exception $e) {
    die($e->getMessage());
}

echo $result;
?>
