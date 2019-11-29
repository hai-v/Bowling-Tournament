<?php

$projectRoot = $_SERVER['DOCUMENT_ROOT'] . '/project/BowlingTournament';
require_once ($projectRoot . '/db/PlayerAccessor.php');
require_once ($projectRoot . '/entity/Player.php');

$id = intval(file_get_contents('php://input'));

$playerObj = new Player($id, null, null, null, null, null);

try {
    $pa = new PlayerAccessor();
    $success = $pa->deleteItem($playerObj);
    echo $success;
} catch (Exception $e) {
    echo "ERROR " . $e->getMessage();
}
?>