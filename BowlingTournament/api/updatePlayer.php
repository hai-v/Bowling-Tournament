<?php

$projectRoot = $_SERVER['DOCUMENT_ROOT'] . '/project/BowlingTournament';
require_once ($projectRoot . '/db/PlayerAccessor.php');
require_once ($projectRoot . '/entity/Player.php');

$body = file_get_contents('php://input');
$contents = json_decode($body, true);

$playerObj = new Player($contents['playerID'], $contents['teamID'], $contents['firstName'], $contents['lastName'], $contents['hometown'], $contents['province']);

try {
    $pa = new PlayerAccessor();
    $success = $pa->updateItem($playerObj);
    echo $success;
} catch (Exception $e) {
    echo "ERROR " . $e->getMessage();
}
?>