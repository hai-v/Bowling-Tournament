let addOrUpdate;

window.onload = function () {
    let tabs = document.querySelectorAll(".tablinks");
    for (let t of tabs) {
        t.addEventListener("click", openTab);
    }
    tabs[0].click();
    
    document.querySelector("#btnAddTeam").addEventListener("click", addTeam);
    document.querySelector("#btnDoneTeam").addEventListener("click", processFormTeam);
    
    document.querySelector("#btnAddPlayer").addEventListener("click", addPlayer);
    document.querySelector("#btnUpdatePlayer").addEventListener("click", updatePlayer);    
    document.querySelector("#btnDonePlayer").addEventListener("click", processFormPlayer);
    document.querySelector("#btnDeletePlayer").addEventListener("click", deletePlayer);

    getAllTeams();
    getAllPlayers();

    document.querySelector("#tableTeam").addEventListener("click", handleRowClick);
    document.querySelector("#tablePlayer").addEventListener("click", handleRowClick);
}

function openTab(e) {
  // Declare all variables
  let i, tabcontent, tablinks;

  // Get all elements with class="tabcontent" and hide them
  tabcontent = document.querySelectorAll(".tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }

  // Get all elements with class="tablinks" and remove the class "active"
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }

  // Show the current tab, and add an "active" class to the button that opened the tab
  document.querySelector("#" + e.target.innerHTML).style.display = "block";
  e.currentTarget.className += " active";
}

function clearSelections() {
    var trs = document.querySelectorAll("tr");
    for (var i = 0; i < trs.length; i++) {
        trs[i].classList.remove("highlighted");
    }
}

function handleRowClick(e) {
    clearSelections();
    e.target.parentElement.classList.add("highlighted");
}

///////////////////////////////////////////////// TEAM

function getAllTeams() {
    let url = "api/getAllTeams.php";
    let xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            let resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
            } else {
                buildTableTeam(resp);
            }
        }
    }
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
}

function buildTableTeam (text) {
    let data = JSON.parse(text);
    let tableTeam = document.querySelector("#tableTeam");
    let html = tableTeam.querySelector("tr").innerHTML;
    for (let i = 0; i < data.length; i++) {
        let temp = data[i];
        html += "<tr>";
        html += "<td>" + temp.teamID + "</td>";
        html += "<td>" + temp.teamName + "</td>";
        html += "<td>" + "$" + ((temp.earnings === null) ? 0 : temp.earnings).toFixed(2) + "</td>";
        html += "</tr>";    
        document.querySelector("#inPlayerTeam").innerHTML += "<option value=" + temp.teamID + ">" + temp.teamName + "</option>";            
    }
    tableTeam.innerHTML = html;
}

function addTeam() {
    document.querySelector("#panelTeam").classList.remove("hidden");
    addOrUpdate = "add";
}

function processFormTeam() {
    let teamID = document.querySelector("#inTeamID").value,
            teamName = document.querySelector("#inTeamName").value;
    let obj = {
        "teamID" : teamID,
        "teamName" : teamName
    };
    let url = (addOrUpdate === "add") ? "api/insertTeam.php" : "api/updateTeam.php";
    let xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            let resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
            } else {
                getAllTeams();
            }
        }
    }
    xmlhttp.open("POST", url, true);
    xmlhttp.send(JSON.stringify(obj));
}

function updateTeam() {
    document.querySelector("#panelTeam").classList.remove("hidden");
    addOrUpdate = "update";
}

//////////////////////////////////END TEAM

//////////////////////////////////PLAYER

function getAllPlayers() {
    let url = "api/getAllPlayers.php";
    let xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            let resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
            } else {
                buildTablePlayer(resp);
            }
        }
    }
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
}

function buildTablePlayer (text) {
    let data = JSON.parse(text);
    let tableTeam = document.querySelector("#tablePlayer");
    let html = tableTeam.querySelector("tr").innerHTML;
    for (let i = 0; i < data.length; i++) {
        let temp = data[i];
        html += "<tr>";
        html += "<td>" + temp.playerID + "</td>";
        html += "<td>" + temp.team.teamName + "</td>";
        html += "<td>" + temp.firstName + "</td>";
        html += "<td>" + temp.lastName + "</td>";
        html += "<td>" + temp.hometown + "</td>";
        html += "<td>" + temp.province + "</td>";
        html += "</tr>";  
    }
    tablePlayer.innerHTML = html;
}

function addPlayer() {
    document.querySelector("#panelPlayer").classList.remove("hidden");
    addOrUpdate = "add";
}

function updatePlayer() {
    document.querySelector("#panelPlayer").classList.remove("hidden");
    addOrUpdate = "update";
    populateUpdatePanelPlayer();
}

function populateUpdatePanelPlayer() {
    let tds = document.querySelector(".highlighted").querySelectorAll("td");
    document.querySelector("#inPlayerID").value = tds[0].innerHTML;
    let options = document.querySelectorAll("inPlayerTeam>option");
    for (let i = 0; i < options.length; i++) {
        options[i].selected = options[i].value === tds[1].innerHTML;
    }
    document.querySelector("#inPlayerFirstName").value = tds[2].innerHTML;
    document.querySelector("#inPlayerLastName").value = tds[3].innerHTML;
    document.querySelector("#inPlayerHometown").value = tds[4].innerHTML;
    document.querySelector("#inPlayerProvince").value = tds[5].innerHTML;    
}

function processFormPlayer() {
    let playerID = document.querySelector("#inPlayerID").value,
            teamID = document.querySelector("#inPlayerTeam").value,
            firstName = document.querySelector("#inPlayerFirstName").value,
            lastName = document.querySelector("#inPlayerLastName").value,
            hometown = document.querySelector("#inPlayerHometown").value,
            province = document.querySelector("#inPlayerProvince").value;
    console.log(teamID);
    let obj = {
        "playerID" : playerID,
        "teamID" : teamID,
        "firstName" : firstName,
        "lastName" : lastName,
        "hometown" : hometown,
        "province" : province
    };
    let url = (addOrUpdate === "add") ? "api/insertPlayer.php" : "api/updatePlayer.php";
    let xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            let resp = xmlhttp.responseText;
            console.log(resp);
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
            } else {
                getAllPlayers();
            }
        }
    }
    xmlhttp.open("POST", url, true);
    xmlhttp.send(JSON.stringify(obj));
}

function deletePlayer() {
    let id = document.querySelector(".highlighted").querySelector("td").innerHTML;
    let url = "api/deletePlayer.php";
    let xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            let resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0 || resp != 1) {
                alert("oh no...");
            } else {
                getAllPlayers();
            }
        }
    };
    xmlhttp.open("POST", url, true);
    xmlhttp.send(id);
}

////////////////////////////////////////////////////END PLAYER