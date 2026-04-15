package datablocks.dlm.agent.shipper;

import datablocks.dlm.agent.AgentConfig;
import datablocks.dlm.agent.buffer.LogBuffer;
import datablocks.dlm.agent.model.AccessLogEntry;
import com.google.gson.Gson;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 배치 전송 데몬 스레드.
 * LogBuffer에서 주기적으로 드레인하여 DLM 서버로 HTTP POST 전송.
 */
public class LogShipper implements Runnable {

    private static final LogShipper INSTANCE = new LogShipper();
    private static final Gson GSON = new Gson();

    private int batchSize = 500;
    private int flushIntervalMs = 3000;
    private String serverUrl;
    private String agentId;
    private String agentSecret;
    private Thread shipperThread;
    private final AtomicLong totalSent = new AtomicLong(0);

    private LogShipper() {}

    public static LogShipper getInstance() {
        return INSTANCE;
    }

    public void start(AgentConfig config) {
        this.batchSize = config.getShipperBatchSize();
        this.flushIntervalMs = config.getShipperFlushIntervalMs();
        this.serverUrl = config.getServerUrl();
        this.agentId = config.getAgentId();
        this.agentSecret = config.getAgentSecret();

        FileFailover.getInstance().init(config);

        shipperThread = new Thread(this, "dlm-agent-log-shipper");
        shipperThread.setDaemon(true);
        shipperThread.start();

        // Heartbeat 데몬 스레드
        Thread heartbeatThread = new Thread(this::heartbeatLoop, "dlm-agent-heartbeat");
        heartbeatThread.setDaemon(true);
        heartbeatThread.start();

        System.out.println("[XAudit-Agent] LogShipper started: batchSize=" + batchSize
                + ", flushInterval=" + flushIntervalMs + "ms");
    }

    @Override
    public void run() {
        while (!Thread.currentThread().isInterrupted()) {
            try {
                Thread.sleep(flushIntervalMs);
                flush();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private void flush() {
        List<AccessLogEntry> batch = LogBuffer.getInstance().drain(batchSize);
        if (batch.isEmpty()) return;

        // Agent ID를 각 엔트리에 설정
        for (AccessLogEntry entry : batch) {
            entry.setAgentId(agentId);
        }

        boolean sent = sendToDlmServer(batch);
        if (!sent) {
            FileFailover.getInstance().save(batch);
        } else {
            totalSent.addAndGet(batch.size());
        }
    }

    /**
     * DLM 서버로 배치 전송.
     * POST {serverUrl}/api/agent/logs
     */
    private boolean sendToDlmServer(List<AccessLogEntry> batch) {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(serverUrl + "/api/agent/logs");
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setRequestProperty("X-Agent-Id", agentId);
            if (agentSecret != null && !agentSecret.isEmpty()) {
                conn.setRequestProperty("X-Agent-Secret", agentSecret);
            }
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(30000);
            conn.setDoOutput(true);

            String json = GSON.toJson(batch);
            try (OutputStream os = conn.getOutputStream()) {
                os.write(json.getBytes(StandardCharsets.UTF_8));
                os.flush();
            }

            int status = conn.getResponseCode();
            if (status >= 200 && status < 300) {
                return true;
            } else {
                System.err.println("[XAudit-Agent] Log send failed: HTTP " + status);
                return false;
            }
        } catch (Exception e) {
            System.err.println("[XAudit-Agent] Log send error: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    /**
     * 주기적 Heartbeat (60초마다)
     */
    private void heartbeatLoop() {
        while (!Thread.currentThread().isInterrupted()) {
            try {
                Thread.sleep(60000); // 1분
                sendHeartbeat();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private void sendHeartbeat() {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(serverUrl + "/api/agent/heartbeat");
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setRequestProperty("X-Agent-Id", agentId);
            if (agentSecret != null && !agentSecret.isEmpty()) {
                conn.setRequestProperty("X-Agent-Secret", agentSecret);
            }
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(10000);
            conn.setDoOutput(true);

            LogBuffer buffer = LogBuffer.getInstance();
            String json = GSON.toJson(new HeartbeatPayload(
                    agentId,
                    buffer.size(),
                    buffer.getDropCount(),
                    totalSent.get(),
                    System.getProperty("java.version"),
                    System.getProperty("java.vm.name")
            ));

            try (OutputStream os = conn.getOutputStream()) {
                os.write(json.getBytes(StandardCharsets.UTF_8));
                os.flush();
            }

            conn.getResponseCode(); // 응답 확인만
        } catch (Exception ignored) {
            // Heartbeat 실패는 무시
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    public long getTotalSent() {
        return totalSent.get();
    }

    // Heartbeat DTO
    private static class HeartbeatPayload {
        final String agentId;
        final int queueSize;
        final long dropCount;
        final long totalSent;
        final String javaVersion;
        final String vmName;

        HeartbeatPayload(String agentId, int queueSize, long dropCount,
                         long totalSent, String javaVersion, String vmName) {
            this.agentId = agentId;
            this.queueSize = queueSize;
            this.dropCount = dropCount;
            this.totalSent = totalSent;
            this.javaVersion = javaVersion;
            this.vmName = vmName;
        }
    }
}
