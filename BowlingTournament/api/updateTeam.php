<?php

$projectRoot = $_SERVER['DOCUMENT_ROOT'] . '/project/BowlingTournament';
require_once ($projectRoot . '/db/PlayerAccessor.php');
require_once ($projectRoot . '/entity/Team.php');

$body = file_get_contents('php://input');
$contents = json_decode($body, true);

$teamObj = new Team($contents['teamID'], $contents['teamName'], null);

try {
    $ta = new TeamAccessor();
    $success = $ta->updateItem($teamObj);
    echo $success;
} catch (Exception $e) {
    echo "ERROR " . $e->getMessage();
}
?>