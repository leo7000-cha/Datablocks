package datablocks.dlm.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

import com.fasterxml.jackson.databind.ObjectMapper;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.AccessLogMapper;
import datablocks.dlm.util.LogUtil;

/**
 * 접속기록 보고서 서비스
 * R1~R4 보고서 생성/조회/다운로드
 */
@Service
public class AccessLogReportService {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogReportService.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    // 인쇄용 단위: 256 = 1 문자 폭
    private static final int CW_NARROW  = 10 * 256;   // 10자 (좁은 컬럼)
    private static final int CW_NORMAL  = 14 * 256;   // 14자 (기본)
    private static final int CW_MEDIUM  = 18 * 256;   // 18자
    private static final int CW_WIDE    = 24 * 256;   // 24자
    private static final int CW_XWIDE   = 36 * 256;   // 36자 (넓은 컬럼)
    private static final int CW_XXWIDE  = 48 * 256;   // 48자 (매우 넓은)

    @Autowired
    private AccessLogMapper mapper;

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    //  CRUD
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    public List<AccessLogReportVO> getReportList(Criteria cri) {
        return mapper.selectReportList(cri);
    }

    public int getReportTotal(Criteria cri) {
        return mapper.selectReportTotal(cri);
    }

    public AccessLogReportVO getReport(Long reportId) {
        return mapper.selectReport(reportId);
    }

    @Transactional
    public boolean deleteReport(Long reportId) {
        return mapper.deleteReport(reportId) > 0;
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    //  보고서 생성
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @Transactional
    public Long generateReport(String reportType, String dateFrom, String dateTo,
                               String reportFormat, String userId) {
        String typeName = getReportTypeName(reportType);
        String reportName = typeName + " (" + dateFrom + " ~ " + dateTo + ")";

        AccessLogReportVO report = new AccessLogReportVO();
        report.setReportType(reportType);
        report.setReportName(reportName);
        report.setDateFrom(dateFrom);
        report.setDateTo(dateTo);
        report.setReportFormat(reportFormat);
        report.setGeneratedBy(userId);
        mapper.insertReport(report);

        Long reportId = report.getReportId();

        try {
            Map<String, Object> data = collectReportData(reportType, dateFrom, dateTo);
            String summaryJson = objectMapper.writeValueAsString(data);
            long fileSize = summaryJson.getBytes("UTF-8").length;
            mapper.updateReportCompleted(reportId, fileSize, summaryJson);
            LogUtil.log("INFO", "Report generated: id=" + reportId + ", type=" + reportType);
        } catch (Exception e) {
            logger.error("Report generation failed: id={}", reportId, e);
            mapper.updateReportFailed(reportId, e.getMessage());
        }
        return reportId;
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    //  데이터 수집 (변경 없음)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private Map<String, Object> collectReportData(String reportType, String dateFrom, String dateTo) {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("reportType", reportType);
        data.put("dateFrom", dateFrom);
        data.put("dateTo", dateTo);
        data.put("generatedAt", LocalDate.now().format(DateTimeFormatter.ISO_DATE));

        switch (reportType) {
            case "PERIODIC":   collectPeriodicData(data, dateFrom, dateTo); break;
            case "ANOMALY":    collectAnomalyData(data, dateFrom, dateTo); break;
            case "USER_BEHAVIOR": collectUserBehaviorData(data, dateFrom, dateTo); break;
            case "COMPLIANCE": collectComplianceData(data, dateFrom, dateTo); break;
            default:           collectPeriodicData(data, dateFrom, dateTo); break;
        }
        return data;
    }

    private void collectPeriodicData(Map<String, Object> data, String dateFrom, String dateTo) {
        Long totalAccess = mapper.selectAccessCountByPeriod(dateFrom, dateTo);
        data.put("totalAccessCount", totalAccess != null ? totalAccess : 0);

        List<Map<String, Object>> userStats = mapper.selectUserAccessStats(dateFrom, dateTo);
        data.put("userCount", userStats.size());
        data.put("userAccessStats", userStats);

        List<Map<String, Object>> afterHours = mapper.selectAfterHoursAccess(dateFrom, dateTo);
        data.put("afterHoursCount", afterHours.size());
        data.put("afterHoursAccess", afterHours);

        List<Map<String, Object>> heavyRepeat = mapper.selectHeavyRepeatAccess(dateFrom, dateTo, 10);
        data.put("heavyRepeatCount", heavyRepeat.size());
        data.put("heavyRepeatAccess", heavyRepeat);

        List<Map<String, Object>> dailyTrend = mapper.selectDailyAccessTrend(dateFrom, dateTo);
        data.put("dailyTrend", dailyTrend);

        List<Map<String, Object>> piiStats = mapper.selectPiiAccessStats(dateFrom, dateTo);
        data.put("piiAccessStats", piiStats);

        List<Map<String, Object>> alertStats = mapper.selectAlertStatsByRule(dateFrom, dateTo);
        data.put("alertStats", alertStats);
        int totalAlerts = alertStats.stream()
                .mapToInt(m -> ((Number) m.getOrDefault("alertCount", 0)).intValue()).sum();
        data.put("totalAlertCount", totalAlerts);

        AccessLogStatVO compliance = mapper.getComplianceStats();
        if (compliance != null) {
            data.put("hashVerifyStatus", compliance.getHashVerifyStatus());
            data.put("invalidHashCount", compliance.getInvalidHashCount());
        }
    }

    private void collectAnomalyData(Map<String, Object> data, String dateFrom, String dateTo) {
        List<Map<String, Object>> alertStats = mapper.selectAlertStatsByRule(dateFrom, dateTo);
        data.put("alertStatsByRule", alertStats);
        int totalAlerts = alertStats.stream()
                .mapToInt(m -> ((Number) m.getOrDefault("alertCount", 0)).intValue()).sum();
        int resolved = alertStats.stream()
                .mapToInt(m -> ((Number) m.getOrDefault("resolvedCount", 0)).intValue()).sum();
        int dismissed = alertStats.stream()
                .mapToInt(m -> ((Number) m.getOrDefault("dismissedCount", 0)).intValue()).sum();
        data.put("totalAlertCount", totalAlerts);
        data.put("resolvedAlertCount", resolved);
        data.put("dismissedAlertCount", dismissed);
        data.put("pendingAlertCount", totalAlerts - resolved - dismissed);

        data.put("piiAccessStats", mapper.selectPiiAccessStats(dateFrom, dateTo));
        data.put("dailyTrend", mapper.selectDailyAccessTrend(dateFrom, dateTo));
    }

    private void collectUserBehaviorData(Map<String, Object> data, String dateFrom, String dateTo) {
        List<Map<String, Object>> userStats = mapper.selectUserAccessStats(dateFrom, dateTo);
        data.put("userAccessStats", userStats);
        data.put("userCount", userStats.size());
        data.put("deptAccessStats", mapper.selectDeptAccessStats(dateFrom, dateTo));

        List<Map<String, Object>> afterHours = mapper.selectAfterHoursAccess(dateFrom, dateTo);
        data.put("afterHoursCount", afterHours.size());
        data.put("afterHoursAccess", afterHours);
        data.put("piiAccessStats", mapper.selectPiiAccessStats(dateFrom, dateTo));
    }

    private void collectComplianceData(Map<String, Object> data, String dateFrom, String dateTo) {
        AccessLogStatVO c = mapper.getComplianceStats();
        if (c != null) {
            data.put("retentionYears", c.getRetentionYears());
            data.put("hashVerifyStatus", c.getHashVerifyStatus());
            data.put("invalidHashCount", c.getInvalidHashCount());
            data.put("thisMonthHashVerifyCount", c.getThisMonthHashVerifyCount());
            data.put("activeRuleCount", c.getActiveRuleCount());
            data.put("totalRuleCount", c.getTotalRuleCount());
            data.put("overdueAlertCount", c.getOverdueAlertCount());
            data.put("oldestAccessDate", c.getOldestAccessDate());
            data.put("latestAccessDate", c.getLatestAccessDate());
        }
        Long totalAccess = mapper.selectAccessCountByPeriod(dateFrom, dateTo);
        data.put("totalAccessCount", totalAccess != null ? totalAccess : 0);
        data.put("hashVerifyMonthlySummary", mapper.selectHashVerifyMonthlySummary());
        data.put("alertStats", mapper.selectAlertStatsByRule(dateFrom, dateTo));
        data.put("complianceChecklist", buildComplianceChecklist(c));
    }

    private List<Map<String, Object>> buildComplianceChecklist(AccessLogStatVO c) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (c == null) return list;
        int retYears = c.getRetentionYears() != null ? c.getRetentionYears() : 0;
        int verifyCount = c.getThisMonthHashVerifyCount() != null ? c.getThisMonthHashVerifyCount() : 0;
        int invalidHash = c.getInvalidHashCount() != null ? c.getInvalidHashCount() : 0;
        int ruleCount = c.getActiveRuleCount() != null ? c.getActiveRuleCount() : 0;
        int totalRule = c.getTotalRuleCount() != null ? c.getTotalRuleCount() : 0;

        addChecklist(list, "개인정보보호법 안전성확보조치 기준 제8조 제2항",
                "접속기록 1년(5만명 이상: 2년) 이상 보관", retYears >= 1,
                "현재 보관 설정: " + retYears + "년");
        addChecklist(list, "개인정보보호법 안전성확보조치 기준 제8조 제3항",
                "접속기록 월 1회 이상 점검", verifyCount >= 1,
                "이번 달 점검 횟수: " + verifyCount + "회");
        addChecklist(list, "개인정보보호법 안전성확보조치 기준 제8조 제4항",
                "접속기록 위·변조 방지 조치", invalidHash == 0,
                "위변조 탐지 건수: " + invalidHash + "건 (SHA-256 해시 체인 적용)");
        addChecklist(list, "개인정보보호법 안전성확보조치 기준 제5조",
                "비인가 접근 탐지 및 통제", ruleCount > 0,
                "활성 탐지 규칙: " + ruleCount + "개 / " + totalRule + "개");
        addChecklist(list, "전자금융감독규정 제14조",
                "정보처리시스템 가동기록 1년 이상 보존", retYears >= 1,
                "현재 보관 설정: " + retYears + "년");
        return list;
    }

