window.onload = function () {
    document.querySelector("#GetButton").addEventListener("click", getAllGames);
    populateRounds();
};
function getAllGames() {
    let url = "gameService/games";
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            var resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
                console.log(resp);
            } else {
                buildTable(xmlhttp.responseText);
            }
        }
    };
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
}

function buildTable(text) {
    let data = JSON.parse(text);
    let scoreTable = document.querySelector("table");
    scoreTable.innerHTML = "";
    let html = "<tr class=scoreTableHeader><th>Game</th><th>Match</th><th>Game Number</th><th>Status</th><th>Score</th></tr>";
    for (let i = 0; i < data.length; i++) {
        let temp = data[i];
        html += "<tbody><tr class=scoreEvent>";
        html += "<td>" + temp.gameID + "</td>";
        html += "<td>" + temp.matchID + "</td>";
        html += "<td>" + temp.gameNumber + "</td>";
        html += "<td>" + temp.gameStatusID + "</td>";
        html += "<td>" + temp.score + "</td>";
        html += "</td>";
        html += getTeamsScore(i, temp.gameID);
        html += "</tr></tbody>";
    }
    scoreTable.innerHTML += html;
    let trs = document.querySelectorAll(".scoreEvent");
    for (let i = 0; i < trs.length; i++) {
        trs[i].addEventListener("click", displayGame);
    }

    let buttons = document.querySelectorAll("#cancelScore");
    for (let i = 0; i < buttons.length; i++) {
        document.querySelector("#updateScore" + i).addEventListener("click", inputScore);
        document.querySelectorAll("#cancelScore")[i].addEventListener("click", hideScoreRows);
        document.querySelectorAll("#ball1Input")[i].addEventListener("input", enableBonusFrameForStrikes);
        document.querySelectorAll("#ball2Input")[i].addEventListener("input", enableBonusFrameForSpares);
    }
}

function enableBonusFrameForStrikes(e) {
    let id = e.target.className;
    let input = e.data;
    let scores = document.querySelectorAll("[name=scores" + id + "]");
    let currentTeam = e.srcElement.parentElement.parentElement.parentElement.id;
    disableOrEnableBonusFrameInputs(input, scores, currentTeam);
    input !== null ? disableOrEnableBonusFrameInputs(input, scores, currentTeam) : disableOrEnableBonusFrameInputs(input, scores, currentTeam);
}

function disableOrEnableBonusFrameInputs(input, scores, currentTeam) {
    let index = "";
    input === null ? input = "" : input = input;
    currentTeam == "0" ? index = scores.length / 2 : index = scores.length;
    scores[index - 1].disabled = true;
    scores[index - 2].disabled = true;
    scores[index - 1].value = "";
    scores[index - 2].value = "";
    if (input.toUpperCase() === "X" || scores[index - 4].value.toUpperCase() === "X") {
        scores[index - 1].disabled = false;
        scores[index - 2].disabled = false;
    } else if (input === "/" || scores[index - 3].value === "/") {
        scores[index - 2].disabled = false;
        scores[index - 1].disabled = true;
    }
}

function enableBonusFrameForSpares(e) {
    let id = e.target.className;
    let input = e.data;
    let scores = document.querySelectorAll("[name=scores" + id + "]");
    let currentTeam = e.srcElement.parentElement.parentElement.parentElement.id;
    disableOrEnableBonusFrameInputs(input, scores, currentTeam);
    input !== null ? disableOrEnableBonusFrameInputs(input, scores, currentTeam) : disableOrEnableBonusFrameInputs(input, scores, currentTeam);
}

function getTeamsScore(index, gameID) {
    let numScores = 11;
    let numTeams = 2;
    let res = "";
    res += "<tr id=gameData" + index + " class=hidden name=gameRow><th colspan=12>Scores for Game: " + gameID + "</th></tr>";
    res += "<tr id=gameData" + index + " class=hidden name=gameRow></tr>";
    res += "<tr id=gameData" + index + " class=hidden name=gameRow><th>Team</th>";
    for (let i = 0; i < numScores; i++) {
        if (i == numScores - 1) {
            res += "<th> Bonus </th>";
        } else {
            res += "<th> Frame " + (i + 1) + "</th>";
        }
    }
    res += "<th></th></tr>";
    for (let i = 0; i < numTeams; i++) {
        res += "<tr id=gameData" + index + " class=hidden name=gameRow><td>TEST</td>";
        for (let x = 0; x < numScores; x++) {
            if (x == numScores - 1) {
                res += "<td><div class=frames><div class=score1><input name=scores" + index + " maxlength=1 disabled></input></div><div class=score2><input name=scores" + index + " class=ball2scores maxlength=1 disabled></input></div><div class=totalScore><p name=error" + index + " class=error></p></div></td></div>";
            } else if (x == numScores - 2) {
                res += "<td id=" + i + "><div class=frames><div class=score1><input name=scores" + index + " id=ball1Input class=" + index + " maxlength=1></input></div><div class=score2><input name=scores" + index + " id=ball2Input class=" + index + " ball2scores maxlength=1></input></div><div class=totalScore><p class=error" + index + "></p></div></td></div>";
            } else {
                res += "<td><div class=frames><div class=score1><input name=scores" + index + " maxlength=1></input></div><div class=score2><input name=scores" + index + " class=ball2scores maxlength=1></input></div><div class=totalScore><p name=error" + index + " class=error></p></div></td></div>";
            }
        }
        if (i == 0) {
            res += "</td><td rowSpan=2>\n\
                        <button id=updateScore" + index + " class=" + index + ">Update</button><br><br><button id=cancelScore>Cancel</button></td>";
        }
        res += "</tr>";
    }
    return res;
}

