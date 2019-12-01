<?php
$projectRoot = $_SERVER['DOCUMENT_ROOT'] . '/project/BowlingTournament';
require_once 'ConnectionManager.php';
require_once ($projectRoot . '/entity/Player.php');
require_once ($projectRoot . '/entity/Team.php');
require_once ($projectRoot . '/utils/ChromePhp.php');

class PlayerAccessor {

    private $getByIDStatementString = "select * from player where playerID = :playerID";
    private $deleteStatementString = "delete from player where playerID = :playerID";
    private $insertStatementString = "insert INTO player values (:playerID, :teamID, :firstName, :lastName, :hometown, :province)";
    private $updateStatementString = "update player set teamID = :teamID, firstName = :firstName, lastName = :lastName, hometown = :hometown, province = :province where playerID = :playerID";
    private $conn = NULL;
    private $getByIDStatement = NULL;
    private $deleteStatement = NULL;
    private $insertStatement = NULL;
    private $updateStatement = NULL;

    public function __construct() {
        $cm = new ConnectionManager();

        $this->conn = $cm->connect_db();
        if (is_null($this->conn)) {
            throw new Exception("no connection");
        }
        $this->getByIDStatement = $this->conn->prepare($this->getByIDStatementString);
        if (is_null($this->getByIDStatement)) {
            throw new Exception("bad statement: '" . $this->getAllStatementString . "'");
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
                $obj = new Player($r['playerID'], new Team($r['teamID'], $r['teamName'], $r['earnings']), $r['firstName'], $r['lastName'], $r['hometown'], $r['province']);
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

    public function getAllItems() {
        return $this->getItemsByQuery("SELECT p.playerID, p.firstName, p.lastName, p.hometown, p.province, t.teamID, t.teamName, t.earnings FROM player p, team t WHERE p.teamID = t.teamID");
    }

    public function getItemByID($id) {
        $result = NULL;

        try {
            $this->getByIDStatement->bindParam(":playerID", $id);
            $this->getByIDStatement->execute();
            $r = $this->getByIDStatement->fetch(PDO::FETCH_ASSOC); // not fetchAll

            if ($r) {
                $playerID = $r['playerID'];
                $teamID = $r['teamID'];
                $firstName = $r['firstName'];
                $lastName = $r['lastName'];
                $hometown = $r['hometown'];
                $province = $r['province'];
                $result = new Player($playerID, $teamID, $firstName, $lastName, $hometown, $province);
            }
        }
        catch (Exception $e) {
            $result = NULL;
        }
        finally {
            if (!is_null($this->getByIDStatement)) {
                $this->getByIDStatement->closeCursor();
            }
        }

        return $result;
    }

    public function deleteItem($player) {
        $success;

        $playerID = $player->getPlayerID(); // only the ID is needed
        
        $deletable =  $this->isDeletable($playerID);
        if ($deletable) {
            try {
                $this->deleteStatement->bindParam(":playerID", $playerID);
                $success = $this->deleteStatement->execute();
            }
            catch (PDOException $e) {
                $success = false;
            }
            finally {
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
    
    private function isDeletable($playerID) {
        $success;
        
        $query = "select * from game where matchId in (select matchID from matchup where teamID = (select teamID from player where playerID = :playerID))";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":playerID", $playerID);
        $stmt->execute();
        $dbresults = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return (count($dbresults) === 0);
    }

    public function insertItem($player) {
        $success;

        $playerID = $player->getPlayerID();
        $teamID = $player->getTeam();
        $firstName = $player->getFirstName();
        $lastName = $player->getLastName();
        $hometown = $player->getHometown();
        $province = $player->getProvince();

        try {
            $this->insertStatement->bindParam(":playerID", $playerID);
            $this->insertStatement->bindParam(":teamID", $teamID);
            $this->insertStatement->bindParam(":firstName", $firstName);
            $this->insertStatement->bindParam(":lastName", $lastName);
            $this->insertStatement->bindParam(":hometown", $hometown);
            $this->insertStatement->bindParam(":province", $province);
            $success = $this->$insertStatement->execute();
        }
        catch (PDOException $e) {
            $success = false;
        }
        finally {
            if (!is_null($this->insertStatement)) {
                $this->insertStatement->closeCursor();
            }
            return $success;
        }
    }

    public function updateItem($player) {
        $success;

        $playerID = $player->getPlayerID();
        $teamID = $player->getTeam();
        $firstName = $player->getFirstName();
        $lastName = $player->getLastName();
        $hometown = $player->getHometown();
        $province = $player->getProvince();

        if ($this->isUpdatable($teamID)) {
            try {
                $this->updateStatement->bindParam(":playerID", $playerID);
                $this->updateStatement->bindParam(":teamID", $teamID);
                $this->updateStatement->bindParam(":firstName", $firstName);
                $this->updateStatement->bindParam(":lastName", $lastName);
                $this->updateStatement->bindParam(":hometown", $hometown);
                $this->updateStatement->bindParam(":province", $province);
                $success = $this->updateStatement->execute();
            }
            catch (PDOException $e) {
                $success = false;
            }
            finally {
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
    
    private function isUpdatable($teamID) {
        $success;
        
        $query = "select * from player where teamID = :teamID";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":teamID", $teamID);
        $stmt->execute();
        $dbresults = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return (count($dbresults) < 4);        
    }
}
// end class PlayerAccessor