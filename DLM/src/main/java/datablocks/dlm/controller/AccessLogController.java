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

import datablocks.dlm.domain.*;
import datablocks.dlm.engine.AccessLogCollector;
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

    // ========== Page Controllers ==========

    @GetMapping("/index")
    public String index(Model model) {
        LogUtil.log("INFO", "AccessLog index page");
        // 대시보드 초기 데이터
        AccessLogStatVO stats = accessLogService.getDashboardStats(null);
        model.addAttribute("stats", stats);
        return "accesslog/index";
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        AccessLogStatVO stats = accessLogService.getDashboardStats(null);
        List<AccessLogAlertVO> latestAlerts = accessLogService.getLatestAlerts(5);
        Criteria cri = new Criteria();
        cri.setAmount(100);
        List<AccessLogSourceVO> sources = accessLogService.getSourceList(cri);
        model.addAttribute("stats", stats);
        model.addAttribute("latestAlerts", latestAlerts);
        model.addAttribute("sources", sources);
        return "accesslog/dashboard";
    }

    @GetMapping("/logs")
    public String logs(@ModelAttribute Criteria cri, Model model) {
        List<AccessLogVO> list = accessLogService.getAccessLogList(cri);
        int total = accessLogService.getAccessLogTotal(cri);
        model.addAttribute("list", list);
        model.addAttribute("total", total);
        model.addAttribute("pageMaker", new PageDTO(cri, total));
        return "accesslog/logs";
    }

    @GetMapping("/alerts")
    public String alerts(@ModelAttribute Criteria cri, Model model) {
        List<AccessLogAlertVO> list = accessLogService.getAlertList(cri);
        int total = accessLogService.getAlertTotal(cri);
        model.addAttribute("list", list);
        model.addAttribute("total", total);
        model.addAttribute("pageMaker", new PageDTO(cri, total));
        return "accesslog/alerts";
    }

    @GetMapping("/sources")
    public String sources(@ModelAttribute Criteria cri, Model model) {
        List<AccessLogSourceVO> list = accessLogService.getSourceList(cri);
        int total = accessLogService.getSourceTotal(cri);
        model.addAttribute("list", list);
        model.addAttribute("total", total);
        model.addAttribute("pageMaker", new PageDTO(cri, total));
        return "accesslog/sources";
    }

    @GetMapping("/settings")
    public String settings(Model model) {
        model.addAttribute("configs", accessLogService.getConfigList());
        model.addAttribute("alertRules", accessLogService.getAlertRuleList());
        return "accesslog/settings";
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
        result.put("list", accessLogService.getAccessLogList(cri));
        result.put("total", accessLogService.getAccessLogTotal(cri));
        result.put("pageMaker", new PageDTO(cri, accessLogService.getAccessLogTotal(cri)));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/api/logs/{logId}")
    @ResponseBody
    public ResponseEntity<AccessLogVO> getLog(@PathVariable Long logId) {
        return ResponseEntity.ok(accessLogService.getAccessLog(logId));
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
        result.put("success", accessLogService.modifyConfig(config));
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
}
