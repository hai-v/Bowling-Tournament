<?php

class Game implements JsonSerializable {

    private $gameID;
    private $matchID;
    private $gameNumber;
    private $gameStatusID;
    private $balls = [null];
    private $score = [null];
    private $team;

    public function __construct($gameID, $matchID, $gameNumber, $gameStatusID, $balls, $score, Team $team) {
        $this->gameID = $gameID;
        $this->matchID = $matchID;
        $this->gameNumber = $gameNumber;
        $this->gameStatusID = $gameStatusID;
        $this->balls = $balls;
        $this->score = $score;
        $this->team = $team;
    }

    public function getGameID() {
        return $this->gameID;
    }

    public function getMatchID() {
        return $this->matchID;
    }

    public function getGameNumber() {
        return $this->gameNumber;
    }

    public function getGameStatusID() {
        return $this->gameStatusID;
    }

    public function getBalls() {
        $res = "";
        for ($i = 0; $i < sizeof($this->balls); $i++) {
            if ($i == sizeof($this->balls)) {
                $res .= $this->balls[$i];
            } else {
                $res .= $this->balls[$i] . ",";
            }
        }
        return $res;
    }

    public function getScore() {
        return $this->score;
    }

    public function jsonSerialize() {
        return get_object_vars($this);
    }

    public function getTotalScore() {
        return $this->score[sizeof($this->score) -1];
    }
}
?> 
