package datablocks.dlm.controller;

import datablocks.dlm.domain.AccessLogSourceVO;
import datablocks.dlm.domain.AccessLogVO;
import datablocks.dlm.domain.MetaTableVO;
import datablocks.dlm.mapper.AccessLogMapper;
import datablocks.dlm.mapper.MetaTableMapper;
import datablocks.dlm.service.AccessLogService;
import datablocks.dlm.util.LogUtil;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.*;

/**
 * Agent API Controller
 * Java Agent에서 보내는 접속기록 수신 및 PII 정책 배포
 *
 * POST /api/agent/logs       — Agent 로그 수신
 * GET  /api/agent/policy     — PII 정책 배포
 * POST /api/agent/heartbeat  — Agent 상태 모니터링
 */
@RestController
@RequestMapping("/api/agent")
public class AgentApiController {

    private static final Logger logger = LoggerFactory.getLogger(AgentApiController.class);

    @Autowired
    private AccessLogService accessLogService;

    @Autowired
    private MetaTableMapper metaTableMapper;

    @Autowired
    private AccessLogMapper accessLogMapper;

    // Agent 상태 저장 (메모리 — 재시작 시 초기화)
    private final Map<String, Map<String, Object>> agentStatusMap =
            Collections.synchronizedMap(new LinkedHashMap<>());

    /**
     * Agent에서 보낸 접속기록 배치 수신.
     * POST /api/agent/logs
     */
    @PostMapping("/logs")
    public ResponseEntity<Map<String, Object>> receiveAgentLogs(
            @RequestHeader(value = "X-Agent-Id", required = false) String agentId,
            @RequestHeader(value = "X-Agent-Secret", required = false) String agentSecret,
            @RequestBody List<AgentLogEntry> entries) {

        Map<String, Object> result = new HashMap<>();

        // Agent Secret 검증 — AGENT_API_SECRET 설정이 있으면 반드시 일치해야 함
        if (!verifyAgentSecret(agentSecret)) {
            result.put("status", "UNAUTHORIZED");
            result.put("message", "Invalid agent secret");
            return ResponseEntity.status(401).body(result);
        }

        if (entries == null || entries.isEmpty()) {
            result.put("status", "OK");
            result.put("received", 0);
            return ResponseEntity.ok(result);
        }

        LogUtil.log("INFO", "Agent logs received: agentId=" + agentId + ", count=" + entries.size());

        try {
            // Agent 소스 정보 조회 (targetDb 매핑용)
            AccessLogSourceVO agentSource = null;
            if (agentId != null) {
                try {
                    agentSource = accessLogMapper.selectSourceByAgentId(agentId);
                } catch (Exception e) {
                    logger.warn("Agent source lookup failed for agentId={}: {}", agentId, e.getMessage());
                }
            }

            // AgentLogEntry → AccessLogVO 변환
            List<AccessLogVO> logs = new ArrayList<>(entries.size());
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            SimpleDateFormat partSdf = new SimpleDateFormat("yyyyMMdd");

            for (AgentLogEntry entry : entries) {
                AccessLogVO log = convertToAccessLogVO(entry, agentId, agentSource, sdf, partSdf);
                if (log != null) {
                    logs.add(log);
                }
            }

            if (!logs.isEmpty()) {
                // SQL 전문 저장 설정 확인
                if (!isSqlTextLoggingEnabled()) {
                    for (AccessLogVO log : logs) {
                        log.setSqlText(null);
                    }
                }
                // 기존 registerAccessLogBatch() 활용 → 해시 체인 자동 생성
                accessLogService.registerAccessLogBatch(logs);
            }

            result.put("status", "OK");
            result.put("received", logs.size());
            return ResponseEntity.ok(result);

        } catch (Exception e) {
            logger.error("Agent log processing failed", e);
            result.put("status", "ERROR");
            result.put("message", e.getMessage());
            return ResponseEntity.internalServerError().body(result);
        }
    }