    private void addChecklist(List<Map<String, Object>> list,
                              String regulation, String requirement, boolean pass, String detail) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("regulation", regulation);
        m.put("requirement", requirement);
        m.put("status", pass ? "적합" : "부적합");
        m.put("detail", detail);
        list.add(m);
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    //  Excel 렌더링 — 인쇄용 공식 보고서 양식
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    public byte[] renderToExcel(Long reportId) throws IOException {
        AccessLogReportVO report = mapper.selectReport(reportId);
        if (report == null || !"COMPLETED".equals(report.getReportStatus())) {
            throw new IllegalStateException("보고서를 찾을 수 없거나 생성이 완료되지 않았습니다.");
        }

        Map<String, Object> data;
        try {
            data = objectMapper.readValue(report.getSummaryJson(), LinkedHashMap.class);
        } catch (Exception e) {
            throw new IOException("보고서 데이터 파싱 실패", e);
        }

        try (XSSFWorkbook wb = new XSSFWorkbook()) {
            Styles s = new Styles(wb);

            switch (report.getReportType()) {
                case "PERIODIC":      renderPeriodic(wb, s, data, report); break;
                case "ANOMALY":       renderAnomaly(wb, s, data, report); break;
                case "USER_BEHAVIOR": renderUserBehavior(wb, s, data, report); break;
                case "COMPLIANCE":    renderCompliance(wb, s, data, report); break;
                default:              renderPeriodic(wb, s, data, report); break;
            }

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            wb.write(out);
            return out.toByteArray();
        }
    }

    // ──────── R1. 정기 점검 보고서 ────────

