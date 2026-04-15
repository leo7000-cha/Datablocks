package datablocks.dlm.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.AccessLogMapper;
import datablocks.dlm.util.LogUtil;

/**
 * Access Log Service Implementation
 * 접속기록관리 서비스 구현체
 */
@Service
public class AccessLogServiceImpl implements AccessLogService {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogServiceImpl.class);

    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Autowired
    private AccessLogMapper mapper;

    @Autowired
    private AccessLogEmailService emailService;

    // ========== Dashboard ==========
    @Override
    public AccessLogStatVO getDashboardStats(String sourceId) {
        LogUtil.log("INFO", "AccessLog getDashboardStats");
        return mapper.getDashboardStats(sourceId);
    }

    @Override
    public Map<String, Object> getDashboardChartData(String date) {
        LogUtil.log("INFO", "AccessLog getDashboardChartData: " + date);
        Map<String, Object> chartData = new HashMap<>();
        chartData.put("hourlyTrend", mapper.selectHourlyAccessTrend(date));
        chartData.put("actionTypeDistribution", mapper.selectActionTypeDistribution(date));
        return chartData;
    }

    @Override
    public AccessLogStatVO getComplianceStats() {
        LogUtil.log("INFO", "AccessLog getComplianceStats");
        return mapper.getComplianceStats();
    }

    // ========== Access Log ==========
    @Override
    @Transactional
    public void registerAccessLog(AccessLogVO log) {
        LogUtil.log("INFO", "AccessLog registerAccessLog: " + log.getUserAccount() + " -> " + log.getActionType());
        // 해시 체인 생성
        String prevHash = mapper.selectLastHash();
        log.setPrevHash(prevHash != null ? prevHash : "GENESIS");
        log.setHashValue(computeHash(log));
        mapper.insertAccessLog(log);
    }

    @Override
    @Transactional
    public void registerAccessLogBatch(List<AccessLogVO> logs) {
        LogUtil.log("INFO", "AccessLog registerAccessLogBatch: " + logs.size() + " records");
        if (logs.isEmpty()) return;

        // 해시 체인 생성
        String prevHash = mapper.selectLastHash();
        if (prevHash == null) prevHash = "GENESIS";

        for (AccessLogVO log : logs) {
            log.setPrevHash(prevHash);
            String hash = computeHash(log);
            log.setHashValue(hash);
            prevHash = hash;
        }
        mapper.insertAccessLogBatch(logs);
    }

    @Override
    public AccessLogVO getAccessLog(Long logId) {
        LogUtil.log("INFO", "AccessLog getAccessLog: " + logId);
        return mapper.selectAccessLog(logId);
    }

    @Override
    public List<AccessLogVO> getAccessLogList(Criteria cri) {
        LogUtil.log("INFO", "AccessLog getAccessLogList");
        return mapper.selectAccessLogList(cri);
    }

    @Override
    public int getAccessLogTotal(Criteria cri) {
        return mapper.selectAccessLogTotal(cri);
    }

    // ========== Source ==========
    @Override
    @Transactional
    public void registerSource(AccessLogSourceVO source) {
        LogUtil.log("INFO", "AccessLog registerSource: " + source.getSourceName());
        if (source.getSourceId() == null || source.getSourceId().isEmpty()) {
            source.setSourceId(UUID.randomUUID().toString());
        }
        if (source.getIsActive() == null) {
            source.setIsActive("Y");
        }
        mapper.insertSource(source);
    }

    @Override
    public AccessLogSourceVO getSource(String sourceId) {
        LogUtil.log("INFO", "AccessLog getSource: " + sourceId);
        return mapper.selectSource(sourceId);
    }

    @Override
    public AccessLogSourceVO getSourceByDbName(String dbName) {
        return mapper.selectSourceByDbName(dbName);
    }

    @Override
    public List<AccessLogSourceVO> getSourceList(Criteria cri) {
        LogUtil.log("INFO", "AccessLog getSourceList");
        return mapper.selectSourceList(cri);
    }

    @Override
    public int getSourceTotal(Criteria cri) {
        return mapper.selectSourceTotal(cri);
    }

    @Override
    @Transactional
    public boolean modifySource(AccessLogSourceVO source) {
        LogUtil.log("INFO", "AccessLog modifySource: " + source.getSourceId());
        return mapper.updateSource(source) == 1;
    }

    @Override
    @Transactional
    public boolean removeSource(String sourceId) {
        LogUtil.log("INFO", "AccessLog removeSource: " + sourceId);
        return mapper.deleteSource(sourceId) == 1;
    }

    // ========== Alert ==========
    @Override
    public List<AccessLogAlertVO> getAlertList(Criteria cri) {
        LogUtil.log("INFO", "AccessLog getAlertList");
        return mapper.selectAlertList(cri);
    }

    @Override
    public int getAlertTotal(Criteria cri) {
        return mapper.selectAlertTotal(cri);
    }

    @Override
    public List<AccessLogAlertVO> getLatestAlerts(int limit) {
        LogUtil.log("INFO", "AccessLog getLatestAlerts: " + limit);
        return mapper.selectLatestAlerts(limit);
    }

    @Override
    public AccessLogAlertVO getAlert(Long alertId) {
        return mapper.selectAlert(alertId);
    }

    @Override
    @Transactional
    public boolean updateAlertStatus(Long alertId, String status, String userId, String comment) {
        LogUtil.log("INFO", "AccessLog updateAlertStatus: " + alertId + " -> " + status);
        return mapper.updateAlertStatus(alertId, status, userId, comment) == 1;
    }

    @Override
    @Transactional
    public int bulkDismissAlerts(List<Long> alertIds, String userId, String comment) {
        LogUtil.log("INFO", "Bulk dismiss alerts: " + alertIds.size() + " by " + userId);
        return mapper.bulkUpdateAlertStatus(alertIds, "DISMISSED", userId, comment);
    }

    @Override
    @Transactional
    public int bulkApproveAlerts(List<Long> alertIds, String approverId, String comment) {
        LogUtil.log("INFO", "Bulk approve alerts: " + alertIds.size() + " by " + approverId);
        return mapper.bulkUpdateAlertApproval(alertIds, approverId, comment);
    }

    // ========== Alert Justification Workflow ==========

    @Override
    public AccessLogAlertVO getAlertByToken(String token) {
        return mapper.selectAlertByToken(token);
    }

    @Override
    @Transactional
    public boolean sendJustificationRequest(Long alertId, String targetEmail, String baseUrl, String requesterId) {
        AccessLogAlertVO alert = mapper.selectAlert(alertId);
        if (alert == null) return false;

        String token = UUID.randomUUID().toString().replace("-", "");
        LocalDateTime now = LocalDateTime.now();
        String tokenExpires = now.plusHours(72).format(DT_FMT);
        String slaDeadline = now.plusHours(48).format(DT_FMT);

        int updated = mapper.updateAlertNotification(alertId, token, tokenExpires, targetEmail, slaDeadline);
        if (updated != 1) return false;

        // 이메일 발송 (비동기)
        alert.setNotificationToken(token);
        alert.setTargetUserEmail(targetEmail);
        emailService.sendJustificationRequest(alert, baseUrl, token, "72");
        LogUtil.log("INFO", "Justification request sent: alertId=" + alertId + ", email=" + targetEmail);
        return true;
    }

    @Override
    @Transactional
    public boolean submitJustification(String token, String justification, String justifiedBy) {
        AccessLogAlertVO alert = mapper.selectAlertByToken(token);
        if (alert == null) {
            LogUtil.log("WARN", "Justification submit: invalid token");
            return false;
        }
        // 토큰 만료 체크
        if (alert.getTokenExpiresAt() != null) {
            LocalDateTime expires = LocalDateTime.parse(alert.getTokenExpiresAt(), DT_FMT);
            if (LocalDateTime.now().isAfter(expires)) {
                LogUtil.log("WARN", "Justification submit: token expired for alertId=" + alert.getAlertId());
                return false;
            }
        }
        // NOTIFIED 또는 RE_JUSTIFY 상태에서만 소명 가능
        if (!"NOTIFIED".equals(alert.getStatus()) && !"RE_JUSTIFY".equals(alert.getStatus())) {
            LogUtil.log("WARN", "Justification submit: invalid status=" + alert.getStatus());
            return false;
        }

        int updated = mapper.updateAlertJustification(alert.getAlertId(), justification, justifiedBy);
        LogUtil.log("INFO", "Justification submitted: alertId=" + alert.getAlertId());

        // 관리자에게 소명 완료 알림
        emailService.sendJustificationCompleteNotice(alert, justifiedBy);
        return updated == 1;
    }

    @Override
    @Transactional
    public boolean approveAlert(Long alertId, String approverId, String comment) {
        LogUtil.log("INFO", "Alert approved: alertId=" + alertId + " by " + approverId);
        return mapper.updateAlertApproval(alertId, "RESOLVED", approverId, comment, null, null) == 1;
    }

    @Override
    @Transactional
    public boolean rejectAlert(Long alertId, String approverId, String comment, String baseUrl) {
        String newToken = UUID.randomUUID().toString().replace("-", "");
        String newTokenExpires = LocalDateTime.now().plusHours(72).format(DT_FMT);

        int updated = mapper.updateAlertApproval(alertId, "RE_JUSTIFY", approverId, comment, newToken, newTokenExpires);
        if (updated == 1) {
            // 대상자에게 재소명 요청 이메일
            AccessLogAlertVO alert = mapper.selectAlert(alertId);
            if (alert != null && alert.getTargetUserEmail() != null) {
                emailService.sendReJustificationRequest(alert, baseUrl, newToken, comment);
            }
            LogUtil.log("INFO", "Re-justification requested: alertId=" + alertId);
        }
        return updated == 1;
    }

    @Override
    @Transactional
    public void checkSlaAndEscalate() {
        // NOTIFIED 상태에서 SLA 초과 → OVERDUE
        List<AccessLogAlertVO> overdueAlerts = mapper.selectOverdueAlerts();
        for (AccessLogAlertVO alert : overdueAlerts) {
            mapper.updateAlertEscalation(alert.getAlertId(), "OVERDUE", 1);
            LogUtil.log("WARN", "Alert OVERDUE: alertId=" + alert.getAlertId());
            emailService.sendOverdueNotice(alert);
        }

        // OVERDUE 상태에서 24시간 추가 경과 → ESCALATED
        List<AccessLogAlertVO> escalationAlerts = mapper.selectEscalationAlerts();
        for (AccessLogAlertVO alert : escalationAlerts) {
            mapper.updateAlertEscalation(alert.getAlertId(), "ESCALATED", 2);
            LogUtil.log("WARN", "Alert ESCALATED: alertId=" + alert.getAlertId());
            emailService.sendEscalationNotice(alert);
        }
    }

    @Override
    public Map<String, Object> getMemberEmail(String userId) {
        return mapper.selectMemberEmail(userId);
    }

    // ========== Alert Rule ==========
    @Override
    @Transactional
    public void registerAlertRule(AccessLogAlertRuleVO rule) {
        LogUtil.log("INFO", "AccessLog registerAlertRule: " + rule.getRuleName());
        if (rule.getRuleId() == null || rule.getRuleId().isEmpty()) {
            rule.setRuleId(UUID.randomUUID().toString());
        }
        mapper.insertAlertRule(rule);
    }

    @Override
    public AccessLogAlertRuleVO getAlertRule(String ruleId) {
        return mapper.selectAlertRule(ruleId);
    }

    @Override
    public List<AccessLogAlertRuleVO> getAlertRuleList() {
        return mapper.selectAlertRuleList();
    }

    @Override
    @Transactional
    public boolean modifyAlertRule(AccessLogAlertRuleVO rule) {
        LogUtil.log("INFO", "AccessLog modifyAlertRule: " + rule.getRuleId());
        return mapper.updateAlertRule(rule) == 1;
    }

    @Override
    @Transactional
    public boolean removeAlertRule(String ruleId) {
        LogUtil.log("INFO", "AccessLog removeAlertRule: " + ruleId);
        return mapper.deleteAlertRule(ruleId) == 1;
    }

    // ========== Config ==========
    @Override
    @Transactional
    public void registerConfig(AccessLogConfigVO config) {
        LogUtil.log("INFO", "AccessLog registerConfig: " + config.getConfigKey());
        if (config.getConfigId() == null || config.getConfigId().isEmpty()) {
            config.setConfigId(UUID.randomUUID().toString());
        }
        mapper.insertConfig(config);
    }

    @Override
    public AccessLogConfigVO getConfigByKey(String configKey) {
        return mapper.selectConfigByKey(configKey);
    }

    @Override
    public List<AccessLogConfigVO> getConfigList() {
        return mapper.selectConfigList();
    }

    @Override
    public List<AccessLogConfigVO> getConfigListByType(String configType) {
        return mapper.selectConfigListByType(configType);
    }

    @Override
    @Transactional
    public boolean modifyConfig(AccessLogConfigVO config) {
        LogUtil.log("INFO", "AccessLog modifyConfig: " + config.getConfigId());
        return mapper.updateConfig(config) == 1;
    }

    // ========== Hash Verify ==========
    @Override
    @Transactional
    public Map<String, Object> verifyHashChain(String date) {
        LogUtil.log("INFO", "AccessLog verifyHashChain: " + date);
        Map<String, Object> result = new HashMap<>();

        Criteria cri = new Criteria();
        cri.setAmount(Integer.MAX_VALUE);
        cri.setSearch7(date + " 00:00:00");
        cri.setSearch8(date + " 23:59:59");

        List<AccessLogVO> logs = mapper.selectAccessLogList(cri);
        long total = logs.size();
        long valid = 0;
        long invalid = 0;
        Long firstInvalidId = null;

        for (AccessLogVO log : logs) {
            String expectedHash = computeHash(log);
            if (expectedHash.equals(log.getHashValue())) {
                valid++;
            } else {
                invalid++;
                if (firstInvalidId == null) {
                    firstInvalidId = log.getLogId();
                }
            }
        }

        String status = invalid == 0 ? "VALID" : "INVALID";
        mapper.insertHashVerify(date, total, valid, invalid, firstInvalidId, status);

        result.put("date", date);
        result.put("totalRecords", total);
        result.put("validRecords", valid);
        result.put("invalidRecords", invalid);
        result.put("status", status);
        return result;
    }

    @Override
    public List<Map<String, Object>> getHashVerifyList(Criteria cri) {
        return mapper.selectHashVerifyList(cri);
    }

    @Override
    @Transactional
    public int dismissByRuleAndUser(String ruleId, String targetUserId, String userId, String comment) {
        LogUtil.log("INFO", "Dismiss by rule+user: ruleId=" + ruleId + ", user=" + targetUserId + " by " + userId);
        return mapper.dismissByRuleAndUser(ruleId, targetUserId, userId, comment);
    }

    // ========== Alert Count ==========
    @Override
    public int getNewAlertCount() {
        return mapper.selectNewAlertCount();
    }

    // ========== Download Audit ==========
    @Override
    @Transactional
    public void recordDownload(String userId, String userName, String searchCriteria,
                               int recordCount, String fileFormat, String reason, String clientIp) {
        LogUtil.log("INFO", "AccessLog recordDownload: " + userId);
        mapper.insertDownloadLog(userId, userName, searchCriteria, recordCount, fileFormat, reason, clientIp);
    }

    // ========== Alert Suppression (알림 예외 규칙) ==========

    @Override
    @Transactional
    public Map<String, Object> registerOrExtendSuppression(AlertSuppressionVO suppression, String actionBy) {
        Map<String, Object> result = new HashMap<>();

        // 기존 활성 억제 규칙 확인
        AlertSuppressionVO existing = mapper.selectActiveSuppressionByRuleAndUser(
                suppression.getRuleId(), suppression.getTargetUserId());

        if (existing != null) {
            // 기존 건의 만료일과 새로 요청한 만료일 비교 → 더 긴 쪽으로 연장
            String newUntil = suppression.getEffectiveUntil();
            if (newUntil != null && newUntil.compareTo(existing.getEffectiveUntil()) > 0) {
                mapper.extendSuppression(existing.getSuppressionId(), newUntil, actionBy);
                mapper.insertSuppressionAudit(existing.getSuppressionId(), "EXTEND",
                        "중복 무시 처리로 유효기간 연장 → " + newUntil
                                + " (사유: " + truncate(suppression.getReason(), 150) + ")",
                        actionBy);
                LogUtil.log("INFO", "Suppression extended (duplicate dismiss): id=" + existing.getSuppressionId());
            } else {
                // 만료일이 기존 건보다 짧으면 연장하지 않고 감사 로그만 남김
                mapper.insertSuppressionAudit(existing.getSuppressionId(), "DUPLICATE_SKIP",
                        "동일 조건 무시 처리 — 기존 예외(만료: " + existing.getEffectiveUntil() + ")가 유효하여 유지"
                                + " (사유: " + truncate(suppression.getReason(), 150) + ")",
                        actionBy);
            }
            result.put("action", "EXTENDED");
            result.put("suppressionId", existing.getSuppressionId());
            result.put("existingUntil", existing.getEffectiveUntil());
        } else {
            // 신규 등록
            registerSuppression(suppression, actionBy);
            result.put("action", "CREATED");
            result.put("suppressionId", suppression.getSuppressionId());
        }
        return result;
    }

    @Override
    @Transactional
    public void registerSuppression(AlertSuppressionVO suppression, String actionBy) {
        LogUtil.log("INFO", "Register suppression: ruleId=" + suppression.getRuleId()
                + ", user=" + suppression.getTargetUserId());
        mapper.insertSuppression(suppression);
        mapper.insertSuppressionAudit(suppression.getSuppressionId(), "CREATE",
                "예외 규칙 등록 — 사유: " + truncate(suppression.getReason(), 200)
                        + ", 만료: " + suppression.getEffectiveUntil()
                        + (suppression.getTargetUserId() != null ? ", 대상자: " + suppression.getTargetUserId() : ", 대상: 전체"),
                actionBy);
    }

    @Override
    public AlertSuppressionVO getSuppression(Long suppressionId) {
        return mapper.selectSuppression(suppressionId);
    }

    @Override
    public AlertSuppressionVO getActiveSuppression(String ruleId, String targetUserId) {
        return mapper.selectActiveSuppressionByRuleAndUser(ruleId, targetUserId);
    }

    @Override
    public List<AlertSuppressionVO> getSuppressionList(Criteria cri) {
        return mapper.selectSuppressionList(cri);
    }

    @Override
    public int getSuppressionTotal(Criteria cri) {
        return mapper.selectSuppressionTotal(cri);
    }

    @Override
    @Transactional
    public boolean reviewSuppression(Long suppressionId, String reviewedBy, String reviewComment) {
        AlertSuppressionVO s = mapper.selectSuppression(suppressionId);
        if (s == null) return false;

        String nextReview = LocalDateTime.now().plusDays(s.getReviewCycleDays()).format(DT_FMT);
        int updated = mapper.updateSuppressionReview(suppressionId, reviewedBy, reviewComment, nextReview);

        if (updated == 1) {
            mapper.insertSuppressionAudit(suppressionId, "REVIEW",
                    "정기 검토 완료 — 의견: " + truncate(reviewComment, 200) + ", 다음 검토: " + nextReview,
                    reviewedBy);
            LogUtil.log("INFO", "Suppression reviewed: id=" + suppressionId + " by " + reviewedBy);
        }
        return updated == 1;
    }

    @Override
    @Transactional
    public boolean deactivateSuppression(Long suppressionId, String deactivatedBy, String reason) {
        int updated = mapper.deactivateSuppression(suppressionId, deactivatedBy, reason);
        if (updated == 1) {
            mapper.insertSuppressionAudit(suppressionId, "DEACTIVATE",
                    "예외 규칙 비활성화 — 사유: " + truncate(reason, 200), deactivatedBy);
            LogUtil.log("INFO", "Suppression deactivated: id=" + suppressionId);
        }
        return updated == 1;
    }

    @Override
    @Transactional
    public boolean extendSuppression(Long suppressionId, String effectiveUntil, String userId) {
        int updated = mapper.extendSuppression(suppressionId, effectiveUntil, userId);
        if (updated == 1) {
            mapper.insertSuppressionAudit(suppressionId, "EXTEND",
                    "유효기간 연장 → " + effectiveUntil, userId);
            LogUtil.log("INFO", "Suppression extended: id=" + suppressionId + " until " + effectiveUntil);
        }
        return updated == 1;
    }

    @Override
    public boolean isSuppressed(String ruleId, String targetUserId) {
        return mapper.countActiveSuppression(ruleId, targetUserId) > 0;
    }

    @Override
    @Transactional
    public void processExpiredAndReviewDue() {
        // 1. 만료된 억제 규칙 자동 비활성화
        int expired = mapper.deactivateExpiredSuppressions();
        if (expired > 0) {
            LogUtil.log("INFO", "Auto-deactivated " + expired + " expired suppressions");
        }

        // 2. 검토 기한 도래 건 로깅 (이메일 알림은 추후 확장)
        List<AlertSuppressionVO> dueForReview = mapper.selectSuppressionsDueForReview();
        if (!dueForReview.isEmpty()) {
            LogUtil.log("WARN", dueForReview.size() + " suppression rules due for review");
        }
    }

    @Override
    public List<Map<String, Object>> getSuppressionAuditList(Long suppressionId) {
        return mapper.selectSuppressionAuditList(suppressionId);
    }

    private String truncate(String s, int maxLen) {
        if (s == null) return "";
        return s.length() > maxLen ? s.substring(0, maxLen) + "..." : s;
    }

    // ========== Utility ==========
    /**
     * SHA-256 해시 체인 생성
     * hash = SHA256(userAccount + accessTime + actionType + targetTable + prevHash)
     *
     * 주의: logId는 AUTO_INCREMENT이므로 INSERT 전에는 null → 해시에 포함하면
     * 생성 시(null)와 검증 시(실제값)의 해시가 불일치. 따라서 logId 제외.
     */
    private String computeHash(AccessLogVO log) {
        try {
            String input = (log.getUserAccount() != null ? log.getUserAccount() : "")
                    + (log.getAccessTime() != null ? log.getAccessTime() : "")
                    + (log.getActionType() != null ? log.getActionType() : "")
                    + (log.getTargetTable() != null ? log.getTargetTable() : "")
                    + (log.getPrevHash() != null ? log.getPrevHash() : "");

            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            logger.error("Hash computation failed", e);
            return "ERROR";
        }
    }
}
