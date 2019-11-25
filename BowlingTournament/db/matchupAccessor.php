<?php

$projectRoot = filter_input(INPUT_SERVER, 'DOCUMENT_ROOT') . '/BowlingTournament';
require_once 'ConnectionManager.php';
require_once ($projectRoot . '/entity/Matchup.php');
require_once ($projectRoot . '/entity/Team.php');
require_once ($projectRoot . '/db/teamItemAccessor.php');

class matchupAccessor {

//    private $getTeamIDByMatchIDString = "select m.teamID, t.teamName, t.earnings, g.gameID, g.matchID, g.gameNumber, g.gameStatusID, g.balls, g.score from matchup m, team t, game g where m.matchID in (select g.gameID from game where g.matchID = :matchID and g.gameStatusID in('available','inprogress"
//            . "')) and t.teamID = m.teamID;";
    private $getTeamIDByMatchIDString = "select m.teamID, t.teamName, t.earnings, g.gameID, g.matchID, g.gameNumber, g.gameStatusID, g.balls, g.score from team t, game g, matchup m where g.matchID = m.matchID and t.teamID = m.teamID and m.matchID = :matchID and g.gameStatusID in('INPROGRESS', 'AVAILABLE')";
    private $getMatchupRoundsString = "select * from matchup";
    private $getMatchupRounds = null;
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

        $this->getMatchupRounds = $this->conn->prepare($this->getMatchupRoundsString);
        if (is_null($this->getMatchupRounds)) {
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
                $score = $r['score'];
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
    }

//end ftn

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
}
