<?php

$projectRoot = $_SERVER['DOCUMENT_ROOT'] . '/project/BowlingTournament';
require_once ($projectRoot . '/db/TeamAccessor.php');
require_once ($projectRoot . '/entity/Team.php');

$id = intval(file_get_contents('php://input'));

$teamObj = new Team($id, null, null);

try {
    $ta = new TeamAccessor();
    $success = $ta->deleteItem($teamObj);
    echo $success;
} catch (Exception $e) {
    echo "ERROR " . $e->getMessage();
}
?>