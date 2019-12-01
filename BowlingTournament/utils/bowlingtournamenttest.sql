-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 29, 2019 at 02:00 PM
-- Server version: 10.4.6-MariaDB
-- PHP Version: 7.3.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bowlingtournamenttest`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `createTieBreaker` (IN `inRoundID` VARCHAR(5), IN `inMatchGroup` INT, IN `inRanking` INT)  NO SQL
BEGIN

DECLARE tempMatchID INTEGER;
DECLARE nextGameNum INTEGER;

SET tempMatchID = (SELECT matchID FROM matchup WHERE ranking = inRanking AND roundID = inRoundID AND matchGroup = inMatchGroup);
SET nextGameNum = (SELECT MAX(gameNumber) + 1 FROM game WHERE matchID = tempMatchID);

INSERT INTO game (matchID, gameNumber, gameStatusID, score, balls) VALUES (tempMatchID, nextGameNum, "AVAILABLE", null, null);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `noTiebreaker` (IN `inRoundID` VARCHAR(5), IN `inMatchGroup` INT, OUT `noTieBreaker` BOOLEAN)  NO SQL
BEGIN

DECLARE tempMatchID INTEGER;
DECLARE firstScore INTEGER;
DECLARE secondScore INTEGER;
DECLARE scoreDiff INTEGER;

SET noTieBreaker = TRUE;

IF (inRoundID = "QUAL") THEN
	SET firstScore = (SELECT score FROM matchup WHERE roundID = inRoundID AND ranking = 16);
    SET secondScore = (SELECT score FROM matchup WHERE roundID = inRoundID AND ranking = 17);
	SET scoreDiff = firstScore - secondScore;
    IF (scoreDiff = 0) THEN
    	CALL createTieBreaker(inRoundID, inMatchGroup, 16);
      	CALL createTieBreaker(inRoundID, inMatchGroup, 17); 
        SET noTieBreaker = FALSE;
   	END IF;
ELSE
	SET firstScore = (SELECT score FROM matchup WHERE matchGroup = inMatchGroup AND roundID = inRoundID AND ranking = 1);
    SET secondScore = (SELECT score FROM matchup WHERE matchGroup = inMatchGroup AND roundID = inRoundID AND ranking = 2);
	SET scoreDiff = firstScore - secondScore;
    IF (scoreDiff = 0) THEN 
    	CALL createTieBreaker(inRoundID, inMatchGroup, 1);
      	CALL createTieBreaker(inRoundID, inMatchGroup, 2);
        SET noTieBreaker = FALSE;
   	END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reset` ()  NO SQL
BEGIN


DECLARE countMatch INTEGER;
DECLARE tempTeamID INTEGER;
DECLARE finished INTEGER DEFAULT 0;
DECLARE curTeamID CURSOR FOR SELECT teamID FROM team;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

SET countMatch = 1;

TRUNCATE TABLE game;
DELETE FROM matchup;
UPDATE team SET earnings = null;

OPEN curTeamID;
	l : LOOP
    	FETCH curTeamID INTO tempTeamID;
		IF finished = 1 THEN
        	LEAVE l;
       	END IF;
        INSERT INTO matchup VALUES (countMatch, "QUAL", 1, tempTeamID, null, null);
        SET countMatch = countMatch + 1;
   	END LOOP;
CLOSE curTeamID;

BEGIN

DECLARE done INTEGER DEFAULT 0;
DECLARE tempMatchID INTEGER;
DECLARE countGames INTEGER;
DECLARE numGameID INTEGER;
DECLARE curMatchID CURSOR FOR SELECT matchID FROM matchup;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

SET countGames = 1;
SET numGameID = 1;

OPEN curMatchID;
	tl : LOOP
    	FETCH curMatchID INTO tempMatchID;
		IF done = 1 THEN
        	LEAVE tl;
      	END IF;
        WHILE countGames <= 8 DO
        	INSERT INTO game (matchID, gameNumber, gameStatusID, score, balls) VALUES (tempMatchID, countGames, "AVAILABLE", null, null);
            SET countGames = countGames + 1;
            SET numGameID = numGameID + 1;
      	END WHILE;
        SET countGames = 1;
	END LOOP;
CLOSE curMatchID;

END;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setupFinal` ()  NO SQL
BEGIN

DECLARE firstSeed INTEGER;
DECLARE firstRand INTEGER;
DECLARE tempMatchID INTEGER;
DECLARE added INTEGER;
DECLARE nextMatchID INTEGER;
declare	countGames INTEGER;

SET firstSeed = (SELECT teamID FROM matchup WHERE roundID = "SEED4" AND ranking = 1 AND matchgroup = 1);
SET firstRand = (SELECT teamID FROM matchup WHERE roundID = "RAND4" AND ranking = 1 AND matchgroup = 1);
SET added = 0;
SET nextMatchID = (SELECT MAX(matchID) FROM matchup) + 1;
SET countGames = 1;

INSERT INTO matchup VALUES (nextMatchID, "FINAL", 1, firstSeed, null, null);
WHILE (countGames <= 3) DO
	INSERT INTO game (matchID, gameNumber, gameStatusID, score, balls) VALUES (nextMatchID, countGames, "AVAILABLE", null, null);
	SET countGames = countGames + 1;
END WHILE;
SET nextMatchID = nextMatchID + 1;
SET countGames = 1;
INSERT INTO matchup VALUES (nextMatchID, "FINAL", 1, firstRand, null, null);
WHILE (countGames <= 3) DO
	INSERT INTO game (matchID, gameNumber, gameStatusID, score, balls) VALUES (nextMatchID, countGames, "AVAILABLE", null, null);
	SET countGames = countGames + 1;
END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setupFirstRandRound` ()  NO SQL
BEGIN

DECLARE randRanking INTEGER;
DECLARE existRandTeam INTEGER;
DECLARE firstRank INTEGER;
declare countGames INTEGER;
DECLARE lastRank INTEGER;
DECLARE maxMatchID INTEGER;
declare	countTeams INTEGER;
DECLARE tempTeamID INTEGER;

SET firstRank = 1;
SET lastRank = 16;
SET maxMatchID = (select max(matchID) from matchup) + 1;
set countTeams = 0;
set countGames = 1;

WHILE countTeams < 16 DO
	SET randRanking = floor(rand() * (lastRank - firstRank + 1) + 1);
	SET existRandTeam = (SELECT COUNT(*) FROM matchup WHERE teamID = (SELECT teamID FROM matchup WHERE ranking = randRanking AND roundID = "QUAL") AND roundID = "RAND1");
	WHILE (existRandTeam >= 1) DO
		SET randRanking = floor(rand() * (lastRank - firstRank + 1) + 1);
		SET existRandTeam = (SELECT COUNT(*) FROM matchup WHERE teamID = (SELECT teamID FROM matchup WHERE ranking = randRanking AND roundID = "QUAL") AND roundID = "RAND1");
	END WHILE;
    	SET tempTeamID = (select teamID from matchup WHERE ranking = randRanking and roundID = "QUAL");
    	INSERT INTO matchup VALUES (maxMatchID, "RAND1", (countTeams DIV 2) + 1, tempTeamID, null, null);
	WHILE (countGames <= 3) DO
		INSERT INTO game (matchID, gameNumber, gameStatusID, score, balls) VALUES (maxMatchID, countGames, "AVAILABLE", null, null);
		SET countGames = countGames + 1;
	END WHILE;
	SET countGames = 1;
	SET countTeams = countTeams + 1;
	SET maxMatchID = maxMatchID + 1;
END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setupFirstSeedRound` ()  NO SQL
BEGIN

DECLARE firstTeamAdded integer;
DECLARE firstRank integer;
DECLARE lastRank integer;
DECLARE counter integer;
DECLARE nextMatchID integer;
DECLARE tempTeamID integer;
DECLARE countGames integer;

SET firstTeamAdded = 0;
SET firstRank = 1;
SET lastRank = 16;
SET counter = 0;
SET nextMatchID = (SELECT MAX(matchID) FROM matchup) + 1;
SET countGames = 1;

WHILE (counter < 16) DO
	IF (firstTeamAdded = 0) THEN
    	SET tempTeamID = (SELECT teamID from matchup WHERE roundID = "QUAL" AND ranking = firstRank);
        SET firstTeamAdded = 1;
        SET firstRank = firstRank + 1;
   	ELSE
    	SET tempTeamID = (SELECT teamID from matchup WHERE roundID = "QUAL" AND ranking = lastRank);
        SET firstTeamAdded = 0;
        SET lastRank = lastRank - 1;
  	END IF;
    INSERT INTO matchup VALUES (nextMatchID, "SEED1", (counter DIV 2) + 1, tempTeamID, null, null);
    WHILE (countGames <= 3) DO
		INSERT INTO game (matchID, gameNumber, gameStatusID, score, balls) VALUES (nextMatchID, countGames, "AVAILABLE", null, null);
		SET countGames = countGames + 1;
	END WHILE;
	SET countGames = 1;
    SET counter = counter + 1;
    SET nextMatchID = (SELECT MAX(matchID) FROM matchup) + 1;
END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setupNextRound` (IN `inRoundID` VARCHAR(5), IN `inMatchgroup` INT)  NO SQL
BEGIN

DECLARE nextRoundID varchar(5);
DECLARE countMatchgroup INTEGER;
DECLARE tempTeamID INTEGER;
DECLARE countGames INTEGER;
DECLARE finished INTEGER DEFAULT 0;
DECLARE nextMatchID INTEGER;
DECLARE curTeamID CURSOR FOR SELECT teamID FROM matchup WHERE roundID = inRoundID AND ranking = 1 AND matchgroup = inMatchgroup;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

SET nextRoundID = CONCAT(SUBSTRING(inRoundID, 1, 4), CAST(SUBSTRING(inRoundID, 5, 1) AS UNSIGNED) + 1);
SET nextMatchID = (SELECT MAX(matchID) FROM matchup) + 1;
SET countMatchgroup = 0;
SET countGames = 1;

