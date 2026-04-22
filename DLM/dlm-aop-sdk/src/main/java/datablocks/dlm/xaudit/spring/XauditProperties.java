package datablocks.dlm.xaudit.spring;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * X-Audit SDK 설정 바인딩.
 *
 * 고객사 처리계 {@code application.properties} / {@code application.yml} 에서
 * {@code xaudit.*} prefix 로 지정한다. 모든 항목은 안전한 기본값을 가진다.
 */
@ConfigurationProperties(prefix = "xaudit")
public class XauditProperties {

    /** 전체 SDK 활성화 여부 */
    private boolean enabled = true;

    /** 처리계 서비스 식별자 (예: "LOAN", "CARD", "CORE") — access_log.source_system_id */
    private String serviceName = "UNKNOWN";

    /** DLM 수집 서버 설정 */
    private final Server server = new Server();

    /** 배치/큐 설정 */
    private final Batch batch = new Batch();

    /** 사용자 식별 전략 */
    private final User user = new User();

    /** 메뉴 식별 전략 */
    private final Menu menu = new Menu();

    /** SQL 수집 옵션 */
    private final Sql sql = new Sql();

    /** Oracle 전용 옵션 */
    private final Oracle oracle = new Oracle();

    /** 수집에서 제외할 URI prefix */
    private List<String> excludeUriPatterns = new ArrayList<>(Arrays.asList(
            "/health", "/actuator", "/css/", "/js/", "/images/", "/favicon"));

    public static class Server {
        /** DLM 수집 엔드포인트 — 신규 X-Audit 전용 */
        private String url = "http://dlm.internal:8080/api/xaudit/events";
        /** API 인증키 (선택) — 헤더 "X-API-KEY" 로 전송 */
        private String apiKey = "";
        /** 연결 타임아웃 (ms) */
        private int connectTimeoutMs = 2000;
        /** 응답 타임아웃 (ms) */
        private int readTimeoutMs = 5000;

        public String getUrl() { return url; }
        public void setUrl(String url) { this.url = url; }
        public String getApiKey() { return apiKey; }
        public void setApiKey(String apiKey) { this.apiKey = apiKey; }
        public int getConnectTimeoutMs() { return connectTimeoutMs; }
        public void setConnectTimeoutMs(int v) { this.connectTimeoutMs = v; }
        public int getReadTimeoutMs() { return readTimeoutMs; }
        public void setReadTimeoutMs(int v) { this.readTimeoutMs = v; }
    }

    public static class Batch {
        /** 큐 최대 용량. 초과 시 DROP + warn 로깅 (서비스 영향 zero) */
        private int queueCapacity = 10000;
        /** 한 번에 전송할 배치 크기 */
        private int size = 100;
        /** 강제 flush 주기 (ms). 배치 크기 미달이어도 이 시간 지나면 송신 */
        private long flushIntervalMs = 3000L;
        /** 플러시 worker 스레드 수 */
        private int workerThreads = 1;

        public int getQueueCapacity() { return queueCapacity; }
        public void setQueueCapacity(int v) { this.queueCapacity = v; }
        public int getSize() { return size; }
        public void setSize(int v) { this.size = v; }
        public long getFlushIntervalMs() { return flushIntervalMs; }
        public void setFlushIntervalMs(long v) { this.flushIntervalMs = v; }
        public int getWorkerThreads() { return workerThreads; }
        public void setWorkerThreads(int v) { this.workerThreads = v; }
    }

    public static class User {
        /** SecurityContext 기본 사용 여부 (true 이면 Authentication.getName()) */
        private boolean useSecurityContext = true;
        /** 세션 attribute 키 — 지정 시 해당 키의 값을 user ID 로 사용 (SecurityContext 보다 우선) */
        private String sessionAttribute = "";
        /** 요청 헤더 키 — 지정 시 해당 헤더 값을 user ID 로 사용 */
        private String header = "";

        public boolean isUseSecurityContext() { return useSecurityContext; }
        public void setUseSecurityContext(boolean v) { this.useSecurityContext = v; }
        public String getSessionAttribute() { return sessionAttribute; }
        public void setSessionAttribute(String v) { this.sessionAttribute = v; }
        public String getHeader() { return header; }
        public void setHeader(String v) { this.header = v; }
    }

    public static class Menu {
        /** 요청 헤더에서 메뉴 ID 읽기 (예: "X-Menu-Id") */
        private String header = "X-Menu-Id";
        /** URI prefix → 메뉴 ID 매핑 (예: LOAN=/loan/) — 헤더 미존재 시 fallback */
        private java.util.Map<String, String> uriPrefixMap = new java.util.LinkedHashMap<>();

        public String getHeader() { return header; }
        public void setHeader(String header) { this.header = header; }
        public java.util.Map<String, String> getUriPrefixMap() { return uriPrefixMap; }
        public void setUriPrefixMap(java.util.Map<String, String> v) { this.uriPrefixMap = v; }
    }

    public static class Sql {
        /** SQL 본문 캡처 */
        private boolean captureText = true;
        /** 바인딩 파라미터 캡처 */
        private boolean captureBindParams = true;
        /** SQL 본문 최대 길이 (초과 시 절삭) */
        private int maxTextLength = 8000;
        /** bind params 최대 길이 */
        private int maxBindLength = 2000;
        /** SQL Comment Injection — DAM(DBSAFER/PSM) 패킷 연계용 */
        private boolean commentInjection = false;
        /** PII 자동 마스킹: JUMIN/CARD/ACCOUNT/PHONE/EMAIL */
        private java.util.List<String> maskPatterns = new java.util.ArrayList<>(
                Arrays.asList("JUMIN", "CARD", "ACCOUNT"));

        public boolean isCaptureText() { return captureText; }
        public void setCaptureText(boolean v) { this.captureText = v; }
        public boolean isCaptureBindParams() { return captureBindParams; }
        public void setCaptureBindParams(boolean v) { this.captureBindParams = v; }
        public int getMaxTextLength() { return maxTextLength; }
        public void setMaxTextLength(int v) { this.maxTextLength = v; }
        public int getMaxBindLength() { return maxBindLength; }
        public void setMaxBindLength(int v) { this.maxBindLength = v; }
        public boolean isCommentInjection() { return commentInjection; }
        public void setCommentInjection(boolean v) { this.commentInjection = v; }
        public List<String> getMaskPatterns() { return maskPatterns; }
        public void setMaskPatterns(List<String> v) { this.maskPatterns = v; }
    }

    public static class Oracle {
        /** V$SESSION.CLIENT_IDENTIFIER 자동 세팅 (setClientInfo) */
        private boolean setClientInfo = false;

        public boolean isSetClientInfo() { return setClientInfo; }
        public void setSetClientInfo(boolean v) { this.setClientInfo = v; }
    }

    // ===== getters/setters =====
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    public String getServiceName() { return serviceName; }
    public void setServiceName(String v) { this.serviceName = v; }
    public Server getServer() { return server; }
    public Batch getBatch() { return batch; }
    public User getUser() { return user; }
    public Menu getMenu() { return menu; }
    public Sql getSql() { return sql; }
    public Oracle getOracle() { return oracle; }
    public List<String> getExcludeUriPatterns() { return excludeUriPatterns; }
    public void setExcludeUriPatterns(List<String> v) { this.excludeUriPatterns = v; }
}
