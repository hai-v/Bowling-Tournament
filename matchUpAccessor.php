<?php

$projectRoot = filter_input(INPUT_SERVER, 'DOCUMENT_ROOT') . '/project/BowlingTournament';
require_once 'ConnectionManager.php';
require_once ($projectRoot . '/objects/Matchup.php');
require_once ($projectRoot . '/ChromePhp.php');

class matchUpAccessor {

    private $getmatchupString = "select * from matchup";
    private $getmatchup = null;

    public function __construct() {
        $cm = new ConnectionManager();
        $this->conn = $cm->connect_db();
        if (is_null($this->conn)) {
            throw new Exception("no connection");
        }
        $this->getmatchup = $this->conn->prepare($this->getmatchupString);
        if (is_null($this->getmatchup)) {
            throw new Exception("bad statment " . $this->getmatchupString . "");
        }
    }

//end constructor

    private function getMatchups($selectString) {
        $result = [];
        try {
            $stmt = $this->conn->prepare($selectString);

            $stmt->execute();

            $dbresults = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($dbresults as $r) {
                $matchID = $r['matchID'];
                $roundID = $r['roundID'];
                $matchGroup = $r['matchgroup'];
                $teamID = $r['teamID'];
                $score = $r['score'];
                $ranking = $r['ranking'];
                $matchupObj = new Matchup($matchID, $roundID, $matchGroup, $teamID, $score, $ranking);
                ChromePhp::log($ranking);
                array_push($result, $matchupObj);
            }
        } catch (Exception $e) {
            $result = [];
        } finally {
            if (!is_null($stmt)) {
                $stmt->closeCursor();
            }
        }
        return $result;
    }

//end ftn

    public function getAllMatchups() {
        return $this->getMatchups($this->getmatchupString);
    }

}