OPEN curTeamID;
	theLoop: LOOP
    	FETCH curTeamID INTO tempTeamID;
        IF finished = 1 THEN 
        	LEAVE theLoop;
       	END IF;
        IF (inMatchgroup = 1 || inMatchgroup = 2) THEN
        	SET countMatchgroup = 1;
       	ELSEIF (inMatchgroup = 3 || inMatchgroup = 4) THEN
        	SET countMatchgroup = 2;
       	ELSEIF (inMatchgroup = 5 || inMatchgroup = 6) THEN
        	SET countMatchgroup = 3;
       	ELSE
        	SET countMatchgroup = 4;
       	END IF;
        INSERT INTO matchup VALUES (nextMatchID, nextRoundID, countMatchgroup, tempTeamID, null, null);
        WHILE (countGames <= 3) DO
			INSERT INTO game (matchID, gameNumber, gameStatusID, score, balls) VALUES (nextMatchID, countGames, "AVAILABLE", null, null);
			SET countGames = countGames + 1;
		END WHILE;
	SET countGames = 1;
        SET countMatchgroup = countMatchgroup + 1;
        SET nextMatchID = nextMatchID + 1;     
   	END LOOP;
CLOSE curTeamID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `test` (IN `inRoundID` VARCHAR(5), IN `inMatchgroup` INT)  NO SQL
BEGIN

DECLARE inScore INTEGER;
DECLARE tempMatchID INTEGER;
DECLARE finished INTEGER DEFAULT 0;
DECLARE curMatchID CURSOR FOR SELECT matchID FROM matchup WHERE roundID = inRoundID AND matchgroup = inMatchgroup;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

OPEN curMatchID;
	theLoop: LOOP
    	FETCH curMatchID INTO tempMatchID;
        IF finished = 1 THEN
        	LEAVE theLoop;
       	END IF;
        CALL testRandScore(tempMatchID);
 	END LOOP theLoop;
CLOSE curMatchID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `testRandScore` (IN `inMatchID` INT)  NO SQL
BEGIN

DECLARE tempGameID INTEGER;
DECLARE randScore INTEGER;
DECLARE finished INTEGER DEFAULT 0;
DECLARE curGame CURSOR FOR SELECT gameID FROM game WHERE matchID = inMatchID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

OPEN curGame;
	theLoop: LOOP
    	FETCH curGame INTO tempGameID;
        IF finished = 1 THEN 
        	LEAVE theLoop;
       	END IF;
        SET randScore = FLOOR(RAND() * (300 - 0 + 1) + 0);
        #SET randScore = 150;
        CALL updateGameScore(tempGameID, "COMPLETE", randScore, "");
   	END LOOP theLoop;
CLOSE curGame;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateEarnings` (IN `inRoundID` VARCHAR(5))  NO SQL
BEGIN

DECLARE tempTeamID INTEGER;
DECLARE finished INTEGER DEFAULT 0;
DECLARE curEarnings INTEGER;
DECLARE curTeamIDQUAL CURSOR FOR SELECT teamID FROM matchup WHERE roundID = inRoundID AND ranking BETWEEN 1 AND 16;
DECLARE curTeamIDFINAL CURSOR FOR SELECT teamID FROM matchup WHERE roundID = inRounDID AND ranking = 1;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

IF (inRoundID = "QUAL") THEN
	OPEN curTeamIDQUAL;
		qualLoop: LOOP
			FETCH curTeamIDQUAL INTO tempTeamID;
            IF finished = 1 THEN
            	LEAVE qualLoop;
          	END IF;
   			SET curEarnings = (SELECT earnings FROM team WHERE teamID = tempTeamID);
            IF (curEarnings IS null) THEN 
            	SET curEarnings = 400;
           	ELSE
        		SET curEarnings = curEarnings + 400;
           	END IF;
        	UPDATE team SET earnings = curEarnings WHERE teamID = tempTeamID;         
  		END LOOP qualLoop;
	CLOSE curTeamIDQUAL;
ELSEIF (inRoundID != "FINAL") THEN
	OPEN curTeamIDFINAL;
    	seedRandLoop: LOOP
        	FETCH curTeamIDFINAL INTO tempTeamID;
            IF finished = 1 THEN
            	LEAVE seedRandLoop;
          	END IF;            
            SET curEarnings = (SELECT earnings FROM team WHERE teamID = tempTeamID);
        	SET curEarnings = curEarnings + 400;
        	UPDATE team SET earnings = curEarnings WHERE teamID = tempTeamID;
  		END LOOP seedRandLoop;
	CLOSE curTeamIDFINAL;
ELSE
	OPEN curTeamIDFINAL;
    	finalLoop: LOOP
        	FETCH curTeamIDFINAL INTO tempTeamID;
            IF finished = 1 THEN
            	LEAVE finalLoop;
          	END IF;
            SET curEarnings = (SELECT earnings FROM team WHERE teamID = tempTeamID);
        	SET curEarnings = curEarnings + 1600;
        	UPDATE team SET earnings = curEarnings WHERE teamID = tempTeamID;
  		END LOOP finalLoop;
	CLOSE curTeamIDFINAL;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateGameScore` (IN `inGameID` INT(11), IN `inGameStatusID` VARCHAR(10), IN `inScore` INT(11), IN `inBalls` VARCHAR(80))  NO SQL
BEGIN

DECLARE curMatchID INTEGER;
DECLARE scoredGames integer;
DECLARE totalGames integer;
DECLARE totalScore integer;
DECLARE curRoundID varchar(11);
DECLARE curMatchGroup integer;
DECLARE matches integer;
DECLARE scoredMatches integer;

SET curMatchID = (SELECT matchID FROM game WHERE gameID = inGameID);

UPDATE game SET gameStatusID = inGameStatusID, score = inScore, balls = inBalls WHERE gameID = inGameID;