function inputScore(e) {
    let id = e.target.className;
    let gameID = e.path[3].childNodes[0].childNodes[0].innerHTML;
    let matchID = e.path[3].childNodes[0].childNodes[1].innerHTML;
    let gameNumber = e.path[3].childNodes[0].childNodes[2].innerHTML;
    let gameStatusID = e.path[3].childNodes[0].childNodes[3].innerHTML;
    getTeams(gameID);
    let scores = document.querySelectorAll("[name=scores" + id + "]");
    let team1ScoresInputs = [];
    let team2ScoresInputs = [];
    let team1Obj = {
        gameID: gameID,
        matchID: matchID,
        gameNumber: gameNumber,
        gameStatusID: gameStatusID,
        score: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        balls: []
    };
    let team2Score = {score: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]};
    for (var i = 0; i < scores.length / 2; i++) {
        team1ScoresInputs.push(scores[i].value);
        team1Obj.balls.push(scores[i].value);
    }
    console.log(team1Obj);
    for (var i = scores.length / 2; i < scores.length; i++) {
        team2ScoresInputs.push(scores[i].value);
    }
    console.log(team2ScoresInputs);
    console.log(document.querySelectorAll("[name=error" + id + "]")[0].innerHTML);
    console.log(validateScore(team1ScoresInputs, id, scores));
    updateScores(team1ScoresInputs, team1Obj);
    console.log(team1Obj.score);
}

function getTeams(gameID) {
    let gameObj = {
        gameID: gameID
    };
      let url = "gameService/games/" + gameID;
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            var resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
                console.log(resp);
            } else {
                console.log(xmlhttp.responseText);
            }
        }
    };
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
}

function validateScore(scoreArray, id, scores) {
    let valid = true;
    let errorIndex = 0;
    let errorMessage = "";
    let ball1Regex = new RegExp(/^[\Xx,\d,]?$/, 'i');
    let ball2Regex = new RegExp(/^[\/,\d,]?$/, 'i');
    for (var i = 0; i < scoreArray.length; i += 2) {
        document.querySelectorAll("[name=error" + id + "]")[errorIndex].innerHTML = "";
        if (i < scoreArray.length - 2) { //If you are NOT on the bonus round
            if (!isPreviousInputValid(scoreArray, i)) {
                valid = false;
                errorMessage = "Previous Frame must be scored.";
                break;
            } else if (!ball1Regex.test(scoreArray[i]) || !ball2Regex.test(scoreArray[i + 1])) { //If the input doesn't match the regex return a false
                valid = false;
                errorMessage = "Invalid input for balls.";
                break;
            } else if (scoreArray[i].toUpperCase() === "X") { //If the first ball is a strike
                if (scoreArray[i + 1] !== "") { //And the next ball in the frame has a value, and the next ball in the frame is empty return false
                    valid = false;
                    errorMessage = "For a strike, the second ball in the frame must be empty.";
                    break;
                }
            } else if (scoreArray[i] !== "X" && scoreArray[i] !== "" || scoreArray[i + 1] !== "") { //If the current ball is not a strike and the first ball has a value ball 2 must also have a value
                if (Number(scoreArray[i]) + Number(scoreArray[i + 1]) >= 10 || scoreArray[i + 1] === "" || scoreArray[i] === "") { //return a false if not the case
                    valid = false;
                    errorMessage = "Total Score must be less than or equal to 9. If the Frame is a spare write a '/' for the second ball."
                    break;
                }
            } 
        }
        errorIndex++;
    }//end loop
    valid ? valid = validateBonus(scoreArray, id, scores) : !valid;
    console.log(valid);
    !valid ? document.querySelectorAll("[name=error" + id + "]")[errorIndex].innerHTML = errorMessage : document.querySelectorAll("[name=error" + id + "]").innerHTML = "";
    return valid;
}

