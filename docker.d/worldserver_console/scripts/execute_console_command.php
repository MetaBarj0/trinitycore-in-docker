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

function getAdminAccountCredentials()
{
    $adminAccountName = strtoupper(getenv('ADMIN_ACCOUNT_NAME'));
    $adminAccountPassword = strtoupper(getenv('ADMIN_ACCOUNT_PASSWORD'));

    if ($adminAccountName == 'TC_ADMIN' || $adminAccountPassword == 'TC_ADMIN') {
        echo 'FATAL: security issue with admin account credentials!' . PHP_EOL;
        echo 'Do not use neither the bootstrap account name nor password.' . PHP_EOL;

        exit(1);
    }

    return [
        'name' => $adminAccountName,
        'password' => $adminAccountPassword
    ];
}

function createSOAPClient()
{
    $credentials = getAdminAccountCredentials();

    return new SoapClient(null, [
        'location' => 'http://worldserver:7878',
        'uri' => 'urn:TC',
        'login' => $credentials['name'],
        'password' => $credentials['password']
    ]);
}

function executeCommand($command)
{
    $client = createSOAPClient();

    try {
        $result = $client->executeCommand(new SoapParam($command, 'command'));
    } catch (Exception $e) {
        echo "Error while executing worldserver command: " . $e->getMessage();

        exit(1);
    }

    echo $result;
}

checkArgsCount($argc);
executeCommand(extractCommand($argv));
