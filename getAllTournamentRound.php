<?php
$projectRoot = $_SERVER['DOCUMENT_ROOT'] . '/project/BowlingTournament';
require_once ($projectRoot . '/db/TournamentRoundAccessor.php');

try {
    $tra = new TournamentRoundAccessor();
    $results = $tra->getAllItems();
    $results = json_encode($results);
    echo $results;
} catch (Exception $e) {
    echo "ERROR " . $e->getMessage();
}
?>