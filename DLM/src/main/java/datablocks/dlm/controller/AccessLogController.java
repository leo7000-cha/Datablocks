package datablocks.dlm.controller;

import java.io.IOException;
import java.security.Principal;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import datablocks.dlm.aop.AccessLogAopConfig;
import datablocks.dlm.aop.annotation.LogAccess;
import datablocks.dlm.domain.*;
import datablocks.dlm.engine.AccessLogCollector;
import datablocks.dlm.mapper.AccessLogMapper;
import datablocks.dlm.mapper.DiscoveryMapper;
import datablocks.dlm.schedule.AccessLogHashVerifyScheduler;
import datablocks.dlm.service.AccessLogReportService;
import datablocks.dlm.service.AccessLogService;
import datablocks.dlm.service.PiiDatabaseService;
import datablocks.dlm.util.LogUtil;

/**
 * Access Log Controller
 * 접속기록관리 모듈 컨트롤러
 */
@Controller
@RequestMapping("/accesslog/*")
public class AccessLogController {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogController.class);

    @Autowired
    private AccessLogService accessLogService;

    @Autowired
    private AccessLogCollector accessLogCollector;

    @Autowired
    private PiiDatabaseService piiDatabaseService;

    @Autowired
    private AccessLogHashVerifyScheduler hashVerifyScheduler;

    @Autowired
    private DiscoveryMapper discoveryMapper;

    @Autowired
    private AccessLogMapper accessLogMapper;

    @Autowired
    private AccessLogReportService reportService;

    @Autowired(required = false)
    private AccessLogAopConfig aopConfig;

    @Autowired
    private org.springframework.context.ApplicationContext applicationContext;

    // ========== Page Controllers ==========

    @GetMapping("/index")
    public String index(Model model) {
        LogUtil.log("INFO", "AccessLog index page");
        // 대시보드 초기 데이터
        AccessLogStatVO stats = accessLogService.getDashboardStats(null);
        AccessLogStatVO compliance = accessLogService.getComplianceStats();
        model.addAttribute("stats", stats);
        model.addAttribute("compliance", compliance);
        return "accesslog/index";
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        AccessLogStatVO stats = accessLogService.getDashboardStats(null);
        AccessLogStatVO compliance = accessLogService.getComplianceStats();
        List<AccessLogAlertVO> latestAlerts = accessLogService.getLatestAlerts(5);
        Criteria cri = new Criteria();
        cri.setAmount(100);
        List<AccessLogSourceVO> sources = accessLogService.getSourceList(cri);
        model.addAttribute("stats", stats);
        model.addAttribute("compliance", compliance);
        model.addAttribute("latestAlerts", latestAlerts);
        model.addAttribute("sources", sources);
        return "accesslog/dashboard";
    }

    @GetMapping("/logs")
    public String logs(Model model) {
        // 초기 로드 시 조회하지 않음 — 필터 조건 입력 후 AJAX로 조회
        return "accesslog/logs";
    }

    @GetMapping("/alerts")
    public String alerts(@ModelAttribute Criteria cri, Model model) {
        List<AccessLogAlertVO> list = accessLogService.getAlertList(cri);
        int total = accessLogService.getAlertTotal(cri);
        model.addAttribute("list", list);
        model.addAttribute("total", total);
        model.addAttribute("pageMaker", new PageDTO(cri, total));
        model.addAttribute("ruleList", accessLogService.getAlertRuleList());
        return "accesslog/alerts";
    }

    @GetMapping("/policy")
    public String policy(Model model) {
        model.addAttribute("dbList", piiDatabaseService.getList());
        return "accesslog/policy";
    }

    @GetMapping("/exclude-patterns")
    public String excludePatterns() {
        return "accesslog/exclude-patterns";
    }

    // ========== Exclude SQL Pattern API ==========
    @GetMapping("/api/exclude-patterns")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getExcludePatterns(
            @RequestParam(value = "sourceType", required = false) String sourceType) {
        return ResponseEntity.ok(accessLogMapper.selectExcludeSqlPatterns(sourceType));
    }

    @PostMapping("/api/exclude-patterns")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addExcludePattern(@RequestBody Map<String, String> body, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            String userId = principal != null ? principal.getName() : "admin";
            accessLogMapper.insertExcludeSqlPattern(
                body.get("sourceType"), body.get("pattern"), body.get("matchType"),
                body.get("description"), userId);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    @PutMapping("/api/exclude-patterns/{patternId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateExcludePattern(
            @PathVariable int patternId, @RequestBody Map<String, String> body) {
        Map<String, Object> result = new HashMap<>();
        accessLogMapper.updateExcludeSqlPattern(patternId, body.get("pattern"),
            body.get("matchType"), body.get("description"), body.get("isActive"));
        result.put("success", true);
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/api/exclude-patterns/{patternId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteExcludePattern(@PathVariable int patternId) {
        Map<String, Object> result = new HashMap<>();
        accessLogMapper.deleteExcludeSqlPattern(patternId);
        result.put("success", true);
        return ResponseEntity.ok(result);
    }

    /**
     * 감사 정책 요약 목록 (전체 DB별 Audit/BCI 개수)
     */
    @GetMapping("/api/policy/list")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getPolicyList() {
        List<Map<String, Object>> result = new java.util.ArrayList<>();
        List<PiiDatabaseVO> dbs = piiDatabaseService.getList();
        for (PiiDatabaseVO db : dbs) {
            Map<String, Object> item = new HashMap<>();
            item.put("dbName", db.getDb());
            item.put("dbType", db.getDbtype());
            item.put("hostname", db.getHostname());
            item.put("port", db.getPort());
            item.put("system", db.getSystem());
            // DB Audit 대상 수
            List<Map<String, Object>> piiTables = accessLogMapper.selectMetaPiiTables(db.getDb());
            long auditCount = piiTables != null ? piiTables.stream().filter(t -> "Y".equals(t.get("auditYn"))).count() : 0;
            long piiTotal = piiTables != null ? piiTables.size() : 0;
            item.put("piiTableCount", piiTotal);
            item.put("auditCount", auditCount);
            // BCI 대상 수
            List<BciTargetVO> bciTargets = accessLogMapper.selectBciTargets(db.getDb());
            item.put("bciCount", bciTargets != null ? bciTargets.size() : 0);
            result.add(item);
        }
        return ResponseEntity.ok(result);
    }

    @GetMapping("/sources")
    public String sources(@ModelAttribute Criteria cri, Model model) {
        List<AccessLogSourceVO> list = accessLogService.getSourceList(cri);
        int total = accessLogService.getSourceTotal(cri);
        model.addAttribute("list", list);
        model.addAttribute("total", total);
        model.addAttribute("pageMaker", new PageDTO(cri, total));
        model.addAttribute("dbList", piiDatabaseService.getList());
        return "accesslog/sources";
    }

    @GetMapping("/settings")
    public String settings(Model model) {
        List<AccessLogConfigVO> allConfigs = accessLogService.getConfigList();
        // configType별 그룹핑
        Map<String, List<AccessLogConfigVO>> grouped = new java.util.LinkedHashMap<>();
        // 표시 순서 정의
        String[] typeOrder = {"GENERAL", "COLLECT", "AOP", "ALERT", "RETENTION", "ARCHIVE"};
        for (String t : typeOrder) {
            grouped.put(t, new java.util.ArrayList<>());
        }
        for (AccessLogConfigVO c : allConfigs) {
            String type = c.getConfigType() != null ? c.getConfigType() : "GENERAL";
            grouped.computeIfAbsent(type, k -> new java.util.ArrayList<>()).add(c);
        }
        // 빈 그룹 제거
        grouped.entrySet().removeIf(e -> e.getValue().isEmpty());
        model.addAttribute("configGroups", grouped);
        return "accesslog/settings";
    }

    @GetMapping("/alert-rules")
    public String alertRules(Model model) {
        model.addAttribute("alertRules", accessLogService.getAlertRuleList());
        return "accesslog/alert-rules";
    }

    @GetMapping("/hash-verify")
    public String hashVerify() {
        return "accesslog/hash-verify";
    }

    // ========== REST APIs ==========

    // --- Dashboard ---
    @GetMapping("/api/dashboard-stats")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getDashboardStats(@RequestParam(required = false) String sourceId) {
        Map<String, Object> result = new HashMap<>();
        result.put("stats", accessLogService.getDashboardStats(sourceId));
        String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        result.put("charts", accessLogService.getDashboardChartData(today));
        result.put("latestAlerts", accessLogService.getLatestAlerts(5));
        return ResponseEntity.ok(result);
    }

    // --- Alert Count (실시간 배지) ---
    @GetMapping("/api/alert-count")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getAlertCount() {
        Map<String, Object> result = new HashMap<>();
        result.put("count", accessLogService.getNewAlertCount());
        return ResponseEntity.ok(result);
    }

    // --- Access Log ---
    @GetMapping("/api/logs")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getLogList(@ModelAttribute Criteria cri) {
        Map<String, Object> result = new HashMap<>();

        // 날짜 범위 필수 검증 (search7=FROM, search8=TO)
        if (cri.getSearch7() == null || cri.getSearch7().isEmpty()
                || cri.getSearch8() == null || cri.getSearch8().isEmpty()) {
            result.put("list", java.util.Collections.emptyList());
            result.put("total", 0);
            result.put("pageMaker", new PageDTO(cri, 0));
            return ResponseEntity.ok(result);
        }

        int total = accessLogService.getAccessLogTotal(cri);
        result.put("list", accessLogService.getAccessLogList(cri));
        result.put("total", total);
        result.put("pageMaker", new PageDTO(cri, total));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/api/logs/{logId}")
    @ResponseBody
    public ResponseEntity<AccessLogVO> getLog(@PathVariable Long logId) {
        return ResponseEntity.ok(accessLogService.getAccessLog(logId));
    }

    /** 동일 req_id 의 HTTP_ACCESS 1건 + SQL N건 — 처리계 SDK 요청 드릴다운. */
    @GetMapping("/api/logs/by-req/{reqId}")
    @ResponseBody
    public ResponseEntity<List<AccessLogVO>> getLogsByReqId(@PathVariable String reqId) {
        return ResponseEntity.ok(accessLogService.getAccessLogByReqId(reqId));
    }

    // --- 연계 DB 목록 ---
    @GetMapping("/api/databases")
    @ResponseBody
    public ResponseEntity<List<PiiDatabaseVO>> getDatabaseList() {
        return ResponseEntity.ok(piiDatabaseService.getList());
    }

    // --- Source CRUD ---
    @PostMapping("/api/source")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> registerSource(@RequestBody AccessLogSourceVO source, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            source.setRegUserId(principal != null ? principal.getName() : "system");
            accessLogService.registerSource(source);
            result.put("success", true);
            result.put("message", "수집 대상이 등록되었습니다.");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    @PutMapping("/api/source/{sourceId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> modifySource(@PathVariable String sourceId,
                                                             @RequestBody AccessLogSourceVO source, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        source.setSourceId(sourceId);
        source.setUpdUserId(principal != null ? principal.getName() : "system");
        result.put("success", accessLogService.modifySource(source));
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/api/source/{sourceId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> removeSource(@PathVariable String sourceId) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", accessLogService.removeSource(sourceId));
        return ResponseEntity.ok(result);
    }

    // --- Batch Operations ---
    @SuppressWarnings("unchecked")
    @PostMapping("/api/source/batch-start")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> batchStartCollection(@RequestBody Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        List<String> sourceIds = (List<String>) body.get("sourceIds");
        if (sourceIds == null || sourceIds.isEmpty()) {
            result.put("success", false);
            result.put("message", "선택된 대상이 없습니다.");
            return ResponseEntity.ok(result);
        }
        int successCount = 0;
        for (String sourceId : sourceIds) {
            try {
                AccessLogSourceVO source = accessLogService.getSource(sourceId);
                if (source != null) {
                    accessLogCollector.startCollection(sourceId);
                    accessLogCollector.collect(source);
                    successCount++;
                }
            } catch (Exception e) {
                logger.warn("Batch start failed for source {}: {}", sourceId, e.getMessage());
            }
        }
        result.put("success", true);
        result.put("message", successCount + "건 수집이 시작되었습니다.");
        return ResponseEntity.ok(result);
    }

    @SuppressWarnings("unchecked")
    @PostMapping("/api/source/batch-stop")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> batchStopCollection(@RequestBody Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        List<String> sourceIds = (List<String>) body.get("sourceIds");
        if (sourceIds == null || sourceIds.isEmpty()) {
            result.put("success", false);
            result.put("message", "선택된 대상이 없습니다.");
            return ResponseEntity.ok(result);
        }
        for (String sourceId : sourceIds) {
            accessLogCollector.stopCollection(sourceId);
        }
        result.put("success", true);
        result.put("message", sourceIds.size() + "건 수집이 중지되었습니다.");
        return ResponseEntity.ok(result);
    }

    @SuppressWarnings("unchecked")
    @PostMapping("/api/source/batch-delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> batchDeleteSources(@RequestBody Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        List<String> sourceIds = (List<String>) body.get("sourceIds");
        if (sourceIds == null || sourceIds.isEmpty()) {
            result.put("success", false);
            result.put("message", "선택된 대상이 없습니다.");
            return ResponseEntity.ok(result);
        }
        int deleted = 0;
        for (String sourceId : sourceIds) {
            if (accessLogService.removeSource(sourceId)) deleted++;
        }
        result.put("success", true);
        result.put("message", deleted + "건이 삭제되었습니다.");
        return ResponseEntity.ok(result);
    }

    @PostMapping("/api/source/test-connection")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> testConnection(@RequestBody Map<String, String> body) {
        Map<String, Object> result = new HashMap<>();
        String dbName = body.get("dbName");
        String hostname = body.get("hostname");
        String port = body.get("port");
        String dbType = body.get("dbType");
        try {
            // 간단한 JDBC 연결 테스트
            String jdbcUrl;
            if ("ORACLE".equalsIgnoreCase(dbType)) {
                jdbcUrl = "jdbc:oracle:thin:@" + hostname + ":" + port + ":ORCL";
            } else if ("MSSQL".equalsIgnoreCase(dbType)) {
                jdbcUrl = "jdbc:sqlserver://" + hostname + ":" + port;
            } else {
                jdbcUrl = "jdbc:mysql://" + hostname + ":" + port + "/" + (dbName != null ? dbName : "");
            }
            java.sql.Connection conn = null;
            try {
                conn = java.sql.DriverManager.getConnection(jdbcUrl, "test", "test");
                result.put("success", true);
                result.put("message", "연결 성공");
            } catch (java.sql.SQLException e) {
                // 인증 실패도 네트워크 연결은 된 것으로 판단
                String msg = e.getMessage();
                if (msg != null && (msg.contains("Access denied") || msg.contains("password") || msg.contains("authentication"))) {
                    result.put("success", true);
                    result.put("message", "네트워크 연결 확인 (인증 정보 별도 설정 필요)");
                } else {
                    result.put("success", false);
                    result.put("message", "연결 실패: " + msg);
                }
            } finally {
                if (conn != null) try { conn.close(); } catch (Exception ignored) {}
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "연결 테스트 오류: " + e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    // --- Collection Control ---
    @PostMapping("/api/collection/{sourceId}/start")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> startCollection(@PathVariable String sourceId) {
        Map<String, Object> result = new HashMap<>();
        try {
            AccessLogSourceVO source = accessLogService.getSource(sourceId);
            if (source == null) {
                result.put("success", false);
                result.put("message", "수집 대상을 찾을 수 없습니다.");
                return ResponseEntity.ok(result);
            }
            accessLogCollector.startCollection(sourceId);
            int collected = accessLogCollector.collect(source);
            result.put("success", true);
            result.put("collected", collected);
            result.put("message", collected + "건 수집 완료");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    @PostMapping("/api/collection/{sourceId}/stop")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> stopCollection(@PathVariable String sourceId) {
        Map<String, Object> result = new HashMap<>();
        accessLogCollector.stopCollection(sourceId);
        result.put("success", true);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/api/collection/{sourceId}/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getCollectionStatus(@PathVariable String sourceId) {
        Map<String, Object> result = new HashMap<>();
        result.put("collecting", accessLogCollector.isCollecting(sourceId));
        result.put("source", accessLogService.getSource(sourceId));
        return ResponseEntity.ok(result);
    }

    // --- Alert ---
    @PostMapping("/api/alert/{alertId}/resolve")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> resolveAlert(@PathVariable Long alertId,
                                                             @RequestBody Map<String, String> body,
                                                             Principal principal) {
        Map<String, Object> result = new HashMap<>();
        String status = body.getOrDefault("status", "RESOLVED");
        String comment = body.get("comment");
        String userId = principal != null ? principal.getName() : "system";
        result.put("success", accessLogService.updateAlertStatus(alertId, status, userId, comment));
        return ResponseEntity.ok(result);
    }

    @SuppressWarnings("unchecked")
    @PostMapping("/api/alert/bulk-dismiss")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> bulkDismissAlerts(@RequestBody Map<String, Object> body,
                                                                  Principal principal) {
        Map<String, Object> result = new HashMap<>();
        List<Integer> rawIds = (List<Integer>) body.get("alertIds");
        if (rawIds == null || rawIds.isEmpty()) {
            result.put("success", false);
            result.put("message", "선택된 알림이 없습니다.");
            return ResponseEntity.ok(result);
        }
        List<Long> alertIds = rawIds.stream().map(Integer::longValue).collect(java.util.stream.Collectors.toList());
        String comment = (String) body.getOrDefault("comment", "");
        String userId = principal != null ? principal.getName() : "system";
        int updated = accessLogService.bulkDismissAlerts(alertIds, userId, comment);
        result.put("success", true);
        result.put("updated", updated);
        result.put("message", updated + "건이 무시 처리되었습니다.");
        return ResponseEntity.ok(result);
    }

    @SuppressWarnings("unchecked")
    @PostMapping("/api/alert/bulk-approve")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> bulkApproveAlerts(@RequestBody Map<String, Object> body,
                                                                   Principal principal) {
        Map<String, Object> result = new HashMap<>();
        List<Integer> rawIds = (List<Integer>) body.get("alertIds");
        if (rawIds == null || rawIds.isEmpty()) {
            result.put("success", false);
            result.put("message", "선택된 알림이 없습니다.");
            return ResponseEntity.ok(result);
        }
        List<Long> alertIds = rawIds.stream().map(Integer::longValue).collect(java.util.stream.Collectors.toList());
        String comment = (String) body.getOrDefault("comment", "");
        String approverId = principal != null ? principal.getName() : "system";
        int updated = accessLogService.bulkApproveAlerts(alertIds, approverId, comment);
        result.put("success", true);
        result.put("updated", updated);
        result.put("message", updated + "건이 승인 처리되었습니다.");
        return ResponseEntity.ok(result);
    }

    /**
     * 무시 처리 + 예외 등록 통합 API
     * 규칙+사용자 조합 목록에 대해: DB 전체의 미처리 알림 일괄 무시 + 예외 규칙 등록/연장
     */
    @SuppressWarnings("unchecked")
    @PostMapping("/api/alert/dismiss-with-suppression")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> dismissWithSuppression(@RequestBody Map<String, Object> body,
                                                                       Principal principal) {
        Map<String, Object> result = new HashMap<>();
        String userId = principal != null ? principal.getName() : "system";
        String comment = (String) body.getOrDefault("comment", "");

        // 1) 지정된 alertIds가 있으면 먼저 무시 처리
        List<Integer> rawIds = (List<Integer>) body.get("alertIds");
        int dismissed = 0;
        if (rawIds != null && !rawIds.isEmpty()) {
            List<Long> alertIds = rawIds.stream().map(Integer::longValue).collect(java.util.stream.Collectors.toList());
            dismissed = accessLogService.bulkDismissAlerts(alertIds, userId, comment);
        }

        // 2) combos별로: DB 전체 같은 규칙+사용자 미처리 알림 무시 + 예외 등록
        List<Map<String, Object>> combos = (List<Map<String, Object>>) body.get("combos");
        List<Map<String, Object>> suppressionResults = new java.util.ArrayList<>();
        if (combos != null) {
            for (Map<String, Object> combo : combos) {
                String ruleId = (String) combo.get("ruleId");
                String ruleCode = (String) combo.get("ruleCode");
                String targetUserId = (String) combo.get("targetUserId");
                String severity = (String) combo.get("severity");
                String effectiveUntil = (String) combo.get("effectiveUntil");
                Integer reviewCycleDays = combo.get("reviewCycleDays") != null
                        ? ((Number) combo.get("reviewCycleDays")).intValue() : 90;

                // 2a) DB 전체에서 같은 규칙+사용자 미처리 알림 무시
                int extra = accessLogService.dismissByRuleAndUser(ruleId, targetUserId, userId, comment);
                dismissed += extra;

                // 2b) 예외 등록/연장
                AlertSuppressionVO suppression = new AlertSuppressionVO();
                suppression.setRuleId(ruleId);
                suppression.setRuleCode(ruleCode);
                suppression.setTargetUserId(targetUserId);
                suppression.setSuppressionType("SUPPRESS");
                suppression.setReason(comment);
                suppression.setSeverityAtTime(severity);
                suppression.setEffectiveUntil(effectiveUntil);
                suppression.setReviewCycleDays(reviewCycleDays);
                suppression.setApprovedBy(userId);
                suppression.setRegUserId(userId);

                Map<String, Object> regResult = accessLogService.registerOrExtendSuppression(suppression, userId);
                regResult.put("ruleCode", ruleCode);
                regResult.put("targetUserId", targetUserId);
                suppressionResults.add(regResult);
            }
        }

        result.put("success", true);
        result.put("dismissed", dismissed);
        result.put("suppressions", suppressionResults);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/api/alert/{alertId}/detail")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getAlertDetail(@PathVariable Long alertId) {
        Map<String, Object> result = new HashMap<>();
        AccessLogAlertVO alert = accessLogService.getAlert(alertId);
        result.put("alert", alert);
        // TBL_MEMBER에서 이메일 조회
        if (alert != null && alert.getTargetUserId() != null) {
            result.put("memberInfo", accessLogService.getMemberEmail(alert.getTargetUserId()));
        }
        return ResponseEntity.ok(result);
    }

    // --- Justification Workflow (관리자) ---
    @PostMapping("/api/alert/{alertId}/notify")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> sendJustificationRequest(@PathVariable Long alertId,
                                                                         @RequestBody Map<String, String> body,
                                                                         HttpServletRequest request,
                                                                         Principal principal) {
        Map<String, Object> result = new HashMap<>();
        String targetEmail = body.get("targetEmail");
        if (targetEmail == null || targetEmail.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "대상자 이메일을 입력하세요.");
            return ResponseEntity.ok(result);
        }
        String baseUrl = request.getScheme() + "://" + request.getServerName()
                + (request.getServerPort() != 80 && request.getServerPort() != 443 ? ":" + request.getServerPort() : "");
        String requesterId = principal != null ? principal.getName() : "system";
        boolean sent = accessLogService.sendJustificationRequest(alertId, targetEmail.trim(), baseUrl, requesterId);
        result.put("success", sent);
        result.put("message", sent ? "소명 요청 이메일이 발송되었습니다." : "발송에 실패했습니다.");
        return ResponseEntity.ok(result);
    }

    @PostMapping("/api/alert/{alertId}/approve")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> approveAlert(@PathVariable Long alertId,
                                                              @RequestBody Map<String, String> body,
                                                              Principal principal) {
        Map<String, Object> result = new HashMap<>();
        String comment = body.get("comment");
        String approverId = principal != null ? principal.getName() : "system";
        result.put("success", accessLogService.approveAlert(alertId, approverId, comment));
        return ResponseEntity.ok(result);
    }

    @PostMapping("/api/alert/{alertId}/reject")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> rejectAlert(@PathVariable Long alertId,
                                                             @RequestBody Map<String, String> body,
                                                             HttpServletRequest request,
                                                             Principal principal) {
        Map<String, Object> result = new HashMap<>();
        String comment = body.get("comment");
        String approverId = principal != null ? principal.getName() : "system";
        String baseUrl = request.getScheme() + "://" + request.getServerName()
                + (request.getServerPort() != 80 && request.getServerPort() != 443 ? ":" + request.getServerPort() : "");
        result.put("success", accessLogService.rejectAlert(alertId, approverId, comment, baseUrl));
        return ResponseEntity.ok(result);
    }

    // --- Justification Page (대상자용, 로그인 불필요) ---
    @GetMapping("/justify/{token}")
    public String justifyPage(@PathVariable String token, Model model) {
        AccessLogAlertVO alert = accessLogService.getAlertByToken(token);
        if (alert == null) {
            model.addAttribute("error", "유효하지 않은 링크입니다.");
            return "accesslog/justify";
        }
        // 토큰 만료 체크
        if (alert.getTokenExpiresAt() != null) {
            try {
                java.time.LocalDateTime expires = java.time.LocalDateTime.parse(alert.getTokenExpiresAt(),
                        java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                if (java.time.LocalDateTime.now().isAfter(expires)) {
                    model.addAttribute("error", "링크가 만료되었습니다. 관리자에게 문의하세요.");
                    return "accesslog/justify";
                }
            } catch (Exception e) { /* parse fail - allow access */ }
        }
        // 이미 소명 제출된 경우
        if ("JUSTIFIED".equals(alert.getStatus()) || "RESOLVED".equals(alert.getStatus())) {
            model.addAttribute("error", "이미 소명이 제출되었습니다.");
            return "accesslog/justify";
        }
        model.addAttribute("alert", alert);
        model.addAttribute("token", token);
        return "accesslog/justify";
    }

    @PostMapping("/justify/{token}/submit")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> submitJustification(@PathVariable String token,
                                                                     @RequestBody Map<String, String> body) {
        Map<String, Object> result = new HashMap<>();
        String justification = body.get("justification");
        String justifiedBy = body.get("justifiedBy");
        if (justification == null || justification.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "소명 사유를 입력하세요.");
            return ResponseEntity.ok(result);
        }
        if (justifiedBy == null || justifiedBy.trim().isEmpty()) {
            justifiedBy = "대상자";
        }
        boolean ok = accessLogService.submitJustification(token, justification.trim(), justifiedBy.trim());
        result.put("success", ok);
        result.put("message", ok ? "소명이 제출되었습니다." : "소명 제출에 실패했습니다. 링크가 만료되었거나 이미 처리되었습니다.");
        return ResponseEntity.ok(result);
    }

    // --- Alert Rule ---
    @PostMapping("/api/alert-rule")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> registerAlertRule(@RequestBody AccessLogAlertRuleVO rule, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        rule.setRegUserId(principal != null ? principal.getName() : "system");
        accessLogService.registerAlertRule(rule);
        result.put("success", true);
        return ResponseEntity.ok(result);
    }

    @PutMapping("/api/alert-rule/{ruleId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> modifyAlertRule(@PathVariable String ruleId,
                                                                @RequestBody AccessLogAlertRuleVO rule, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        rule.setRuleId(ruleId);
        rule.setUpdUserId(principal != null ? principal.getName() : "system");
        result.put("success", accessLogService.modifyAlertRule(rule));
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/api/alert-rule/{ruleId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> removeAlertRule(@PathVariable String ruleId) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", accessLogService.removeAlertRule(ruleId));
        return ResponseEntity.ok(result);
    }

    // --- Config ---
    @GetMapping("/api/configs")
    @ResponseBody
    public ResponseEntity<List<AccessLogConfigVO>> getConfigList(@RequestParam(required = false) String configType) {
        if (configType != null && !configType.isEmpty()) {
            return ResponseEntity.ok(accessLogService.getConfigListByType(configType));
        }
        return ResponseEntity.ok(accessLogService.getConfigList());
    }

    @PutMapping("/api/config/{configId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> modifyConfig(@PathVariable String configId,
                                                             @RequestBody AccessLogConfigVO config, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        config.setConfigId(configId);
        config.setUpdUserId(principal != null ? principal.getName() : "system");
        boolean success = accessLogService.modifyConfig(config);
        result.put("success", success);
        // 스케줄 설정 변경 시 동적 반영
        if (success) {
            try {
                AccessLogConfigVO saved = accessLogService.getConfigByKey("HASH_VERIFY_SCHEDULE");
                if (saved != null && saved.getConfigId().equals(configId)) {
                    hashVerifyScheduler.reschedule();
                }
            } catch (Exception e) {
                logger.warn("Failed to reschedule hash verify", e);
            }
        }
        return ResponseEntity.ok(result);
    }

    // --- Hash Verify ---
    @PostMapping("/api/hash-verify")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> verifyHashChain(@RequestBody Map<String, String> body) {
        String date = body.get("date");
        if (date == null) {
            date = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        }
        return ResponseEntity.ok(accessLogService.verifyHashChain(date));
    }

    @GetMapping("/api/hash-verify")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getHashVerifyList(@ModelAttribute Criteria cri) {
        return ResponseEntity.ok(accessLogService.getHashVerifyList(cri));
    }

    @GetMapping("/api/hash-verify/monthly")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getHashVerifyMonthlySummary() {
        return ResponseEntity.ok(accessLogService.getHashVerifyMonthlySummary());
    }

    @GetMapping("/api/hash-verify/month/{yearMonth}")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getHashVerifyByMonth(@PathVariable String yearMonth) {
        return ResponseEntity.ok(accessLogService.getHashVerifyByMonth(yearMonth));
    }

    // --- Alert Suppression (알림 예외 규칙) ---
    @GetMapping("/suppressions")
    public String suppressions(@ModelAttribute Criteria cri, Model model) {
        List<AlertSuppressionVO> list = accessLogService.getSuppressionList(cri);
        int total = accessLogService.getSuppressionTotal(cri);
        model.addAttribute("list", list);
        model.addAttribute("total", total);
        model.addAttribute("pageMaker", new PageDTO(cri, total));
        model.addAttribute("ruleList", accessLogService.getAlertRuleList());
        return "accesslog/suppressions";
    }

    @PostMapping("/api/suppression")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> registerSuppression(@RequestBody AlertSuppressionVO suppression,
                                                                     Principal principal) {
        Map<String, Object> result = new HashMap<>();
        String userId = principal != null ? principal.getName() : "system";
        suppression.setApprovedBy(userId);
        suppression.setRegUserId(userId);
        if (suppression.getReviewCycleDays() <= 0) suppression.setReviewCycleDays(90);
        // 중복 체크: 기존 활성 건이 있으면 연장, 없으면 신규 등록
        Map<String, Object> regResult = accessLogService.registerOrExtendSuppression(suppression, userId);
        result.put("success", true);
        result.put("action", regResult.get("action"));           // CREATED or EXTENDED
        result.put("suppressionId", regResult.get("suppressionId"));
        if ("EXTENDED".equals(regResult.get("action"))) {
            result.put("message", "이미 동일 조건의 예외 규칙이 있어 유효기간이 연장되었습니다.");
            result.put("existingUntil", regResult.get("existingUntil"));
        } else {
            result.put("message", "알림 예외 규칙이 등록되었습니다.");
        }
        return ResponseEntity.ok(result);
    }

    /** 특정 규칙+사용자의 활성 예외 존재 여부 확인 */
    @GetMapping("/api/suppression/check")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkActiveSuppression(
            @RequestParam String ruleId, @RequestParam String targetUserId) {
        Map<String, Object> result = new HashMap<>();
        AlertSuppressionVO existing = accessLogService.getActiveSuppression(ruleId, targetUserId);
        result.put("exists", existing != null);
        if (existing != null) {
            result.put("suppressionId", existing.getSuppressionId());
            result.put("effectiveUntil", existing.getEffectiveUntil());
            result.put("reason", existing.getReason());
        }
        return ResponseEntity.ok(result);
    }

    @GetMapping("/api/suppression/{suppressionId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getSuppressionDetail(@PathVariable Long suppressionId) {
        Map<String, Object> result = new HashMap<>();
        result.put("suppression", accessLogService.getSuppression(suppressionId));
        result.put("auditLog", accessLogService.getSuppressionAuditList(suppressionId));
        return ResponseEntity.ok(result);
    }

    @PostMapping("/api/suppression/{suppressionId}/review")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> reviewSuppression(@PathVariable Long suppressionId,
                                                                    @RequestBody Map<String, String> body,
                                                                    Principal principal) {
        Map<String, Object> result = new HashMap<>();
        String reviewedBy = principal != null ? principal.getName() : "system";
        String comment = body.get("comment");
        result.put("success", accessLogService.reviewSuppression(suppressionId, reviewedBy, comment));
        return ResponseEntity.ok(result);
    }

    @PostMapping("/api/suppression/{suppressionId}/deactivate")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deactivateSuppression(@PathVariable Long suppressionId,
                                                                       @RequestBody Map<String, String> body,
                                                                       Principal principal) {
        Map<String, Object> result = new HashMap<>();
        String userId = principal != null ? principal.getName() : "system";
        String reason = body.getOrDefault("reason", "관리자 비활성화");
        result.put("success", accessLogService.deactivateSuppression(suppressionId, userId, reason));
        return ResponseEntity.ok(result);
    }

    @PostMapping("/api/suppression/{suppressionId}/extend")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> extendSuppression(@PathVariable Long suppressionId,
                                                                    @RequestBody Map<String, String> body,
                                                                    Principal principal) {
        Map<String, Object> result = new HashMap<>();
        String userId = principal != null ? principal.getName() : "system";
        String effectiveUntil = body.get("effectiveUntil");
        result.put("success", accessLogService.extendSuppression(suppressionId, effectiveUntil, userId));
        return ResponseEntity.ok(result);
    }

    // --- Download (Excel Export) ---
    @PostMapping("/api/logs/download")
    public void downloadLogs(@ModelAttribute Criteria cri,
                             @RequestParam String reason,
                             Principal principal,
                             HttpServletRequest request,
                             HttpServletResponse response) throws IOException {
        String userId = principal != null ? principal.getName() : "system";
        List<AccessLogVO> list = accessLogService.getAccessLogList(cri);

        // 다운로드 감사 기록
        accessLogService.recordDownload(userId, userId, cri.toString(),
                list.size(), "XLSX", reason, request.getRemoteAddr());

        // Excel 생성
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=access_log_" +
                new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()) + ".xlsx");

        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("접속기록");

            // Header
            Row headerRow = sheet.createRow(0);
            String[] headers = {"No", "접속일시", "사용자", "접속IP", "작업유형", "대상DB", "대상테이블", "PII등급", "결과"};
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // Data
            int rowNum = 1;
            for (AccessLogVO log : list) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(rowNum - 1);
                row.createCell(1).setCellValue(log.getAccessTime() != null ? log.getAccessTime() : "");
                row.createCell(2).setCellValue(log.getUserAccount() != null ? log.getUserAccount() : "");
                row.createCell(3).setCellValue(log.getClientIp() != null ? log.getClientIp() : "");
                row.createCell(4).setCellValue(log.getActionType() != null ? log.getActionType() : "");
                row.createCell(5).setCellValue(log.getTargetDb() != null ? log.getTargetDb() : "");
                row.createCell(6).setCellValue(log.getTargetTable() != null ? log.getTargetTable() : "");
                row.createCell(7).setCellValue(log.getPiiGrade() != null ? log.getPiiGrade() : "");
                row.createCell(8).setCellValue(log.getResultCode() != null ? log.getResultCode() : "");
            }

            workbook.write(response.getOutputStream());
        }
    }

    // ========== Audit Policy Script Generation ==========

    /**
     * 설정 프로세스 상태 확인 API
     * MetaTable 마스터 기반으로 PII 테이블 목록 반환
     */
    @GetMapping("/api/setup/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getSetupStatus(@RequestParam String dbName) {
        Map<String, Object> result = new HashMap<>();
        try {
            // 1단계: DB 등록 여부
            PiiDatabaseVO dbInfo = piiDatabaseService.get(dbName);
            result.put("dbRegistered", dbInfo != null);
            result.put("dbType", dbInfo != null ? dbInfo.getDbtype() : null);

            // 2단계: MetaTable에서 PII 테이블 목록 (piitype이 있고 notpii가 아닌 것)
            List<Map<String, Object>> piiTables = accessLogMapper.selectMetaPiiTables(dbName);
            result.put("piiTableCount", piiTables != null ? piiTables.size() : 0);
            result.put("piiTables", piiTables);

            // BCI 대상 테이블 목록
            List<BciTargetVO> bciTargets = accessLogMapper.selectBciTargets(dbName);
            result.put("bciTargetCount", bciTargets != null ? bciTargets.size() : 0);
            result.put("bciTargets", bciTargets);

            // 전체 테이블 목록 (BCI용, PII+비PII)
            List<Map<String, Object>> allTables = accessLogMapper.selectAllTablesForBci(dbName);
            result.put("allTableCount", allTables != null ? allTables.size() : 0);
            result.put("allTables", allTables);

            // 수집 대상 등록 여부
            AccessLogSourceVO source = accessLogService.getSourceByDbName(dbName);
            result.put("sourceRegistered", source != null);
            result.put("sourceStatus", source != null ? source.getStatus() : null);

            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    /**
     * Audit 대상 테이블 개별 저장 (체크박스 변경 시 즉시 호출)
     */
    @PostMapping("/api/audit-policy/save")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveAuditTarget(@RequestBody Map<String, String> body) {
        Map<String, Object> result = new HashMap<>();
        accessLogMapper.updateAuditTarget(body.get("dbName"), body.get("owner"), body.get("tableName"), body.get("auditYn"));
        result.put("success", true);
        return ResponseEntity.ok(result);
    }

    /**
     * Audit 대상 테이블 일괄 저장 (전체 선택/해제 시)
     */
    @PostMapping("/api/audit-policy/save-batch")
    @ResponseBody
    @SuppressWarnings("unchecked")
    public ResponseEntity<Map<String, Object>> saveAuditTargetBatch(@RequestBody Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        String dbName = (String) body.get("dbName");
        String auditYn = (String) body.get("auditYn");
        List<Map<String, String>> tables = (List<Map<String, String>>) body.get("tables");
        for (Map<String, String> t : tables) {
            accessLogMapper.updateAuditTarget(dbName, t.get("owner"), t.get("tableName"), auditYn);
        }
        result.put("success", true);
        result.put("count", tables.size());
        return ResponseEntity.ok(result);
    }

    /**
     * Oracle Audit Policy 스크립트 생성 API
     * 사용자가 선택한 테이블 목록 기반으로 스크립트 생성
     */
    @PostMapping("/api/audit-policy/script")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> generateAuditPolicyScript(@RequestBody Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        try {
            String dbName = (String) body.get("dbName");
            @SuppressWarnings("unchecked")
            List<Map<String, String>> selectedTables = (List<Map<String, String>>) body.get("tables");

            PiiDatabaseVO dbInfo = piiDatabaseService.get(dbName);
            if (dbInfo == null) {
                result.put("success", false);
                result.put("message", "등록된 DB를 찾을 수 없습니다: " + dbName);
                return ResponseEntity.ok(result);
            }

            if (selectedTables == null || selectedTables.isEmpty()) {
                result.put("success", false);
                result.put("message", "Audit 대상 테이블을 선택하세요.");
                return ResponseEntity.ok(result);
            }

            String script = buildAuditPolicyScript(dbInfo, selectedTables);
            result.put("success", true);
            result.put("script", script);
            result.put("dbName", dbName);
            result.put("dbType", dbInfo.getDbtype());
            result.put("tableCount", selectedTables.size());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    /**
     * Audit Policy + 자동 정리 통합 스크립트 생성
     */
    private String buildAuditPolicyScript(PiiDatabaseVO dbInfo, List<Map<String, String>> tables) {
        StringBuilder sb = new StringBuilder();
        String dbType = dbInfo.getDbtype();
        String now = new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date());

        sb.append("-- ============================================================\n");
        sb.append("-- DLM 감사 정책 스크립트 (자동 생성: ").append(now).append(")\n");
        sb.append("-- DB: ").append(dbInfo.getDb()).append(" (").append(dbType).append(")\n");
        sb.append("-- 대상: 선택된 PII 테이블 ").append(tables.size()).append("개\n");
        sb.append("-- ============================================================\n\n");

        if ("ORACLE".equalsIgnoreCase(dbType)) {
            buildOracleAuditScript(sb, tables);
        } else if ("MARIADB".equalsIgnoreCase(dbType) || "MYSQL".equalsIgnoreCase(dbType)) {
            buildMariaDbAuditScript(sb, dbInfo, tables);
        }

        return sb.toString();
    }

    private void buildOracleAuditScript(StringBuilder sb, List<Map<String, String>> tables) {
        sb.append("-- [1단계] 기존 DLM 감사 정책 제거\n");
        sb.append("-- (정책이 없으면 오류 발생하므로 무시하세요)\n");
        sb.append("NOAUDIT POLICY XAUDIT_PII_POLICY;\n");
        sb.append("DROP AUDIT POLICY XAUDIT_PII_POLICY;\n\n");

        sb.append("-- [2단계] PII 테이블 대상 감사 정책 생성\n");
        sb.append("CREATE AUDIT POLICY XAUDIT_PII_POLICY\n");
        sb.append("  ACTIONS\n");

        boolean first = true;
        for (Map<String, String> table : tables) {
            String schema = table.get("owner");
            String tableName = table.get("tableName");
            String piiCols = table.get("piiColumns");

            String fullName = (schema != null && !schema.isEmpty())
                    ? schema + "." + tableName : tableName;

            sb.append("    -- PII 컬럼: ").append(piiCols != null ? piiCols : "").append("\n");
            String[] actions = {"SELECT", "INSERT", "UPDATE", "DELETE"};
            for (String action : actions) {
                if (!first) sb.append(",\n");
                sb.append("    ").append(action).append(" ON ").append(fullName);
                first = false;
            }
            sb.append("\n");
        }
        sb.append(";\n\n");

        sb.append("-- [3단계] 감사 정책 활성화 (전체 사용자 대상)\n");
        sb.append("AUDIT POLICY XAUDIT_PII_POLICY;\n\n");

        sb.append("-- [4단계] 기존 감사 로그 정리 (선택사항 - 용량 확보)\n");
        sb.append("-- 주의: 실행 시 기존 감사 기록이 모두 삭제됩니다.\n");
        sb.append("-- BEGIN\n");
        sb.append("--   DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(\n");
        sb.append("--     audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,\n");
        sb.append("--     use_last_arch_timestamp => FALSE\n");
        sb.append("--   );\n");
        sb.append("-- END;\n");
        sb.append("-- /\n\n");

        sb.append("-- [5단계] 감사 로그 자동 정리 (권장 - 30일 보존)\n");
        sb.append("BEGIN\n");
        sb.append("  DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(\n");
        sb.append("    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,\n");
        sb.append("    audit_trail_purge_interval => 24,\n");
        sb.append("    audit_trail_purge_name     => 'XAUDIT_PURGE',\n");
        sb.append("    use_last_arch_timestamp    => TRUE\n");
        sb.append("  );\n");
        sb.append("END;\n");
        sb.append("/\n\n");

        sb.append("-- [확인] 적용된 정책 확인\n");
        sb.append("SELECT POLICY_NAME, AUDIT_OPTION, OBJECT_SCHEMA, OBJECT_NAME\n");
        sb.append("FROM AUDIT_UNIFIED_POLICIES\n");
        sb.append("WHERE POLICY_NAME = 'XAUDIT_PII_POLICY';\n\n");
        sb.append("SELECT * FROM AUDIT_UNIFIED_ENABLED_POLICIES\n");
        sb.append("WHERE POLICY_NAME = 'XAUDIT_PII_POLICY';\n");
    }

    private void buildMariaDbAuditScript(StringBuilder sb, PiiDatabaseVO dbInfo, List<Map<String, String>> tables) {
        sb.append("-- MariaDB/MySQL: General Log 활성화\n");
        sb.append("-- 주의: General Log는 테이블 단위 필터링이 불가합니다.\n");
        sb.append("-- DLM 수집 대상 설정에서 아래 테이블 필터를 사용하세요.\n\n");
        sb.append("SET GLOBAL general_log = 'ON';\n");
        sb.append("SET GLOBAL log_output = 'TABLE';\n\n");
        sb.append("-- DLM 수집 대상 > 대상 테이블에 아래를 입력하세요:\n");
        StringBuilder tableList = new StringBuilder();
        for (Map<String, String> t : tables) {
            if (tableList.length() > 0) tableList.append(", ");
            tableList.append(t.get("tableName"));
        }
        sb.append("-- ").append(tableList).append("\n");
    }

    // ========== BCI Target API ==========

    /**
     * BCI 대상 일괄 저장 (기존 초기화 후 새 목록 등록)
     */
    @PostMapping("/api/bci-target/save")
    @ResponseBody
    @SuppressWarnings("unchecked")
    public ResponseEntity<Map<String, Object>> saveBciTargets(@RequestBody Map<String, Object> body, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            String dbName = (String) body.get("dbName");
            List<Map<String, String>> tables = (List<Map<String, String>>) body.get("tables");
            String userId = principal != null ? principal.getName() : "admin";

            // 기존 초기화
            accessLogMapper.clearBciTargets(dbName);

            // 새 목록 등록
            for (Map<String, String> t : tables) {
                BciTargetVO target = new BciTargetVO();
                target.setTargetId(java.util.UUID.randomUUID().toString());
                target.setDbName(dbName);
                target.setOwner(t.get("owner") != null ? t.get("owner") : "");
                target.setTableName(t.get("tableName"));
                target.setTargetType(t.get("targetType") != null ? t.get("targetType") : "PII");
                target.setDescription(t.get("description"));
                target.setRegUserId(userId);
                accessLogMapper.insertBciTarget(target);
            }

            result.put("success", true);
            result.put("count", tables.size());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    // ========== Report (보고서) ==========

    @GetMapping("/reports")
    public String reportsPage(Model model) {
        Criteria cri = new Criteria();
        cri.setAmount(20);
        List<AccessLogReportVO> list = reportService.getReportList(cri);
        int total = reportService.getReportTotal(cri);
        model.addAttribute("list", list);
        model.addAttribute("total", total);
        return "accesslog/reports";
    }

    @GetMapping("/api/report/list")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getReportList(@ModelAttribute Criteria cri) {
        Map<String, Object> result = new HashMap<>();
        try {
            List<AccessLogReportVO> list = reportService.getReportList(cri);
            int total = reportService.getReportTotal(cri);
            result.put("list", list);
            result.put("total", total);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    @PostMapping("/api/report/generate")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> generateReport(@RequestBody Map<String, String> params,
                                                               Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            String reportType = params.get("reportType");
            String dateFrom = params.get("dateFrom");
            String dateTo = params.get("dateTo");
            String format = params.getOrDefault("reportFormat", "XLSX");
            String userId = principal != null ? principal.getName() : "system";

            Long reportId = reportService.generateReport(reportType, dateFrom, dateTo, format, userId);
            AccessLogReportVO report = reportService.getReport(reportId);

            result.put("success", true);
            result.put("reportId", reportId);
            result.put("report", report);
        } catch (Exception e) {
            logger.error("Report generation failed", e);
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    @GetMapping("/api/report/{reportId}/download")
    public void downloadReport(@PathVariable Long reportId,
                               Principal principal,
                               HttpServletRequest request,
                               HttpServletResponse response) throws IOException {
        AccessLogReportVO report = reportService.getReport(reportId);
        if (report == null || !"COMPLETED".equals(report.getReportStatus())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "보고서를 찾을 수 없습니다.");
            return;
        }

        String userId = principal != null ? principal.getName() : "system";
        LogUtil.log("INFO", "Report download: id=" + reportId + ", user=" + userId);

        byte[] fileBytes = reportService.renderToExcel(reportId);

        String fileName = report.getReportName().replaceAll("[^가-힣a-zA-Z0-9()_ -]", "") + ".xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" + new String(fileName.getBytes("UTF-8"), "ISO-8859-1") + "\"");
        response.setContentLength(fileBytes.length);
        response.getOutputStream().write(fileBytes);
        response.getOutputStream().flush();
    }

    @GetMapping("/api/report/{reportId}/detail")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getReportDetail(@PathVariable Long reportId) {
        Map<String, Object> result = new HashMap<>();
        try {
            AccessLogReportVO report = reportService.getReport(reportId);
            if (report == null) {
                result.put("success", false);
                result.put("message", "보고서를 찾을 수 없습니다.");
            } else {
                result.put("success", true);
                result.put("report", report);
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/api/report/{reportId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteReport(@PathVariable Long reportId) {
        Map<String, Object> result = new HashMap<>();
        try {
            boolean deleted = reportService.deleteReport(reportId);
            result.put("success", deleted);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    // ========== AOP 수집 상태/제어 ==========
    @GetMapping("/api/aop-status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> aopStatus() {
        Map<String, Object> result = new HashMap<>();
        if (aopConfig == null) {
            result.put("available", false);
            return ResponseEntity.ok(result);
        }
        result.put("available", true);
        result.put("mode", aopConfig.getMode().name());
        result.put("minImportance", aopConfig.getMinImportance());
        result.put("recordParams", aopConfig.isRecordParams());
        result.put("recordReads", aopConfig.isRecordReads());
        result.put("paramMaxLen", aopConfig.getParamMaxLen());
        result.put("durationThresholdMs", aopConfig.getDurationThresholdMs());
        result.put("maskFields", aopConfig.getMaskFields());
        result.put("includePatterns", aopConfig.getIncludePatterns());
        result.put("excludePatterns", aopConfig.getExcludePatterns());
        result.put("droppedCount", aopConfig.getDroppedCount());
        result.put("lastLoadedMs", aopConfig.getLastLoadedMs());
        result.put("annotatedMethods", countAnnotatedMethods());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/api/aop-reload")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> aopReload() {
        Map<String, Object> result = new HashMap<>();
        if (aopConfig == null) {
            result.put("success", false);
            result.put("message", "AOP config not available");
            return ResponseEntity.ok(result);
        }
        aopConfig.reloadFromDb();
        result.put("success", true);
        result.put("mode", aopConfig.getMode().name());
        result.put("lastLoadedMs", aopConfig.getLastLoadedMs());
        return ResponseEntity.ok(result);
    }

    private int countAnnotatedMethods() {
        int count = 0;
        try {
            Map<String, Object> controllers = applicationContext.getBeansWithAnnotation(Controller.class);
            for (Object bean : controllers.values()) {
                Class<?> cls = org.springframework.aop.support.AopUtils.getTargetClass(bean);
                for (java.lang.reflect.Method m : cls.getDeclaredMethods()) {
                    if (m.isAnnotationPresent(LogAccess.class)) count++;
                }
            }
        } catch (Exception ignore) {}
        return count;
    }
}
