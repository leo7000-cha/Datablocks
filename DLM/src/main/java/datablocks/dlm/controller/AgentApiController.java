package datablocks.dlm.controller;

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
            @RequestBody List<AgentLogEntry> entries) {

        Map<String, Object> result = new HashMap<>();

        if (entries == null || entries.isEmpty()) {
            result.put("status", "OK");
            result.put("received", 0);
            return ResponseEntity.ok(result);
        }

        LogUtil.log("INFO", "Agent logs received: agentId=" + agentId + ", count=" + entries.size());

        try {
            // AgentLogEntry → AccessLogVO 변환
            List<AccessLogVO> logs = new ArrayList<>(entries.size());
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            SimpleDateFormat partSdf = new SimpleDateFormat("yyyyMMdd");

            for (AgentLogEntry entry : entries) {
                AccessLogVO log = convertToAccessLogVO(entry, agentId, sdf, partSdf);
                if (log != null) {
                    logs.add(log);
                }
            }

            if (!logs.isEmpty()) {
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
     * Agent가 SQL의 컬럼이 PII인지 판단하는 데 필요.
     */
    @GetMapping("/policy")
    public ResponseEntity<List<Map<String, String>>> getAgentPolicy(
            @RequestParam(value = "agentId", required = false) String agentId) {

        LogUtil.log("INFO", "Agent policy requested: agentId=" + agentId);

        try {
            List<MetaTableVO> piiColumns = metaTableMapper.selectPiiColumnsForCache();
            List<Map<String, String>> policy = new ArrayList<>();

            for (MetaTableVO col : piiColumns) {
                Map<String, String> entry = new HashMap<>();
                entry.put("table", col.getTable_name());
                entry.put("column", col.getColumn_name());
                entry.put("piitype", col.getPiitype());
                entry.put("piigrade", col.getPiigrade());
                policy.add(entry);
            }

            return ResponseEntity.ok(policy);

        } catch (Exception e) {
            logger.error("Agent policy export failed", e);
            return ResponseEntity.internalServerError().body(Collections.emptyList());
        }
    }

    /**
     * Agent 상태 보고 (Heartbeat).
     * POST /api/agent/heartbeat
     */
    @PostMapping("/heartbeat")
    public ResponseEntity<Map<String, Object>> heartbeat(
            @RequestHeader(value = "X-Agent-Id", required = false) String headerAgentId,
            @RequestBody Map<String, Object> payload) {

        String agentId = payload.containsKey("agentId")
                ? payload.get("agentId").toString()
                : headerAgentId;

        if (agentId == null) agentId = "UNKNOWN";

        // 상태 저장
        Map<String, Object> status = new HashMap<>(payload);
        status.put("lastHeartbeat", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
        status.put("status", "ACTIVE");
        agentStatusMap.put(agentId, status);

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
        log.setAccessChannel("WAS_AGENT");
        log.setResultCode(entry.success ? "SUCCESS" : "FAIL");

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
