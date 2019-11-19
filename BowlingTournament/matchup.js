window.onload = function () {
    document.querySelector("#GetButton").addEventListener("click", getAllMatches);
}

function getAllMatches() {
    let url = "matchupService/matchups";
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            var resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
                console.log(resp);
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
    let matchTable = document.querySelector("table");
    matchTable.innerHTML = "";
    let html = "<tr class=scoreTableHeader><th>Match ID</th><th>Round ID</th><th>Matchgroup</th><th>Team ID</th><th>Score</th><th>Ranking</th></tr>";
    for (let i = 0; i < data.length; i++) {
        let temp = data[i];
        html += "<tr class=scoreEvent id=" + i + ">";
        html += "<td>" + temp.matchID + "</td>";
        html += "<td>" + temp.roundID + "</td>";
        html += "<td>" + temp.matchGroup + "</td>";
        html += "<td>" + temp.teamID + "</td>";
        html += "<td>" + temp.score + "</td>";
        html += "<td>" + temp.ranking + "</td>";
        html += "<tbody id=gameData" + i + ">";
        html += "</tr>";
        matchTable.innerHTML = html;
        document.querySelector(".scoreEvent").addEventListener("click", displayGame);
    }
}

function displayGame(e) {
    if (e.target.nodeName === "TR" && e.target.className === "scoreEvent") {
        let matchID = e.target.children[0].innerHTML;
        getTeamsForMatch(matchID);
    }//end if
}

function getTeamsForMatch(matchID) {
    let url = "matchupService/matchups/" + matchID;
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            var resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
                console.log(resp);
            } else {
                buildGameTable(resp, matchID);
            }
        }
    };
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
}

function hideRows(matchID) {
}

function buildGameTable(text, matchID) {
    let data = JSON.parse(text);
    hideRows(matchID);
    let gameData = document.querySelector("#gameData" + (matchID - 1));
    html = "<tr class=gameDataHeader><th>Team</th></tr>";
    for (var i = 0; i < data.length; i++) {
        let temp = data[i];
        let balls = "";
        temp.balls === null ? balls = [] : balls = temp.balls.split("");
        console.log(balls);
        html += "<tr>";
        html += "<td>" + temp.gameID + "</td>";
        html += "<td class=teamNameCell>" + temp.team.teamName + "</td>";
        for (var x = 0; x < 10; x++) {
            html += "<td><div class=frames>";
            if (x < 9) {
                html += "<div class=score1><input name=scores" + i + " maxlength=1></input></div>";
                html += "<div class=score2><input name=scores" + i + " maxlength=1></input></div>";
            } else {
                html += "<div class=bonus1><input name=scores" + i + " maxlength=1 class=frame10Input></input></div>";
                html += "<div class=bonus2><input name=scores" + i + " class=bonusscore" + i + " maxlength=1></input></div>";
                html += "<div class=hidden><input name=scores" + i + " class=bonusscore" + i + " maxlength=1></input></div>";

            }
            html += "<div class=totalScore><p name=error" + i + " class=error>test</p></div></td></div>";
            updateScoreInput(x, balls, i);
        }
        html += "<td><button id=updateScore" + i + " class=updateScorebtn name=" + i + ">Update Score</button></td>";
    }
    html += "</tr>";
    html += "</tbody>";
    gameData.innerHTML += html;
    let frame10scores = document.querySelectorAll("[class=frame10Input]");
    for (var i = 0; i < frame10scores.length; i++) {
        frame10scores[i].addEventListener("input", enableFrames);
        document.querySelector("#updateScore" + i).addEventListener("click", inputScore);
    }
    console.log(frame10scores.length);
}

function inputScore(e) {
    let currentTeam = e.target.name;
    let balls = document.querySelectorAll("[name=scores" + currentTeam + "]"); 
    console.log(balls[0].value);
}

function enableFrames(e) {
    e.srcElement.parentElement.nextSibling.nextSibling.classList.add("hidden");
    if (e.data !== null) {
        if (e.data.toUpperCase() === "X") {
            e.srcElement.parentElement.nextSibling.nextSibling.classList.remove("hidden");
            e.srcElement.parentElement.nextSibling.nextSibling.classList.add("bonus2");
        }
    }
}

function updateScoreInput(currentBallIndex, balls, inputs) {
    if (currentBallIndex < balls.length) {
        console.log(currentBallIndex);
        console.log(balls);
    }
}