    @SuppressWarnings("unchecked")
    private void renderPeriodic(XSSFWorkbook wb, Styles s, Map<String, Object> data, AccessLogReportVO rpt) {
        // [표지 시트]
        XSSFSheet cover = createCoverSheet(wb, s, rpt,
                "개인정보처리시스템 접속기록 점검 결과 보고서",
                "개인정보보호법 안전성확보조치 기준 제8조에 의거하여\n접속기록 점검 결과를 아래와 같이 보고합니다.");

        // 점검 개요 테이블
        int row = 12;
        row = writeSectionTitle(cover, s, row, "1. 점검 개요");
        String[][] overview = {
                {"점검 기간", rpt.getDateFrom() + "  ~  " + rpt.getDateTo()},
                {"점검 대상", "개인정보처리시스템 전체"},
                {"점검 방법", "접속기록 자동 분석 (DLM 접속기록관리 솔루션)"},
                {"점검자", rpt.getGeneratedBy()},
                {"총 접속 건수", fmt(data.get("totalAccessCount")) + " 건"},
                {"접속자 수", fmt(data.get("userCount")) + " 명"},
        };
        row = writeKvTable(cover, s, row, overview);

        // 점검 결과 요약
        row += 2;
        row = writeSectionTitle(cover, s, row, "2. 점검 결과 요약");
        String[][] resultSummary = {
                {"업무시간 외 접속", fmt(data.get("afterHoursCount")) + " 건", "야간/주말/공휴일 접속 현황"},
                {"대량 반복 조회", fmt(data.get("heavyRepeatCount")) + " 건", "동일 테이블 10회 이상 반복 조회"},
                {"이상행위 탐지", fmt(data.get("totalAlertCount")) + " 건", "탐지 규칙 기반 이상행위 알림"},
                {"접속기록 위변조", str(data.get("hashVerifyStatus")), "SHA-256 해시 체인 검증 결과"},
        };
        String[] resultHeaders = {"점검 항목", "결과", "비고"};
        int[] resultWidths = {CW_WIDE, CW_NORMAL, CW_XWIDE};
        row = writeDataTable(cover, s, row, resultHeaders, resultSummary, resultWidths);

        setupPrint(cover, "접속기록 정기 점검 보고서");

        // [사용자별 접속 통계 시트]
        List<Map<String, Object>> userStats = (List<Map<String, Object>>) data.get("userAccessStats");
        if (userStats != null && !userStats.isEmpty()) {
            XSSFSheet sh = wb.createSheet("사용자별 접속 통계");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "사용자별 접속 통계", rpt);
            String[] h = {"No", "사용자 계정", "이름", "부서", "총 접속수", "조회(SELECT)", "변경(DML)", "다운로드", "개인정보 접근", "접속 IP 수", "접근 테이블 수"};
            String[] k = {"userAccount", "userName", "department", "totalCount", "selectCount", "dmlCount", "downloadCount", "piiAccessCount", "distinctIpCount", "distinctTableCount"};
            int[] w = {CW_NARROW, CW_NORMAL, CW_NORMAL, CW_NORMAL, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW};
            r = writeDataTableFromList(sh, s, r, h, k, userStats, w, true);
            setupPrint(sh, "사용자별 접속 통계");
        }

