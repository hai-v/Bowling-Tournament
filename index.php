<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title></title>
        <script src="main.js"></script>
        <link rel="stylesheet" type="text/css" href="main.css">
    </head>
    <body>
        <h1>Admin</h1>
        <!-- Tab links -->
        <div class="tab">
            <button class="tablinks">Teams</button>
            <button class="tablinks">Players</button>
            <button class="tablinks">Matches</button>
            <button class="tablinks">Payouts</button>
        </div>

        <div id="Teams" class="tabcontent">
            <h3>Teams</h3>
            <div>
                <button id="btnAddTeam">Add Team</button>
                <div id="panelTeam" class="hidden">
                    <div>Team ID</div><input type="number" id="inTeamID">
                    <div>Team Name</div><input type="text" id="inTeamName">
                    <button id="btnDoneTeam">Done</button>
                </div>
            </div>
            <table id="tableTeam">
                <tr>
                    <th>Team ID</th>
                    <th>Team Name</th>
                    <th>Earnings</th>
                </tr>
            </table>
        </div>

        <div id="Players" class="tabcontent">
            <h3>Players</h3>
            <div></div>
        </div>

        <div id="Matches" class="tabcontent">
            <h3>Matches</h3>
            <div></div>
        </div>
        
        <div id="Payouts" class="tabcontent">
            <h3>Prize payouts</h3>
            <div></div>
        </div>
    </body>
</html>