IF (inGameStatusID = "COMPLETE") THEN
	SET scoredGames = (SELECT COUNT(*) FROM game WHERE gameStatusID = "COMPLETE" AND matchID = curMatchID);
	SET totalGames = (SELECT COUNT(*) FROM game WHERE matchID = curMatchID);
	IF (scoredGames = totalGames) THEN 
    	SET totalScore = (SELECT SUM(score) FROM game WHERE matchID = curMatchID);
		UPDATE matchup SET score = totalScore WHERE matchID = curMatchID;
        SET curRoundID = (SELECT roundID FROM matchup WHERE matchID = curMatchID);
        SET curMatchGroup = (SELECT matchgroup FROM matchup WHERE matchID = curMatchID);
        SET matches = (SELECT COUNT(*) FROM game WHERE matchID in (SELECT matchID FROM matchup WHERE roundID = curRoundID AND matchgroup = curMatchGroup));
        SET scoredMatches = (SELECT COUNT(*) FROM game WHERE matchID in (SELECT matchID FROM matchup WHERE roundID = curRoundID AND matchgroup = curMatchGroup) AND score IS NOT null);
        IF (scoredMatches = matches) THEN
            CALL updateRanking(curRoundID, curMatchGroup);
            CALL noTiebreaker(curRoundID, curMatchGroup, @noTiebreaker);
         	IF (@noTiebreaker IS TRUE) THEN
            	CALL updateEarnings(curRoundID);
                IF (curRoundID = "QUAL") THEN
            		CALL setupFirstRandRound();
                	CALL setupFirstSeedRound();
               	ELSEIF (curRoundID != "FINAL") THEN
                	IF (curRoundID != "SEED4" AND curRoundID != "RAND4") THEN
                    	CALL setupNextRound(curRoundID, curMatchGroup);
                   	ELSE
                    	CALL setupFinal();
                   	END IF;
             	END IF;       
           	END IF;
        END IF;
  	END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateRanking` (IN `inRoundID` VARCHAR(5), IN `inMatchgroup` INT)  NO SQL
BEGIN

DECLARE finished INTEGER DEFAULT 0;
DECLARE winner INTEGER;
DECLARE tempMatchID INTEGER;
DECLARE curMatchID CURSOR FOR SELECT matchID FROM matchup WHERE matchgroup = inMatchgroup AND roundID = inRoundID ORDER BY score DESC;           
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
     
SET winner = 1;

OPEN curMatchID;
    aLoop: LOOP
    FETCH curMatchID INTO tempMatchID;
   		IF finished = 1 THEN
        	LEAVE aLoop;
     	END IF;
      	UPDATE matchup SET ranking = winner WHERE matchID = tempMatchID;
       	SET winner = winner + 1;
  	END LOOP aLoop;
CLOSE curMatchID;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `game`
--

CREATE TABLE `game` (
  `gameID` int(11) NOT NULL,
  `matchID` int(11) DEFAULT NULL,
  `gameNumber` int(11) DEFAULT NULL,
  `gameStatusID` varchar(10) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `balls` varchar(80) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `game`
--

INSERT INTO `game` (`gameID`, `matchID`, `gameNumber`, `gameStatusID`, `score`, `balls`) VALUES
(1, 1, 1, 'AVAILABLE', NULL, NULL),
(2, 1, 2, 'AVAILABLE', NULL, NULL),
(3, 1, 3, 'AVAILABLE', NULL, NULL),
(4, 1, 4, 'AVAILABLE', NULL, NULL),
(5, 1, 5, 'AVAILABLE', NULL, NULL),
(6, 1, 6, 'AVAILABLE', NULL, NULL),
(7, 1, 7, 'AVAILABLE', NULL, NULL),
(8, 1, 8, 'AVAILABLE', NULL, NULL),
(9, 2, 1, 'AVAILABLE', NULL, NULL),
(10, 2, 2, 'AVAILABLE', NULL, NULL),
(11, 2, 3, 'AVAILABLE', NULL, NULL),
(12, 2, 4, 'AVAILABLE', NULL, NULL),
(13, 2, 5, 'AVAILABLE', NULL, NULL),
(14, 2, 6, 'AVAILABLE', NULL, NULL),
(15, 2, 7, 'AVAILABLE', NULL, NULL),
(16, 2, 8, 'AVAILABLE', NULL, NULL),
(17, 3, 1, 'AVAILABLE', NULL, NULL),
(18, 3, 2, 'AVAILABLE', NULL, NULL),
(19, 3, 3, 'AVAILABLE', NULL, NULL),
(20, 3, 4, 'AVAILABLE', NULL, NULL),
(21, 3, 5, 'AVAILABLE', NULL, NULL),
(22, 3, 6, 'AVAILABLE', NULL, NULL),
(23, 3, 7, 'AVAILABLE', NULL, NULL),
(24, 3, 8, 'AVAILABLE', NULL, NULL),
(25, 4, 1, 'AVAILABLE', NULL, NULL),
(26, 4, 2, 'AVAILABLE', NULL, NULL),
(27, 4, 3, 'AVAILABLE', NULL, NULL),
(28, 4, 4, 'AVAILABLE', NULL, NULL),
(29, 4, 5, 'AVAILABLE', NULL, NULL),
(30, 4, 6, 'AVAILABLE', NULL, NULL),
(31, 4, 7, 'AVAILABLE', NULL, NULL),
(32, 4, 8, 'AVAILABLE', NULL, NULL),
(33, 5, 1, 'AVAILABLE', NULL, NULL),
(34, 5, 2, 'AVAILABLE', NULL, NULL),
(35, 5, 3, 'AVAILABLE', NULL, NULL),
(36, 5, 4, 'AVAILABLE', NULL, NULL),
(37, 5, 5, 'AVAILABLE', NULL, NULL),
(38, 5, 6, 'AVAILABLE', NULL, NULL),
(39, 5, 7, 'AVAILABLE', NULL, NULL),
(40, 5, 8, 'AVAILABLE', NULL, NULL),
(41, 6, 1, 'AVAILABLE', NULL, NULL),
(42, 6, 2, 'AVAILABLE', NULL, NULL),
(43, 6, 3, 'AVAILABLE', NULL, NULL),
(44, 6, 4, 'AVAILABLE', NULL, NULL),
(45, 6, 5, 'AVAILABLE', NULL, NULL),
(46, 6, 6, 'AVAILABLE', NULL, NULL),
(47, 6, 7, 'AVAILABLE', NULL, NULL),
(48, 6, 8, 'AVAILABLE', NULL, NULL),
(49, 7, 1, 'AVAILABLE', NULL, NULL),
(50, 7, 2, 'AVAILABLE', NULL, NULL),
(51, 7, 3, 'AVAILABLE', NULL, NULL),
(52, 7, 4, 'AVAILABLE', NULL, NULL),
(53, 7, 5, 'AVAILABLE', NULL, NULL),
(54, 7, 6, 'AVAILABLE', NULL, NULL),
(55, 7, 7, 'AVAILABLE', NULL, NULL),
(56, 7, 8, 'AVAILABLE', NULL, NULL),
(57, 8, 1, 'AVAILABLE', NULL, NULL),
(58, 8, 2, 'AVAILABLE', NULL, NULL),
(59, 8, 3, 'AVAILABLE', NULL, NULL),
(60, 8, 4, 'AVAILABLE', NULL, NULL),
(61, 8, 5, 'AVAILABLE', NULL, NULL),
(62, 8, 6, 'AVAILABLE', NULL, NULL),
(63, 8, 7, 'AVAILABLE', NULL, NULL),
(64, 8, 8, 'AVAILABLE', NULL, NULL),
(65, 9, 1, 'AVAILABLE', NULL, NULL),
(66, 9, 2, 'AVAILABLE', NULL, NULL),
(67, 9, 3, 'AVAILABLE', NULL, NULL),
(68, 9, 4, 'AVAILABLE', NULL, NULL),
(69, 9, 5, 'AVAILABLE', NULL, NULL),
(70, 9, 6, 'AVAILABLE', NULL, NULL),
(71, 9, 7, 'AVAILABLE', NULL, NULL),
(72, 9, 8, 'AVAILABLE', NULL, NULL),
(73, 10, 1, 'AVAILABLE', NULL, NULL),
(74, 10, 2, 'AVAILABLE', NULL, NULL),
(75, 10, 3, 'AVAILABLE', NULL, NULL),
(76, 10, 4, 'AVAILABLE', NULL, NULL),
(77, 10, 5, 'AVAILABLE', NULL, NULL),
(78, 10, 6, 'AVAILABLE', NULL, NULL),
(79, 10, 7, 'AVAILABLE', NULL, NULL),
(80, 10, 8, 'AVAILABLE', NULL, NULL),
(81, 11, 1, 'AVAILABLE', NULL, NULL),
(82, 11, 2, 'AVAILABLE', NULL, NULL),
(83, 11, 3, 'AVAILABLE', NULL, NULL),
(84, 11, 4, 'AVAILABLE', NULL, NULL),
(85, 11, 5, 'AVAILABLE', NULL, NULL),
(86, 11, 6, 'AVAILABLE', NULL, NULL),
(87, 11, 7, 'AVAILABLE', NULL, NULL),
(88, 11, 8, 'AVAILABLE', NULL, NULL),
(89, 12, 1, 'AVAILABLE', NULL, NULL),
(90, 12, 2, 'AVAILABLE', NULL, NULL),
(91, 12, 3, 'AVAILABLE', NULL, NULL),
(92, 12, 4, 'AVAILABLE', NULL, NULL),
(93, 12, 5, 'AVAILABLE', NULL, NULL),
(94, 12, 6, 'AVAILABLE', NULL, NULL),
(95, 12, 7, 'AVAILABLE', NULL, NULL),
(96, 12, 8, 'AVAILABLE', NULL, NULL),
(97, 13, 1, 'AVAILABLE', NULL, NULL),
(98, 13, 2, 'AVAILABLE', NULL, NULL),
(99, 13, 3, 'AVAILABLE', NULL, NULL),
(100, 13, 4, 'AVAILABLE', NULL, NULL),
(101, 13, 5, 'AVAILABLE', NULL, NULL),
(102, 13, 6, 'AVAILABLE', NULL, NULL),
(103, 13, 7, 'AVAILABLE', NULL, NULL),
(104, 13, 8, 'AVAILABLE', NULL, NULL),
(105, 14, 1, 'AVAILABLE', NULL, NULL),
(106, 14, 2, 'AVAILABLE', NULL, NULL),
(107, 14, 3, 'AVAILABLE', NULL, NULL),
(108, 14, 4, 'AVAILABLE', NULL, NULL),
(109, 14, 5, 'AVAILABLE', NULL, NULL),
(110, 14, 6, 'AVAILABLE', NULL, NULL),
(111, 14, 7, 'AVAILABLE', NULL, NULL),
(112, 14, 8, 'AVAILABLE', NULL, NULL),
(113, 15, 1, 'AVAILABLE', NULL, NULL),
(114, 15, 2, 'AVAILABLE', NULL, NULL),
(115, 15, 3, 'AVAILABLE', NULL, NULL),
(116, 15, 4, 'AVAILABLE', NULL, NULL),
(117, 15, 5, 'AVAILABLE', NULL, NULL),
(118, 15, 6, 'AVAILABLE', NULL, NULL),
(119, 15, 7, 'AVAILABLE', NULL, NULL),
(120, 15, 8, 'AVAILABLE', NULL, NULL),
(121, 16, 1, 'AVAILABLE', NULL, NULL),
(122, 16, 2, 'AVAILABLE', NULL, NULL),
(123, 16, 3, 'AVAILABLE', NULL, NULL),
(124, 16, 4, 'AVAILABLE', NULL, NULL),
(125, 16, 5, 'AVAILABLE', NULL, NULL),
(126, 16, 6, 'AVAILABLE', NULL, NULL),
(127, 16, 7, 'AVAILABLE', NULL, NULL),
(128, 16, 8, 'AVAILABLE', NULL, NULL),
(129, 17, 1, 'AVAILABLE', NULL, NULL),
(130, 17, 2, 'AVAILABLE', NULL, NULL),
(131, 17, 3, 'AVAILABLE', NULL, NULL),
(132, 17, 4, 'AVAILABLE', NULL, NULL),
(133, 17, 5, 'AVAILABLE', NULL, NULL),
(134, 17, 6, 'AVAILABLE', NULL, NULL),
(135, 17, 7, 'AVAILABLE', NULL, NULL),
(136, 17, 8, 'AVAILABLE', NULL, NULL),
(137, 18, 1, 'AVAILABLE', NULL, NULL),
(138, 18, 2, 'AVAILABLE', NULL, NULL),
(139, 18, 3, 'AVAILABLE', NULL, NULL),
(140, 18, 4, 'AVAILABLE', NULL, NULL),
(141, 18, 5, 'AVAILABLE', NULL, NULL),
(142, 18, 6, 'AVAILABLE', NULL, NULL),
(143, 18, 7, 'AVAILABLE', NULL, NULL),
(144, 18, 8, 'AVAILABLE', NULL, NULL),
(145, 19, 1, 'AVAILABLE', NULL, NULL),
(146, 19, 2, 'AVAILABLE', NULL, NULL),
(147, 19, 3, 'AVAILABLE', NULL, NULL),
(148, 19, 4, 'AVAILABLE', NULL, NULL),
(149, 19, 5, 'AVAILABLE', NULL, NULL),
(150, 19, 6, 'AVAILABLE', NULL, NULL),
(151, 19, 7, 'AVAILABLE', NULL, NULL),
(152, 19, 8, 'AVAILABLE', NULL, NULL),
(153, 20, 1, 'AVAILABLE', NULL, NULL),
(154, 20, 2, 'AVAILABLE', NULL, NULL),
(155, 20, 3, 'AVAILABLE', NULL, NULL),
(156, 20, 4, 'AVAILABLE', NULL, NULL),
(157, 20, 5, 'AVAILABLE', NULL, NULL),
(158, 20, 6, 'AVAILABLE', NULL, NULL),
(159, 20, 7, 'AVAILABLE', NULL, NULL),
(160, 20, 8, 'AVAILABLE', NULL, NULL),
(161, 21, 1, 'AVAILABLE', NULL, NULL),
(162, 21, 2, 'AVAILABLE', NULL, NULL),
(163, 21, 3, 'AVAILABLE', NULL, NULL),
(164, 21, 4, 'AVAILABLE', NULL, NULL),
(165, 21, 5, 'AVAILABLE', NULL, NULL),
(166, 21, 6, 'AVAILABLE', NULL, NULL),
(167, 21, 7, 'AVAILABLE', NULL, NULL),
(168, 21, 8, 'AVAILABLE', NULL, NULL),
(169, 22, 1, 'AVAILABLE', NULL, NULL),
(170, 22, 2, 'AVAILABLE', NULL, NULL),
(171, 22, 3, 'AVAILABLE', NULL, NULL),
(172, 22, 4, 'AVAILABLE', NULL, NULL),
(173, 22, 5, 'AVAILABLE', NULL, NULL),
(174, 22, 6, 'AVAILABLE', NULL, NULL),
(175, 22, 7, 'AVAILABLE', NULL, NULL),
(176, 22, 8, 'AVAILABLE', NULL, NULL),
(177, 23, 1, 'AVAILABLE', NULL, NULL),
(178, 23, 2, 'AVAILABLE', NULL, NULL),
(179, 23, 3, 'AVAILABLE', NULL, NULL),
(180, 23, 4, 'AVAILABLE', NULL, NULL),
(181, 23, 5, 'AVAILABLE', NULL, NULL),
(182, 23, 6, 'AVAILABLE', NULL, NULL),
(183, 23, 7, 'AVAILABLE', NULL, NULL),
(184, 23, 8, 'AVAILABLE', NULL, NULL),
(185, 24, 1, 'AVAILABLE', NULL, NULL),
(186, 24, 2, 'AVAILABLE', NULL, NULL),
(187, 24, 3, 'AVAILABLE', NULL, NULL),
(188, 24, 4, 'AVAILABLE', NULL, NULL),
(189, 24, 5, 'AVAILABLE', NULL, NULL),
(190, 24, 6, 'AVAILABLE', NULL, NULL),
(191, 24, 7, 'AVAILABLE', NULL, NULL),
(192, 24, 8, 'AVAILABLE', NULL, NULL),
(193, 25, 1, 'AVAILABLE', NULL, NULL),
(194, 25, 2, 'AVAILABLE', NULL, NULL),
(195, 25, 3, 'AVAILABLE', NULL, NULL),
(196, 25, 4, 'AVAILABLE', NULL, NULL),
(197, 25, 5, 'AVAILABLE', NULL, NULL),
(198, 25, 6, 'AVAILABLE', NULL, NULL),
(199, 25, 7, 'AVAILABLE', NULL, NULL),
(200, 25, 8, 'AVAILABLE', NULL, NULL),
(201, 26, 1, 'AVAILABLE', NULL, NULL),
(202, 26, 2, 'AVAILABLE', NULL, NULL),
(203, 26, 3, 'AVAILABLE', NULL, NULL),
(204, 26, 4, 'AVAILABLE', NULL, NULL),
(205, 26, 5, 'AVAILABLE', NULL, NULL),
(206, 26, 6, 'AVAILABLE', NULL, NULL),
(207, 26, 7, 'AVAILABLE', NULL, NULL),
(208, 26, 8, 'AVAILABLE', NULL, NULL),
(209, 27, 1, 'AVAILABLE', NULL, NULL),
(210, 27, 2, 'AVAILABLE', NULL, NULL),
(211, 27, 3, 'AVAILABLE', NULL, NULL),
(212, 27, 4, 'AVAILABLE', NULL, NULL),
(213, 27, 5, 'AVAILABLE', NULL, NULL),
(214, 27, 6, 'AVAILABLE', NULL, NULL),
(215, 27, 7, 'AVAILABLE', NULL, NULL),
(216, 27, 8, 'AVAILABLE', NULL, NULL),
(217, 28, 1, 'AVAILABLE', NULL, NULL),
(218, 28, 2, 'AVAILABLE', NULL, NULL),
(219, 28, 3, 'AVAILABLE', NULL, NULL),
(220, 28, 4, 'AVAILABLE', NULL, NULL),
(221, 28, 5, 'AVAILABLE', NULL, NULL),
(222, 28, 6, 'AVAILABLE', NULL, NULL),
(223, 28, 7, 'AVAILABLE', NULL, NULL),
(224, 28, 8, 'AVAILABLE', NULL, NULL),
(225, 29, 1, 'AVAILABLE', NULL, NULL),
(226, 29, 2, 'AVAILABLE', NULL, NULL),
(227, 29, 3, 'AVAILABLE', NULL, NULL),
(228, 29, 4, 'AVAILABLE', NULL, NULL),
(229, 29, 5, 'AVAILABLE', NULL, NULL),
(230, 29, 6, 'AVAILABLE', NULL, NULL),
(231, 29, 7, 'AVAILABLE', NULL, NULL),
(232, 29, 8, 'AVAILABLE', NULL, NULL),
(233, 30, 1, 'AVAILABLE', NULL, NULL),
(234, 30, 2, 'AVAILABLE', NULL, NULL),
(235, 30, 3, 'AVAILABLE', NULL, NULL),
(236, 30, 4, 'AVAILABLE', NULL, NULL),
(237, 30, 5, 'AVAILABLE', NULL, NULL),
(238, 30, 6, 'AVAILABLE', NULL, NULL),
(239, 30, 7, 'AVAILABLE', NULL, NULL),
(240, 30, 8, 'AVAILABLE', NULL, NULL),
(241, 31, 1, 'AVAILABLE', NULL, NULL),
(242, 31, 2, 'AVAILABLE', NULL, NULL),
(243, 31, 3, 'AVAILABLE', NULL, NULL),
(244, 31, 4, 'AVAILABLE', NULL, NULL),
(245, 31, 5, 'AVAILABLE', NULL, NULL),
(246, 31, 6, 'AVAILABLE', NULL, NULL),
(247, 31, 7, 'AVAILABLE', NULL, NULL),
(248, 31, 8, 'AVAILABLE', NULL, NULL),
(249, 32, 1, 'AVAILABLE', NULL, NULL),
(250, 32, 2, 'AVAILABLE', NULL, NULL),
(251, 32, 3, 'AVAILABLE', NULL, NULL),
(252, 32, 4, 'AVAILABLE', NULL, NULL),
(253, 32, 5, 'AVAILABLE', NULL, NULL),
(254, 32, 6, 'AVAILABLE', NULL, NULL),
(255, 32, 7, 'AVAILABLE', NULL, NULL),
(256, 32, 8, 'AVAILABLE', NULL, NULL),
(257, 33, 1, 'AVAILABLE', NULL, NULL),
(258, 33, 2, 'AVAILABLE', NULL, NULL),
(259, 33, 3, 'AVAILABLE', NULL, NULL),
(260, 33, 4, 'AVAILABLE', NULL, NULL),
(261, 33, 5, 'AVAILABLE', NULL, NULL),
(262, 33, 6, 'AVAILABLE', NULL, NULL),
(263, 33, 7, 'AVAILABLE', NULL, NULL),
(264, 33, 8, 'AVAILABLE', NULL, NULL),
(265, 34, 1, 'AVAILABLE', NULL, NULL),
(266, 34, 2, 'AVAILABLE', NULL, NULL),
(267, 34, 3, 'AVAILABLE', NULL, NULL),
(268, 34, 4, 'AVAILABLE', NULL, NULL),
(269, 34, 5, 'AVAILABLE', NULL, NULL),
(270, 34, 6, 'AVAILABLE', NULL, NULL),
(271, 34, 7, 'AVAILABLE', NULL, NULL),
(272, 34, 8, 'AVAILABLE', NULL, NULL),
(273, 35, 1, 'AVAILABLE', NULL, NULL),
(274, 35, 2, 'AVAILABLE', NULL, NULL),
(275, 35, 3, 'AVAILABLE', NULL, NULL),
(276, 35, 4, 'AVAILABLE', NULL, NULL),
(277, 35, 5, 'AVAILABLE', NULL, NULL),
(278, 35, 6, 'AVAILABLE', NULL, NULL),
(279, 35, 7, 'AVAILABLE', NULL, NULL),
(280, 35, 8, 'AVAILABLE', NULL, NULL),
(281, 36, 1, 'AVAILABLE', NULL, NULL),
(282, 36, 2, 'AVAILABLE', NULL, NULL),
(283, 36, 3, 'AVAILABLE', NULL, NULL),
(284, 36, 4, 'AVAILABLE', NULL, NULL),
(285, 36, 5, 'AVAILABLE', NULL, NULL),
(286, 36, 6, 'AVAILABLE', NULL, NULL),
(287, 36, 7, 'AVAILABLE', NULL, NULL),
(288, 36, 8, 'AVAILABLE', NULL, NULL),
(289, 37, 1, 'AVAILABLE', NULL, NULL),
(290, 37, 2, 'AVAILABLE', NULL, NULL),
(291, 37, 3, 'AVAILABLE', NULL, NULL),
(292, 37, 4, 'AVAILABLE', NULL, NULL),
(293, 37, 5, 'AVAILABLE', NULL, NULL),
(294, 37, 6, 'AVAILABLE', NULL, NULL),
(295, 37, 7, 'AVAILABLE', NULL, NULL),
(296, 37, 8, 'AVAILABLE', NULL, NULL),
(297, 38, 1, 'AVAILABLE', NULL, NULL),
(298, 38, 2, 'AVAILABLE', NULL, NULL),
(299, 38, 3, 'AVAILABLE', NULL, NULL),
(300, 38, 4, 'AVAILABLE', NULL, NULL),
(301, 38, 5, 'AVAILABLE', NULL, NULL),
(302, 38, 6, 'AVAILABLE', NULL, NULL),
(303, 38, 7, 'AVAILABLE', NULL, NULL),
(304, 38, 8, 'AVAILABLE', NULL, NULL),
(305, 39, 1, 'AVAILABLE', NULL, NULL),
(306, 39, 2, 'AVAILABLE', NULL, NULL),
(307, 39, 3, 'AVAILABLE', NULL, NULL),
(308, 39, 4, 'AVAILABLE', NULL, NULL),
(309, 39, 5, 'AVAILABLE', NULL, NULL),
(310, 39, 6, 'AVAILABLE', NULL, NULL),
(311, 39, 7, 'AVAILABLE', NULL, NULL),
(312, 39, 8, 'AVAILABLE', NULL, NULL),
(313, 40, 1, 'AVAILABLE', NULL, NULL),
(314, 40, 2, 'AVAILABLE', NULL, NULL),
(315, 40, 3, 'AVAILABLE', NULL, NULL),
(316, 40, 4, 'AVAILABLE', NULL, NULL),
(317, 40, 5, 'AVAILABLE', NULL, NULL),
(318, 40, 6, 'AVAILABLE', NULL, NULL),
(319, 40, 7, 'AVAILABLE', NULL, NULL),
(320, 40, 8, 'AVAILABLE', NULL, NULL),
(321, 41, 1, 'AVAILABLE', NULL, NULL),
(322, 41, 2, 'AVAILABLE', NULL, NULL),
(323, 41, 3, 'AVAILABLE', NULL, NULL),
(324, 41, 4, 'AVAILABLE', NULL, NULL),
(325, 41, 5, 'AVAILABLE', NULL, NULL),
(326, 41, 6, 'AVAILABLE', NULL, NULL),
(327, 41, 7, 'AVAILABLE', NULL, NULL),
(328, 41, 8, 'AVAILABLE', NULL, NULL),
(329, 42, 1, 'AVAILABLE', NULL, NULL),
(330, 42, 2, 'AVAILABLE', NULL, NULL),
(331, 42, 3, 'AVAILABLE', NULL, NULL),
(332, 42, 4, 'AVAILABLE', NULL, NULL),
(333, 42, 5, 'AVAILABLE', NULL, NULL),
(334, 42, 6, 'AVAILABLE', NULL, NULL),
(335, 42, 7, 'AVAILABLE', NULL, NULL),
(336, 42, 8, 'AVAILABLE', NULL, NULL),
(337, 43, 1, 'AVAILABLE', NULL, NULL),
(338, 43, 2, 'AVAILABLE', NULL, NULL),
(339, 43, 3, 'AVAILABLE', NULL, NULL),
(340, 43, 4, 'AVAILABLE', NULL, NULL),
(341, 43, 5, 'AVAILABLE', NULL, NULL),
(342, 43, 6, 'AVAILABLE', NULL, NULL),
(343, 43, 7, 'AVAILABLE', NULL, NULL),
(344, 43, 8, 'AVAILABLE', NULL, NULL),
(345, 44, 1, 'AVAILABLE', NULL, NULL),
(346, 44, 2, 'AVAILABLE', NULL, NULL),
(347, 44, 3, 'AVAILABLE', NULL, NULL),
(348, 44, 4, 'AVAILABLE', NULL, NULL),
(349, 44, 5, 'AVAILABLE', NULL, NULL),
(350, 44, 6, 'AVAILABLE', NULL, NULL),
(351, 44, 7, 'AVAILABLE', NULL, NULL),
(352, 44, 8, 'AVAILABLE', NULL, NULL),
(353, 45, 1, 'AVAILABLE', NULL, NULL),
(354, 45, 2, 'AVAILABLE', NULL, NULL),
(355, 45, 3, 'AVAILABLE', NULL, NULL),
(356, 45, 4, 'AVAILABLE', NULL, NULL),
(357, 45, 5, 'AVAILABLE', NULL, NULL),
(358, 45, 6, 'AVAILABLE', NULL, NULL),
(359, 45, 7, 'AVAILABLE', NULL, NULL),
(360, 45, 8, 'AVAILABLE', NULL, NULL),
(361, 46, 1, 'AVAILABLE', NULL, NULL),
(362, 46, 2, 'AVAILABLE', NULL, NULL),
(363, 46, 3, 'AVAILABLE', NULL, NULL),
(364, 46, 4, 'AVAILABLE', NULL, NULL),
(365, 46, 5, 'AVAILABLE', NULL, NULL),
(366, 46, 6, 'AVAILABLE', NULL, NULL),
(367, 46, 7, 'AVAILABLE', NULL, NULL),
(368, 46, 8, 'AVAILABLE', NULL, NULL),
(369, 47, 1, 'AVAILABLE', NULL, NULL),
(370, 47, 2, 'AVAILABLE', NULL, NULL),
(371, 47, 3, 'AVAILABLE', NULL, NULL),
(372, 47, 4, 'AVAILABLE', NULL, NULL),
(373, 47, 5, 'AVAILABLE', NULL, NULL),
(374, 47, 6, 'AVAILABLE', NULL, NULL),
(375, 47, 7, 'AVAILABLE', NULL, NULL),
(376, 47, 8, 'AVAILABLE', NULL, NULL),
(377, 48, 1, 'AVAILABLE', NULL, NULL),
(378, 48, 2, 'AVAILABLE', NULL, NULL),
(379, 48, 3, 'AVAILABLE', NULL, NULL),
(380, 48, 4, 'AVAILABLE', NULL, NULL),
(381, 48, 5, 'AVAILABLE', NULL, NULL),
(382, 48, 6, 'AVAILABLE', NULL, NULL),
(383, 48, 7, 'AVAILABLE', NULL, NULL),
(384, 48, 8, 'AVAILABLE', NULL, NULL),
(385, 49, 1, 'AVAILABLE', NULL, NULL),
(386, 49, 2, 'AVAILABLE', NULL, NULL),
(387, 49, 3, 'AVAILABLE', NULL, NULL),
(388, 49, 4, 'AVAILABLE', NULL, NULL),
(389, 49, 5, 'AVAILABLE', NULL, NULL),
(390, 49, 6, 'AVAILABLE', NULL, NULL),
(391, 49, 7, 'AVAILABLE', NULL, NULL),
(392, 49, 8, 'AVAILABLE', NULL, NULL),
(393, 50, 1, 'AVAILABLE', NULL, NULL),
(394, 50, 2, 'AVAILABLE', NULL, NULL),
(395, 50, 3, 'AVAILABLE', NULL, NULL),
(396, 50, 4, 'AVAILABLE', NULL, NULL),
(397, 50, 5, 'AVAILABLE', NULL, NULL),
(398, 50, 6, 'AVAILABLE', NULL, NULL),
(399, 50, 7, 'AVAILABLE', NULL, NULL),
(400, 50, 8, 'AVAILABLE', NULL, NULL),
(401, 51, 1, 'AVAILABLE', NULL, NULL),
(402, 51, 2, 'AVAILABLE', NULL, NULL),
(403, 51, 3, 'AVAILABLE', NULL, NULL),
(404, 51, 4, 'AVAILABLE', NULL, NULL),
(405, 51, 5, 'AVAILABLE', NULL, NULL),
(406, 51, 6, 'AVAILABLE', NULL, NULL),
(407, 51, 7, 'AVAILABLE', NULL, NULL),
(408, 51, 8, 'AVAILABLE', NULL, NULL),
(409, 52, 1, 'AVAILABLE', NULL, NULL),
(410, 52, 2, 'AVAILABLE', NULL, NULL),
(411, 52, 3, 'AVAILABLE', NULL, NULL),
(412, 52, 4, 'AVAILABLE', NULL, NULL),
(413, 52, 5, 'AVAILABLE', NULL, NULL),
(414, 52, 6, 'AVAILABLE', NULL, NULL),
(415, 52, 7, 'AVAILABLE', NULL, NULL),
(416, 52, 8, 'AVAILABLE', NULL, NULL),
(417, 53, 1, 'AVAILABLE', NULL, NULL),
(418, 53, 2, 'AVAILABLE', NULL, NULL),
(419, 53, 3, 'AVAILABLE', NULL, NULL),
(420, 53, 4, 'AVAILABLE', NULL, NULL),
(421, 53, 5, 'AVAILABLE', NULL, NULL),
(422, 53, 6, 'AVAILABLE', NULL, NULL),
(423, 53, 7, 'AVAILABLE', NULL, NULL),
(424, 53, 8, 'AVAILABLE', NULL, NULL),
(425, 54, 1, 'AVAILABLE', NULL, NULL),
(426, 54, 2, 'AVAILABLE', NULL, NULL),
(427, 54, 3, 'AVAILABLE', NULL, NULL),
(428, 54, 4, 'AVAILABLE', NULL, NULL),
(429, 54, 5, 'AVAILABLE', NULL, NULL),
(430, 54, 6, 'AVAILABLE', NULL, NULL),
(431, 54, 7, 'AVAILABLE', NULL, NULL),
(432, 54, 8, 'AVAILABLE', NULL, NULL),
(433, 55, 1, 'AVAILABLE', NULL, NULL),
(434, 55, 2, 'AVAILABLE', NULL, NULL),
(435, 55, 3, 'AVAILABLE', NULL, NULL),
(436, 55, 4, 'AVAILABLE', NULL, NULL),
(437, 55, 5, 'AVAILABLE', NULL, NULL),
(438, 55, 6, 'AVAILABLE', NULL, NULL),
(439, 55, 7, 'AVAILABLE', NULL, NULL),
(440, 55, 8, 'AVAILABLE', NULL, NULL),
(441, 56, 1, 'AVAILABLE', NULL, NULL),
(442, 56, 2, 'AVAILABLE', NULL, NULL),
(443, 56, 3, 'AVAILABLE', NULL, NULL),
(444, 56, 4, 'AVAILABLE', NULL, NULL),
(445, 56, 5, 'AVAILABLE', NULL, NULL),
(446, 56, 6, 'AVAILABLE', NULL, NULL),
(447, 56, 7, 'AVAILABLE', NULL, NULL),
(448, 56, 8, 'AVAILABLE', NULL, NULL),
(449, 57, 1, 'AVAILABLE', NULL, NULL),
(450, 57, 2, 'AVAILABLE', NULL, NULL),
(451, 57, 3, 'AVAILABLE', NULL, NULL),
(452, 57, 4, 'AVAILABLE', NULL, NULL),
(453, 57, 5, 'AVAILABLE', NULL, NULL),
(454, 57, 6, 'AVAILABLE', NULL, NULL),
(455, 57, 7, 'AVAILABLE', NULL, NULL),
(456, 57, 8, 'AVAILABLE', NULL, NULL),
(457, 58, 1, 'AVAILABLE', NULL, NULL),
(458, 58, 2, 'AVAILABLE', NULL, NULL),
(459, 58, 3, 'AVAILABLE', NULL, NULL),
(460, 58, 4, 'AVAILABLE', NULL, NULL),
(461, 58, 5, 'AVAILABLE', NULL, NULL),
(462, 58, 6, 'AVAILABLE', NULL, NULL),
(463, 58, 7, 'AVAILABLE', NULL, NULL),
(464, 58, 8, 'AVAILABLE', NULL, NULL),
(465, 59, 1, 'AVAILABLE', NULL, NULL),
(466, 59, 2, 'AVAILABLE', NULL, NULL),
(467, 59, 3, 'AVAILABLE', NULL, NULL),
(468, 59, 4, 'AVAILABLE', NULL, NULL),
(469, 59, 5, 'AVAILABLE', NULL, NULL),
(470, 59, 6, 'AVAILABLE', NULL, NULL),
(471, 59, 7, 'AVAILABLE', NULL, NULL),
(472, 59, 8, 'AVAILABLE', NULL, NULL),
(473, 60, 1, 'AVAILABLE', NULL, NULL),
(474, 60, 2, 'AVAILABLE', NULL, NULL),
(475, 60, 3, 'AVAILABLE', NULL, NULL),
(476, 60, 4, 'AVAILABLE', NULL, NULL),
(477, 60, 5, 'AVAILABLE', NULL, NULL),
(478, 60, 6, 'AVAILABLE', NULL, NULL),
(479, 60, 7, 'AVAILABLE', NULL, NULL),
(480, 60, 8, 'AVAILABLE', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `gamestatus`
--

CREATE TABLE `gamestatus` (
  `gameStatusID` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gamestatus`
