let matchID;
let rowID;
let rowIndex;

window.onload = function () {
    document.querySelector("#GetButton").addEventListener("click", getAllMatches);
    populateRounds();
    document.querySelector("#rounds").addEventListener("change", getRound);
    getAllMatches();
}

function getAllMatches() {
    rowIndex = 0;
    let url = "matchupService/matchups";
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            var resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
            } else {
                buildMatches(xmlhttp.responseText);
            }
        }
    };
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
}

function buildMatches(text) {
    let data = JSON.parse(text);
    console.log(data.length);
    if (data.length > 0) { //If there are games in the table
        let matchTable = document.querySelector("table");
        matchTable.innerHTML = "";
        let html = "<tr class=scoreTableHeader><th>Match ID</th><th>Round ID</th><th>Matchgroup</th><th>Team ID</th><th>Score</th></tr>";
        for (let i = 0; i < data.length; i++) {
            let temp = data[i];
            html += "<tbody><tr class=scoreEvent id=" + i + ">";
            html += "<td>" + temp.matchID + "</td>";
            html += "<td>" + temp.roundID + "</td>";
            html += "<td>" + temp.matchGroup + "</td>";
            html += "<td>" + temp.teamID + "</td>";
            html += "<td>" + temp.score + "</td>";
            html += "<tbody id=gameData" + i + " name=game>";
            html += "</tr></tbody>";
            matchTable.innerHTML = html;
        }
        let trs = document.querySelectorAll(".scoreEvent");
        for (var i = 0; i < trs.length; i++) {
            trs[i].addEventListener("click", displayGame);
        }
    } else { //If there are no games in the match based on the round return all tables
        alert("No games to score this round. Getting all games.");
        getAllMatches();
    }
}

function displayGame(e) {
    matchID = e.target.parentElement.cells[0].outerText;
    rowID = e.path[1].id;
    getTeamsForMatch(matchID, rowID);
}

function getTeamsForMatch(matchID, rowID) {
    let url = "matchupService/matchups/" + matchID;
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            var resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
            } else {
                buildGameTable(resp, rowID);
            }
        }
    };
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
}

function hideRows(matchID) {
    let trs = document.querySelectorAll("[name=game]");
    for (var i = 0; i < trs.length; i++) {
        if (i === Number(matchID)) {
            document.querySelector("#gameData" + i).classList.remove("hidden");
        } else {
            document.querySelector("#gameData" + i).classList.add("hidden");
        }
    }
}

function buildGameTable(text, matchID) {
    let data = JSON.parse(text);
    if (data.length >= 1) { //If there are teams to score for do the following
        let gameData = document.querySelector("#gameData" + matchID);
        gameData.innerHTML = "";
        html = "<tr id=gameDataHeader name=gameRow class=scoreHeader><th>Game Number</th><th>Game Status</th><th>Team</th>"
                + "<th>Frame 1</th><th>Frame 2</th></th><th>Frame 3</th><th>Frame 4</th>" +
                "<th>Frame 5</th><th>Frame 6</th><th>Frame 7</th><th>Frame 8</th><th>Frame 9</th><th>Frame 10</th><th>Update Score</th></tr>";
        for (var i = 0; i < data.length; i++) {
            document.querySelectorAll("[name=scores" + i + "]");
            let temp = data[i];
            let balls = "";
            temp.balls === null ? balls = [] : balls = temp.balls.split(",");
            let ballIndex = 0;
            html += "<tr id=gameRecord" + matchID + " name=gameRow>";
            html += "<td>" + temp.gameID + "</td>";
            html += "<td>" + temp.gameStatusID + "</td>";
            html += "<td class=teamNameCell>" + temp.team.teamName + "</td>";
            for (var x = 0; x < 10; x++) {
                html += "<td><div class=frames>";
                if (x < 9) {
                    html += "<div class=score1><input name=scores" + rowIndex + " maxlength=1 ";
                    x < balls.length ? html += "value=" + balls[ballIndex] + "></input></div>" : html += "></input></div>";
                    html += "<div class=score2><input name=scores" + rowIndex + " maxlength=1 ";
                    x < balls.length ? html += "value=" + balls[ballIndex + 1] + "></input></div>" : html += "></input></div>";
                } else {
                    html += "<div class=bonus1><input name=scores" + rowIndex + " maxlength=1 class=frame10Input></input></div>";
                    html += "<div class=bonus2><input name=scores" + rowIndex + " class=bonusscore" + i + " id=frame10Input2 maxlength=1></input></div>";
                    html += "<div class=hidden><input name=scores" + rowIndex + " class=bonusscore" + i + " maxlength=1></input></div>";
                }
                html += "<div class=totalScore><p name=error" + rowIndex + " class=error></p></div></td></div>";
                ballIndex += 2;
            }
            html += "<td><button id=updateScore" + i + " class=updateScorebtn name=" + rowIndex + ">Update Score</button></td>";
            rowIndex++;
        }
        html += "</tr>";
        html += "</tbody>";
        gameData.innerHTML = html;
        hideRows(matchID);
        let frame10scores = document.querySelectorAll("[class=frame10Input]");
        let frame10scores2 = document.querySelectorAll("[id=frame10Input2]");
        let btns = document.querySelectorAll(".updateScorebtn");
        for (var i = 0; i < btns.length; i++) {
            btns[i].addEventListener("click", inputScore);
            frame10scores[i].addEventListener("input", enableInputForStrike);
            frame10scores2[i].addEventListener("input", enableInputForSpare);
        }
    }//end if checking if there are teams in a game
    else { //If there are no teams to score display a message and reload matchup table
        alert("All games have been scored for. Getting all matches.");
        getAllMatches();
    }
}

