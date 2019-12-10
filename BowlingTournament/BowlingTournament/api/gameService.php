<?php

$projectRoot = filter_input(INPUT_SERVER, "DOCUMENT_ROOT") . '/BowlingTournament';
require_once ($projectRoot . '/db/GameAccessor.php');
require_once ($projectRoot . '/entity/Game.php');
require_once ($projectRoot . '/entity/Team.php');
require_once ($projectRoot . '/utils/ChromePhp.php');

$method = filter_input(INPUT_SERVER, 'REQUEST_METHOD');
if ($method === "GET") {
    doGet();
}

if ($method === "PUT") {
    doPut();
}

function doGet() {
    if (!filter_has_var(INPUT_GET, 'gameID')) {
        try {
            $mia = new GameAccessor();
            $results = $mia->getAllGames();
            $results = json_encode($results, JSON_NUMERIC_CHECK);
            echo $results;
        } catch (Exception $ex) {
            echo "ERROR " . $ex->getMessage();
        }
    } else {
        if(filter_input(INPUT_GET, 'gameID')) {
        $gameID = filter_input(INPUT_GET, 'gameID');
        ChromePhp::log("You are requesting matchID " .$gameID);
        $mia = new GameAccessor();
        $results = $mia->getTeamsByGameID($gameID);
        $results = json_encode($results, JSON_NUMERIC_CHECK);
        }
        if(filter_input(INPUT_GET, 'matchID')) {
             $matchID = filter_input(INPUT_GET, 'matchID');
            ChromePhp::log("You are requesting matchID " .$matchID);
        }
    }
}

function doPut() {
    $body = file_get_contents('php://input');
    $contents = json_decode($body, true);
    //$teamID, $teamName, $earnings
    $tempTeam = new Team(0, 'dummyName', 0);
    $game = new Game($contents['gameID'], $contents['matchID'],
            $contents['gameNumber'], $contents['gameStatusID'], $contents['balls'], $contents['score'], $tempTeam);
    $mia = new GameAccessor();
    $success = $mia->updateGame($game);
    echo $success;
}