--

INSERT INTO `gamestatus` (`gameStatusID`) VALUES
('AVAILABLE'),
('COMPLETE'),
('INPROGRESS'),
('UNASSIGNED');

-- --------------------------------------------------------

--
-- Table structure for table `matchup`
--

CREATE TABLE `matchup` (
  `matchID` int(11) NOT NULL,
  `roundID` varchar(5) DEFAULT NULL,
  `matchgroup` int(11) DEFAULT NULL,
  `teamID` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `ranking` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `matchup`
--

INSERT INTO `matchup` (`matchID`, `roundID`, `matchgroup`, `teamID`, `score`, `ranking`) VALUES
(1, 'QUAL', 1, 1, NULL, NULL),
(2, 'QUAL', 1, 2, NULL, NULL),
(3, 'QUAL', 1, 3, NULL, NULL),
(4, 'QUAL', 1, 4, NULL, NULL),
(5, 'QUAL', 1, 5, NULL, NULL),
(6, 'QUAL', 1, 6, NULL, NULL),
(7, 'QUAL', 1, 7, NULL, NULL),
(8, 'QUAL', 1, 8, NULL, NULL),
(9, 'QUAL', 1, 9, NULL, NULL),
(10, 'QUAL', 1, 10, NULL, NULL),
(11, 'QUAL', 1, 11, NULL, NULL),
(12, 'QUAL', 1, 12, NULL, NULL),
(13, 'QUAL', 1, 13, NULL, NULL),
(14, 'QUAL', 1, 14, NULL, NULL),
(15, 'QUAL', 1, 15, NULL, NULL),
(16, 'QUAL', 1, 16, NULL, NULL),
(17, 'QUAL', 1, 17, NULL, NULL),
(18, 'QUAL', 1, 18, NULL, NULL),
(19, 'QUAL', 1, 19, NULL, NULL),
(20, 'QUAL', 1, 20, NULL, NULL),
(21, 'QUAL', 1, 21, NULL, NULL),
(22, 'QUAL', 1, 22, NULL, NULL),
(23, 'QUAL', 1, 23, NULL, NULL),
(24, 'QUAL', 1, 24, NULL, NULL),
(25, 'QUAL', 1, 25, NULL, NULL),
(26, 'QUAL', 1, 26, NULL, NULL),
(27, 'QUAL', 1, 27, NULL, NULL),
(28, 'QUAL', 1, 28, NULL, NULL),
(29, 'QUAL', 1, 29, NULL, NULL),
(30, 'QUAL', 1, 30, NULL, NULL),
(31, 'QUAL', 1, 31, NULL, NULL),
(32, 'QUAL', 1, 32, NULL, NULL),
(33, 'QUAL', 1, 33, NULL, NULL),
(34, 'QUAL', 1, 34, NULL, NULL),
(35, 'QUAL', 1, 35, NULL, NULL),
(36, 'QUAL', 1, 36, NULL, NULL),
(37, 'QUAL', 1, 37, NULL, NULL),
(38, 'QUAL', 1, 38, NULL, NULL),
(39, 'QUAL', 1, 39, NULL, NULL),
(40, 'QUAL', 1, 40, NULL, NULL),
(41, 'QUAL', 1, 41, NULL, NULL),
(42, 'QUAL', 1, 42, NULL, NULL),
(43, 'QUAL', 1, 43, NULL, NULL),
(44, 'QUAL', 1, 44, NULL, NULL),
(45, 'QUAL', 1, 45, NULL, NULL),
(46, 'QUAL', 1, 46, NULL, NULL),
(47, 'QUAL', 1, 47, NULL, NULL),
(48, 'QUAL', 1, 48, NULL, NULL),
(49, 'QUAL', 1, 49, NULL, NULL),
(50, 'QUAL', 1, 50, NULL, NULL),
(51, 'QUAL', 1, 51, NULL, NULL),
(52, 'QUAL', 1, 52, NULL, NULL),
(53, 'QUAL', 1, 53, NULL, NULL),
(54, 'QUAL', 1, 54, NULL, NULL),
(55, 'QUAL', 1, 55, NULL, NULL),
(56, 'QUAL', 1, 56, NULL, NULL),
(57, 'QUAL', 1, 57, NULL, NULL),
(58, 'QUAL', 1, 58, NULL, NULL),
(59, 'QUAL', 1, 59, NULL, NULL),
(60, 'QUAL', 1, 60, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `player`
--

CREATE TABLE `player` (
  `playerID` int(11) NOT NULL,
  `teamID` int(11) DEFAULT NULL,
  `firstName` varchar(40) DEFAULT NULL,
  `lastName` varchar(40) DEFAULT NULL,
  `hometown` varchar(40) DEFAULT NULL,
  `province` varchar(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `player`
--

INSERT INTO `player` (`playerID`, `teamID`, `firstName`, `lastName`, `hometown`, `province`) VALUES
(1, 60, 'Willia', 'Stroupe', 'Fredericton', 'NB'),
(2, 1, 'Magda', 'Agrawal', 'Saint John', 'NB'),
(3, 1, 'Julius', 'Strawser', 'Fredericton', 'NB'),
(4, 1, 'Tien', 'Rehbein', 'Fredericton', 'NB'),
(5, 2, 'Marjory', 'Bensen', 'Deer Island', 'NB'),
(6, 2, 'Jonnie', 'Finn', 'Fredericton', 'NB'),
(7, 2, 'Matilde', 'Carrales', 'Moncton', 'NB'),
(8, 2, 'Rubin', 'Brott', 'Fredericton', 'NB'),
(9, 3, 'Lillie', 'Gauthier', 'Deer Island', 'NB'),
(10, 3, 'Milo', 'Callen', 'Moncton', 'NB'),
(11, 3, 'Rachael', 'Pickert', 'Fredericton', 'NB'),
(12, 3, 'Dewey', 'Stearn', 'Fredericton', 'NB'),
(13, 4, 'Christa', 'Stolp', 'Moncton', 'NB'),
(14, 4, 'Ruby', 'Gomes', 'Fredericton', 'NB'),
(15, 4, 'Belia', 'Graves', 'Saint John', 'NB'),
(16, 4, 'Cristobal', 'Ashbrook', 'Fredericton', 'NB'),
(17, 5, 'Marlen', 'Kin', 'Fredericton', 'NB'),
(18, 5, 'Kareen', 'Selvey', 'Moncton', 'NB'),
(19, 5, 'Ona', 'Macedo', 'Fredericton', 'NB'),
(20, 5, 'Elodia', 'Gonyea', 'Fredericton', 'NB'),
(21, 6, 'Joane', 'Mckie', 'Saint John', 'NB'),
(22, 6, 'Ken', 'Baehr', 'Fredericton', 'NB'),
(23, 6, 'Julius', 'Capito', 'Saint John', 'NB'),
(24, 6, 'Dirk', 'Toohey', 'Saint John', 'NB'),
(25, 7, 'Barrie', 'Tomilson', 'Fredericton', 'NB'),
(26, 7, 'Shawn', 'McShawn', 'Saint John', 'NB'),
(27, 7, 'Connor', 'Pendleton', 'Deer Island', 'NB'),
(28, 7, 'Omar', 'Mouton', 'Saint John', 'NB'),
(29, 8, 'Yvette', 'Teal', 'Fredericton', 'NB'),
(30, 8, 'Ezequiel', 'Delao', 'Deer Island', 'NB'),
(31, 8, 'Francie', 'Hamlet', 'Saint John', 'NB'),
(32, 8, 'Jacinta', 'Gushiken', 'Fredericton', 'NB'),
(33, 9, 'Cliff', 'Liedtke', 'Saint John', 'NB'),
(34, 9, 'Julene', 'Melgarejo', 'Saint John', 'NB'),
(35, 9, 'Mollie', 'Mcgibbon', 'Deer Island', 'NB'),
(36, 9, 'Gaston', 'Aman', 'Saint John', 'NB'),
(37, 10, 'Enriqueta', 'Coulson', 'Saint John', 'NB'),
(38, 10, 'Emerald', 'Neidert', 'Deer Island', 'NB'),
(39, 10, 'Alethea', 'Flanery', 'Deer Island', 'NB'),
(40, 10, 'Sage', 'Addis', 'Saint John', 'NB'),
(41, 11, 'Matthew', 'Johnson', 'Saint John', 'NB'),
(42, 11, 'Tyler', 'Jacobs', 'Saint John', 'NB'),
(43, 11, 'Angel', 'McCrane', 'Saint John', 'NB'),
(44, 11, 'Ryan', 'Simchison ', 'Saint John', 'NB'),
(45, 12, 'Ned', 'Manders', 'Springhill', 'NS'),
(46, 12, 'Marrisa', 'Powers', 'Amherst', 'NS'),
(47, 12, 'Emily', 'Jane', 'Amherst', 'NS'),
(48, 12, 'Max', 'Power', 'Oxford', 'NS'),
(49, 13, 'Trent', 'Steel', 'Charlottetown', 'PE'),
(50, 13, 'Biff', 'Webster', 'Charlottetown', 'PE'),
(51, 13, 'Shane', 'Solomon', 'Summerside', 'PE'),
(52, 13, 'Sal', 'Ritchie', 'Port Elgin', 'NB'),
(53, 14, 'Jose', 'Montezuma', 'Moncton', 'NB'),
(54, 14, 'Daniel', 'Reggiano', 'Moncton', 'NB'),
(55, 14, 'Carly', 'Valentine', 'Dieppe', 'NB'),
(56, 14, 'Scott', 'Myers', 'Peticodiac', 'NB'),
(57, 15, 'Katelyn', 'Church', 'Saint Andrews', 'NB'),
(58, 15, 'Jeremy', 'Trent', 'Fredicton', 'NB'),
(59, 15, 'Brandon', 'Tompson', 'Fredicton', 'NB'),
(60, 15, 'Michael', 'Pepper', 'Saint Andrews', 'NB'),
(61, 16, 'Trevor', 'Daggel', 'Saint John', 'NB'),
(62, 16, 'Livia', 'Sanders', 'Springhill', 'NS'),
(63, 16, 'Alima', 'Shea', 'Springhill', 'NS'),
(64, 16, 'Owen', 'Gilbert', 'Saint John', 'NB'),
(65, 17, 'Ernie', 'Vaughn', 'Saint John', 'NB'),
(66, 17, 'Rocky', 'O\'Rilly', 'Saint Andrews', 'NB'),
(67, 17, 'Parker', 'McClain', 'Saint Andrews', 'NB'),
(68, 17, 'Bradly', 'Mcgregor', 'Saint John', 'NB'),
(69, 18, 'Fred', 'Jacobson', 'Saint John', 'NB'),
(70, 18, 'Ralph', 'Monro', 'Grand Falls', 'NB'),
(71, 18, 'Wendy', 'Molly', 'Vancouver ', 'BC'),
(72, 18, 'Jessica', 'Crud', 'Victoria', 'BC'),
(73, 19, 'Jack', 'Roberts', 'Moncton', 'NB'),
(74, 19, 'Katie', 'Frank', 'Winnipeg', 'MN'),
(75, 19, 'Tom', 'Turner', 'Brandon', 'MN'),
(76, 19, 'Luke', 'Nukem', 'Winkler', 'MN'),
(77, 20, 'Hue', 'Jackson', 'Kelowna', 'BC'),
(78, 20, 'Patrick', 'Biscuits', 'Richmond', 'BC'),
(79, 20, 'Wayne', 'Yellow', 'Saint John', 'NB'),
(80, 20, 'Jacob', 'Benson', 'Saint John', 'NB'),
(81, 21, 'Ricky ', 'Johnson', 'Styx', 'AB'),
(82, 21, 'Francesco', 'Ferdinand', 'Iron Islands', 'NU'),
(83, 21, 'Alonso', 'Byfield', 'Reach', 'SK'),
(84, 21, 'Quinton', 'Jameson', 'Stormlands', 'BC'),
(85, 22, 'Geroge', 'Vincenzo', 'Dorisville', 'PE'),
(86, 22, 'Jim', 'Green', 'The North', 'NT'),
(87, 22, 'Jeny', 'Wilson', 'Vale', 'AB'),
(88, 22, 'Brent', 'Harrison', 'Dorne', 'NS'),
(89, 23, 'Lily', 'Church', 'Westerlands', 'MB'),
(90, 23, 'Dylan', 'Marchment', 'The Wall', 'YK'),
(91, 23, 'Norville', 'Rogers', 'Essos', 'PE'),
(92, 23, 'Delilah', 'Martin', 'Riverlands', 'QC'),
(93, 24, 'Dan', 'Burgess', 'Crownlands', 'ON'),
(94, 24, 'Henry', 'Folkins', 'Whitewalker', 'NL'),
(95, 24, 'Wilbur', 'Von Sanhyme', 'Little Canada', 'QC'),
(96, 24, 'Jimmy-John', 'Felburg', 'New Delhi', 'NB'),
(97, 25, 'Colby', 'Covington', 'Clovis', 'AB'),
(98, 25, 'Bilbo', 'Baggins', 'The Shire', 'NB'),
(99, 25, 'John', 'Frusciante', 'Smallville', 'YK'),
(100, 25, 'Brandon', 'Boyd', 'Gondor', 'ON'),
(101, 26, 'Wes', 'Tjet', 'Airline', 'SK'),
(102, 26, 'Reginald', 'Fils-Aime', 'Zanarkand', 'BC'),
(103, 26, 'Wolly', 'Chipson', 'Calm Lands', 'MB'),
(104, 26, 'Eric', 'Anada', 'Airport', 'NS'),
(105, 27, 'Shallan', 'Davar', 'Jah Keved', 'SK'),
(106, 27, 'Doug ', 'Bowser', 'Yuge', 'YK'),
(107, 27, 'Bob', 'Ross', 'Pretty Little Trees', 'MB'),
(108, 27, 'Eck', 'Spedia', 'Rhodias', 'ON'),
(109, 28, 'Lawrence', 'Tureaud', 'Luca', 'QC'),
(110, 28, 'Ricky', 'Arsenault', 'Ardan', 'NS'),
(111, 28, 'Tim ', 'Allen', 'Besaid', 'PE'),
(112, 28, 'George', 'Daniel', 'London', 'ON'),
(113, 29, 'Terry', 'Crews', 'Edmonton', 'AB'),
(114, 29, 'Elon', 'Musk', 'Mars', 'ON'),
(115, 29, 'Scarlett', 'Johansson', 'Vormir', 'AB'),
(116, 29, 'Danny', 'Devito', 'Montredelphia', 'AB'),
(117, 30, 'Chris', 'Evans', 'Brooklin', 'ON'),
(118, 30, 'Wesley', 'Snipes', 'Titusville', 'NB'),
(119, 30, 'Charlie ', 'Cox', 'London', 'ON'),
(120, 30, 'Ryan ', 'Reynolds', 'Vancouver', 'BC'),
(121, 31, 'Ricky', 'Dicky', 'Rothesay', 'NB'),
(122, 31, 'Trixie', 'Dixie', 'Quispamsis', 'NB'),
(123, 31, 'Frenando', 'Santos', 'Halifax', 'NS'),
(124, 31, 'Lickidy', 'Splickidy', 'Quispamsis', 'NB'),
(125, 32, 'John', 'Snow', 'Saint John', 'NB'),
(126, 32, 'Mark', 'Marketeer', 'Rothesay', 'NB'),
(127, 32, 'Wendy', 'Mcdonald', 'Halifax,', 'NS'),
(128, 32, 'Joeseph', 'Fresh', 'Rothesay', 'NB'),
(129, 33, 'Win', 'Doe', 'Saint John', 'NB'),
(130, 33, 'Jeff', 'Shar', 'Rothesay', 'NB'),
(131, 33, 'Mort', 'Goldstine', 'Quispamsis', 'NB'),
(132, 33, 'David', 'Matthews', 'Saint John', 'NB'),
(133, 34, 'Rick', 'Girtrude', 'Quispamsis', 'NB'),
(134, 34, 'Frank', 'Sinarrrtra', 'Rothesay', 'NB'),
(135, 34, 'Micky', 'BlueEyes', 'Rothesay', 'NB'),
(136, 34, 'David', 'Spadicus', 'Rothesay', 'NB'),
(137, 35, 'Adam', 'Shandler', 'Saint John', 'NB'),
(138, 35, 'Donald', 'Rump', 'Saint John', 'NB'),
(139, 35, 'Mick', 'Yager', 'Saint John', 'NB'),
(140, 35, 'Don', 'Corleon', 'Saint John', 'NB'),
(141, 36, 'Musk', 'Ratinson', 'Quispamsis', 'NB'),
(142, 36, 'Dirk', 'Diggler', 'Halifax', 'NS'),
(143, 36, 'Marky', 'Mark', 'Halifax', 'NS'),
(144, 36, 'Winnie', 'Dapoo', 'Moncton', 'NB'),
(145, 37, 'Hawk', 'Eyeson', 'Fredericton', 'NB'),
(146, 37, 'Tony', 'Spar', 'Fredericton', 'NB'),
(147, 37, 'Spied', 'erma', 'Fredericton', 'NB'),
(148, 37, 'Theador', 'Ragnarok', 'Fredericton', 'NB'),
(149, 38, 'Martin', 'King', 'Moncton', 'NB'),
(150, 38, 'Jon', 'Ahill', 'Saint John', 'NB'),
(151, 38, 'Tom', 'Cruise', 'Rothesay', 'NB'),
(152, 38, 'James', 'Haterfield', 'Quispamsis', 'NB'),
(153, 39, 'Steve', 'Sharp', 'Saint John', 'NB'),
(154, 39, 'Jameson', 'Irish', 'Saint John', 'NB'),
(155, 39, 'Ronald', 'Reserve', 'Saint John', 'NB'),
(156, 39, 'Ben', 'Stiffler', 'Rothesay', 'NB'),
(157, 40, 'Quentin', 'Tarantillo', 'Rothesay', 'NB'),
(158, 40, 'Frenchie', 'Heins', 'Rothesay', 'NB'),
(159, 40, 'Richard', 'Ross', 'Rothesay', 'NB'),
(160, 40, 'Steve', 'Carello', 'Quispamsis', 'NB'),
(161, 41, 'Bob', 'Dawson', 'Dawson City', 'YT'),
(162, 41, 'Billy', 'Mayes', 'Saint John', 'NB'),
(163, 41, 'Keanu', 'Reeves', 'Fredericton', 'NB'),
(164, 41, 'Matthew', 'Price', 'Englehart', 'ON'),
(165, 42, 'Sebastian', 'Santos', 'Rocki', 'MB'),
(166, 42, 'Caine', 'Broadhurst', 'North Coear', 'AB'),
(167, 42, 'Zarah', 'Christensen', 'Prince Sept', 'BC'),
(168, 42, 'Dean', 'Gross', 'Nabi Lake', 'NU'),
(169, 43, 'Blossom', 'Le', 'Rexdale', 'PE'),
(170, 43, 'Kasim', 'Glass', 'Young', 'NS'),
(171, 43, 'Cory', 'Rich', 'Matador', 'QC'),
(172, 43, 'Aled', 'Clements', 'Dorval', 'NL'),
(173, 44, 'Hallie', 'Villarreal', 'Rogers Pass', 'NT'),
(174, 44, 'Kajus', 'Humphreys', 'Fingal', 'AB'),
(175, 44, 'Dominique', 'Wagstaff', 'Gibsons', 'SK'),
(176, 44, 'Skye', 'Brewer', 'Vanguard', 'ON'),
(177, 45, 'Cory', 'Rich', 'Quinsam', 'ON'),
(178, 45, 'Emiliee', 'Muir', 'Cabri', 'QC'),
(179, 45, 'Diana', 'Reid', 'Trochu', 'NU'),
(180, 45, 'Lochlan', 'Anthony', 'Tuxedo', 'PE'),
(181, 46, 'Jessie', 'Redman', 'Buchans', 'NL'),
(182, 46, 'Bryce', 'Cope', 'Riverhurst', 'QC'),
(183, 46, 'Vienna', 'Orr', 'Como', 'NT'),
(184, 46, 'Emilee', 'Clements', 'Plunkett', 'BC'),
(185, 47, 'Vlad', 'Corbett', 'Leo', 'NB'),
(186, 47, 'Isabella', 'Rose', 'Shoreacres', 'QC'),
(187, 47, 'John', 'Jones', 'Clayoquot', 'PE'),
(188, 47, 'Jac', 'Duffy', 'Altona', 'SK'),
(189, 48, 'Adeel', 'Espinoza', 'Port Perry', 'SK'),
(190, 48, 'Hoorain', 'Bains', 'Doyles', 'QC'),
(191, 48, 'Jacqueline', 'Griffin', 'Altona', 'NU'),
(192, 48, 'Eilish', 'Wilson', 'Maniwaki', 'NL'),
(193, 49, 'Keanue', 'Alcock', 'Dayton', 'SK'),
(194, 49, 'Emyr', 'Ponce', 'Gascons', 'AB'),
(195, 49, 'Usman', 'Moon', 'Carbtree', 'BC'),
(196, 49, 'Corinne', 'Vincent', 'Amesbury', 'PE'),
(197, 50, 'Yasmin', 'Flower', 'Whitehorse', 'NT'),
(198, 50, 'Laura', 'Potts', 'Yellowknife', 'YT'),
(199, 50, 'Sebastien', 'Maillet', 'Fredericton', 'NB'),
(200, 50, 'Hai', 'Vu', 'Saint John', 'NB'),
(201, 51, 'Kurtis', 'Connor', 'Fort Troiski', 'NB'),
(202, 51, 'Mary', 'Marlbro', 'Mou Bay', 'NB'),
(203, 51, 'Lorne', 'Kirkpatrick', 'Port Datbee', 'NB'),
(204, 51, 'Madelyn', 'Morgan', 'Toommansroy', 'NB'),
(205, 52, 'Alex', 'Baldwin', 'Port Bamur', 'NS'),
(206, 52, 'Curwin', 'Frost', 'Mount Kamivesca', 'NS'),
(207, 52, 'Lucy', 'Heartfellia', 'Port Rashun', 'NS'),
(208, 52, 'Ezra', 'King', 'Mount Char', 'NS'),
(209, 53, 'Mike', 'Myers', 'Mount Debier', 'ON'),
(210, 53, 'Jay', 'Massicus', 'Creek', 'ON'),
(211, 53, 'Fred', 'Stone', 'Stonar Bay', 'ON'),
(212, 53, 'Allan', 'Walker', 'Port Westant', 'ON'),
(213, 54, 'Great', 'Flambeanie', 'Belling Creek', 'QC'),
(214, 54, 'Fonce', 'Fortran', 'Pifolkenheads', 'QC'),
(215, 54, 'Leenalee', 'Lee', 'Mount Tann', 'QC'),
(216, 54, 'Kellen', 'Heller', 'Facewest City', 'QC'),
(217, 55, 'Roger', 'Dodger', 'Loxldu Beach', 'SK'),
(218, 55, 'Juvia', 'Rain', 'Grand Hapvan', 'SK'),
(219, 55, 'Carly', 'Rae', 'West Ferkent', 'SK'),
(220, 55, 'Suzy', 'Peirce', 'Saint Saintebramp', 'SK'),
(221, 56, 'Jenna', 'Marbs', 'Nyardbran', 'NU'),
(222, 56, 'Danny', 'Velasquez', 'Fort Liotro', 'NU'),
(223, 56, 'Sara', 'Stephens', 'Moose Derrika', 'NU'),
(224, 56, 'Terry', 'Fox', 'Yatelough', 'NU'),
(225, 57, 'Cindy', 'Day', 'Post Lawynd', 'AB'),
(226, 57, 'Han', 'Fernandez', 'Alaylnorth', 'AB'),
(227, 57, 'Clarke', 'Kent', 'Lonsstone', 'AB'),
(228, 57, 'Sammy', 'Sanders', 'Mount Mor', 'AB'),
(229, 58, 'Mike', 'Mendoza', 'Mount Tertu', 'PE'),
(230, 58, 'Christeen', 'Christensen', 'Dibierlaide Hill', 'PE'),
(231, 58, 'Jack', 'Black', 'Sconecreekmee', 'PE'),
(232, 58, 'Anna', 'Fields', 'Anna Fields', 'PE'),
(233, 59, 'Flynn', 'Ryder', 'Port Matmark', 'MB'),
(234, 59, 'Garry', 'White', 'Mount Mor', 'MB'),
(235, 59, 'David', 'Hansen', 'Bahin', 'MB'),
(236, 59, 'The', 'Hamburgler', 'Wonbairns', 'MB'),
(237, 60, 'Gork', 'Delacruz', 'Gika Bay', 'NL'),
(238, 60, 'Brian', 'Little', 'Wawra', 'NL'),
(239, 60, 'Jason', 'Lamb', 'Qualum Bay', 'NL'),
(240, 60, 'Allison', 'Arrbak', 'Aznepewya', 'NL');

-- --------------------------------------------------------

--
-- Table structure for table `team`
--

CREATE TABLE `team` (
  `teamID` int(11) NOT NULL,
  `teamName` varchar(40) DEFAULT NULL,
  `earnings` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `team`
--

INSERT INTO `team` (`teamID`, `teamName`, `earnings`) VALUES
(1, 'Quick Release', NULL),
(2, 'Bowl Movements', NULL),
(3, 'Glory Bowl', NULL),
(4, 'I Can\'t Believe It\'s Not Gutter', NULL),
(5, 'Livin\' on a Spare', NULL),
(6, 'The Bowling Stones', NULL),
(7, 'Dolls With Balls', NULL),
(8, 'Alley Cats', NULL),
(9, 'Gutter Girls', NULL),
(10, 'Holy Rollers', NULL),
(11, 'The Pin Pals', NULL),
(12, 'The Holy Rollers', NULL),
(13, 'Split Happens', NULL),
(14, 'Obviously Not Golfers', NULL),
(15, 'Bi-polar Rollers', NULL),
(16, 'Split Personalities ', NULL),
(17, 'Freeze Frame', NULL),
(18, 'Buffalos', NULL),
(19, 'Elephants', NULL),
(20, 'Beanzos', NULL),
(21, 'Papa Franku\'s Finsest', NULL),
(22, 'The Golden Company', NULL),
(23, 'The Hodors', NULL),
(24, 'The Unsullied', NULL),
(25, 'The Precious Ones', NULL),
(26, 'The Fight or Flights', NULL),
(27, 'The Knights Radiant', NULL),
(28, 'The Misfits', NULL),
(29, 'The Dream Team', NULL),
(30, 'Team Marvelous', NULL),
(31, 'Tri-County Sweat Twisters', NULL),
(32, 'Lucky Lightning Squares', NULL),
(33, 'The Raw Crabs', NULL),
(34, 'The Sweaty Icebergs', NULL),
(35, 'Infamous Bayside Godzillas', NULL),
(36, 'The Savage Mosquitoes', NULL),
(37, 'The Avengers', NULL),
(38, 'The Prickly Predators', NULL),
(39, 'The Noble Professors', NULL),
(40, 'Gothic Hotshots', NULL),
(41, 'Tan Strike Venison', NULL),
(42, 'Los Lightning Aggies', NULL),
(43, 'Optimistic Yellow Trample', NULL),
(44, 'Flying Twisters', NULL),
(45, 'Vaulting Luck Vigilantes', NULL),
(46, 'Yellow Desert Hurl', NULL),
(47, 'Eastern Jet Hurl', NULL),
(48, 'Steel Ozone Makers', NULL),
(49, 'Whirling Gentlemen', NULL),
(50, 'Prancing Happy Rats', NULL),
(51, 'Obviously Not Golfers', NULL),
(52, 'Long Valley Rats', NULL),
(53, 'The Astro Gang', NULL),
(54, 'Instant Breakfast Butterflies', NULL),
(55, 'Standing Swamp Leprechauns', NULL),
(56, 'Strutting Gargoyles', NULL),
(57, 'Raw Concrete', NULL),
(58, 'Bad Karma Presidents', NULL),
(59, 'Killing Turtles', NULL),
(60, 'Instant Land Clowns', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tournamentround`
--

CREATE TABLE `tournamentround` (
  `roundID` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tournamentround`
--

INSERT INTO `tournamentround` (`roundID`) VALUES
('FINAL'),
('QUAL'),
('RAND1'),
('RAND2'),
('RAND3'),
('RAND4'),
('SEED1'),
('SEED2'),
('SEED3'),
('SEED4');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `game`
--
ALTER TABLE `game`
  ADD PRIMARY KEY (`gameID`),
  ADD KEY `matchID` (`matchID`),
  ADD KEY `gameStatusID` (`gameStatusID`);

--
-- Indexes for table `gamestatus`
--
ALTER TABLE `gamestatus`
  ADD PRIMARY KEY (`gameStatusID`);

--
-- Indexes for table `matchup`
--
ALTER TABLE `matchup`
  ADD PRIMARY KEY (`matchID`),
  ADD KEY `roundID` (`roundID`),
  ADD KEY `teamID` (`teamID`);

--
-- Indexes for table `player`
--
ALTER TABLE `player`
  ADD PRIMARY KEY (`playerID`),
  ADD KEY `teamID` (`teamID`);

--
-- Indexes for table `team`
--
ALTER TABLE `team`
  ADD PRIMARY KEY (`teamID`);

--
-- Indexes for table `tournamentround`
--
ALTER TABLE `tournamentround`
  ADD PRIMARY KEY (`roundID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `game`
--
ALTER TABLE `game`
  MODIFY `gameID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=481;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `game`
--
ALTER TABLE `game`
  ADD CONSTRAINT `game_ibfk_1` FOREIGN KEY (`matchID`) REFERENCES `matchup` (`matchID`),
  ADD CONSTRAINT `game_ibfk_2` FOREIGN KEY (`gameStatusID`) REFERENCES `gamestatus` (`gameStatusID`);

--
-- Constraints for table `matchup`
--
ALTER TABLE `matchup`
  ADD CONSTRAINT `matchup_ibfk_1` FOREIGN KEY (`roundID`) REFERENCES `tournamentround` (`roundID`),
  ADD CONSTRAINT `matchup_ibfk_2` FOREIGN KEY (`teamID`) REFERENCES `team` (`teamID`);

--
-- Constraints for table `player`
--
ALTER TABLE `player`
  ADD CONSTRAINT `player_ibfk_1` FOREIGN KEY (`teamID`) REFERENCES `team` (`teamID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
