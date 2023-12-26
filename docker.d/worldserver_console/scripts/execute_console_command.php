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
    $adminAccountName = getenv('ADMIN_ACCOUNT_NAME');
    $adminAccountPassword = getenv('ADMIN_ACCOUNT_PASSWORD');

    $client = new SoapClient(null, [
        'location' => 'http://worldserver:7878',
        'uri' => 'urn:TC',
        'login' => $adminAccountName,
        'password' => $adminAccountPassword
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
