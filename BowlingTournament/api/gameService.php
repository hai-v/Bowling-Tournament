<?php
$projectRoot = filter_input(INPUT_SERVER, "DOCUMENT_ROOT") .'/BowlingTournament';
require_once ($projectRoot .'/db/GameAccessor.php');
require_once ($projectRoot .'/entity/Game.php');
require_once ($projectRoot .'/utils/ChromePhp.php');

$method = filter_input(INPUT_SERVER, 'REQUEST_METHOD');
if($method === "GET") {
    doGet();
}

function doGet() {
    if(!filter_has_var(INPUT_GET, 'gameID')) {
        try {
            $mia = new GameAccessor();
            $results = $mia->getAllGames();
            $results = json_encode($results, JSON_NUMERIC_CHECK);
            echo $results;
        } catch (Exception $ex) {
            echo "ERROR " .$ex->getMessage();
        }
    }
    else {
        ChromePhp::log("You are requesting item " .filter_input(INPUT_GET, 'gameID'));
    }
}