function inputScore(e) {
    console.log(matchID);
    let gameID = e.path[2].cells[0].innerHTML;
    let gameObj = {
        "gameID": gameID,
        "matchID": null,
        "gameNumber": null,
        "gameStatusID": 'INPROGRESS',
        "balls": [],
        "score": [0, 0, 0, 0, 0, 0, 0, 0, 0],
        "team": null
    };
    let valid = validateScore(e.target.name, gameObj);
    if (valid) {
        updateScores(e.target.name, gameObj);
        updateGame(gameObj);
    }
}

function validateScore(currentTeam, gameObj) {
    let balls = document.querySelectorAll("[name=scores" + currentTeam + "]");
    let valid = true;
    let errorIndex = 0;
    for (let i = 0; i <= balls.length - 5; i += 2) {
        let ball1Regex = new RegExp(/^[\Xx,\d,]?$/, 'i');
        let ball2Regex = new RegExp(/^[\/,\d,]?$/, 'i');
        if (!getPreviousInputs(i, balls)) {
            valid = false;
            break;
        } else if (!ball1Regex.test(balls[i].value) || !ball2Regex.test(balls[i + 1].value)) {
            valid = false;
            break;
        } else if (balls[i].value.toUpperCase() === "X" && balls[i + 1].value !== "") {
            valid = false;
            break;
        } else if (balls[i].value === "" && balls[i + 1].value !== "") {
            valid = false;
            break;
        } else if (balls[i].value.toUpperCase() !== "X" && balls[i].value !== "") {
            ball2Regex = RegExp(/^[\/,\d]/, 'i');
            if (!ball2Regex.test(balls[i + 1].value) || Number(balls[i].value) + Number(balls[i + 1].value) >= 10) {
                valid = false;
                break;
            }
        }
        gameObj.balls[i] = balls[i].value;
        gameObj.balls[i + 1] = balls[i + 1].value;
        gameObj.balls[balls.length - 3] = balls[balls.length - 3].value;
        gameObj.balls[balls.length - 2] = balls[balls.length - 2].value;
        gameObj.balls[balls.length - 1] = balls[balls.length - 1].value;
        errorIndex++;
    }//end loop
    valid && balls[balls.length - 3].value.toUpperCase() != "" || balls[balls.length - 2].value != "" ? valid = validateFrame10(balls) : valid;
    if (!valid) {
        alert("Error updating game.");
        !valid ? document.querySelectorAll("[name=error" + currentTeam + "]")[errorIndex].innerHTML = "Invalid Input" : document.querySelectorAll("[name=error" + currentTeam + "]").innerHTML = "";
    }
    return valid;
}

function getPreviousInputs(index, balls) {
    let valid = true;
    if (index >= 2) {
        if (balls[index].value !== "" && balls[index - 2].value === "") {
            valid = false;
        }
    }
    return valid;
}

function validateFrame10(currentTeamsBall) {
    let valid = true;
    let bonusBallRegex = new RegExp(/^[\Xx,\d]/, 'i');
    let bonusBallRegex2 = new RegExp(/^[\/Xx,\d]/, 'i');
    if (!bonusBallRegex.test(currentTeamsBall[currentTeamsBall.length - 3].value) || currentTeamsBall[currentTeamsBall.length - 5].value === "") {
        valid = false;
    }
    if (!bonusBallRegex2.test(currentTeamsBall[currentTeamsBall.length - 2].value)) {
        valid = false;
    }
    if (currentTeamsBall[currentTeamsBall.length - 3].value.toUpperCase() === "X")
    {
        if (!bonusBallRegex.test(currentTeamsBall[currentTeamsBall.length - 2].value) || !bonusBallRegex2.test(currentTeamsBall[currentTeamsBall.length - 1].value)
                || Number(currentTeamsBall[currentTeamsBall.length - 2].value) + Number(currentTeamsBall[currentTeamsBall.length - 1].value) >= 10) {
            valid = false;
        }
        if (currentTeamsBall[currentTeamsBall.length - 2].value.toUpperCase() === "X" && !bonusBallRegex.test(currentTeamsBall[currentTeamsBall.length - 1].value)) {
            valid = false;
        }
    }
    if (Number(currentTeamsBall[currentTeamsBall.length - 3].value) + Number(currentTeamsBall[currentTeamsBall.length - 2].value) >= 10) {
        valid = false;
    }
    if (currentTeamsBall[currentTeamsBall.length - 2].value === "/" && !bonusBallRegex.test(currentTeamsBall[currentTeamsBall.length - 1].value)) {
        valid = false;
    }
    return valid;
}

