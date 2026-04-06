package datablocks.dlm.handler;

import com.jcraft.jsch.*;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

public class TerminalWebSocketHandler extends TextWebSocketHandler {
    private ConcurrentMap<WebSocketSession, Session> sshSessions = new ConcurrentHashMap<>();

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        if (payload.startsWith("CONNECT ")) {
            String[] parts = payload.split(" ", 6);
            if (parts.length < 6) {
                session.sendMessage(new TextMessage("Error: Invalid connection info. Expected format: username password host port rootPassword"));
                return;
            }
            String username = parts[1];
            String password = parts[2];
            String host = parts[3];
            int port;
            try {
                port = Integer.parseInt(parts[4]);
            } catch (NumberFormatException e) {
                session.sendMessage(new TextMessage("Error: Invalid port number. " + parts[4]));
                return;
            }
            String rootPassword = parts[5];

            JSch jsch = new JSch();
            Session sshSession = jsch.getSession(username, host, port);
            sshSession.setPassword(password);
            sshSession.setConfig("StrictHostKeyChecking", "no");

            try {
                sshSession.connect();
                sshSessions.put(session, sshSession);
                session.sendMessage(new TextMessage("Connected to SSH server."));
            } catch (Exception e) {
                session.sendMessage(new TextMessage("Error: " + e.getMessage()));
            }
        } else {
            Session sshSession = sshSessions.get(session);
            if (sshSession != null && sshSession.isConnected()) {
                ChannelExec channelExec = (ChannelExec) sshSession.openChannel("exec");
                channelExec.setCommand(payload);
                BufferedReader reader = new BufferedReader(new InputStreamReader(channelExec.getInputStream(), "UTF-8"));
                channelExec.connect();

                StringBuilder output = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }

                channelExec.disconnect();
                session.sendMessage(new TextMessage(output.toString()));
            } else {
                session.sendMessage(new TextMessage("SSH session is not connected."));
            }
        }
    }
}
