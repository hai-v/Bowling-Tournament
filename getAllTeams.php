<?php
$projectRoot = $_SERVER['DOCUMENT_ROOT'] . '/project/BowlingTournament';
require_once ($projectRoot . '/db/TeamAccessor.php');

try {
    $ta = new TeamAccessor();
    $results = $ta->getAllItems();
    $results = json_encode($results, JSON_NUMERIC_CHECK);
    echo $results;
} catch (Exception $e) {
    echo "ERROR " . $e->getMessage();
}
?>