<?php
    class GameStatus implements JsonSerializable {
        private $gameStatusID;
        
        public function __construct($gameStatusID) {
            $this->gameStatusID = $gameStatusID;
        }
        
        public function getGameStatusID() {
            return $this->gameStatusID;
        }
        
        public function jsonSerialize() {
            return get_object_vars($this);
        }
    }
?>
