<?php

$projectRoot = $_SERVER['DOCUMENT_ROOT'] . '/project/BowlingTournament';
require_once ($projectRoot . '/db/TeamAccessor.php');
require_once ($projectRoot . '/entity/Team.php');

// reading the HTTP request body
$body = file_get_contents('php://input');
$contents = json_decode($body, true);

// create a MenuItem object
$teamObj = new Team($contents['teamID'], $contents['teamName'], null);

// add the object to DB
try {
    $ta = new TeamAccessor();
    $success = $ta->insertItem($teamObj);
    echo $success;
} catch (Exception $e) {
    echo "ERROR " . $e->getMessage();
}
?>