        // [업무시간 외 접속 시트]
        List<Map<String, Object>> afterHours = (List<Map<String, Object>>) data.get("afterHoursAccess");
        if (afterHours != null && !afterHours.isEmpty()) {
            XSSFSheet sh = wb.createSheet("업무시간 외 접속");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "업무시간 외 접속 현황", rpt);
            String[] h = {"No", "사용자", "이름", "접속 일시", "접속 IP", "작업 유형", "대상 DB", "대상 테이블", "개인정보 등급", "구분"};
            String[] k = {"userAccount", "userName", "accessTime", "clientIp", "actionType", "targetDb", "targetTable", "piiGrade", "reason"};
            int[] w = {CW_NARROW, CW_NORMAL, CW_NORMAL, CW_MEDIUM, CW_NORMAL, CW_NARROW, CW_NORMAL, CW_MEDIUM, CW_NARROW, CW_NARROW};
            r = writeDataTableFromList(sh, s, r, h, k, afterHours, w, true);
            setupPrint(sh, "업무시간 외 접속");
        }

        // [대량 반복 조회 시트]
        List<Map<String, Object>> heavyRepeat = (List<Map<String, Object>>) data.get("heavyRepeatAccess");
        if (heavyRepeat != null && !heavyRepeat.isEmpty()) {
            XSSFSheet sh = wb.createSheet("대량 반복 조회");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "동일 테이블 대량 반복 조회 현황 (10회 이상)", rpt);
            String[] h = {"No", "사용자", "이름", "대상 테이블", "조회 횟수", "최초 접속", "최종 접속"};
            String[] k = {"userAccount", "userName", "targetTable", "accessCount", "firstAccess", "lastAccess"};
            int[] w = {CW_NARROW, CW_NORMAL, CW_NORMAL, CW_WIDE, CW_NARROW, CW_MEDIUM, CW_MEDIUM};
            r = writeDataTableFromList(sh, s, r, h, k, heavyRepeat, w, true);
            setupPrint(sh, "대량 반복 조회");
        }

        // [이상행위 통계 시트]
        List<Map<String, Object>> alertStats = (List<Map<String, Object>>) data.get("alertStats");
        if (alertStats != null && !alertStats.isEmpty()) {
            XSSFSheet sh = wb.createSheet("이상행위 탐지 현황");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "이상행위 탐지 현황", rpt);
            String[] h = {"No", "탐지 유형", "규칙명", "탐지 건수", "승인 완료", "무시 처리", "미처리", "높음", "보통", "낮음"};
            String[] k = {"conditionType", "ruleName", "alertCount", "resolvedCount", "dismissedCount", "pendingCount", "highCount", "mediumCount", "lowCount"};
            int[] w = {CW_NARROW, CW_NORMAL, CW_WIDE, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW};
            r = writeDataTableFromList(sh, s, r, h, k, alertStats, w, true);
            setupPrint(sh, "이상행위 탐지 현황");
        }

        // [개인정보 접근 통계 시트]
        List<Map<String, Object>> piiStats = (List<Map<String, Object>>) data.get("piiAccessStats");
        if (piiStats != null && !piiStats.isEmpty()) {
            XSSFSheet sh = wb.createSheet("개인정보 접근 통계");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "개인정보 등급별 접근 통계", rpt);
            String[] h = {"No", "개인정보 등급", "접근 건수", "접근 사용자 수", "접근 테이블 수"};
            String[] k = {"piiGrade", "accessCount", "userCount", "tableCount"};
            int[] w = {CW_NARROW, CW_NORMAL, CW_NORMAL, CW_NORMAL, CW_NORMAL};
            r = writeDataTableFromList(sh, s, r, h, k, piiStats, w, true);
            setupPrint(sh, "개인정보 접근 통계");
        }
    }

    // ──────── R2. 이상행위 탐지 보고서 ────────

    @SuppressWarnings("unchecked")
    private void renderAnomaly(XSSFWorkbook wb, Styles s, Map<String, Object> data, AccessLogReportVO rpt) {
        XSSFSheet cover = createCoverSheet(wb, s, rpt,
                "이상행위 탐지 분석 보고서",
                "접속기록 이상행위 탐지 결과를 아래와 같이 보고합니다.");

        int row = 12;
        row = writeSectionTitle(cover, s, row, "1. 탐지 개요");
        String[][] overview = {
                {"분석 기간", rpt.getDateFrom() + "  ~  " + rpt.getDateTo()},
                {"분석 방법", "규칙 기반 이상행위 탐지 엔진 (7개 유형)"},
                {"총 탐지 건수", fmt(data.get("totalAlertCount")) + " 건"},
                {"승인 완료", fmt(data.get("resolvedAlertCount")) + " 건"},
                {"무시 처리", fmt(data.get("dismissedAlertCount")) + " 건"},
                {"미처리", fmt(data.get("pendingAlertCount")) + " 건"},
        };
        row = writeKvTable(cover, s, row, overview);

        setupPrint(cover, "이상행위 탐지 보고서");

        // [유형별 상세]
        List<Map<String, Object>> alertStats = (List<Map<String, Object>>) data.get("alertStatsByRule");
        if (alertStats != null && !alertStats.isEmpty()) {
            XSSFSheet sh = wb.createSheet("유형별 탐지 상세");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "유형별 탐지 상세", rpt);
            String[] h = {"No", "탐지 유형", "규칙명", "탐지 건수", "승인", "무시", "미처리", "높음", "보통", "낮음"};
            String[] k = {"conditionType", "ruleName", "alertCount", "resolvedCount", "dismissedCount", "pendingCount", "highCount", "mediumCount", "lowCount"};
            int[] w = {CW_NARROW, CW_NORMAL, CW_WIDE, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW};
            r = writeDataTableFromList(sh, s, r, h, k, alertStats, w, true);
            setupPrint(sh, "유형별 탐지 상세");
        }

        // [일별 추이]
        List<Map<String, Object>> dailyTrend = (List<Map<String, Object>>) data.get("dailyTrend");
        if (dailyTrend != null && !dailyTrend.isEmpty()) {
            XSSFSheet sh = wb.createSheet("일별 접속 추이");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "일별 접속 추이", rpt);
            String[] h = {"No", "일자", "총 접속수", "개인정보 접근", "접속 사용자 수"};
            String[] k = {"accessDate", "totalCount", "piiCount", "userCount"};
            int[] w = {CW_NARROW, CW_NORMAL, CW_NORMAL, CW_NORMAL, CW_NORMAL};
            r = writeDataTableFromList(sh, s, r, h, k, dailyTrend, w, true);
            setupPrint(sh, "일별 접속 추이");
        }
    }

    // ──────── R3. 사용자 행동 분석 보고서 ────────

    @SuppressWarnings("unchecked")
    private void renderUserBehavior(XSSFWorkbook wb, Styles s, Map<String, Object> data, AccessLogReportVO rpt) {
        XSSFSheet cover = createCoverSheet(wb, s, rpt,
                "사용자 행동 분석 보고서",
                "사용자별/부서별 접속 패턴 분석 결과를 아래와 같이 보고합니다.");

        int row = 12;
        row = writeSectionTitle(cover, s, row, "1. 분석 개요");
        String[][] overview = {
                {"분석 기간", rpt.getDateFrom() + "  ~  " + rpt.getDateTo()},
                {"분석 대상 사용자 수", fmt(data.get("userCount")) + " 명"},
                {"업무시간 외 접속", fmt(data.get("afterHoursCount")) + " 건"},
        };
        row = writeKvTable(cover, s, row, overview);
        setupPrint(cover, "사용자 행동 분석 보고서");

        // [사용자별 상세]
        List<Map<String, Object>> userStats = (List<Map<String, Object>>) data.get("userAccessStats");
        if (userStats != null && !userStats.isEmpty()) {
            XSSFSheet sh = wb.createSheet("사용자별 접속 상세");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "사용자별 접속 상세", rpt);
            String[] h = {"No", "사용자 계정", "이름", "부서", "총 접속수", "조회(SELECT)", "변경(DML)", "다운로드", "개인정보 접근", "접속 IP 수", "접근 테이블 수"};
            String[] k = {"userAccount", "userName", "department", "totalCount", "selectCount", "dmlCount", "downloadCount", "piiAccessCount", "distinctIpCount", "distinctTableCount"};
            int[] w = {CW_NARROW, CW_NORMAL, CW_NORMAL, CW_NORMAL, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW};
            r = writeDataTableFromList(sh, s, r, h, k, userStats, w, true);
            setupPrint(sh, "사용자별 접속 상세");
        }

        // [부서별 통계]
        List<Map<String, Object>> deptStats = (List<Map<String, Object>>) data.get("deptAccessStats");
        if (deptStats != null && !deptStats.isEmpty()) {
            XSSFSheet sh = wb.createSheet("부서별 접속 통계");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "부서별 접속 통계", rpt);
            String[] h = {"No", "부서", "총 접속수", "사용자 수", "개인정보 접근", "업무시간 외 접속"};
            String[] k = {"department", "totalCount", "userCount", "piiAccessCount", "afterHoursCount"};
            int[] w = {CW_NARROW, CW_WIDE, CW_NORMAL, CW_NORMAL, CW_NORMAL, CW_NORMAL};
            r = writeDataTableFromList(sh, s, r, h, k, deptStats, w, true);
            setupPrint(sh, "부서별 접속 통계");
        }

        // [업무시간 외 접속]
        List<Map<String, Object>> afterHours = (List<Map<String, Object>>) data.get("afterHoursAccess");
        if (afterHours != null && !afterHours.isEmpty()) {
            XSSFSheet sh = wb.createSheet("업무시간 외 접속");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "업무시간 외 접속 현황", rpt);
            String[] h = {"No", "사용자", "이름", "접속 일시", "접속 IP", "작업 유형", "대상 DB", "대상 테이블", "개인정보 등급", "구분"};
            String[] k = {"userAccount", "userName", "accessTime", "clientIp", "actionType", "targetDb", "targetTable", "piiGrade", "reason"};
            int[] w = {CW_NARROW, CW_NORMAL, CW_NORMAL, CW_MEDIUM, CW_NORMAL, CW_NARROW, CW_NORMAL, CW_MEDIUM, CW_NARROW, CW_NARROW};
            r = writeDataTableFromList(sh, s, r, h, k, afterHours, w, true);
            setupPrint(sh, "업무시간 외 접속");
        }
    }

    // ──────── R4. 법규 준수 현황 보고서 ────────

    @SuppressWarnings("unchecked")
    private void renderCompliance(XSSFWorkbook wb, Styles s, Map<String, Object> data, AccessLogReportVO rpt) {
        XSSFSheet cover = createCoverSheet(wb, s, rpt,
                "개인정보 접속기록 관리 법규 준수 현황 보고서",
                "관련 법규의 준수 현황을 점검하고 결과를 아래와 같이 보고합니다.");

        int row = 12;
        row = writeSectionTitle(cover, s, row, "1. 점검 개요");
        String[][] overview = {
                {"점검 기간", rpt.getDateFrom() + "  ~  " + rpt.getDateTo()},
                {"총 접속 건수", fmt(data.get("totalAccessCount")) + " 건"},
                {"접속기록 보관 설정", fmt(data.get("retentionYears")) + " 년"},
                {"가장 오래된 기록", str(data.get("oldestAccessDate"))},
                {"가장 최근 기록", str(data.get("latestAccessDate"))},
        };
        row = writeKvTable(cover, s, row, overview);

        // 법규 준수 체크리스트
        row += 2;
        row = writeSectionTitle(cover, s, row, "2. 법규 준수 점검 결과");
        List<Map<String, Object>> checklist = (List<Map<String, Object>>) data.get("complianceChecklist");
        if (checklist != null && !checklist.isEmpty()) {
            String[] clHeaders = {"No", "관련 규정", "요구사항", "판정", "상세 내용"};
            int[] clWidths = {CW_NARROW, CW_XWIDE, CW_WIDE, CW_NARROW, CW_XWIDE};

            Row hRow = cover.createRow(row++);
            hRow.setHeightInPoints(28);
            for (int i = 0; i < clHeaders.length; i++) {
                Cell c = hRow.createCell(i);
                c.setCellValue(clHeaders[i]);
                c.setCellStyle(s.tableHeader);
                cover.setColumnWidth(i, clWidths[i]);
            }
            for (int idx = 0; idx < checklist.size(); idx++) {
                Map<String, Object> item = checklist.get(idx);
                Row dRow = cover.createRow(row++);
                dRow.setHeightInPoints(36);
                boolean pass = "적합".equals(str(item.get("status")));

                setCell(dRow, 0, String.valueOf(idx + 1), s.cellCenter);
                setCell(dRow, 1, str(item.get("regulation")), s.cellWrap);
                setCell(dRow, 2, str(item.get("requirement")), s.cellWrap);
                setCell(dRow, 3, str(item.get("status")), pass ? s.cellPass : s.cellFail);
                setCell(dRow, 4, str(item.get("detail")), s.cellWrap);
            }
        }

        setupPrint(cover, "법규 준수 현황 보고서");

        // [해시 검증 이력]
        List<Map<String, Object>> hashSummary = (List<Map<String, Object>>) data.get("hashVerifyMonthlySummary");
        if (hashSummary != null && !hashSummary.isEmpty()) {
            XSSFSheet sh = wb.createSheet("접속기록 무결성 검증 이력");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "접속기록 무결성 검증 이력 (월별)", rpt);
            String[] h = {"No", "검증 연월", "검증 일수", "정상 일수", "위반 일수", "총 기록수", "위변조 건수", "최종 검증일시"};
            String[] k = {"yearMonth", "verifiedDays", "validDays", "invalidDays", "totalRecords", "totalInvalidRecords", "lastVerifiedAt"};
            int[] w = {CW_NARROW, CW_NORMAL, CW_NARROW, CW_NARROW, CW_NARROW, CW_NORMAL, CW_NARROW, CW_MEDIUM};
            r = writeDataTableFromList(sh, s, r, h, k, hashSummary, w, true);
            setupPrint(sh, "무결성 검증 이력");
        }

        // [이상행위 탐지 현황]
        List<Map<String, Object>> alertStats = (List<Map<String, Object>>) data.get("alertStats");
        if (alertStats != null && !alertStats.isEmpty()) {
            XSSFSheet sh = wb.createSheet("이상행위 탐지 현황");
            int r = 0;
            r = writeSheetTitle(sh, s, r, "이상행위 탐지 및 조치 현황", rpt);
            String[] h = {"No", "탐지 유형", "규칙명", "탐지 건수", "승인", "무시", "미처리"};
            String[] k = {"conditionType", "ruleName", "alertCount", "resolvedCount", "dismissedCount", "pendingCount"};
            int[] w = {CW_NARROW, CW_NORMAL, CW_WIDE, CW_NARROW, CW_NARROW, CW_NARROW, CW_NARROW};
            r = writeDataTableFromList(sh, s, r, h, k, alertStats, w, true);
            setupPrint(sh, "이상행위 탐지 현황");
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    //  공통 렌더링 유틸리티
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /** 표지 시트 생성 */
    private XSSFSheet createCoverSheet(XSSFWorkbook wb, Styles s, AccessLogReportVO rpt,
                                        String title, String description) {
        XSSFSheet sh = wb.createSheet("표지");
        sh.setColumnWidth(0, CW_WIDE);
        sh.setColumnWidth(1, CW_XXWIDE);
        sh.setColumnWidth(2, CW_WIDE);
        sh.setColumnWidth(3, CW_WIDE);
        sh.setColumnWidth(4, CW_WIDE);

        // 빈 줄
        int row = 1;

        // 문서 분류
        Row classRow = sh.createRow(row++);
        classRow.setHeightInPoints(20);
        setCell(classRow, 4, "내부문서", s.cellRight);

        row++; // 빈 줄

        // 보고서 제목
        Row titleRow = sh.createRow(row);
        titleRow.setHeightInPoints(42);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue(title);
        titleCell.setCellStyle(s.coverTitle);
        sh.addMergedRegion(new CellRangeAddress(row, row, 0, 4));
        row++;

        // 구분선
        Row lineRow = sh.createRow(row);
        lineRow.setHeightInPoints(4);
        for (int i = 0; i <= 4; i++) {
            Cell c = lineRow.createCell(i);
            c.setCellStyle(s.divider);
        }
        row++;
        row++; // 빈 줄

        // 설명
        Row descRow = sh.createRow(row);
        descRow.setHeightInPoints(38);
        Cell descCell = descRow.createCell(0);
        descCell.setCellValue(description);
        descCell.setCellStyle(s.coverDesc);
        sh.addMergedRegion(new CellRangeAddress(row, row, 0, 4));
        row++;

        // 문서 정보
        row++; // 빈 줄
        Row infoRow1 = sh.createRow(row++);
        infoRow1.setHeightInPoints(22);
        setCell(infoRow1, 0, "작성일", s.kvKey);
        setCell(infoRow1, 1, rpt.getGeneratedAt(), s.kvValue);

        Row infoRow2 = sh.createRow(row++);
        infoRow2.setHeightInPoints(22);
        setCell(infoRow2, 0, "작성자", s.kvKey);
        setCell(infoRow2, 1, rpt.getGeneratedBy(), s.kvValue);

        Row infoRow3 = sh.createRow(row++);
        infoRow3.setHeightInPoints(22);
        setCell(infoRow3, 0, "분석 기간", s.kvKey);
        setCell(infoRow3, 1, rpt.getDateFrom() + "  ~  " + rpt.getDateTo(), s.kvValue);

        return sh;
    }

    /** 섹션 제목 (예: "1. 점검 개요") */
    private int writeSectionTitle(XSSFSheet sh, Styles s, int row, String title) {
        Row r = sh.createRow(row);
        r.setHeightInPoints(26);
        Cell c = r.createCell(0);
        c.setCellValue(title);
        c.setCellStyle(s.sectionTitle);
        sh.addMergedRegion(new CellRangeAddress(row, row, 0, 4));
        return row + 1;
    }

    /** Key-Value 테이블 (2열) */
    private int writeKvTable(XSSFSheet sh, Styles s, int row, String[][] kvPairs) {
        for (String[] kv : kvPairs) {
            Row r = sh.createRow(row++);
            r.setHeightInPoints(24);
            setCell(r, 0, kv[0], s.kvKey);
            setCell(r, 1, kv[1], s.kvValue);
            if (kv.length > 2) {
                sh.addMergedRegion(new CellRangeAddress(row - 1, row - 1, 1, 2));
            }
        }
        return row;
    }

    /** 데이터 시트 상단 제목 행 */
    private int writeSheetTitle(XSSFSheet sh, Styles s, int row, String title, AccessLogReportVO rpt) {
        Row titleRow = sh.createRow(row);
        titleRow.setHeightInPoints(32);
        Cell c = titleRow.createCell(0);
        c.setCellValue(title);
        c.setCellStyle(s.sheetTitle);
        row++;

        Row infoRow = sh.createRow(row);
        infoRow.setHeightInPoints(18);
        Cell infoCell = infoRow.createCell(0);
        infoCell.setCellValue("기간: " + rpt.getDateFrom() + " ~ " + rpt.getDateTo() + "    |    작성: " + rpt.getGeneratedAt() + "    |    작성자: " + rpt.getGeneratedBy());
        infoCell.setCellStyle(s.sheetSubtitle);
        row++;
        row++; // 빈 줄

        return row;
    }

    /** 2차원 배열 데이터로 테이블 작성 */
    private int writeDataTable(XSSFSheet sh, Styles s, int row, String[] headers, String[][] rows, int[] widths) {
        Row hRow = sh.createRow(row++);
        hRow.setHeightInPoints(26);
        for (int i = 0; i < headers.length; i++) {
            Cell c = hRow.createCell(i);
            c.setCellValue(headers[i]);
            c.setCellStyle(s.tableHeader);
            if (widths != null && i < widths.length) sh.setColumnWidth(i, widths[i]);
        }

        boolean alt = false;
        for (String[] vals : rows) {
            Row dRow = sh.createRow(row++);
            dRow.setHeightInPoints(22);
            for (int i = 0; i < vals.length; i++) {
                setCell(dRow, i, vals[i], alt ? s.cellAlt : s.cell);
            }
            alt = !alt;
        }
        return row;
    }

    /** List<Map> 데이터로 테이블 작성 */
    private int writeDataTableFromList(XSSFSheet sh, Styles s, int row,
                                       String[] headers, String[] keys,
                                       List<Map<String, Object>> dataList,
                                       int[] widths, boolean hasNo) {
        // 헤더 행
        Row hRow = sh.createRow(row++);
        hRow.setHeightInPoints(28);
        for (int i = 0; i < headers.length; i++) {
            Cell c = hRow.createCell(i);
            c.setCellValue(headers[i]);
            c.setCellStyle(s.tableHeader);
            if (widths != null && i < widths.length) sh.setColumnWidth(i, widths[i]);
        }

        // 데이터 행
        int noOffset = hasNo ? 1 : 0;
        boolean alt = false;
        for (int idx = 0; idx < dataList.size(); idx++) {
            Map<String, Object> item = dataList.get(idx);
            Row dRow = sh.createRow(row++);
            dRow.setHeightInPoints(22);

            CellStyle cs = alt ? s.cellAlt : s.cell;
            CellStyle numCs = alt ? s.cellNumAlt : s.cellNum;

            if (hasNo) {
                setCell(dRow, 0, String.valueOf(idx + 1), alt ? s.cellCenterAlt : s.cellCenter);
            }

            for (int i = 0; i < keys.length; i++) {
                Object val = item.get(keys[i]);
                Cell c = dRow.createCell(i + noOffset);
                if (val instanceof Number) {
                    c.setCellValue(((Number) val).longValue());
                    c.setCellStyle(numCs);
                } else {
                    c.setCellValue(str(val));
                    c.setCellStyle(cs);
                }
            }
            alt = !alt;
        }

        // 데이터 없을 때
        if (dataList.isEmpty()) {
            Row emptyRow = sh.createRow(row++);
            emptyRow.setHeightInPoints(24);
            Cell c = emptyRow.createCell(0);
            c.setCellValue("해당 기간에 데이터가 없습니다.");
            c.setCellStyle(s.cell);
            sh.addMergedRegion(new CellRangeAddress(row - 1, row - 1, 0, headers.length - 1));
        }

        return row;
    }

    /** 인쇄 설정 (A4 가로, 여백, 머리글/바닥글) */
    private void setupPrint(XSSFSheet sh, String reportTitle) {
        PrintSetup ps = sh.getPrintSetup();
        ps.setPaperSize(PrintSetup.A4_PAPERSIZE);
        ps.setLandscape(true);
        ps.setFitWidth((short) 1);
        ps.setFitHeight((short) 0);
        sh.setFitToPage(true);

        sh.setMargin(Sheet.LeftMargin, 0.5);
        sh.setMargin(Sheet.RightMargin, 0.5);
        sh.setMargin(Sheet.TopMargin, 0.6);
        sh.setMargin(Sheet.BottomMargin, 0.6);

        Header header = sh.getHeader();
        header.setLeft("DLM 접속기록관리");
        header.setCenter(reportTitle);
        header.setRight("내부문서");

        Footer footer = sh.getFooter();
        footer.setLeft("출력일: " + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
        footer.setCenter("- &P / &N -");
        footer.setRight("Datablocks DLM");

        sh.setRepeatingRows(CellRangeAddress.valueOf("1:1"));
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    //  셀 유틸리티
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private void setCell(Row row, int col, String value, CellStyle style) {
        Cell c = row.createCell(col);
        c.setCellValue(value != null ? value : "-");
        c.setCellStyle(style);
    }

    private String str(Object obj) {
        return obj != null ? obj.toString() : "-";
    }

    private String fmt(Object obj) {
        if (obj == null) return "0";
        if (obj instanceof Number) {
            return String.format("%,d", ((Number) obj).longValue());
        }
        return obj.toString();
    }

    private String getReportTypeName(String type) {
        switch (type) {
            case "PERIODIC":      return "접속기록 정기 점검 보고서";
            case "ANOMALY":       return "이상행위 탐지 보고서";
            case "USER_BEHAVIOR": return "사용자 행동 분석 보고서";
            case "COMPLIANCE":    return "법규 준수 현황 보고서";
            case "AI_ANALYSIS":   return "AI 분석 보고서";
            default:              return "접속기록 보고서";
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    //  스타일 정의 (한 번만 생성하여 재사용)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private static class Styles {
        // 표지
        final XSSFCellStyle coverTitle;
        final XSSFCellStyle coverDesc;
        final XSSFCellStyle divider;
        // 섹션
        final XSSFCellStyle sectionTitle;
        final XSSFCellStyle sheetTitle;
        final XSSFCellStyle sheetSubtitle;
        // K-V
        final XSSFCellStyle kvKey;
        final XSSFCellStyle kvValue;
        // 테이블
        final XSSFCellStyle tableHeader;
        final XSSFCellStyle cell;
        final XSSFCellStyle cellAlt;
        final XSSFCellStyle cellCenter;
        final XSSFCellStyle cellCenterAlt;
        final XSSFCellStyle cellNum;
        final XSSFCellStyle cellNumAlt;
        final XSSFCellStyle cellWrap;
        final XSSFCellStyle cellRight;
        // 판정
        final XSSFCellStyle cellPass;
        final XSSFCellStyle cellFail;

        Styles(XSSFWorkbook wb) {
            // 색상 팔레트
            XSSFColor headerBg    = new XSSFColor(new byte[]{(byte)0x1E, (byte)0x3A, (byte)0x5F}, null); // 진한 남색
            XSSFColor altRowBg    = new XSSFColor(new byte[]{(byte)0xF1, (byte)0xF5, (byte)0xF9}, null); // 연한 회색
            XSSFColor kvKeyBg     = new XSSFColor(new byte[]{(byte)0xE2, (byte)0xE8, (byte)0xF0}, null);
            XSSFColor sectionBg   = new XSSFColor(new byte[]{(byte)0x0D, (byte)0x94, (byte)0x88}, null); // teal
            XSSFColor dividerBg   = new XSSFColor(new byte[]{(byte)0x0D, (byte)0x94, (byte)0x88}, null);
            XSSFColor passBg      = new XSSFColor(new byte[]{(byte)0xD1, (byte)0xFA, (byte)0xE5}, null);
            XSSFColor failBg      = new XSSFColor(new byte[]{(byte)0xFE, (byte)0xE2, (byte)0xE2}, null);

            // 폰트
            XSSFFont fontTitle = wb.createFont();
            fontTitle.setFontName("맑은 고딕");
            fontTitle.setFontHeightInPoints((short) 20);
            fontTitle.setBold(true);
            fontTitle.setColor(IndexedColors.DARK_BLUE.getIndex());

            XSSFFont fontSheet = wb.createFont();
            fontSheet.setFontName("맑은 고딕");
            fontSheet.setFontHeightInPoints((short) 14);
            fontSheet.setBold(true);

            XSSFFont fontSection = wb.createFont();
            fontSection.setFontName("맑은 고딕");
            fontSection.setFontHeightInPoints((short) 11);
            fontSection.setBold(true);
            fontSection.setColor(IndexedColors.WHITE.getIndex());

            XSSFFont fontHeader = wb.createFont();
            fontHeader.setFontName("맑은 고딕");
            fontHeader.setFontHeightInPoints((short) 10);
            fontHeader.setBold(true);
            fontHeader.setColor(IndexedColors.WHITE.getIndex());

            XSSFFont fontNormal = wb.createFont();
            fontNormal.setFontName("맑은 고딕");
            fontNormal.setFontHeightInPoints((short) 10);

            XSSFFont fontDesc = wb.createFont();
            fontDesc.setFontName("맑은 고딕");
            fontDesc.setFontHeightInPoints((short) 11);
            fontDesc.setColor(IndexedColors.GREY_50_PERCENT.getIndex());

            XSSFFont fontSub = wb.createFont();
            fontSub.setFontName("맑은 고딕");
            fontSub.setFontHeightInPoints((short) 9);
            fontSub.setColor(IndexedColors.GREY_50_PERCENT.getIndex());

            XSSFFont fontKvKey = wb.createFont();
            fontKvKey.setFontName("맑은 고딕");
            fontKvKey.setFontHeightInPoints((short) 10);
            fontKvKey.setBold(true);

            XSSFFont fontPassBold = wb.createFont();
            fontPassBold.setFontName("맑은 고딕");
            fontPassBold.setFontHeightInPoints((short) 10);
            fontPassBold.setBold(true);
            fontPassBold.setColor(IndexedColors.GREEN.getIndex());

            XSSFFont fontFailBold = wb.createFont();
            fontFailBold.setFontName("맑은 고딕");
            fontFailBold.setFontHeightInPoints((short) 10);
            fontFailBold.setBold(true);
            fontFailBold.setColor(IndexedColors.RED.getIndex());

            // ──── 표지 스타일 ────
            coverTitle = wb.createCellStyle();
            coverTitle.setFont(fontTitle);
            coverTitle.setVerticalAlignment(VerticalAlignment.CENTER);

            coverDesc = wb.createCellStyle();
            coverDesc.setFont(fontDesc);
            coverDesc.setVerticalAlignment(VerticalAlignment.TOP);
            coverDesc.setWrapText(true);

            divider = wb.createCellStyle();
            divider.setFillForegroundColor(dividerBg);
            divider.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            // ──── 섹션/시트 제목 ────
            sectionTitle = wb.createCellStyle();
            sectionTitle.setFont(fontSection);
            sectionTitle.setFillForegroundColor(sectionBg);
            sectionTitle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            sectionTitle.setVerticalAlignment(VerticalAlignment.CENTER);
            sectionTitle.setAlignment(HorizontalAlignment.LEFT);

            sheetTitle = wb.createCellStyle();
            sheetTitle.setFont(fontSheet);
            sheetTitle.setVerticalAlignment(VerticalAlignment.CENTER);
            sheetTitle.setBorderBottom(BorderStyle.MEDIUM);

            sheetSubtitle = wb.createCellStyle();
            sheetSubtitle.setFont(fontSub);
            sheetSubtitle.setVerticalAlignment(VerticalAlignment.CENTER);

            // ──── K-V 스타일 ────
            kvKey = wb.createCellStyle();
            kvKey.setFont(fontKvKey);
            kvKey.setFillForegroundColor(kvKeyBg);
            kvKey.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            kvKey.setVerticalAlignment(VerticalAlignment.CENTER);
            kvKey.setAlignment(HorizontalAlignment.LEFT);
            applyBorder(kvKey, BorderStyle.THIN);

            kvValue = wb.createCellStyle();
            kvValue.setFont(fontNormal);
            kvValue.setVerticalAlignment(VerticalAlignment.CENTER);
            kvValue.setAlignment(HorizontalAlignment.LEFT);
            applyBorder(kvValue, BorderStyle.THIN);

            // ──── 테이블 헤더 ────
            tableHeader = wb.createCellStyle();
            tableHeader.setFont(fontHeader);
            tableHeader.setFillForegroundColor(headerBg);
            tableHeader.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            tableHeader.setAlignment(HorizontalAlignment.CENTER);
            tableHeader.setVerticalAlignment(VerticalAlignment.CENTER);
            applyBorder(tableHeader, BorderStyle.THIN);

            // ──── 데이터 셀 (기본) ────
            cell = createCellStyle(wb, fontNormal, null, HorizontalAlignment.LEFT);
            cellAlt = createCellStyle(wb, fontNormal, altRowBg, HorizontalAlignment.LEFT);
            cellCenter = createCellStyle(wb, fontNormal, null, HorizontalAlignment.CENTER);
            cellCenterAlt = createCellStyle(wb, fontNormal, altRowBg, HorizontalAlignment.CENTER);

            // 숫자 (우측 정렬 + 천단위 쉼표)
            cellNum = createCellStyle(wb, fontNormal, null, HorizontalAlignment.RIGHT);
            cellNum.setDataFormat(wb.createDataFormat().getFormat("#,##0"));
            cellNumAlt = createCellStyle(wb, fontNormal, altRowBg, HorizontalAlignment.RIGHT);
            cellNumAlt.setDataFormat(wb.createDataFormat().getFormat("#,##0"));

            cellWrap = createCellStyle(wb, fontNormal, null, HorizontalAlignment.LEFT);
            cellWrap.setWrapText(true);

            cellRight = wb.createCellStyle();
            cellRight.setFont(fontSub);
            cellRight.setAlignment(HorizontalAlignment.RIGHT);

            // ──── 판정 스타일 ────
            cellPass = wb.createCellStyle();
            cellPass.setFont(fontPassBold);
            cellPass.setFillForegroundColor(passBg);
            cellPass.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            cellPass.setAlignment(HorizontalAlignment.CENTER);
            cellPass.setVerticalAlignment(VerticalAlignment.CENTER);
            applyBorder(cellPass, BorderStyle.THIN);

            cellFail = wb.createCellStyle();
            cellFail.setFont(fontFailBold);
            cellFail.setFillForegroundColor(failBg);
            cellFail.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            cellFail.setAlignment(HorizontalAlignment.CENTER);
            cellFail.setVerticalAlignment(VerticalAlignment.CENTER);
            applyBorder(cellFail, BorderStyle.THIN);
        }

        private XSSFCellStyle createCellStyle(XSSFWorkbook wb, XSSFFont font, XSSFColor bg, HorizontalAlignment align) {
            XSSFCellStyle cs = wb.createCellStyle();
            cs.setFont(font);
            cs.setAlignment(align);
            cs.setVerticalAlignment(VerticalAlignment.CENTER);
            if (bg != null) {
                cs.setFillForegroundColor(bg);
                cs.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            }
            applyBorder(cs, BorderStyle.THIN);
            return cs;
        }

        private static void applyBorder(CellStyle cs, BorderStyle border) {
            cs.setBorderTop(border);
            cs.setBorderBottom(border);
            cs.setBorderLeft(border);
            cs.setBorderRight(border);
            // 테두리 색상: 연한 회색
            cs.setTopBorderColor(IndexedColors.GREY_40_PERCENT.getIndex());
            cs.setBottomBorderColor(IndexedColors.GREY_40_PERCENT.getIndex());
            cs.setLeftBorderColor(IndexedColors.GREY_40_PERCENT.getIndex());
            cs.setRightBorderColor(IndexedColors.GREY_40_PERCENT.getIndex());
        }
    }
}
