package datablocks.dlm.engine;

import datablocks.dlm.domain.AccessLogAlertRuleVO;
import datablocks.dlm.domain.AccessLogAlertVO;
import datablocks.dlm.domain.AccessLogConfigVO;
import datablocks.dlm.mapper.AccessLogMapper;
import datablocks.dlm.service.AccessLogEmailService;
import datablocks.dlm.service.AccessLogService;
import datablocks.dlm.util.LogUtil;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

/**
 * 접속기록 이상행위 탐지 엔진 구현체
 * 7가지 규칙 유형: VOLUME, TIME_RANGE, ACCESS_DENIED, PII_GRADE, REPEAT, NEW_IP, INACTIVE
 */
@Component
public class AccessLogDetectionEngineImpl implements AccessLogDetectionEngine {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogDetectionEngineImpl.class);

    @Autowired
    private AccessLogMapper mapper;

    @Autowired
    private AccessLogEmailService emailService;

    @Autowired
    private AccessLogService accessLogService;

    @Value("${server.port:8080}")
    private int serverPort;

    @Override
    public int detectAnomalies(String sourceId) {
        return runDetection();
    }

    @Override
    public int detectAll() {
        return runDetection();
    }

    private int runDetection() {
        // 탐지 활성화 여부 확인
        AccessLogConfigVO detectionCfg = mapper.selectConfigByKey("DETECTION_ENABLED");
        if (detectionCfg != null && "N".equals(detectionCfg.getConfigValue())) {
            return 0;
        }

        List<AccessLogAlertRuleVO> rules = mapper.selectAlertRuleList();
        int totalAlerts = 0;

        for (AccessLogAlertRuleVO rule : rules) {
            if (!"Y".equals(rule.getIsActive())) continue;

            try {
                int detected = processRule(rule);
                totalAlerts += detected;
            } catch (Exception e) {
                logger.error("Detection failed for rule: {} ({})", rule.getRuleName(), rule.getConditionType(), e);
            }
        }

        if (totalAlerts > 0) {
            LogUtil.log("INFO", "AccessLogDetection: " + totalAlerts + " anomalies detected");
        }
        return totalAlerts;
    }

    private int processRule(AccessLogAlertRuleVO rule) {
        int timeWindow = rule.getTimeWindowMin() != null ? rule.getTimeWindowMin() : 60;
        int threshold = rule.getThresholdValue() != null ? rule.getThresholdValue() : 10;
        int alertCount = 0;

        switch (rule.getConditionType()) {
            case "VOLUME":
                alertCount = detectVolume(rule, timeWindow, threshold);
                break;
            case "TIME_RANGE":
                alertCount = detectTimeRange(rule);
                break;
            case "ACCESS_DENIED":
                alertCount = detectAccessDenied(rule, timeWindow, threshold);
                break;
            case "PII_GRADE":
                alertCount = detectPiiGrade(rule, timeWindow, threshold);
                break;
            case "REPEAT":
                alertCount = detectRepeat(rule, timeWindow, threshold);
                break;
            case "NEW_IP":
                alertCount = detectNewIp(rule);
                break;
            case "INACTIVE":
                alertCount = detectInactive(rule, threshold);
                break;
            default:
                logger.warn("Unknown condition type: {}", rule.getConditionType());
        }

        return alertCount;
    }

    private int detectVolume(AccessLogAlertRuleVO rule, int timeWindow, int threshold) {
        List<Map<String, Object>> results = mapper.detectVolumeAnomaly(timeWindow, threshold);
        int count = 0;
        for (Map<String, Object> row : results) {
            String userAccount = (String) row.get("userAccount");
            String userName = (String) row.get("userName");
            Object accessCountObj = row.get("accessCount");
            long accessCount = accessCountObj instanceof Number ? ((Number) accessCountObj).longValue() : 0;
            String logIds = row.get("logIds") != null ? row.get("logIds").toString() : "";

            AccessLogAlertVO alert = buildAlert(rule,
                    userAccount, userName,
                    "대량 접속 감지: " + userAccount + " (" + accessCount + "건/" + timeWindow + "분)",
                    timeWindow + "분 내 " + accessCount + "건 접속 (임계치: " + threshold + "건)",
                    logIds);
            insertAlertAndNotify(alert, rule);
            count++;
        }
        return count;
    }

    private int detectTimeRange(AccessLogAlertRuleVO rule) {
        String start = rule.getTimeRangeStart() != null ? rule.getTimeRangeStart() : "22:00:00";
        String end = rule.getTimeRangeEnd() != null ? rule.getTimeRangeEnd() : "06:00:00";

        List<Map<String, Object>> results = mapper.detectTimeRangeAnomaly(start, end);
        int count = 0;
        for (Map<String, Object> row : results) {
            String userAccount = (String) row.get("userAccount");
            String userName = (String) row.get("userName");
            Object accessCountObj = row.get("accessCount");
            long accessCount = accessCountObj instanceof Number ? ((Number) accessCountObj).longValue() : 0;
            String logIds = row.get("logIds") != null ? row.get("logIds").toString() : "";

            AccessLogAlertVO alert = buildAlert(rule,
                    userAccount, userName,
                    "비인가 시간 접속: " + userAccount + " (" + start + "~" + end + ")",
                    "야간/공휴일 시간대 " + accessCount + "건 접속",
                    logIds);
            insertAlertAndNotify(alert, rule);
            count++;
        }
        return count;
    }

    private int detectAccessDenied(AccessLogAlertRuleVO rule, int timeWindow, int threshold) {
        List<Map<String, Object>> results = mapper.detectAccessDenied(timeWindow, threshold);
        int count = 0;
        for (Map<String, Object> row : results) {
            String userAccount = (String) row.get("userAccount");
            String userName = (String) row.get("userName");
            Object deniedCountObj = row.get("deniedCount");
            long deniedCount = deniedCountObj instanceof Number ? ((Number) deniedCountObj).longValue() : 0;
            String logIds = row.get("logIds") != null ? row.get("logIds").toString() : "";

            AccessLogAlertVO alert = buildAlert(rule,
                    userAccount, userName,
                    "접속 거부 반복: " + userAccount + " (" + deniedCount + "회)",
                    timeWindow + "분 내 접속 거부 " + deniedCount + "회 (임계치: " + threshold + "회)",
                    logIds);
            insertAlertAndNotify(alert, rule);
            count++;
        }
        return count;
    }

    private int detectPiiGrade(AccessLogAlertRuleVO rule, int timeWindow, int threshold) {
        String piiGrade = rule.getTargetPiiGrade() != null ? rule.getTargetPiiGrade() : "HIGH";
        List<Map<String, Object>> results = mapper.detectPiiGradeAnomaly(piiGrade, timeWindow, threshold);
        int count = 0;
        for (Map<String, Object> row : results) {
            String userAccount = (String) row.get("userAccount");
            String userName = (String) row.get("userName");
            Object piiCountObj = row.get("piiAccessCount");
            long piiCount = piiCountObj instanceof Number ? ((Number) piiCountObj).longValue() : 0;
            String logIds = row.get("logIds") != null ? row.get("logIds").toString() : "";

            AccessLogAlertVO alert = buildAlert(rule,
                    userAccount, userName,
                    "고등급 PII 대량 접근: " + userAccount + " (" + piiGrade + ", " + piiCount + "건)",
                    piiGrade + " 등급 개인정보 " + piiCount + "건 접근 (임계치: " + threshold + "건)",
                    logIds);
            insertAlertAndNotify(alert, rule);
            count++;
        }
        return count;
    }

    private int detectRepeat(AccessLogAlertRuleVO rule, int timeWindow, int threshold) {
        List<Map<String, Object>> results = mapper.detectRepeatAccess(timeWindow, threshold);
        int count = 0;
        for (Map<String, Object> row : results) {
            String userAccount = (String) row.get("userAccount");
            String userName = (String) row.get("userName");
            String targetTable = (String) row.get("targetTable");
            Object repeatCountObj = row.get("repeatCount");
            long repeatCount = repeatCountObj instanceof Number ? ((Number) repeatCountObj).longValue() : 0;
            String logIds = row.get("logIds") != null ? row.get("logIds").toString() : "";

            AccessLogAlertVO alert = buildAlert(rule,
                    userAccount, userName,
                    "동일 테이블 반복 접근: " + userAccount + " → " + targetTable + " (" + repeatCount + "회)",
                    "테이블 " + targetTable + "에 " + timeWindow + "분 내 " + repeatCount + "회 접근",
                    logIds);
            insertAlertAndNotify(alert, rule);
            count++;
        }
        return count;
    }

    private int detectNewIp(AccessLogAlertRuleVO rule) {
        List<Map<String, Object>> results = mapper.detectNewIp();
        int count = 0;
        for (Map<String, Object> row : results) {
            String userAccount = (String) row.get("userAccount");
            String userName = (String) row.get("userName");
            String clientIp = (String) row.get("clientIp");
            String logIds = row.get("logIds") != null ? row.get("logIds").toString() : "";

            AccessLogAlertVO alert = buildAlert(rule,
                    userAccount, userName,
                    "미등록 IP 접근: " + userAccount + " from " + clientIp,
                    "90일간 사용 이력이 없는 IP " + clientIp + "에서 접속",
                    logIds);
            insertAlertAndNotify(alert, rule);
            count++;
        }
        return count;
    }

    private int detectInactive(AccessLogAlertRuleVO rule, int inactiveDays) {
        if (inactiveDays <= 0) inactiveDays = 90;
        List<Map<String, Object>> results = mapper.detectInactiveAccount(inactiveDays);
        int count = 0;
        for (Map<String, Object> row : results) {
            String userAccount = (String) row.get("userAccount");
            String userName = (String) row.get("userName");
            String logId = row.get("logId") != null ? row.get("logId").toString() : "";

            AccessLogAlertVO alert = buildAlert(rule,
                    userAccount, userName,
                    "장기미사용 계정 접근: " + userAccount,
                    inactiveDays + "일간 접속 이력이 없던 계정의 접속 감지",
                    logId);
            insertAlertAndNotify(alert, rule);
            count++;
        }
        return count;
    }

    private AccessLogAlertVO buildAlert(AccessLogAlertRuleVO rule,
                                         String userId, String userName,
                                         String title, String detail, String logIds) {
        AccessLogAlertVO alert = new AccessLogAlertVO();
        alert.setRuleId(rule.getRuleId());
        alert.setRuleCode(rule.getRuleCode());
        alert.setSeverity(rule.getSeverity());
        alert.setAlertTitle(title);
        alert.setAlertDetail(detail);
        alert.setTargetUserId(userId);
        alert.setTargetUserName(userName != null ? userName : userId);
        alert.setRelatedLogIds(logIds);
        alert.setStatus("NEW");
        return alert;
    }

    /**
     * 억제 규칙 확인: 해당 사용자+규칙에 활성 예외가 있으면 알림 생성 건너뜀
     */
    private boolean isSuppressed(String ruleId, String targetUserId) {
        try {
            return mapper.countActiveSuppression(ruleId, targetUserId) > 0;
        } catch (Exception e) {
            // 테이블 미존재 등 예외 시 억제 안 함 (안전)
            logger.warn("Suppression check failed, proceeding with alert: {}", e.getMessage());
            return false;
        }
    }

    private void insertAlertAndNotify(AccessLogAlertVO alert, AccessLogAlertRuleVO rule) {
        // 억제 규칙 확인
        if (isSuppressed(rule.getRuleId(), alert.getTargetUserId())) {
            LogUtil.log("INFO", "Alert suppressed: rule=" + rule.getRuleCode()
                    + ", user=" + alert.getTargetUserId());
            return;
        }

        mapper.insertAlert(alert);

        // 관리자에게 알림 (HIGH severity)
        if ("HIGH".equals(rule.getSeverity())) {
            try {
                emailService.sendAlertNotification(alert);
            } catch (Exception e) {
                logger.error("Email notification failed for alert: {}", alert.getAlertTitle(), e);
            }
        }

        // 대상자 이메일이 TBL_MEMBER에 있으면 자동 소명 요청 발송
        try {
            Map<String, Object> memberInfo = mapper.selectMemberEmail(alert.getTargetUserId());
            if (memberInfo != null && memberInfo.get("email") != null
                    && !((String) memberInfo.get("email")).trim().isEmpty()) {
                String email = ((String) memberInfo.get("email")).trim();
                String baseUrl = "http://localhost:" + serverPort;

                // 설정에서 baseUrl 가져오기 (있으면)
                AccessLogConfigVO baseUrlCfg = mapper.selectConfigByKey("DLM_BASE_URL");
                if (baseUrlCfg != null && baseUrlCfg.getConfigValue() != null
                        && !baseUrlCfg.getConfigValue().trim().isEmpty()) {
                    baseUrl = baseUrlCfg.getConfigValue().trim();
                }

                accessLogService.sendJustificationRequest(alert.getAlertId(), email, baseUrl, "system");
                LogUtil.log("INFO", "Auto justification request sent: alertId=" + alert.getAlertId() + ", email=" + email);
            }
        } catch (Exception e) {
            logger.error("Auto justification request failed for alert: {}", alert.getAlertTitle(), e);
        }
    }
}
