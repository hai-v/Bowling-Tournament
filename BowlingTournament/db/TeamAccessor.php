<?php
$projectRoot = $_SERVER['DOCUMENT_ROOT'] . '/project/BowlingTournament';
require_once 'ConnectionManager.php';
require_once ($projectRoot . '/entity/Team.php');

class TeamAccessor {

    private $deleteStatementString = "delete from team where teamID = :teamID";
    private $insertStatementString = "insert INTO team values (:teamID, :teamName, :earnings)";
    private $updateStatementString = "update team set teamName = :teamName where teamID = :teamID";
    private $conn = NULL;
    private $deleteStatement = NULL;
    private $insertStatement = NULL;
    private $updateStatement = NULL;

    public function __construct() {
        $cm = new ConnectionManager();

        $this->conn = $cm->connect_db();
        if (is_null($this->conn)) {
            throw new Exception("no connection");
        }

        $this->deleteStatement = $this->conn->prepare($this->deleteStatementString);
        if (is_null($this->deleteStatement)) {
            throw new Exception("bad statement: '" . $this->deleteStatementString . "'");
        }

        $this->insertStatement = $this->conn->prepare($this->insertStatementString);
        if (is_null($this->insertStatement)) {
            throw new Exception("bad statement: '" . $this->getAllStatementString . "'");
        }

        $this->updateStatement = $this->conn->prepare($this->updateStatementString);
        if (is_null($this->updateStatement)) {
            throw new Exception("bad statement: '" . $this->updateStatementString . "'");
        }
    }

    private function getItemsByQuery($selectString) {
        $result = [];
        
        try {
            $stmt = $this->conn->prepare($selectString);
            $stmt->execute();
            $dbresults = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($dbresults as $r) {
                $teamID = $r['teamID'];
                $teamName = $r['teamName'];
                $earnings = $r['earnings'];
                $obj = new Team($teamID, $teamName, $earnings);
                array_push($result, $obj);
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

// end function getItemsByQuery

    public function getAllItems() {
        return $this->getItemsByQuery("SELECT * FROM team");
    }
   
// end function getAllItems

    private function getItemByID($id) {
        $result = NULL;

        try {
            $this->getByIDStatement->bindParam(":teamID", $id);
            $this->getByIDStatement->execute();
            $dbresults = $this->getByIDStatement->fetch(PDO::FETCH_ASSOC);

            if ($dbresults) {
                $teamID = $r['teamID'];
                $teamName = $r['teamName'];
                $earnings = $r['earnings'];
                $obj = new Team($teamID, $teamName, $earnings);
            }
        } catch (Exception $e) {
            $result = NULL;
        } finally {
            if (!is_null($this->getByIDStatement)) {
                $this->getByIDStatement->closeCursor();
            }
        }

        return $result;
    }


    public function deleteItem($item) {
        $success = false;

        $itemID = $item->getItemID();
        
        if ($this->countGames($item) === 0 && $this->countPlayers($item) === 0) {
            try {
                $this->deleteStatement->bindParam(":teamID", $teamID);
                $success = $this->deleteStatement->execute();
                $rc = $this->deleteStatement->rowCount();
            } catch (PDOException $e) {
                $success = false;
            } finally {
                if (!is_null($this->deleteStatement)) {
                    $this->deleteStatement->closeCursor();
                }
                return $success;
            }            
        }
        else {
            return false;
        }
    }

    public function insertItem($item) {
        $success = false;

        $teamID = $item->getTeamID();
        $teamName = $item->getTeamName();
        $earnings = $item->getEarnings();
        try {
            $this->insertStatement->bindParam(":teamID", $teamID);
            $this->insertStatement->bindParam(":teamName", $teamName);
            $this->insertStatement->bindParam(":earnings", $earnings);
            $success = $this->insertStatement->execute();
        } catch (PDOException $e) {
            $success = false;
        } finally {
            if (!is_null($this->insertStatement)) {
                $this->insertStatement->closeCursor();
            }
            return $success;
        }
    }

    public function updateItem($item) {
        $success = false;

        $itemID = $item->getTeamID();
        $itemName = $item->getTeamName();
        
        if ($this->countGames($item) === 0) {
            try {
                $this->updateStatement->bindParam(":teamID", $itemID);
                $this->updateStatement->bindParam(":teamName", $teamName);
                $success = $this->updateStatement->execute();
            } catch (PDOException $e) {
                $success = false;
            } finally {
                if (!is_null($this->updateStatement)) {
                    $this->updateStatement->closeCursor();
                }
                return $success;
            }
        }
        else {
            return false;
        }
    }
    
    private function countPlayers($item) {
        $query = "select * from player where teamID = :teamID";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":teanID", $teamID);
        $stmt->execute();
        $numPlayers = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return  count($numPlayers);
    }
    
    private function countGames($item) {
        $query = "select * from game where matchID in (select matchID from matchup where teamID = :teamID)";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":teamID", $teamID);
        $stmt->execute();
        $numMatches = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return count($numMatches);
    }
}
?>