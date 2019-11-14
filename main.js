let addOrUpdate;

window.onload = function () {
    let tabs = document.querySelectorAll(".tablinks");
    for (let t of tabs) {
        t.addEventListener("click", openTab);
    }
    tabs[0].click();
    
    document.querySelector("#btnAddTeam").addEventListener("click", addTeam);
    document.querySelector("#btnDoneTeam").addEventListener("click", processFormTeam);
    
    getAllTeams();
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

function getAllTeams() {
    let url = "api/getAllTeams.php";
    let xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            let resp = xmlhttp.responseText;
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
                console.log(resp);
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
            console.log(resp);
            if (resp.search("ERROR") >= 0) {
                alert("oh no... see console for error");
                console.log(resp);
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