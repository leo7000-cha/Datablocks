package datablocks.dlm.aop;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicLong;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import datablocks.dlm.domain.AccessLogConfigVO;
import datablocks.dlm.service.AccessLogService;

import jakarta.annotation.PostConstruct;

/**
 * AOP 수집 동작을 제어하는 런타임 설정 캐시.
 * TBL_ACCESS_LOG_CONFIG (configType='AOP') 를 1분마다 리로드한다.
 * UI에서 모드 변경 후 즉시 반영이 필요하면 AccessLogController.reloadAop() 호출.
 */
@Component
public class AccessLogAopConfig {

    public enum Mode { OFF, ANNOTATION, ALL }

    private static final Logger log = LoggerFactory.getLogger(AccessLogAopConfig.class);

    @Autowired
    private AccessLogService accessLogService;

    private volatile Mode mode = Mode.OFF;
    private volatile Set<String> maskFields = Collections.emptySet();
    private volatile Set<String> includePatterns = Collections.emptySet();
    private volatile Set<String> excludePatterns = defaultExcludes();
    private volatile boolean recordParams = true;
    private volatile int paramMaxLen = 2000;
    private volatile String minImportance = "LOW";
    private volatile boolean recordReads = true;
    private volatile long durationThresholdMs = 0;
    private volatile int errorMsgLen = 100;
    private volatile long lastLoadedMs = 0;

    private final AtomicLong droppedCount = new AtomicLong();

    @PostConstruct
    public void init() {
        reloadFromDb();
    }

    /** 1분 주기 자동 재로딩 */
    @Scheduled(fixedDelay = 60_000L, initialDelay = 60_000L)
    public void reloadFromDb() {
        try {
            List<AccessLogConfigVO> list = accessLogService.getConfigListByType("AOP");
            if (list == null) return;
            for (AccessLogConfigVO c : list) {
                apply(c.getConfigKey(), c.getConfigValue());
            }
            lastLoadedMs = System.currentTimeMillis();
            log.debug("[AOP] config reloaded: mode={}, maskFields={}, minImportance={}",
                    mode, maskFields.size(), minImportance);
        } catch (Exception e) {
            log.warn("[AOP] config reload failed: {}", e.getMessage());
        }
    }

    private void apply(String key, String value) {
        if (key == null) return;
        if (value == null) value = "";
        switch (key) {
            case "AOP_COLLECT_MODE":
                this.mode = parseMode(value);
                break;
            case "AOP_MASK_FIELDS":
                this.maskFields = ParamMasker.parseMaskFields(value);
                break;
            case "AOP_INCLUDE_PATTERNS":
                this.includePatterns = splitCsv(value);
                break;
            case "AOP_EXCLUDE_PATTERNS":
                Set<String> ex = splitCsv(value);
                this.excludePatterns = ex.isEmpty() ? defaultExcludes() : ex;
                break;
            case "AOP_RECORD_PARAMS":
                this.recordParams = "Y".equalsIgnoreCase(value);
                break;
            case "AOP_PARAM_MAX_LEN":
                this.paramMaxLen = parseIntSafe(value, 2000);
                break;
            case "AOP_MIN_IMPORTANCE":
                this.minImportance = value.isBlank() ? "LOW" : value.trim().toUpperCase();
                break;
            case "AOP_RECORD_READS":
                this.recordReads = "Y".equalsIgnoreCase(value);
                break;
            case "AOP_DURATION_THRESHOLD_MS":
                this.durationThresholdMs = parseLongSafe(value, 0);
                break;
            case "AOP_ERROR_MSG_LEN":
                this.errorMsgLen = parseIntSafe(value, 100);
                break;
            default:
                /* ignore */
        }
    }

    private Mode parseMode(String v) {
        if (v == null) return Mode.OFF;
        try { return Mode.valueOf(v.trim().toUpperCase()); }
        catch (Exception e) { return Mode.OFF; }
    }

    private Set<String> splitCsv(String v) {
        if (v == null || v.isBlank()) return Collections.emptySet();
        Set<String> out = new HashSet<>();
        for (String s : v.split(",")) {
            if (!s.isBlank()) out.add(s.trim());
        }
        return out;
    }

    private int parseIntSafe(String v, int def) {
        try { return Integer.parseInt(v.trim()); } catch (Exception e) { return def; }
    }
    private long parseLongSafe(String v, long def) {
        try { return Long.parseLong(v.trim()); } catch (Exception e) { return def; }
    }

    private static Set<String> defaultExcludes() {
        return new HashSet<>(Arrays.asList(
                "/resources/", "/favicon", "/accesslog/", "/common/",
                "/locale/", "/home", "/api/agent/", "/dlmapi/"));
    }

    /** URI 가 제외 prefix 중 하나로 시작하면 true */
    public boolean isExcludedUri(String uri) {
        if (uri == null) return true;
        for (String ex : excludePatterns) {
            if (uri.startsWith(ex)) return true;
        }
        return false;
    }

    /** include 패턴이 지정되어 있으면 해당 prefix 로 시작하는 URI만 허용 */
    public boolean passesIncludeFilter(String uri) {
        if (includePatterns.isEmpty()) return true;
        if (uri == null) return false;
        for (String inc : includePatterns) {
            if (uri.startsWith(inc)) return true;
        }
        return false;
    }

    /** 중요도 비교 (HIGH=3, MEDIUM=2, LOW=1) */
    public boolean meetsImportance(String importance) {
        return rank(importance) >= rank(minImportance);
    }
    private int rank(String i) {
        if ("HIGH".equalsIgnoreCase(i)) return 3;
        if ("MEDIUM".equalsIgnoreCase(i)) return 2;
        return 1;
    }

    public void incrementDropped() { droppedCount.incrementAndGet(); }

    // ===== getters =====
    public Mode getMode()                  { return mode; }
    public Set<String> getMaskFields()     { return maskFields; }
    public boolean isRecordParams()        { return recordParams; }
    public int getParamMaxLen()            { return paramMaxLen; }
    public String getMinImportance()       { return minImportance; }
    public boolean isRecordReads()         { return recordReads; }
    public long getDurationThresholdMs()   { return durationThresholdMs; }
    public int getErrorMsgLen()            { return errorMsgLen; }
    public long getLastLoadedMs()          { return lastLoadedMs; }
    public long getDroppedCount()          { return droppedCount.get(); }
    public Set<String> getIncludePatterns(){ return includePatterns; }
    public Set<String> getExcludePatterns(){ return excludePatterns; }
}
