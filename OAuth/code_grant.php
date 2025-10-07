<?php

require './utils/utils.php';

$PORT                  = '8080';
$IP                    = 'localhost';

$outputFile            = 'config/ds_access_token.txt';
$state                 = bin2hex(random_bytes(5));

$clientID              = getenv("INTEGRATION_KEY");
$clientSecret          = getenv("SECRET_KEY");
$target_account_id     = getenv("TARGET_ACCOUNT_ID");

$authorizationEndpoint = 'https://account-d.docusign.com/oauth/';

$socket                =  'tcp://' . $IP . ':' . $PORT;
$redirectURI           = 'http://' . $IP . ':' . $PORT . '/authorization-code/callback';

$outputFile = "config/ds_access_token.txt";
$apiAccountIdFile = 'config/API_ACCOUNT_ID';
if (!file_exists($outputFile)) {
    $outputFile = "../config/ds_access_token.txt";
    $apiAccountIdFile = '../config/API_ACCOUNT_ID';
}

$scope = "signature aow_manage";

$authorizationURL = $authorizationEndpoint . 'auth?' . http_build_query(
    [
        'redirect_uri'  => $redirectURI,
        'scope'         => $scope,
        'client_id'     => $clientID,
        'state'         => $state,
        'response_type' => 'code'
    ]
);

echo "\nOpen the following URL in a browser to continue:\n" . $authorizationURL . "\n";


// Windows fix: https://stackoverflow.com/a/1327444/2226328
if (stripos(PHP_OS, 'WIN') === 0) {
    shell_exec('start "" "'.$authorizationURL.'"');
} else {
    shell_exec("xdg-open " . $authorizationURL);
}

$auth = startHttpServer($socket);

if ($auth['state'] != $state) {
    echo "\nWrong 'state' parameter returned\n";
    exit(2);
}

$code = $auth['code'];
echo "\nGetting an access token...\n";

$response = http(
    $authorizationEndpoint . 'token', [
        'grant_type'   => 'authorization_code',
        'redirect_uri' => $redirectURI,
        'code'         => $code
    ], [
        'Authorization: Basic ' . base64_encode($clientID . ':' .$clientSecret),
    ], true
);

$accessToken = $response->access_token;
file_put_contents($outputFile, $accessToken);
echo "\nAccess token has been written to " . $outputFile . "\n\n";

$userInfo = http($authorizationEndpoint . 'userinfo', false,
    [
        'Authorization: Bearer ' . $accessToken
    ]
);

if ($target_account_id != "{TARGET_ACCOUNT_ID}") {
    $targetAccountFound = false;
    foreach ($userInfo->accounts as $account_info) {
        if ($account_info->account_id == $target_account_id) {
            $APIAccountId = $account_info->account_id;
            $targetAccountFound = true;
            break;
        }
    }
    if (!$targetAccountFound) {
        throw new Exception("Targeted Account with Id " . $target_account_id . " not found.");
    }
} else {
    foreach ($userInfo->accounts as $account_info) {
        if ($account_info->is_default) {
            $APIAccountId = $account_info->account_id;
            break;
        }
    }
}

file_put_contents($apiAccountIdFile, $APIAccountId);
echo "Account id: $APIAccountId\n";
echo "Account id has been written to config/API_ACCOUNT_ID file...\n\n";
?>