function updateScores(currentTeam, teamScore) {
    let balls = document.querySelectorAll("[name=scores" + currentTeam + "]");
    let scoreIndex = 0;
    balls[balls.length - 3].value !== "" ? teamScore.gameStatusID = "COMPLETE" : teamScore.gameStatusID = "INPROGRESS";
    for (var i = 0; i < balls.length / 2 - 1; i++) {
        if (i > 0) {
            teamScore.score[i] = teamScore.score[i - 1];
        }
        balls[scoreIndex].value.toUpperCase() === "X" ? teamScore.score[i] += Number(doStrike(balls, scoreIndex)) : teamScore.score[i] += 0;
        balls[scoreIndex + 1].value === "/" ? teamScore.score[i] += doSpare(balls, scoreIndex) : teamScore.score[i] += 0;
        balls[scoreIndex].value.toUpperCase() !== "X" && balls[scoreIndex + 1].value !== "/" ? teamScore.score[i] += Number(balls[scoreIndex].value) + Number(balls[scoreIndex + 1].value) : teamScore.score[i] += 0;
        scoreIndex += 2;
    }
}

function doStrike(scoreArray, index) {
    res = 10; //Add 10 the total frames score
    if (index < scoreArray.length - 3) { //If you are NOT on the bonus frame do the following:
        if (scoreArray[index + 2].value.toUpperCase() === "X") { //If the next ball is a strike add 10 to the total
            res += 10;
        } else { //Otherwise and the next two balls 
            scoreArray[index + 3].value === "/" ? res += 10 : res += Number(scoreArray[index + 2].value) + Number(scoreArray[index + 3].value);
            return res;
        }
        if (scoreArray[index + 4].value.toUpperCase() === "X") { //If the next ball is a strike add 10
            res += 10;
        } else { //Otherwise add the number to the total
            if (index < scoreArray.length - 5)
                res += Number(scoreArray[index + 4].value);
            else {
                scoreArray[index + 3].value.toUpperCase() === "X" ? res += 10 : res += Number(scoreArray[index + 3].value);
            }
        }
    }//end validation for checking if you are on the bonus frame
    else {
        if (scoreArray[index + 1].value.toUpperCase() === "X") {
            res += 10;
            if (scoreArray[index + 2].value.toUpperCase() === "X")
                res += 10;
            else
                res += Number(scoreArray[index + 2].value);
        } else {
            scoreArray[index + 2].value === "/" ? res += 10 : res += Number(scoreArray[index + 1].value) + Number(scoreArray[index + 2].value);
        }
    }
    return res;
}

function doSpare(scoreArray, index) {
    res = 10;
    scoreArray[index + 2].value.toUpperCase() === "X" ? res += 10 : res += Number(scoreArray[index + 2].value);
    return res;
}

function enableInputForStrike(e) {
    e.srcElement.parentElement.nextSibling.nextSibling.classList.add("hidden");
    let nextBall = e.srcElement.parentElement.nextSibling.lastChild.value;
    if (e.data !== null && nextBall !== null && e.data.toUpperCase() === "X" || nextBall === "/") {
        e.srcElement.parentElement.nextSibling.nextSibling.classList.remove("hidden");
        e.srcElement.parentElement.nextSibling.nextSibling.classList.add("bonus2");
        e.srcElement.parentElement.nextSibling.nextSibling.lastElementChild.value = "";
    }
}
function enableInputForSpare(e) {
    e.srcElement.parentElement.nextSibling.classList.add("hidden");
    let previousBall = e.srcElement.parentElement.previousElementSibling.firstChild.value;
    if (e.data !== null && previousBall !== null && e.data === "/" || previousBall.toUpperCase() === "X") {
        e.srcElement.parentElement.nextSibling.classList.remove("hidden");
        e.srcElement.parentElement.nextSibling.classList.add("bonus2");
        e.srcElement.parentElement.nextSibling.lastElementChild.value = "";
    }
}

function updateGame(gameObj) {
    var url = "gameService/games/" + gameObj.gameID;
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            var resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0 || resp != 1) {
                alert("Game ID: " + gameObj.gameID + " was not successsfully added/updated.");
            } else {
                alert("Game ID: " + gameObj.gameID + " was successsfully added/updated.");
                getAllMatches();
            }
        }
    };
    xmlhttp.open("PUT", url, true);
    xmlhttp.send(JSON.stringify(gameObj));
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

function buildRoundOptions(text) {
    let data = JSON.parse(text);
    let rounds = document.querySelector("#rounds");
    let html = "";
    for (let i = 0; i < data.length; i++) {
        html += "<option>";
        html += data[i].roundID;
        html += "</option>";
    }
    rounds.innerHTML += html;
}

function getRound(e) {
    let roundID = e.srcElement.value;
    getMatchesByRound(roundID);
}

function getMatchesByRound(roundID) {
    rowIndex = 0;
    let url = "matchupService/matchups/" + roundID;
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            var resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
            } else {
                buildMatches(resp);
            }
        }
    };
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
}