<?php

$projectRoot = filter_input(INPUT_SERVER, 'DOCUMENT_ROOT') . '/BowlingTournament';
require_once 'ConnectionManager.php';
require_once ($projectRoot . '/entity/TournamentRound.php');

class tournamentAccessor {

    private $getTournamentRoundsString = "select * from TOURNAMENTROUND";
    private $getTournamentRounds = null;

    public function __construct() {
        $cm = new ConnectionManager();
        $this->conn = $cm->connect_db();
        if (is_null($this->conn)) {
            throw new Exception("no connection");
        }
        $this->getTournamentRounds = $this->conn->prepare($this->getTournamentRoundsString);
        if (is_null($this->getTournamentRounds)) {
            throw new Exception("bad statment " . $this->getTournamentRoundsString . "");
        }
    }

//end constructor

    private function getTournamentRoundsByQuery($selectString) {
        $result = [];
        try {
            $stmt = $this->conn->prepare($selectString);
            $stmt->execute();
            $dbresults = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($dbresults as $r) {
                $roundID = $r['roundID'];
                $tournamentRoundObj = new TournamentRound($roundID);
                array_push($result, $tournamentRoundObj);
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

    public function getAllRounds() {
        return $this->getTournamentRoundsByQuery($this->getTournamentRoundsString);
    }
}
