package datablocks.dlm.agent.analyzer;

import datablocks.dlm.agent.AgentConfig;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.lang.reflect.Type;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * DLM 서버에서 PII 정책을 주기적으로 동기화하여 캐싱.
 * Agent 내에서 SQL의 컬럼이 PII인지 판단하는 데 사용.
 */
public class PiiPolicyCache {

    private static final PiiPolicyCache INSTANCE = new PiiPolicyCache();

    // key: "TABLE.COLUMN" (대문자) → PiiInfo
    private volatile Map<String, PiiInfo> policy = new ConcurrentHashMap<>();

    private volatile boolean initialized = false;
    private Thread syncThread;

    private PiiPolicyCache() {}

    public static PiiPolicyCache getInstance() {
        return INSTANCE;
    }

    public void init(AgentConfig config) {
        // 초기 동기화 시도
        syncPolicy(config);
        initialized = true;

        // 주기적 동기화 데몬 스레드
        syncThread = new Thread(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                try {
                    Thread.sleep(config.getPolicySyncIntervalMs());
                    syncPolicy(config);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        }, "dlm-agent-policy-sync");
        syncThread.setDaemon(true);
        syncThread.start();
    }

    /**
     * 테이블.컬럼으로 PII 정보 조회.
     */
    public PiiInfo lookup(String table, String column) {
        if (table == null || column == null) return null;
        return policy.get((table + "." + column).toUpperCase());
    }

    /**
     * DLM 서버에서 PII 정책 동기화.
     * GET {serverUrl}/api/agent/policy?agentId={agentId}
     */
    private void syncPolicy(AgentConfig config) {
        HttpURLConnection conn = null;
        try {
            String urlStr = config.getServerUrl() + "/api/agent/policy?agentId="
                    + config.getAgentId();
            URL url = new URL(urlStr);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Accept", "application/json");
            conn.setRequestProperty("X-Agent-Id", config.getAgentId());
            String secret = config.getAgentSecret();
            if (secret != null && !secret.isEmpty()) {
                conn.setRequestProperty("X-Agent-Secret", secret);
            }
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(30000);

            int status = conn.getResponseCode();
            if (status == 200) {
                StringBuilder sb = new StringBuilder();
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                }
                parseAndUpdate(sb.toString());
                System.out.println("[DLM-Agent] Policy synced: " + policy.size() + " PII columns");
            } else {
                System.err.println("[DLM-Agent] Policy sync failed: HTTP " + status);
            }
        } catch (Exception e) {
            System.err.println("[DLM-Agent] Policy sync error: " + e.getMessage());
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    /**
     * JSON 응답 파싱하여 캐시 갱신.
     * 응답 형식: [{"table":"CUSTOMER","column":"NAME","piitype":"3_1_name","piigrade":"1"}, ...]
     */
    private void parseAndUpdate(String json) {
        try {
            Gson gson = new Gson();
            Type listType = new TypeToken<List<PolicyEntry>>() {}.getType();
            List<PolicyEntry> entries = gson.fromJson(json, listType);

            Map<String, PiiInfo> newPolicy = new ConcurrentHashMap<>();
            if (entries != null) {
                for (PolicyEntry entry : entries) {
                    if (entry.table != null && entry.column != null && entry.piitype != null) {
                        String key = (entry.table + "." + entry.column).toUpperCase();
                        newPolicy.put(key, new PiiInfo(entry.piitype, entry.piigrade));
                    }
                }
            }
            policy = newPolicy;
        } catch (Exception e) {
            System.err.println("[DLM-Agent] Policy parse error: " + e.getMessage());
        }
    }

    public boolean isInitialized() {
        return initialized;
    }

    // ── Inner classes ──

    public static class PiiInfo {
        private final String piiType;
        private final String piiGrade;

        public PiiInfo(String piiType, String piiGrade) {
            this.piiType = piiType;
            this.piiGrade = piiGrade != null ? piiGrade : "3";
        }

        public String getPiiType() { return piiType; }
        public String getPiiGrade() { return piiGrade; }
    }

    /**
     * DLM 서버 응답 JSON 매핑용
     */
    private static class PolicyEntry {
        String table;
        String column;
        String piitype;
        String piigrade;
    }
}