function validateBonus(scoreArray, id, scores) {
    valid = true;
    console.log(scores);
    if (scores[scoreArray.length - 2].disabled == false) {
        let ball1Regex = new RegExp(/^[\Xx,\d]/, 'i');
        valid = ball1Regex.test(scoreArray[scoreArray.length - 2]);
    }
    if (scores[scoreArray.length - 1].disabled == false && valid) {
        let ball2Regex = new RegExp(/^[\/,\d,Xx]/, 'i');
        valid = ball2Regex.test(scoreArray[scoreArray.length - 1]);
        if (valid && scoreArray[scoreArray.length - 2].toUpperCase() !== "X") {
            if (Number(scoreArray[scoreArray.length - 1]) + Number(scoreArray[scoreArray.length - 2]) >= 10) {
                valid = false;
            }
        } else {
            if (scoreArray[scoreArray.length - 1] === "/" && valid) {
                valid = false;
            }
        }
    }
    return valid;
}

function isPreviousInputValid(scoreArray, index) {
    let valid = true;
    if (index >= 2) {
        if (scoreArray[index] != "") {
            if (scoreArray[index - 2] === "") {
                valid = false;
            }
        }
    }
    return valid;
}

function updateScores(scoreArray, teamScore) {
    scoreIndex = 0;
    for (var i = 0; i < scoreArray.length / 2 - 1; i++) {
        if (i > 0) {
            teamScore.score[i] = teamScore.score[i - 1];
        }
        scoreArray[scoreIndex].toUpperCase() === "X" ? teamScore.score[i] += Number(doStrike(scoreArray, scoreIndex)) : teamScore.score[i] += 0;
        scoreArray[scoreIndex + 1] === "/" ? teamScore.score[i] += doSpare(scoreArray, scoreIndex) : teamScore.score[i] += 0;
        scoreArray[scoreIndex].toUpperCase() !== "X" && scoreArray[scoreIndex + 1] !== "/" ? teamScore.score[i] += Number(scoreArray[scoreIndex]) + Number(scoreArray[scoreIndex + 1]) : teamScore.score[i] += 0;
        scoreIndex += 2;
    }
}

function doStrike(scoreArray, index) {
    res = 10; //Add 10 the total frames score
    if (index < scoreArray.length - 3) { //If you are NOT on the bonus frame do the following:
        if (scoreArray[index + 2].toUpperCase() === "X") { //If the next ball is a strike add 10 to the total
            res += 10;
        } else { //Otherwise and the next two balls 
            scoreArray[index + 3] === "/" ? res += 10 : res += Number(scoreArray[index + 2]) + Number(scoreArray[index + 3]);
            return res;
        }
        if (index < scoreArray.length - 4) { //If you are on the 10th Frame
            if (scoreArray[index + 4].toUpperCase() === "X") { //If the next ball is a strike add 10
                res += 10;
            } else { //Otherwise add the number to the total
                res += Number(scoreArray[index + 4]);
            }
        } else { //If the 10th Frame is a strike add the next ball is a strike add the next input to the scores array
            scoreArray[index + 3].toUpperCase() === "X" || scoreArray[index + 3].toUpperCase() === "/" ? res += 10 : res += Number(scoreArray[index + 3]);
        }
    }//end validation for checking if you are on the bonus frame
    return res;
}

function doSpare(scoreArray, index) {
    res = 10;
    scoreArray[index + 2].toUpperCase() === "X" ? res += 10 : res += Number(scoreArray[index + 2]);
    return res;
}

function populateRounds() {
    var url = "tournamentService/tournaments";
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            var resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
            } else {
                buildRoundOptions(xmlhttp.responseText);
            }
        }
    };
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
}

function displayGame(e) {
    hideScoreRows();
    let ids = "";
    if (e.target.parentElement.nextSibling === null) {
        ids = e.target.parentElement.lastChild.id;
    } else {
        e.target.parentElement.nextSibling.id != "" || e.target.parentElement.nextSibling.id != "" ? ids = e.target.parentElement.nextSibling.id : ids = e.target.parentElement.lastChild.id;
    }
    console.log(ids);
    let idArray = document.querySelectorAll("#" + ids);
    for (let i = 0; i < idArray.length; i++) {
        if (idArray[i].classList.contains("hidden")) {
            idArray[i].classList.remove("hidden");
        } else {
            idArray[i].classList.add("hidden");
        }
    }
}

function buildRoundOptions(text) {
    let data = JSON.parse(text);
    let rounds = document.querySelector("#rounds");
    let html = "";
    for (let i = 0; i < data.length; i++) {
        html += "<option>";
        let temp = data[i].roundID.toLowerCase();
        html += temp[0].toUpperCase() + data[i].roundID.substring(1).toLowerCase();
        html += "</option>";
    }
    rounds.innerHTML += html;
}


