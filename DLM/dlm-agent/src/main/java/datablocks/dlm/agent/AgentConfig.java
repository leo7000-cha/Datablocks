package datablocks.dlm.agent;

import java.io.FileInputStream;
import java.io.InputStream;
import java.util.*;

public class AgentConfig {

    private static volatile AgentConfig INSTANCE;

    private final Properties props;

    private AgentConfig(Properties props) {
        this.props = props;
    }

    public static AgentConfig getInstance() {
        return INSTANCE;
    }

    /**
     * 설정 로드. agentArgs = properties 파일 경로.
     */
    public static AgentConfig load(String agentArgs) {
        Properties props = new Properties();

        // 1) 기본 설정 (classpath)
        try (InputStream is = AgentConfig.class.getClassLoader()
                .getResourceAsStream("dlm-agent.properties")) {
            if (is != null) {
                props.load(is);
            }
        } catch (Exception ignored) {}

        // 2) 외부 설정 파일 (agentArgs로 전달된 경로)
        if (agentArgs != null && !agentArgs.isEmpty()) {
            try (FileInputStream fis = new FileInputStream(agentArgs)) {
                props.load(fis);
            } catch (Exception e) {
                System.err.println("[XAudit-Agent] Failed to load config: " + agentArgs + " - " + e.getMessage());
            }
        }

        INSTANCE = new AgentConfig(props);
        return INSTANCE;
    }

    // ── DLM 서버 연결 ──

    public String getServerUrl() {
        return props.getProperty("dlm.server.url", "http://localhost:8080");
    }

    public String getAgentId() {
        return props.getProperty("dlm.agent.id", "DEFAULT_AGENT");
    }

    public String getAgentSecret() {
        return props.getProperty("dlm.agent.secret", "");
    }

    // ── 사용자 식별 ──

    public String getUserIdHeader() {
        return getNonEmpty("dlm.user.header");
    }

    public String getUserIdSessionAttr() {
        return getNonEmpty("dlm.user.session-attr");
    }

    public String getUserNameHeader() {
        return getNonEmpty("dlm.user.name-header");
    }

    public String getUserNameSessionAttr() {
        return getNonEmpty("dlm.user.name-session-attr");
    }

    // ── 성능 튜닝 ──

    public int getBufferCapacity() {
        return getInt("dlm.buffer.capacity", 10000);
    }

    public int getShipperBatchSize() {
        return getInt("dlm.shipper.batch-size", 500);
    }

    public int getShipperFlushIntervalMs() {
        return getInt("dlm.shipper.flush-interval-ms", 3000);
    }

    public long getPolicySyncIntervalMs() {
        return getLong("dlm.policy.sync-interval-ms", 300000L);
    }

    // ── 필터링 ──

    public Set<String> getExcludeSqlPatterns() {
        String val = props.getProperty("dlm.exclude.sql-patterns", "");
        return parseCommaSeparated(val);
    }

    public Set<String> getExcludeUsers() {
        String val = props.getProperty("dlm.exclude.users", "");
        return parseCommaSeparated(val);
    }

    /**
     * PreparedStatement bind 값 캡처 여부 (opt-in).
     * 기본 false — WAS 메모리/CPU 영향 가능성 때문에 명시적으로 켜야 함.
     * properties 키: dlm.capture.bind=true/false
     */
    public boolean isCaptureBindEnabled() {
        return Boolean.parseBoolean(props.getProperty("dlm.capture.bind", "false"));
    }

    // ── 폴백 ──

    public String getFailoverDir() {
        return props.getProperty("dlm.failover.dir", "/tmp/dlm-agent-failover");
    }

    // ── 유틸 ──

    /**
     * 빈 문자열("")이면 null 반환. 설정 파일에서 key= (값 없음) 시 안전.
     */
    private String getNonEmpty(String key) {
        String val = props.getProperty(key);
        return (val != null && !val.trim().isEmpty()) ? val.trim() : null;
    }

    private int getInt(String key, int defaultValue) {
        try {
            return Integer.parseInt(props.getProperty(key, String.valueOf(defaultValue)));
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private long getLong(String key, long defaultValue) {
        try {
            return Long.parseLong(props.getProperty(key, String.valueOf(defaultValue)));
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private Set<String> parseCommaSeparated(String value) {
        Set<String> set = new HashSet<>();
        if (value == null || value.isEmpty()) return set;
        for (String s : value.split(",")) {
            String trimmed = s.trim();
            if (!trimmed.isEmpty()) {
                set.add(trimmed.toUpperCase());
            }
        }
        return set;
    }
}
