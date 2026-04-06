<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Terminal</title>
    <script>
        let socket = null;
        let connectionInfo = '';

        function connect() {
            const username = document.getElementById("username").value;
            const password = document.getElementById("password").value;
            const host = document.getElementById("host").value;
            const port = parseInt(document.getElementById("port").value, 10);
            const rootPassword = document.getElementById("rootPassword").value;

            console.log("Username:", username);
            console.log("Password:", password);
            console.log("Host:", host);
            console.log("Port:", port);
            console.log("Root Password:", rootPassword);

            //connectionInfo = `${username} ${password} ${host} ${port} ${rootPassword}`;
            connectionInfo = username + " " + password + " " + host + " " + port + " " + rootPassword;

            console.log("Connection Info:", connectionInfo);

            socket = new WebSocket('ws://' + window.location.host + '/terminal');

            socket.onmessage = function(event) {
                document.getElementById("output").innerText += event.data + "\n";
            };

            socket.onopen = function() {
                console.log("WebSocket connection established.");
                socket.send(`CONNECT ${connectionInfo}`);
                document.getElementById("output").innerText += "WebSocket connection established.\n";
            };

            socket.onclose = function() {
                document.getElementById("output").innerText += "Disconnected from terminal.\n";
            };

            socket.onerror = function(error) {
                console.log("WebSocket error:", error);
            };
        }

        function executeCommand() {
            const command = document.getElementById("command").value;
            if (socket && socket.readyState === WebSocket.OPEN) {
                socket.send(command);
            } else {
                document.getElementById("output").innerText += "WebSocket is not connected.\n";
            }
        }
    </script>
</head>
<body>
<h1>Terminal</h1>
<div>
    <input type="text" id="username" value="root" placeholder="Enter username" />
    <input type="password" id="password" value="dlm1234" placeholder="Enter password" />
    <input type="text" id="host" value="192.168.0.33" placeholder="Enter host" />
    <input type="number" id="port" value="22" placeholder="Enter port" />
    <input type="password" id="rootPassword" value="dlm1234" placeholder="Enter root password" />
    <button id="connectBtn" onclick="connect()">Connect</button>
</div>
<div>
    <input type="text" id="command" placeholder="Enter command" />
    <button id="executeBtn" onclick="executeCommand()">Execute</button>
</div>
<pre id="output"></pre>
</body>
</html>
