<?php

$projectRoot = filter_input(INPUT_SERVER, 'DOCUMENT_ROOT') . '/BowlingTournament';
require_once 'ConnectionManager.php';
require_once ($projectRoot . '/entity/Game.php');

class GameAccessor {

    private $getGameByStatusIDString = "select * from GAME where gameStatusID = 'INPROGRESS' or gameStatusID='AVAILABLE'";
    private $updateStatementByScoreString = "update GAME set score=:score where gameID=:gameID";
    private $updateStatementGameByStatusString = "update GAME set gameStatusID =(select gamestatusID from gameStatus where gameStatusID=:gameStatusID) where GAMEID=:gameID";
    private $getByGameStatusID = null;
    private $updateStatementByScore = null;
    private $updateStatementByGameStatus = null;

    public function __construct() {
        $cm = new ConnectionManager();
        $this->conn = $cm->connect_db();
        if (is_null($this->conn)) {
            throw new Exception("no connection");
        }
        $this->getByGameStatusID = $this->conn->prepare($this->getGameByStatusIDString);
        if (is_null($this->getByGameStatusID)) {
            throw new Exception("bad statment " .$this->getAllStatementString ."");
        }
        $this->updateStatementByGameStatus = $this->conn->prepare($this->updateStatementGameByStatusString);
        if (is_null($this->updateStatementByGameStatus)) {
            throw new Exception("bad statement: " .$this->updateStatementGameByStatusString ."");
        }
        $this->updateStatementByScore = $this->conn->prepare($this->updateStatementByScoreString);
        if (is_null($this->updateStatementByScore)) {
            throw new Exception("bad statement: " .$this->updateStatementByScoreString ."");
        }
    }

    private function getGamesByQuery($selectString) {
        $result = [];
        try {
            $stmt = $this->conn->prepare($selectString);
            $stmt->execute();
            $dbresults = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            foreach ($dbresults as $r) {
                $gameID = $r['gameID'];
                $matchID = $r['matchID'];
                $gameNumber = $r['gameNumber'];
                $gameStatusID = $r['gameStatusID'];
                $score = $r['score'];
                $balls = $r['balls'];
                $gameObj = new Game($gameID, $matchID, $gameNumber, $gameStatusID, $balls, $score);
                array_push($result, $gameObj);
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
    public function getAllGames() {
        return $this->getGamesByQuery($this->getGameByStatusIDString);
    }
}