    /**
     * PII 정책 배포.
     * GET /api/agent/policy?agentId={agentId}
     * BCI Target 테이블에 등록된 대상만 반환.
     * BCI Target 미등록 시 빈 정책 반환 (Agent는 아무것도 캡처하지 않음).
     */
    @GetMapping("/policy")
    public ResponseEntity<Map<String, Object>> getAgentPolicy(
            @RequestParam(value = "agentId", required = false) String agentId) {

        LogUtil.log("INFO", "Agent policy requested: agentId=" + agentId);

        try {
            Map<String, Object> response = new HashMap<>();
            List<Map<String, String>> policy = new ArrayList<>();

            // Agent의 소스에서 dbName 조회
            String dbName = null;
            if (agentId != null) {
                var source = accessLogMapper.selectSourceByAgentId(agentId);
                if (source != null) dbName = source.getDbName();
            }

            // BCI Target이 등록되어 있으면 해당 테이블의 PII 컬럼만 반환
            if (dbName != null) {
                List<Map<String, Object>> bciColumns = accessLogMapper.selectBciPolicyColumns(dbName);
                if (bciColumns != null && !bciColumns.isEmpty()) {
                    Set<String> targetTables = new LinkedHashSet<>();
                    for (Map<String, Object> col : bciColumns) {
                        String table = (String) col.get("tableName");
                        if (table != null) targetTables.add(table);
                        if (col.get("columnName") != null) {
                            Map<String, String> entry = new HashMap<>();
                            entry.put("table", (String) col.get("tableName"));
                            entry.put("column", (String) col.get("columnName"));
                            entry.put("piitype", (String) col.get("piiType"));
                            entry.put("piigrade", (String) col.get("piiGrade"));
                            entry.put("targetType", (String) col.get("targetType"));
                            policy.add(entry);
                        }
                    }
                    response.put("targetTables", targetTables);
                    response.put("columns", policy);
                    response.put("mode", "BCI_TARGET");
                    return ResponseEntity.ok(response);
                }
            }

            // BCI Target 미등록 → 빈 정책 반환 (Agent는 캡처하지 않음)
            response.put("targetTables", Collections.emptyList());
            response.put("columns", Collections.emptyList());
            response.put("mode", "NO_TARGET");
            LogUtil.log("WARN", "No BCI targets registered for agentId=" + agentId
                    + " — Agent will not capture any SQL");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("Agent policy export failed", e);
            return ResponseEntity.internalServerError().body(Collections.emptyMap());
        }
    }

    /**
     * Agent 상태 보고 (Heartbeat).
     * POST /api/agent/heartbeat
     */
    @PostMapping("/heartbeat")
    public ResponseEntity<Map<String, Object>> heartbeat(
            @RequestHeader(value = "X-Agent-Id", required = false) String headerAgentId,
            @RequestHeader(value = "X-Agent-Secret", required = false) String agentSecret,
            @RequestBody Map<String, Object> payload) {

        // Agent Secret 검증
        if (!verifyAgentSecret(agentSecret)) {
            Map<String, Object> err = new HashMap<>();
            err.put("status", "UNAUTHORIZED");
            return ResponseEntity.status(401).body(err);
        }

        String agentId = payload.containsKey("agentId")
                ? payload.get("agentId").toString()
                : headerAgentId;

        if (agentId == null) agentId = "UNKNOWN";

        // 메모리 상태 저장
        Map<String, Object> status = new HashMap<>(payload);
        status.put("lastHeartbeat", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
        status.put("status", "ACTIVE");
        agentStatusMap.put(agentId, status);

        // DB 영속화 (TBL_ACCESS_LOG_SOURCE.agent_last_heartbeat 업데이트)
        try {
            accessLogMapper.updateAgentHeartbeat(agentId, "ACTIVE");
        } catch (Exception e) {
            logger.warn("Agent heartbeat DB update failed for {}: {}", agentId, e.getMessage());
        }

        Map<String, Object> result = new HashMap<>();
        result.put("status", "OK");
        result.put("serverTime", System.currentTimeMillis());
        return ResponseEntity.ok(result);
    }

    /**
     * Agent 상태 목록 조회 (관리 화면용).
     * GET /api/agent/status
     */
    @GetMapping("/status")
    public ResponseEntity<List<Map<String, Object>>> getAgentStatusList() {
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map.Entry<String, Map<String, Object>> entry : agentStatusMap.entrySet()) {
            Map<String, Object> item = new HashMap<>(entry.getValue());
            item.put("agentId", entry.getKey());
            list.add(item);
        }
        return ResponseEntity.ok(list);
    }

