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
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * DLM 서버에서 PII 정책을 주기적으로 동기화하여 캐싱.
 * Agent 내에서 SQL의 컬럼이 PII인지 판단하는 데 사용.
 *
 * 핵심 원칙: 감사 대상 테이블(targetTables)에 등록된 테이블의 SQL만 캡처.
 * 미등록 시 어떤 SQL도 캡처하지 않음 (안전).
 */
public class PiiPolicyCache {

    private static final PiiPolicyCache INSTANCE = new PiiPolicyCache();

    // key: "TABLE.COLUMN" (대문자) → PiiInfo
    private volatile Map<String, PiiInfo> policy = new ConcurrentHashMap<>();

    // 감사 대상 테이블 목록 (대문자). 이 Set에 포함된 테이블의 SQL만 캡처.
    private volatile Set<String> targetTables = Collections.emptySet();

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
     * 해당 테이블이 감사 대상인지 확인.
     * targetTables가 비어있으면 false (감사 대상 미등록 → 캡처 안 함).
     */
    public boolean isTargetTable(String tableName) {
        if (tableName == null || targetTables.isEmpty()) return false;
        return targetTables.contains(tableName.toUpperCase());
    }

    /**
     * SQL이 접근하는 테이블 중 감사 대상이 하나라도 있는지 확인.
     */
    public boolean hasAnyTargetTable(Set<String> tableNames) {
        if (tableNames == null || tableNames.isEmpty() || targetTables.isEmpty()) return false;
        for (String t : tableNames) {
            if (targetTables.contains(t.toUpperCase())) return true;
        }
        return false;
    }

    /**
     * 감사 대상 테이블 수.
     */
    public int getTargetTableCount() {
        return targetTables.size();
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
                System.out.println("[XAudit-Agent] Policy synced: " + targetTables.size()
                        + " target tables, " + policy.size() + " PII columns");
            } else {
                System.err.println("[XAudit-Agent] Policy sync failed: HTTP " + status);
            }
        } catch (Exception e) {
            System.err.println("[XAudit-Agent] Policy sync error: " + e.getMessage());
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    /**
     * JSON 응답 파싱하여 캐시 갱신.
     * 응답 형식 (BCI_TARGET 모드):
     *   {"mode":"BCI_TARGET","targetTables":["TB_USER","TB_ORDER"],
     *    "columns":[{"table":"TB_USER","column":"NAME","piitype":"3_1_name","piigrade":"1"}, ...]}
     * 응답 형식 (NO_TARGET 모드):
     *   {"mode":"NO_TARGET","targetTables":[],"columns":[]}
     */
    @SuppressWarnings("unchecked")
    private void parseAndUpdate(String json) {
        try {
            Gson gson = new Gson();
            Map<String, Object> response = gson.fromJson(json, Map.class);
            if (response == null) return;

            // 1. targetTables 파싱 (감사 대상 테이블)
            Set<String> newTargets = new HashSet<>();
            Object targetsObj = response.get("targetTables");
            if (targetsObj instanceof List) {
                for (Object t : (List<Object>) targetsObj) {
                    if (t != null) newTargets.add(t.toString().toUpperCase());
                }
            }
            targetTables = newTargets;

            // 2. PII 컬럼 정보 파싱
            Map<String, PiiInfo> newPolicy = new ConcurrentHashMap<>();
            Object columnsObj = response.get("columns");
            if (columnsObj instanceof List) {
                for (Object item : (List<Object>) columnsObj) {
                    if (item instanceof Map) {
                        Map<String, Object> col = (Map<String, Object>) item;
                        String table = col.get("table") != null ? col.get("table").toString() : null;
                        String column = col.get("column") != null ? col.get("column").toString() : null;
                        String piitype = col.get("piitype") != null ? col.get("piitype").toString() : null;
                        String piigrade = col.get("piigrade") != null ? col.get("piigrade").toString() : null;
                        if (table != null && column != null && piitype != null) {
                            String key = (table + "." + column).toUpperCase();
                            newPolicy.put(key, new PiiInfo(piitype, piigrade));
                        }
                    }
                }
            }
            policy = newPolicy;

            // 레거시 응답 호환 (columns가 최상위 배열인 경우)
            if (columnsObj == null && response.containsKey("table")) {
                // 단일 엔트리 형식 → 리스트 미사용 (폴백 없음, 무시)
            }
        } catch (Exception e) {
            System.err.println("[XAudit-Agent] Policy parse error: " + e.getMessage());
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

}
