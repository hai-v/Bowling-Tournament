<?php
    class TournamentRound implements JsonSerializable {
        private $roundID;
        
        public function __construct($roundID) {
            $this->roundID = $roundID;
        }
        
        public function getRoundID() {
            return $this->roundID;
        }
        
        public function jsonSerialize() {
            return get_object_vars($this);
        }
    }
?>
