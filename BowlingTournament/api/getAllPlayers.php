<?php
$projectRoot = $_SERVER['DOCUMENT_ROOT'] . '/project/BowlingTournament';
require_once ($projectRoot . '/db/PlayerAccessor.php');

try {
    $pa= new PlayerAccessor();
    $results = $pa->getAllItems();
    $results = json_encode($results, JSON_NUMERIC_CHECK);
    echo $results;
} catch (Exception $e) {
    echo "ERROR" . $e->getMessage();
}
?>
