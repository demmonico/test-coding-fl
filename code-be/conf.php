<?php

/*
 * Database configuration file
 */

$cbGetEnv = function ($envVarName, $defaultValue) {
    $envValue = getenv($envVarName);

    return $envValue !== false ? $envValue : $defaultValue;
};

$mysql_host = $cbGetEnv('DB_HOST', 'db');
$mysql_user = $cbGetEnv('DB_USER', 'mydb');
$mysql_pass = $cbGetEnv('DB_PASSWORD', 'mydb');
$mysql_db = $cbGetEnv('DB_NAME', 'mydb');
