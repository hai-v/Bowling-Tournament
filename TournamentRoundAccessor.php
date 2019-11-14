<?php
$projectRoot = filter_input(INPUT_SERVER, "DOCUMENT_ROOT") . '/project/BowlingTournament';
require_once 'ConnectionManager.php';
require_once ($projectRoot . '/entity/TournamentRound.php');
require_once ($projectRoot . '/utils/ChromePhp.php');

class TournamentRoundAccessor {

    private $getByIDStatementString = "select * from tournamentround where roundID = :roundID";
    private $deleteStatementString = "delete from tournamentround where roundID = :roundID";
    private $insertStatementString = "insert INTO tournamentround values (:roundID)";
    private $conn = NULL;
    private $getByIDStatement = NULL;
    private $deleteStatement = NULL;
    private $insertStatement = NULL;

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
                $roundID = $r['roundID'];
                $obj = new TournamentRound($roundID);
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
        return $this->getItemsByQuery("select * from tournamentround");
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
            $this->getByIDStatement->bindParam(":roundID", $id);
            $this->getByIDStatement->execute();
            $r = $this->getByIDStatement->fetch(PDO::FETCH_ASSOC); // not fetchAll

            if ($r) {
                $roundID = $r['roundID'];
                $result = new TournamentRound($roundID);
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
    public function deleteItem($item) {
        $success;

        $roundID = $item->getRoundID(); // only the ID is needed

        try {
            $this->deleteStatement->bindParam(":roundID", $roundID);
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
    public function insertItem($item) {
        $success;

        $roundID = $item->getRoundID();

        try {
            $this->insertStatement->bindParam(":roundID", $roundID);
            $success = $this->insertStatement->execute();
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
}
// end class PlayerAccessor