    // ── 변환 로직 ──

    private AccessLogVO convertToAccessLogVO(AgentLogEntry entry, String agentId,
                                              AccessLogSourceVO agentSource,
                                              SimpleDateFormat sdf, SimpleDateFormat partSdf) {
        if (entry.sql == null || entry.sql.isEmpty()) return null;

        AccessLogVO log = new AccessLogVO();
        log.setSourceSystemId(agentId != null ? agentId : (entry.agentId != null ? entry.agentId : "AGENT"));
        log.setUserAccount(entry.userId != null ? entry.userId : "UNKNOWN");
        log.setUserName(entry.userName);
        log.setClientIp(entry.clientIp);
        log.setSessionId(entry.sessionId);
        log.setActionType(entry.actionType != null ? entry.actionType : "OTHER");
        log.setSqlText(entry.sql);
        log.setCollectType("WAS_AGENT");
        log.setAccessChannel("WAS");
        log.setResultCode(entry.success ? "SUCCESS" : "FAIL");

        // Agent 소스에서 targetDb/targetSchema 보강
        if (agentSource != null) {
            log.setTargetDb(agentSource.getDbName());
            log.setTargetSchema(agentSource.getSchemaName());
        }

        // 타임스탬프 → 문자열
        Date accessDate = new Date(entry.timestamp);
        log.setAccessTime(sdf.format(accessDate));
        log.setPartitionKey(partSdf.format(accessDate));
        log.setCollectedAt(sdf.format(new Date()));

        // PII 정보 (Agent에서 이미 분석)
        log.setTargetTable(entry.targetTable);
        log.setTargetColumns(entry.targetColumns);
        log.setPiiTypeCodes(entry.piiTypeCodes);
        log.setPiiGrade(entry.piiGrade);

        return log;
    }

    /**
     * Agent Secret 검증.
     * TBL_ACCESS_LOG_CONFIG에 AGENT_API_SECRET이 설정되어 있으면 일치 여부 확인.
     * 미설정 시 검증 건너뜀 (하위 호환).
     */
    private boolean verifyAgentSecret(String clientSecret) {
        try {
            var config = accessLogMapper.selectConfigByKey("AGENT_API_SECRET");
            if (config == null || config.getConfigValue() == null
                    || config.getConfigValue().trim().isEmpty()) {
                return true; // 미설정 — 검증 스킵
            }
            String serverSecret = config.getConfigValue().trim();
            return serverSecret.equals(clientSecret);
        } catch (Exception e) {
            logger.warn("Agent secret verification failed, allowing request: {}", e.getMessage());
            return true; // 설정 테이블 미존재 등 예외 시 허용 (안전)
        }
    }

    private boolean isSqlTextLoggingEnabled() {
        try {
            var config = accessLogMapper.selectConfigByKey("SQL_TEXT_LOGGING");
            return config != null && "Y".equals(config.getConfigValue());
        } catch (Exception e) {
            return false;
        }
    }

    // ── Agent 로그 엔트리 DTO ──

    public static class AgentLogEntry {
        public String sql;
        public String userId;
        public String userName;
        public String clientIp;
        public String sessionId;
        public long elapsedMs;
        public long timestamp;
        public boolean success;
        public String actionType;
        public String targetTable;
        public String targetColumns;
        public String piiTypeCodes;
        public String piiGrade;
        public String agentId;
    }
}
