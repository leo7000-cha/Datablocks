package datablocks.dlm.controller;

import java.io.IOException;
import java.security.Principal;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

import datablocks.dlm.client.PrivacyAiClient;
import datablocks.dlm.domain.*;
import datablocks.dlm.engine.DiscoveryEngine;
import datablocks.dlm.service.DiscoveryService;
import datablocks.dlm.service.PiiDatabaseService;
import datablocks.dlm.util.LogUtil;

/**
 * PII Discovery Controller
 * 개인정보 자동탐지 모듈 컨트롤러
 */
@Controller
@RequestMapping("/piidiscovery/*")
public class PiiDiscoveryController {

    private static final Logger logger = LoggerFactory.getLogger(PiiDiscoveryController.class);

    @Autowired
    private DiscoveryService discoveryService;

    @Autowired
    private PiiDatabaseService databaseService;

    @Autowired
    private DiscoveryEngine discoveryEngine;

    @Autowired
    private PrivacyAiClient privacyAiClient;

    @Autowired
    private datablocks.dlm.service.LkPiiScrTypeService lkPiiScrTypeService;

    @Autowired
    private datablocks.dlm.service.MetaTableService metaTableService;

    // ========== Page Controllers ==========

    /**
     * Discovery 메인 페이지 (독립 레이아웃)
     */
    @GetMapping("/index")
    @PreAuthorize("isAuthenticated()")
    public String index(Model model) {
        LogUtil.log("INFO", "PiiDiscovery index page");
        // 통계는 JSP ready 시점에 /api/stats 로 AJAX 로드하므로 여기서는 호출하지 않음 (첫 진입 지연 개선)
        return "piidiscovery/index";
    }

    /**
     * Dashboard - 탐지 현황 대시보드
     */
    @GetMapping("/dashboard")
    @PreAuthorize("isAuthenticated()")
    public void dashboard(Criteria cri, Model model) {
        LogUtil.log("INFO", "PiiDiscovery dashboard");
        DiscoveryStatVO stats = discoveryService.getDashboardStats();
        model.addAttribute("stats", stats);

        // 최근 스캔 작업
        cri.setAmount(5);
        List<DiscoveryScanJobVO> recentScans = discoveryService.getScanJobList(cri);
        model.addAttribute("recentScans", recentScans);

        int total = discoveryService.getScanJobTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
    }

    /**
     * Scan Jobs - 스캔 작업 목록
     */
    @GetMapping("/jobs")
    @PreAuthorize("isAuthenticated()")
    public void jobs(Criteria cri, Model model) {
        LogUtil.log("INFO", "PiiDiscovery jobs list");
        List<DiscoveryScanJobVO> jobList = discoveryService.getScanJobList(cri);
        model.addAttribute("jobList", jobList);

        int total = discoveryService.getScanJobTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);

