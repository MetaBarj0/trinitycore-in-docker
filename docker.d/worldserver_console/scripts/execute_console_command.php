<?php
function checkArgsCount($argCount)
{
    if ($argCount < 2) {
        echo "Usage: lsphp83 execute_console_command.php '<cmd>'\n";

        exit(1);
    }
}

function extractCommand($args)
{
    return $args[1];
}

function executeCommand($command)
{
    $client = new SoapClient(null, [
        'location' => 'http://worldserver:7878',
        'uri' => 'urn:TC',
        'login' => 'TC_ADMIN',
        'password' => 'TC_ADMIN',
    ]);

    try {
        $result = $client->executeCommand(new SoapParam($command, 'command'));
    } catch (Exception $e) {
        die($e->getMessage());

        exit(1);
    }

    echo $result;
}

checkArgsCount($argc);
executeCommand(extractCommand($argv));
