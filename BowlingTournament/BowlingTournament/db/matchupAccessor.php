<?php

$projectRoot = filter_input(INPUT_SERVER, 'DOCUMENT_ROOT') . '/BowlingTournament';
require_once 'ConnectionManager.php';
require_once ($projectRoot . '/entity/Matchup.php');
require_once ($projectRoot . '/entity/Team.php');
require_once ($projectRoot . '/db/teamItemAccessor.php');

class matchupAccessor {

    private $getTeamIDByMatchIDString = "select m.teamID, t.teamName, t.earnings, g.gameID, g.matchID, g.gameNumber, g.gameStatusID, g.balls, g.score from team t, game g, matchup m where g.matchID = m.matchID and t.teamID = m.teamID and m.matchID = :matchID and g.gameStatusID in('INPROGRESS', 'AVAILABLE')";
    private $getMatchupRoundsString = "select distinct m.matchID, m.roundID, m.matchgroup, m.teamID, m.score, m.ranking from matchup m, game g where m.matchID = g.matchID and g.gameStatusID in('available', 'inprogress')";
    private $getTotalScoreForMatchString = "select sum(score) as sum from game where matchID = :matchID";
    private $getMatchupByRoundsString = "select distinct m.matchID, m.roundID, m.matchgroup, m.teamID, m.score, m.ranking from matchup m, game g where m.matchID = g.matchID and g.gameStatusID in('available', 'inprogress') and g.gameStatusID in('available', 'inprogress') and m.roundID=:roundID";
    private $getMatchupByRoundsStatement = NULL;
    private $getTotalScoreForMatchStatement = NULL;
    private $getTeamsbyMatchIDStatement = NULL;

    public function __construct() {
        $cm = new ConnectionManager();
        $this->conn = $cm->connect_db();
        if (is_null($this->conn)) {
            throw new Exception("no connection");
        }

        $this->getTeamsbyMatchIDStatement = $this->conn->prepare($this->getTeamIDByMatchIDString);
        if (is_null($this->getTeamsbyMatchIDStatement)) {
            throw new Exception("bad statement: '" . $this->getAllStatementString . "'");
        }

         $this->getTotalScoreForMatchStatement = $this->conn->prepare($this->getTotalScoreForMatchString);
        if (is_null($this->getTotalScoreForMatchStatement)) {
            throw new Exception("bad statment " . $this->getAllStatementString . "");
        }
        
        $this->getMatchupByRoundsStatement = $this->conn->prepare($this->getMatchupByRoundsString);
        if (is_null($this->getMatchupByRoundsStatement)) {
            throw new Exception("bad statment " . $this->getAllStatementString . "");
        }
    }

    private function getMatchupsByQuery($selectString) {
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
                $score = $this->getTotalScoreForMatch($matchID);
                $ranking = $r['ranking'];
                $matchupObj = new Matchup($matchID, $roundID, $matchGroup, $teamID, $score, $ranking);
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
    }//end ftn
    
    private function getTotalScoreForMatch($matchID) {
        $this->getTotalScoreForMatchStatement->bindParam(":matchID", $matchID);
        $this->getTotalScoreForMatchStatement->execute();
        $dbresults = $this->getTotalScoreForMatchStatement->fetchAll(PDO::FETCH_ASSOC);
        $totalScore = 0;
        foreach ($dbresults as $r) {
            $totalScore = $r['sum'];
        }
        return $totalScore;
    }

    public function getAllMatchups() {
        return $this->getMatchupsByQuery($this->getMatchupRoundsString);
    }

    public function getTeamsByMatchID($matchID) {
        $result = [];
        try {
            $this->getTeamsbyMatchIDStatement->bindParam(":matchID", $matchID);
            $this->getTeamsbyMatchIDStatement->execute();
            $dbresults = $this->getTeamsbyMatchIDStatement->fetchAll(PDO::FETCH_ASSOC);
            foreach ($dbresults as $r) {
                $teamObj = new Team($r['teamID'], $r['teamName'], $r['earnings']);
                $gameObj = new Game($r['gameID'], $r['gameNumber'], $r['gameStatusID'], $r['gameStatusID'], $r['balls'], $r['score'], $teamObj);
                array_push($result, $gameObj);
            }
        } catch (Exception $e) {
            $result = NULL;
        } finally {
            if (!is_null($this->getTeamsbyMatchIDStatement)) {
                $this->getTeamsbyMatchIDStatement->closeCursor();
            }
        }
        return $result;
    }

    public function getMatchupsByRound($roundID) {
        $result = [];
        try {
            $this->getMatchupByRoundsStatement->bindParam(":roundID", $roundID);
            $this->getMatchupByRoundsStatement->execute();
            $dbresults = $this->getMatchupByRoundsStatement->fetchAll(PDO::FETCH_ASSOC);
            foreach ($dbresults as $r) {
                $matchID = $r['matchID'];
                $roundID = $r['roundID'];
                $matchGroup = $r['matchgroup'];
                $teamID = $r['teamID'];
                $score = $r['score'];
                $ranking = $r['ranking'];
                $matchupObj = new Matchup($matchID, $roundID, $matchGroup, $teamID, $score, $ranking);
                array_push($result, $matchupObj);
            }
        } catch (Exception $e) {
            $result = NULL;
        } finally {
            if (!is_null($this->getMatchupByRoundsStatement)) {
                $this->getMatchupByRoundsStatement->closeCursor();
            }
        }
        return $result;
    }

}