        // DB 목록 (필터용)
        List<PiiDatabaseVO> dbList = databaseService.getList();
        model.addAttribute("dbList", dbList);
    }

    /**
     * Results - 탐지 결과 목록
     */
    @GetMapping("/results")
    @PreAuthorize("isAuthenticated()")
    public void results(Criteria cri,
                        @RequestParam(required = false) String executionId,
                        Model model) {
        LogUtil.log("INFO", "PiiDiscovery results list, executionId=" + executionId);

        // executionId가 있으면 Criteria에 설정
        if (executionId != null && !executionId.isEmpty()) {
            cri.setExecutionId(executionId);
        }

        List<DiscoveryScanResultVO> resultList = discoveryService.getScanResultList(cri);
        model.addAttribute("resultList", resultList);

        int total = discoveryService.getScanResultTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);

        // PII 유형 목록 (필터용)
        List<DiscoveryPiiTypeVO> piiTypeList = discoveryService.getPiiTypeList();
        model.addAttribute("piiTypeList", piiTypeList);
    }

    /**
     * Rules - 탐지 규칙 관리
     */
    @GetMapping("/rules")
    @PreAuthorize("isAuthenticated()")
    public void rules(Criteria cri, Model model) {
        LogUtil.log("INFO", "PiiDiscovery rules list");
        List<DiscoveryRuleVO> ruleList = discoveryService.getRuleList(cri);
        model.addAttribute("ruleList", ruleList);

        // PII 유형 목록
        List<DiscoveryPiiTypeVO> piiTypeList = discoveryService.getPiiTypeList();
        model.addAttribute("piiTypeList", piiTypeList);

        int total = ruleList.size();
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
    }

    /**
     * Columns - PII 컬럼 목록 (MetaTable 기반)
     * 탭: confirmed = piitype IS NOT NULL, excluded = val2 = 'EXCLUDED'
     */
    @GetMapping("/columns")
    @PreAuthorize("isAuthenticated()")
    public void columns(Criteria cri, Model model) {
        LogUtil.log("INFO", "PiiDiscovery columns list (MetaTable full)");

        // 페이징 offset 계산
        try { cri.setOffset((cri.getPagenum() - 1) * cri.getAmount()); } catch (Exception e) { cri.setOffset(0); }

        // MetaTable 전체 조회 (데이터 인벤토리와 동일)
        @SuppressWarnings("unchecked")
        List<datablocks.dlm.domain.MetaTableVO> columnList = (List<datablocks.dlm.domain.MetaTableVO>)(List<?>)
                discoveryService.getMetaTableAllColumns(cri);
        model.addAttribute("list", columnList);

        int total = discoveryService.getMetaTableAllColumnsTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);

        // PII 유형 목록 (서치 필터 + 코드→이름 매핑)
        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());
        java.util.Map<String, String> piiTypeNames = new java.util.HashMap<>();
        for (datablocks.dlm.domain.LkPiiScrTypeVO t : lkPiiScrTypeService.getListAll()) {
            piiTypeNames.put(t.getPiicode(), t.getPiitypename());
        }
        model.addAttribute("piiTypeNames", piiTypeNames);

        // 통계
        model.addAttribute("stats", metaTableService.getStats());
    }

    /**
     * PII Policy - 민감정보 분류·보호 정책 (기존 LkPiiScrType 관리)
     */
    @GetMapping("/piipolicy")
    @PreAuthorize("isAuthenticated()")
    public void piipolicy(Criteria cri, Model model) {
        LogUtil.log("INFO", "PiiDiscovery piipolicy (LkPiiScrType)");
        try { cri.setOffset((cri.getPagenum() - 1) * cri.getAmount()); } catch (Exception e) { cri.setOffset(0); }
        model.addAttribute("list", lkPiiScrTypeService.getList(cri));
        int total = lkPiiScrTypeService.getTotal(cri);
        model.addAttribute("pageMaker", new PageDTO(cri, total));
    }

    /**
     * Settings - 설정
     */
    @GetMapping("/settings")
    @PreAuthorize("isAuthenticated()")
    public void settings(Model model) {
        LogUtil.log("INFO", "PiiDiscovery settings");
        DiscoveryStatVO stats = discoveryService.getDashboardStats();
        model.addAttribute("stats", stats);
    }

    // ========== REST API Controllers ==========

    /**
     * 대시보드 통계 조회 API
     */
    @GetMapping("/api/stats")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<DiscoveryStatVO> getStats() {
        DiscoveryStatVO stats = discoveryService.getDashboardStats();
        return ResponseEntity.ok(stats);
    }

    /**
     * 대시보드 차트 데이터 API (PII 유형 분포, 신뢰도 분포, Top 테이블)
     */
    @GetMapping("/api/dashboard-charts")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getDashboardCharts() {
        Map<String, Object> chartData = discoveryService.getDashboardChartData();
        return ResponseEntity.ok(chartData);
    }

    /**
     * 스캔 작업 등록 API
     */
    @PostMapping("/api/jobs")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createScanJob(
            @RequestBody DiscoveryScanJobVO job, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            job.setRegUserId(principal.getName());
            discoveryService.registerScanJob(job);
            result.put("success", true);
            result.put("message", "Scan job created successfully");
            result.put("jobId", job.getJobId());
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to create scan job", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 스캔 작업 조회 API
     */
    @GetMapping("/api/jobs/{jobId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<DiscoveryScanJobVO> getScanJob(@PathVariable String jobId) {
        DiscoveryScanJobVO job = discoveryService.getScanJob(jobId);
        if (job != null) {
            return ResponseEntity.ok(job);
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * 스캔 실행 API (새로운 Execution 생성)
     */
    @PostMapping("/api/jobs/{jobId}/execute")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> executeScan(@PathVariable String jobId) {
        Map<String, Object> result = new HashMap<>();
        try {
            String executionId = discoveryService.executeScan(jobId);
            result.put("success", true);
            result.put("message", "Scan started");
            result.put("executionId", executionId);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to execute scan", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 스캔 재시작 API (FAILED/CANCELLED Execution의 완료된 테이블을 스킵하고 이어서 실행)
     */
    @PostMapping("/api/executions/{executionId}/resume")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> resumeScan(@PathVariable String executionId) {
        Map<String, Object> result = new HashMap<>();
        try {
            String resumedId = discoveryService.resumeScan(executionId);
            if (resumedId == null) {
                result.put("success", false);
                result.put("message", "Cannot resume: execution not found or not in FAILED/CANCELLED status");
                return ResponseEntity.badRequest().body(result);
            }
            result.put("success", true);
            result.put("message", "Scan resumed (skipping completed tables)");
            result.put("executionId", resumedId);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to resume scan", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 스캔 취소 API (executionId로 취소)
     */
    @PostMapping("/api/executions/{executionId}/cancel")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> cancelScan(@PathVariable String executionId) {
        Map<String, Object> result = new HashMap<>();
        try {
            discoveryService.cancelScan(executionId);
            result.put("success", true);
            result.put("message", "Scan cancelled");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to cancel scan", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 스캔 진행 상황 조회 API (executionId로 조회)
     * - 실행 중: 메모리의 실시간 진행 상황 반환
     * - 완료/실패: DB의 저장된 통계 반환
     */
    @GetMapping("/api/executions/{executionId}/progress")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<DiscoveryScanProgressVO> getProgress(@PathVariable String executionId) {
        // 1. 실행 중인 경우 메모리에서 실시간 진행 상황 조회
        DiscoveryScanProgressVO progress = discoveryService.getScanProgress(executionId);
        if (progress != null) {
            return ResponseEntity.ok(progress);
        }

        // 2. 완료된 경우 DB에서 저장된 통계 조회
        DiscoveryScanExecutionVO execution = discoveryService.getExecution(executionId);
        DiscoveryScanProgressVO result = new DiscoveryScanProgressVO();
        result.setExecutionId(executionId);

        if (execution != null) {
            // 기본 정보
            result.setJobId(execution.getJobId());
            result.setJobName(execution.getJobName());
            result.setStatus(execution.getStatus());
            result.setProgress(execution.getProgress() != null ? execution.getProgress() : 100);
            result.setThreadCount(execution.getThreadCount() != null ? execution.getThreadCount() : 0);

            // 테이블 통계
            result.setTotalTables(execution.getTotalTables() != null ? execution.getTotalTables() : 0);
            result.setScannedTables(execution.getScannedTables() != null ? execution.getScannedTables() : 0);
            result.setRemainingTables(0); // 완료됨

            // 컬럼 통계
            result.setTotalColumns(execution.getTotalColumns() != null ? execution.getTotalColumns() : 0);
            result.setScannedColumns(execution.getScannedColumns() != null ? execution.getScannedColumns() : 0);
            result.setExcludedColumns(execution.getExcludedColumns() != null ? execution.getExcludedColumns() : 0);
            result.setPiiCount(execution.getPiiCount() != null ? execution.getPiiCount() : 0);

            // 시간 정보
            result.setStartTime(execution.getStartTime());
            if (execution.getDurationMs() != null && execution.getDurationMs() > 0) {
                result.setElapsedSeconds(execution.getDurationMs() / 1000);
            } else if (execution.getStartTime() != null && execution.getEndTime() != null) {
                // durationMs가 없으면 startTime/endTime에서 계산
                try {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    java.util.Date start = sdf.parse(execution.getStartTime());
                    java.util.Date end = sdf.parse(execution.getEndTime());
                    long diffMs = end.getTime() - start.getTime();
                    result.setElapsedSeconds(diffMs / 1000);
                } catch (Exception e) {
                    logger.debug("Failed to parse execution times", e);
                }
            }

            // 에러 정보
            result.setErrorMsg(execution.getErrorMsg());
        } else {
            result.setStatus("NOT_FOUND");
            result.setProgress(0);
        }

        return ResponseEntity.ok(result);
    }

    /**
     * 실행 정보 조회 API
     */
    @GetMapping("/api/executions/{executionId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<DiscoveryScanExecutionVO> getExecution(@PathVariable String executionId) {
        DiscoveryScanExecutionVO execution = discoveryService.getExecution(executionId);
        if (execution != null) {
            return ResponseEntity.ok(execution);
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * 실행 목록 조회 API
     */
    @GetMapping("/api/executions")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getExecutionList(Criteria cri) {
        Map<String, Object> result = new HashMap<>();
        List<DiscoveryScanExecutionVO> executions = discoveryService.getExecutionList(cri);
        int total = discoveryService.getExecutionTotal(cri);
        result.put("executions", executions);
        result.put("total", total);
        return ResponseEntity.ok(result);
    }

    /**
     * Job별 실행 목록 조회 API
     */
    @GetMapping("/api/jobs/{jobId}/executions")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<List<DiscoveryScanExecutionVO>> getExecutionsByJob(@PathVariable String jobId) {
        List<DiscoveryScanExecutionVO> executions = discoveryService.getExecutionListByJobId(jobId);
        return ResponseEntity.ok(executions);
    }

    /**
     * 스캔 작업 수정 API
     */
    @PutMapping("/api/jobs/{jobId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateScanJob(
            @PathVariable String jobId,
            @RequestBody DiscoveryScanJobVO job, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            job.setJobId(jobId);
            job.setUpdUserId(principal.getName());
            boolean updated = discoveryService.modifyScanJob(job);
            if (updated) {
                result.put("success", true);
                result.put("message", "Scan job updated successfully");
            } else {
                result.put("success", false);
                result.put("message", "Scan job not found: " + jobId);
            }
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to update scan job", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 스캔 작업 삭제 API
     */
    @DeleteMapping("/api/jobs/{jobId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteScanJob(@PathVariable String jobId) {
        Map<String, Object> result = new HashMap<>();
        try {
            discoveryService.removeScanJob(jobId);
            result.put("success", true);
            result.put("message", "Scan job deleted");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to delete scan job", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 탐지 결과 상세 조회 API
     */
    @GetMapping("/api/results/{resultId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<DiscoveryScanResultVO> getResultDetail(@PathVariable String resultId) {
        DiscoveryScanResultVO result = discoveryService.getScanResult(resultId);
        if (result == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(result);
    }

    /**
     * 탐지 결과 확인 처리 API
     * - CONFIRMED/EXCLUDED: Registry에 등록
     * - PENDING: Registry에서 삭제 (Reset)
     */
    @PostMapping("/api/results/{resultId}/confirm")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> confirmResult(
            @PathVariable String resultId,
            @RequestParam String status,
            Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            if ("CONFIRMED".equals(status) || "EXCLUDED".equals(status)) {
                // Registry에 등록 (UPSERT)
                discoveryService.registerToRegistry(resultId, status, principal.getName());
                result.put("message", "CONFIRMED".equals(status) ? "PII로 확정됨" : "오탐으로 제외됨");
            } else if ("PENDING".equals(status)) {
                // Scan Result만 업데이트 (Registry는 건드리지 않음 - Reset은 별도 API)
                discoveryService.confirmScanResult(resultId, status, principal.getName());
                result.put("message", "상태가 Pending으로 변경됨");
            } else {
                throw new IllegalArgumentException("Invalid status: " + status);
            }
            result.put("success", true);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to confirm result", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * PII 확정 + 인벤토리 세팅 API (단건)
     * 개인정보 유형, 암호화 여부, 변환타입, 보모키를 한 번에 세팅
     */
    @PostMapping("/api/results/{resultId}/confirm-with-settings")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> confirmWithSettings(
            @PathVariable String resultId,
            @RequestBody Map<String, String> settings,
            Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            String piiTypeCode = settings.get("piiTypeCode");
            String encryptFlag = settings.get("encryptFlag");
            String scrambleType = settings.get("scrambleType");
            String piiGrade = settings.get("piiGrade");

            discoveryService.confirmWithSettings(resultId, principal.getName(),
                    piiTypeCode, piiGrade, encryptFlag, scrambleType);

            result.put("success", true);
            result.put("message", "PII 확정 및 인벤토리 세팅 완료");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to confirm with settings", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * MetaTable PII 설정 직접 업데이트 API (개인정보 컬럼 페이지용)
     */
    @PostMapping("/api/meta-pii-update")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> metaPiiUpdate(
            @RequestBody Map<String, String> data) {
        Map<String, Object> result = new HashMap<>();
        try {
            discoveryService.updateMetaTablePiiDirect(
                    data.get("db"), data.get("schema"),
                    data.get("table"), data.get("column"),
                    data.get("piiTypeCode"), data.get("piiGrade"),
                    data.get("encryptFlag"), data.get("scrambleType"));
            result.put("success", true);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to update MetaTable PII settings", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * LkPiiScrType 목록 조회 API (PII 확정 다이얼로그용)
     */
    @GetMapping("/api/lk-pii-types")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<java.util.List<datablocks.dlm.domain.LkPiiScrTypeVO>> getLkPiiTypes() {
        return ResponseEntity.ok(lkPiiScrTypeService.getList());
    }

    /**
     * 탐지 결과 일괄 확인 처리 API
     */
    @PostMapping("/api/results/confirm-batch")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> confirmResultBatch(
            @RequestBody Map<String, Object> request,
            Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            @SuppressWarnings("unchecked")
            List<String> resultIds = (List<String>) request.get("resultIds");
            String status = (String) request.get("status");

            if ("CONFIRMED".equals(status) || "EXCLUDED".equals(status)) {
                // Registry에 일괄 등록
                discoveryService.registerToRegistryBatch(resultIds, status, principal.getName());
            } else {
                // 기존 로직 (Scan Result만 업데이트)
                discoveryService.confirmScanResultBatch(resultIds, status, principal.getName());
            }

            result.put("success", true);
            result.put("message", resultIds.size() + "개 항목이 처리됨");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to confirm results batch", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 규칙 등록 API
     */
    @PostMapping("/api/rules")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createRule(
            @RequestBody DiscoveryRuleVO rule, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            rule.setRegUserId(principal.getName());
            discoveryService.registerRule(rule);
            result.put("success", true);
            result.put("message", "Rule created successfully");
            result.put("ruleId", rule.getRuleId());
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to create rule", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 규칙 수정 API
     */
    @PutMapping("/api/rules/{ruleId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateRule(
            @PathVariable String ruleId,
            @RequestBody DiscoveryRuleVO rule,
            Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            rule.setRuleId(ruleId);
            rule.setUpdUserId(principal.getName());
            discoveryService.modifyRule(rule);
            result.put("success", true);
            result.put("message", "Rule updated successfully");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to update rule", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 규칙 삭제 API
     */
    @DeleteMapping("/api/rules/{ruleId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteRule(@PathVariable String ruleId) {
        Map<String, Object> result = new HashMap<>();
        try {
            discoveryService.removeRule(ruleId);
            result.put("success", true);
            result.put("message", "Rule deleted");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to delete rule", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 카테고리별 규칙 목록 조회 API
     */
    @GetMapping("/api/rules/category/{category}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<List<DiscoveryRuleVO>> getRulesByCategory(@PathVariable String category) {
        List<DiscoveryRuleVO> rules = discoveryService.getRuleListByCategory(category);
        return ResponseEntity.ok(rules);
    }

    /**
     * 규칙 상세 조회 API
     */
    @GetMapping("/api/rules/{ruleId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<DiscoveryRuleVO> getRule(@PathVariable String ruleId) {
        DiscoveryRuleVO rule = discoveryService.getRule(ruleId);
        if (rule == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(rule);
    }

    /**
     * 카테고리별 규칙 개수 조회 API
     */
    @GetMapping("/api/rules/categories/counts")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Integer>> getRuleCategoryCounts() {
        Map<String, Integer> counts = new java.util.HashMap<>();
        String[] categories = {"NAME", "SSN", "CONTACT", "FINANCIAL", "ADDRESS", "CUSTOM"};
        for (String cat : categories) {
            List<DiscoveryRuleVO> rules = discoveryService.getRuleListByCategory(cat);
            counts.put(cat, rules != null ? rules.size() : 0);
        }
        return ResponseEntity.ok(counts);
    }

    /**
     * PII 유형 목록 API
     */
    @GetMapping("/api/pii-types")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<List<DiscoveryPiiTypeVO>> getPiiTypes() {
        List<DiscoveryPiiTypeVO> piiTypes = discoveryService.getPiiTypeList();
        return ResponseEntity.ok(piiTypes);
    }

    /**
     * DB 목록 API (스캔 대상 선택용)
     */
    @GetMapping("/api/databases")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<List<PiiDatabaseVO>> getDatabases() {
        List<PiiDatabaseVO> dbList = databaseService.getList();
        return ResponseEntity.ok(dbList);
    }

    /**
     * 스키마 목록 API (특정 DB의 스키마 목록 조회)
     */
    @GetMapping("/api/schemas/{dbName}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<List<String>> getSchemas(@PathVariable String dbName) {
        try {
            List<String> schemas = discoveryService.getSchemaList(dbName);
            return ResponseEntity.ok(schemas);
        } catch (Exception e) {
            logger.error("Failed to get schemas for: " + dbName, e);
            return ResponseEntity.ok(new java.util.ArrayList<>());
        }
    }

    /**
     * Meta Table 동기화 API (기존)
     */
    @PostMapping("/api/sync-meta")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> syncToMeta(@RequestBody Map<String, Object> request) {
        Map<String, Object> result = new HashMap<>();
        try {
            @SuppressWarnings("unchecked")
            List<String> resultIds = (List<String>) request.get("resultIds");
            int syncCount = discoveryService.syncToMetaTable(resultIds);
            result.put("success", true);
            result.put("message", syncCount + " columns synced to Meta Table");
            result.put("syncCount", syncCount);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to sync to meta table", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * Meta Table DOMAIN 컬럼에 PII 탐지 정보 동기화 API
     * 단일 Registry 항목 동기화
     * 포맷: "PII_TYPE|SCORE" (예: "주민등록번호|85.5")
     */
    @PostMapping("/api/registry/{registryId}/sync-to-domain")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> syncRegistryToDomain(@PathVariable String registryId) {
        Map<String, Object> result = new HashMap<>();
        try {
            int syncCount = discoveryService.syncRegistryToMetaDomain(registryId);
            if (syncCount > 0) {
                result.put("success", true);
                result.put("message", "Meta Table DOMAIN 컬럼에 동기화 완료");
                result.put("syncCount", syncCount);
            } else {
                result.put("success", false);
                result.put("message", "동기화할 대상을 찾을 수 없습니다.");
            }
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to sync registry to domain", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * Meta Table DOMAIN 컬럼에 PII 탐지 정보 일괄 동기화 API
     * 여러 Registry 항목 동기화
     */
    @PostMapping("/api/registry/sync-to-domain-batch")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> syncRegistryToDomainBatch(@RequestBody Map<String, Object> request) {
        Map<String, Object> result = new HashMap<>();
        try {
            @SuppressWarnings("unchecked")
            List<String> registryIds = (List<String>) request.get("registryIds");
            int syncCount = discoveryService.syncRegistryToMetaDomainBatch(registryIds);
            result.put("success", true);
            result.put("message", syncCount + "개 컬럼이 Meta Table DOMAIN에 동기화됨");
            result.put("syncCount", syncCount);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to sync registry batch to domain", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 특정 DB의 모든 CONFIRMED Registry를 Meta Table DOMAIN에 동기화 API
     */
    @PostMapping("/api/registry/sync-all-to-domain")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> syncAllConfirmedToDomain(
            @RequestParam(required = false) String dbName) {
        Map<String, Object> result = new HashMap<>();
        try {
            int syncCount = discoveryService.syncAllConfirmedToMetaDomain(dbName);
            result.put("success", true);
            result.put("message", syncCount + "개 컬럼이 Meta Table DOMAIN에 동기화됨");
            result.put("syncCount", syncCount);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to sync all confirmed to domain", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    // ========== PII Registry API Controllers ==========

    /**
     * Registry 상세 조회 API
     */
    @GetMapping("/api/registry/{registryId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<DiscoveryPiiRegistryVO> getRegistry(@PathVariable String registryId) {
        DiscoveryPiiRegistryVO registry = discoveryService.getPiiRegistry(registryId);
        if (registry == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(registry);
    }

    /**
     * Registry에서 삭제 (Reset) API
     * - PII Columns 페이지에서 Reset 버튼 클릭 시 호출
     * - 원본 Scan Result를 PENDING으로 변경
     * - 다음 스캔에서 해당 컬럼이 다시 탐지됨
     */
    @DeleteMapping("/api/registry/{registryId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> removeFromRegistry(
            @PathVariable String registryId,
            Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            boolean deleted = discoveryService.removeFromRegistry(registryId, principal.getName());
            if (deleted) {
                result.put("success", true);
                result.put("message", "Registry에서 삭제됨. 원본 Result가 PENDING으로 변경되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "삭제할 항목을 찾을 수 없습니다.");
            }
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to remove from registry", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * Registry Excel Export API
     */
    @GetMapping("/api/registry/export")
    @PreAuthorize("isAuthenticated()")
    public void exportRegistryToExcel(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String dbName,
            HttpServletResponse response) throws IOException {

        // 조회 조건 설정
        Criteria cri = new Criteria();
        cri.setAmount(100000); // 전체 조회
        if (status != null && !status.isEmpty()) {
            cri.setSearch4(status);
        }
        if (dbName != null && !dbName.isEmpty()) {
            cri.setSearch1(dbName);
        }

        List<DiscoveryPiiRegistryVO> list = discoveryService.getPiiRegistryList(cri);

        // Excel 파일 생성
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("PII Registry");

        // 헤더 스타일
        CellStyle headerStyle = workbook.createCellStyle();
        headerStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        headerStyle.setFont(headerFont);

        // 헤더 행 생성
        Row headerRow = sheet.createRow(0);
        String[] headers = {"Database", "Schema", "Table", "Column", "Data Type", "PII Type", "Score", "Detection", "Encryption Status", "Encryption Method", "Encryption Ratio(%)", "Status", "Registered By", "Registered Date"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        // 데이터 행 생성
        int rowNum = 1;
        for (DiscoveryPiiRegistryVO item : list) {
            Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(item.getDbName() != null ? item.getDbName() : "");
            row.createCell(1).setCellValue(item.getSchemaName() != null ? item.getSchemaName() : "");
            row.createCell(2).setCellValue(item.getTableName() != null ? item.getTableName() : "");
            row.createCell(3).setCellValue(item.getColumnName() != null ? item.getColumnName() : "");
            row.createCell(4).setCellValue(item.getDataType() != null ? item.getDataType() : "");
            row.createCell(5).setCellValue(item.getPiiTypeName() != null ? item.getPiiTypeName() : "");
            row.createCell(6).setCellValue(item.getConfidenceScore() != null ? item.getConfidenceScore() : 0);
            row.createCell(7).setCellValue(item.getDetectionMethod() != null ? item.getDetectionMethod() : "");
            row.createCell(8).setCellValue(item.getEncryptionStatus() != null ? item.getEncryptionStatus() : "NONE");
            row.createCell(9).setCellValue(item.getEncryptionMethod() != null ? item.getEncryptionMethod() : "");
            row.createCell(10).setCellValue(item.getEncryptionRatio() != null ? item.getEncryptionRatio() : 0);
            row.createCell(11).setCellValue(item.getStatus() != null ? item.getStatus() : "");
            row.createCell(12).setCellValue(item.getRegisteredBy() != null ? item.getRegisteredBy() : "");
            row.createCell(13).setCellValue(item.getRegisteredDate() != null ? item.getRegisteredDate() : "");
        }

        // 컬럼 너비 자동 조정
        for (int i = 0; i < headers.length; i++) {
            sheet.autoSizeColumn(i);
        }

        // 파일 다운로드 설정
        String fileName = "PII_Registry_" + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()) + ".xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        workbook.write(response.getOutputStream());
        workbook.close();
    }

    /**
     * Registry 상태 변경 API (CONFIRMED <-> EXCLUDED)
     */
    @PutMapping("/api/registry/{registryId}/status")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateRegistryStatus(
            @PathVariable String registryId,
            @RequestParam String status,
            Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            boolean updated = discoveryService.updateRegistryStatus(registryId, status, principal.getName());
            if (updated) {
                result.put("success", true);
                result.put("message", "상태가 " + status + "로 변경됨");
            } else {
                result.put("success", false);
                result.put("message", "업데이트할 항목을 찾을 수 없습니다.");
            }
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to update registry status", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 수동 PII 컬럼 등록 API (Add Manual)
     */
    @PostMapping("/api/registry")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addManualRegistry(
            @RequestBody DiscoveryPiiRegistryVO registry,
            Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            registry.setRegisteredBy(principal.getName());
            discoveryService.registerManualPiiColumn(registry);
            result.put("success", true);
            result.put("message", "PII 컬럼이 Registry에 등록됨");
            result.put("registryId", registry.getRegistryId());
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to add manual registry", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    // ========== Config API Controllers ==========

    /**
     * 설정 목록 조회 API
     */
    @GetMapping("/api/configs")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<List<DiscoveryConfigVO>> getConfigs() {
        List<DiscoveryConfigVO> configs = discoveryService.getConfigList();
        return ResponseEntity.ok(configs);
    }

    /**
     * 타입별 설정 목록 조회 API
     */
    @GetMapping("/api/configs/type/{configType}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<List<DiscoveryConfigVO>> getConfigsByType(@PathVariable String configType) {
        List<DiscoveryConfigVO> configs = discoveryService.getConfigListByType(configType);
        return ResponseEntity.ok(configs);
    }

    /**
     * 설정 단건 조회 API
     */
    @GetMapping("/api/configs/{configId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<DiscoveryConfigVO> getConfig(@PathVariable String configId) {
        DiscoveryConfigVO config = discoveryService.getConfig(configId);
        if (config != null) {
            return ResponseEntity.ok(config);
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * 키로 설정 조회 API
     */
    @GetMapping("/api/configs/key/{configKey}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<DiscoveryConfigVO> getConfigByKey(@PathVariable String configKey) {
        DiscoveryConfigVO config = discoveryService.getConfigByKey(configKey);
        if (config != null) {
            return ResponseEntity.ok(config);
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * 설정 등록 API
     */
    @PostMapping("/api/configs")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createConfig(
            @RequestBody DiscoveryConfigVO config, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            config.setRegUserId(principal.getName());
            discoveryService.registerConfig(config);
            result.put("success", true);
            result.put("message", "Config created successfully");
            result.put("configId", config.getConfigId());
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to create config", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 설정 수정 API
     */
    @PutMapping("/api/configs/{configId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateConfig(
            @PathVariable String configId,
            @RequestBody DiscoveryConfigVO config,
            Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            config.setConfigId(configId);
            config.setUpdUserId(principal.getName());
            boolean updated = discoveryService.modifyConfig(config);
            result.put("success", updated);
            result.put("message", updated ? "Config updated successfully" : "Config not found");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to update config", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * 설정 삭제 API
     */
    @DeleteMapping("/api/configs/{configId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteConfig(@PathVariable String configId) {
        Map<String, Object> result = new HashMap<>();
        try {
            boolean deleted = discoveryService.removeConfig(configId);
            result.put("success", deleted);
            result.put("message", deleted ? "Config deleted" : "Config not found");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to delete config", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    // ========== PII Registry API Controllers ==========

    /**
     * PII Registry 목록 조회 API
     */
    @GetMapping("/api/registry")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getRegistryList(Criteria cri) {
        Map<String, Object> result = new HashMap<>();
        List<DiscoveryPiiRegistryVO> registryList = discoveryService.getPiiRegistryList(cri);
        int total = discoveryService.getPiiRegistryTotal(cri);
        result.put("registryList", registryList);
        result.put("total", total);
        return ResponseEntity.ok(result);
    }

    // ========== LLM Settings API Controllers ==========

    /**
     * LLM 설정 조회 API
     * llm.enabled, llm.api.url 설정을 한 번에 반환
     */
    @GetMapping("/api/llm/settings")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getLlmSettings() {
        Map<String, Object> result = new HashMap<>();
        try {
            DiscoveryConfigVO enabledConfig = discoveryService.getConfigByKey("llm.enabled");
            DiscoveryConfigVO urlConfig = discoveryService.getConfigByKey("llm.api.url");

            result.put("enabled", enabledConfig != null ? "Y".equals(enabledConfig.getConfigValue()) : false);
            result.put("apiUrl", urlConfig != null ? urlConfig.getConfigValue() : "");
            result.put("success", true);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to get LLM settings", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * LLM 설정 저장 API
     * llm.enabled, llm.api.url 설정을 한 번에 저장 (upsert)
     */
    @PostMapping("/api/llm/settings")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveLlmSettings(
            @RequestBody Map<String, Object> params, Principal principal) {
        Map<String, Object> result = new HashMap<>();
        try {
            String userId = principal.getName();
            boolean enabled = Boolean.TRUE.equals(params.get("enabled"));
            String apiUrl = params.get("apiUrl") != null ? params.get("apiUrl").toString() : "";

            // llm.enabled 저장
            upsertConfig("llm.enabled", enabled ? "Y" : "N", "LLM", "AI PII 탐지 활성화 여부", userId);

            // llm.api.url 저장
            upsertConfig("llm.api.url", apiUrl, "LLM", "Privacy-AI 서비스 URL", userId);

            result.put("success", true);
            result.put("message", "LLM 설정이 저장되었습니다.");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to save LLM settings", e);
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    /**
     * LLM 연결 테스트 API
     * Privacy-AI 서비스의 /api/v1/privacy/llm-status 호출
     */
    @PostMapping("/api/llm/test-connection")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> testLlmConnection(
            @RequestBody Map<String, String> params) {
        Map<String, Object> result = new HashMap<>();
        try {
            String apiUrl = params.get("apiUrl");
            if (apiUrl == null || apiUrl.isEmpty()) {
                result.put("success", false);
                result.put("message", "Privacy-AI URL이 비어있습니다.");
                return ResponseEntity.ok(result);
            }

            Map<String, Object> status = privacyAiClient.checkLlmStatus(apiUrl);
            result.put("success", true);
            result.putAll(status);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Failed to test LLM connection", e);
            result.put("success", false);
            result.put("message", "연결 테스트 실패: " + e.getMessage());
            return ResponseEntity.ok(result);
        }
    }

    /**
     * Config upsert 헬퍼 (키가 있으면 업데이트, 없으면 삽입)
     */
    private void upsertConfig(String configKey, String configValue,
                               String configType, String description, String userId) {
        DiscoveryConfigVO existing = discoveryService.getConfigByKey(configKey);
        if (existing != null) {
            existing.setConfigValue(configValue);
            existing.setUpdUserId(userId);
            discoveryService.modifyConfig(existing);
        } else {
            DiscoveryConfigVO newConfig = new DiscoveryConfigVO();
            newConfig.setConfigKey(configKey);
            newConfig.setConfigValue(configValue);
            newConfig.setConfigType(configType);
            newConfig.setDescription(description);
            newConfig.setIsActive("Y");
            newConfig.setRegUserId(userId);
            discoveryService.registerConfig(newConfig);
        }
    }

}
