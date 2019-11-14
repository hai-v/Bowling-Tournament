window.onload = function () {
    document.querySelector("#GetButton").addEventListener("click", getAllGames);
    populateRounds();
};
function getAllGames() {
    var url = "gameService/games";
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
    let html = "<tr><th>Game</th><th>Match</th><th>Game Number</th><th>Status</th><th>Score</th></tr>";
    for (let i = 0; i < data.length; i++) {
        let temp = data[i];
        html += "<tr class=scoreEvent>";
        html += "<td>" + temp.gameID + "</td>";
        html += "<td>" + temp.matchID + "</td>";
        html += "<td>" + temp.gameNumber + "</td>";
        html += "<td>" + temp.gameStatusID + "</td>";
        html += "<td>" + temp.score + "</td>";
        html += "</td>";
        html += getTeamsScore(i, temp.gameID);
        html += "</tr>";
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
        document.querySelector("#bonusBall" + i).addEventListener("input", enableBonusFrame);
    }
}

function enableBonusFrame(e) {
    console.log(e.data);
    console.log(e.target);
}

function getTeamsScore(index, gameID) {
    let numScores = 11;
    let numTeams = 2;
    let res = "";
    res += "<tr id=gameData" + index + " class=hidden name=gameRow><th>Team</th><th colspan=12>Scores for Game: " + gameID + "</th></tr>";
    res += "<tr id=gameData" + index + " class=hidden name=gameRow></tr>";
    res += "<tr id=gameData" + index + " class=hidden name=gameRow><th></th>";
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
                res += "<td>Ball 1: <input name=scores" + index + " maxlength=1 disabled></input></br>Ball 2: <input name=scores" + index +  " maxlength=1 disabled></input></td>";
            }
            else if(x == numScores - 2) {
                 res += "<td>Ball 1: <input name=scores" + index + " id=bonusBall" + index + " maxlength=1></input></br>Ball 2: <input name=scores" + index +  " id=bonusBall" + index +  " maxlength=1></input></td>";
            }
            else {
                res += "<td>Ball 1: <input name=scores" + index + " maxlength=1></input><br>Ball 2: <input name=scores" + index + " maxlength=1></input></td>";
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
    let scores = document.querySelectorAll("[name=scores" + id + "]");
    let team1Scores = [];
    let team1Score = {score: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]};
    let team2Score = {score: 0};
    let team2Array = [];
    for (var i = 0; i < scores.length / 2; i++) {
        team1Scores.push(scores[i].value);
    }
    for (var i = scores.length / 2; i < scores.length; i++) {
        team2Array.push(scores[i].value);
    }
    console.log(validateScore(team1Scores, scores, id));
    updateScores(team1Scores, team1Score);
    console.log(team1Score.score);
}

function validateScore(scoreArray, scores, id) {
    let valid = true;
    let ball1Regex = new RegExp(/^[\Xx,\d,]?$/, 'i');
    let ball2Regex = new RegExp(/^[\/,\d,]?$/, 'i');
    for (var i = 0; i < scoreArray.length; i += 2) {
        if (i < scoreArray.length - 2) { //If you are NOT on the bonus round
            if (!isPreviousInputValid(scoreArray, i)) {
                valid = false;
                break;
            } else if (!ball1Regex.test(scoreArray[i]) || !ball2Regex.test(scoreArray[i + 1])) { //If the input doesn't match the regex return a false
                valid = false;
                break;
            } else if (scoreArray[i].toUpperCase() === "X") { //If the first ball is a strike
                if (scoreArray[i + 1] !== "") { //And the next ball in the frame has a value, and the next ball in the frame is empty return false
                    valid = false;
                    break;
                }
            } else if (scoreArray[i] !== "X" && scoreArray[i] !== "" || scoreArray[i + 1] !== "") { //If the current ball is not a strike and the first ball has a value ball 2 must also have a value
                if (Number(scoreArray[i]) + Number(scoreArray[i + 1]) >= 10 || scoreArray[i + 1] === "" || scoreArray[i] === "") { //return a false if not the case
                    valid = false;
                    break;
                }
            }
        }
    }//end loop
    if ((scores[scoreArray.length - 4].value).toUpperCase() === "X" || scores[scoreArray.length - 3].value === "/") {
        alert("Bonus Round for Team: team is enabled");
        if ((scores[scoreArray.length - 4].value).toUpperCase() === "X") {
            scores[scoreArray.length - 2].disabled = !valid;
            scores[scoreArray.length - 1].disabled = !valid;
        } 
        else {
            scores[scoreArray.length - 2].disabled = !valid;
            scores[scoreArray.length - 1].disabled = valid;
        }
    } else {
        scores[scoreArray.length - 2].value = "";
        scores[scoreArray.length - 1].value = "";
        scores[scoreArray.length - 2].disabled = valid;
        scores[scoreArray.length - 1].disabled = valid;
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

function hideScoreRows() {
    let trs = document.querySelectorAll("[name=gameRow]");
    for (var i = 0; i < trs.length; i++) {
        if (!trs[i].classList.contains("hidden")) {
            trs[i].classList.add("hidden");
        }
    }
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
    let ids = e.target.parentElement.nextSibling.id;
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


