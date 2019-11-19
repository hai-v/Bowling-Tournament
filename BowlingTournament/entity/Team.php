<?php


    class Team implements JsonSerializable {
        private $teamID;
        private $teamName;
        private $earnings;
        
        public function __construct($teamID, $teamName, $earnings) {
            $this->teamID = $teamID;
            $this->teamName = $teamName;
            $this->earnings = $earnings;   
        }
        
        public function getTeamID() {
            return $this->teamID;
        }
        
        public function getTeamName() {
            return $this->teamName;
        }
        
        public function getEarnings() {
            return $this->earnings;
        }
        
        public function jsonSerialize() {
            return get_object_vars($this);
        }
    }
?>
