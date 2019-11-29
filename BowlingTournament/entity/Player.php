<?php
    require_once ($projectRoot . '/entity/Team.php');
    class Player implements JsonSerializable {
        private $playerID;
        private $team; // can be a Team obj or teamID
        private $firstName;
        private $lastName;
        private $hometown;
        private $province;

        
        public function __construct($playerID, $team, $firstName, $lastName, $hometown, $province) {
            $this->playerID = $playerID;
            $this->team = $team;
            $this->firstName = $firstName;
            $this->lastName = $lastName;
            $this->hometown = $hometown;
            $this->province = $province;
        }
        
        public function getPlayerID() {
            return $this->playerID;
        }
        
        public function getTeam() {
            return $this->team;
        }
        
        public function getFirstName() {
            return $this->firstName;
        }
        
        public function getLastName() {
            return $this->lastName;
        }
        
        public function getHometown() {
            return $this->hometown;
        }
        
        public function getProvince() {
            return $this->province;
        }
             
        public function jsonSerialize() {
            return get_object_vars($this);
        }
    }
?>    
