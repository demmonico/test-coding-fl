<?php

echo '<h1>Frontend</h1>' . PHP_EOL;
echo gethostname() . PHP_EOL;

echo '<h1>Backend</h1>' . PHP_EOL;
$beHost = getenv('BE_HOST', 'http://httpdbe');
echo $beHost . '<hr>' . PHP_EOL;
echo file_get_contents($beHost);
