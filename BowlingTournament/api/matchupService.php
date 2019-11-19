<?php
$projectRoot = filter_input(INPUT_SERVER, "DOCUMENT_ROOT") .'/BowlingTournament';
require_once ($projectRoot .'/db/GameAccessor.php');
require_once ($projectRoot .'/entity/Game.php');
require_once ($projectRoot .'/entity/Matchup.php');
require_once ($projectRoot .'/db/matchupAccessor.php');
require_once ($projectRoot .'/db/teamItemAccessor.php');
require_once ($projectRoot .'/utils/ChromePhp.php');

$method = filter_input(INPUT_SERVER, 'REQUEST_METHOD');
if($method === "GET") {
    doGet();
}

function doGet() {
    if(!filter_has_var(INPUT_GET, 'matchID')) {
        try {
            $mia = new matchupAccessor();
            $results = $mia->getAllMatchups();
            $results = json_encode($results, JSON_NUMERIC_CHECK);
            echo $results;
        } catch (Exception $ex) {
            echo "ERROR " .$ex->getMessage();
        }
    }
    else {
        $mia = new matchupAccessor();
        $matchID = filter_input(INPUT_GET, 'matchID');
        $results = $mia->getTeamsByMatchID($matchID);
       $results = json_encode($results, JSON_NUMERIC_CHECK);
        echo $results;
    }
}
