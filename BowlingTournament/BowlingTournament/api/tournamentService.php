<?php
$projectRoot = filter_input(INPUT_SERVER, "DOCUMENT_ROOT") .'/BowlingTournament';
require_once ($projectRoot .'/db/tournamentAccessor.php');
require_once ($projectRoot .'/entity/TournamentRound.php');
require_once ($projectRoot .'/utils/ChromePhp.php');

$method = filter_input(INPUT_SERVER, 'REQUEST_METHOD');
if($method === "GET") {
    doGet();
}

function doGet() {
    if(!filter_has_var(INPUT_GET, 'roundID')) {
        try {
            $mia = new tournamentAccessor();
            $results = $mia->getAllRounds();
            $results = json_encode($results, JSON_NUMERIC_CHECK);
            echo $results;
        } catch (Exception $ex) {
            echo "ERROR " .$ex->getMessage();
        }
    }
}
