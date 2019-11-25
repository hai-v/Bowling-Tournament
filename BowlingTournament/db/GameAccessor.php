<?php

$projectRoot = filter_input(INPUT_SERVER, 'DOCUMENT_ROOT') . '/BowlingTournament';
require_once 'ConnectionManager.php';
require_once ($projectRoot . '/entity/Game.php');

class GameAccessor {

    private $getGameByStatusIDString = "select * from GAME where gameStatusID = 'INPROGRESS' or gameStatusID='AVAILABLE'";
    private $getByGameStatusID = null;
    private $updateStatementGameByGameIDString = "update GAME set score=:score, balls=:balls, gameStatusID=:gameStatusID where gameID=:gameID";
    private $updateStatementByGameID = null;

    public function __construct() {
        $cm = new ConnectionManager();
        $this->conn = $cm->connect_db();
        if (is_null($this->conn)) {
            throw new Exception("no connection");
        }
        $this->getByGameStatusID = $this->conn->prepare($this->getGameByStatusIDString);
        if (is_null($this->getByGameStatusID)) {
            throw new Exception("bad statment " . $this->getAllStatementString . "");
        }
        $this->updateStatementByGameID = $this->conn->prepare($this->updateStatementGameByGameIDString);
        if (is_null($this->updateStatementByGameID)) {
            throw new Exception("bad statement: " . $this->updateStatementGameByGameIDString . "");
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

    public function updateGame($game) {
        $success = false;
        $gameID = $game->getGameID();
        $gameStatusID = $game->getGameStatusID();
        $balls = $game->getBalls();
        $score = $game->getTotalScore();
        try {
            $this->updateStatementByGameID->bindParam(":gameID", $gameID);
            $this->updateStatementByGameID->bindParam(":gameStatusID", $gameStatusID);
            $this->updateStatementByGameID->bindParam(":balls", $balls);
            $this->updateStatementByGameID->bindParam(":score", $score);
            $success = $this->updateStatementByGameID->execute();
        } catch (PDOException $e) {
            $success = false;
        } finally {
            if (!is_null($this->updateStatementByGameID)) {
                $this->updateStatementByGameID->closeCursor();
            }
            return $success;
        }
    }

}
