<?php
$projectRoot = filter_input(INPUT_SERVER, "DOCUMENT_ROOT") . '/project/BowlingTournament';
require_once 'ConnectionManager.php';
require_once ($projectRoot . '/entity/Player.php');

class MenuItemAccessor {

    private $getByIDStatementString = "select * from player where playerID = :playerID";
    private $deleteStatementString = "delete from player where playerID = :playerID";
    private $insertStatementString = "insert INTO player values (:playerID, :teamID, :firstName, :lastName, :hometown, :province)";
    private $updateStatementString = "update player set teamID = :teamID, firstName = :firstName, lastName = :lastName, hometown = :hometown, province = :province where playerID = :playerID";
    private $conn = NULL;
    private $getByIDStatement = NULL;
    private $deleteStatement = NULL;
    private $insertStatement = NULL;
    private $updateStatement = NULL;

    // Constructor will throw exception if there is a problem with ConnectionManager,
    // or with the prepared statements.
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

    /**
     * Gets menu items by executing a SQL "select" statement. An empty array
     * is returned if there are no results, or if the query contains an error.
     * 
     * @param String $selectString a valid SQL "select" statement
     * @return array MenuItem objects
     */
    public function getItemsByQuery($selectString) {
        $result = [];

        try {
            $stmt = $this->conn->prepare($selectString);
            $stmt->execute();
            $dbresults = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($dbresults as $r) {
                $playerID = $r['playerID'];
                $teamID = $r['teamID'];
                $firstName = $r['firstName'];
                $lastName = $r['lastName'];
                $hometown = $r['hometown'];
                $province = $r['province'];
                $obj = new Player($playerID, $teamID, $firstName, $lastName, $hometown, $province);
                array_push($result, $obj);
            }
        }
        catch (Exception $e) {
            $result = [];
        }
        finally {
            if (!is_null($stmt)) {
                $stmt->closeCursor();
            }
        }

        return $result;
    }

    /**
     * Gets all menu items.
     * 
     * @return array MenuItem objects, possibly empty
     */
    public function getAllItems() {
        return $this->getItemsByQuery("select * from player");
    }

    /**
     * Gets the menu item with the specified ID.
     * 
     * @param Integer $id the ID of the item to retrieve 
     * @return the MenuItem object with the specified ID, or NULL if not found
     */
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

    /**
     * Deletes a menu item.
     * @param MenuItem $item an object EQUAL TO the item to delete
     * @return boolean indicates whether the item was deleted
     */
    public function deleteItem($player) {
        $success;

        $playerID = $player->getPlayerID(); // only the ID is needed

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

    /**
     * Inserts a menu item into the database.
     * 
     * @param MenuItem $item an object of type MenuItem
     * @return boolean indicates if the item was inserted
     */
    public function insertItem($player) {
        $success;

        $playerID = $player->getPlayerID();
        $teamID = $player->getTeamID();
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
            $success = $this->updateStatement->execute();
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

    /**
     * Updates a menu item in the database.
     * 
     * @param MenuItem $item an object of type MenuItem, the new values to replace the database's current values
     * @return boolean indicates if the item was updated
     */
    public function updateItem($player) {
        $success;

        $playerID = $player->getPlayerID();
        $teamID = $player->getTeamID();
        $firstName = $player->getFirstName();
        $lastName = $player->getLastName();
        $hometown = $player->getHometown();
        $province = $player->getProvince();

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

}
// end class PlayerAccessor
