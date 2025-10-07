<?php

require './utils/utils.php';

$PORT                  = '8080';
$IP                    = 'localhost';
$socket                =  'tcp://' . $IP . ':' . $PORT;

startHttpServer($socket);

?>