package datablocks.dlm.service;

import java.util.List;
import java.util.Map;

import datablocks.dlm.domain.*;

/**
 * Access Log Service Interface
 * 접속기록관리 서비스
 */
public interface AccessLogService {

    // ========== Dashboard ==========
    AccessLogStatVO getDashboardStats(String sourceId);
    Map<String, Object> getDashboardChartData(String date);
    AccessLogStatVO getComplianceStats();

    // ========== Access Log ==========
    void registerAccessLog(AccessLogVO log);
    void registerAccessLogBatch(List<AccessLogVO> logs);
    AccessLogVO getAccessLog(Long logId);
    List<AccessLogVO> getAccessLogList(Criteria cri);
    int getAccessLogTotal(Criteria cri);

    // ========== Source ==========
    void registerSource(AccessLogSourceVO source);
    AccessLogSourceVO getSource(String sourceId);
    AccessLogSourceVO getSourceByDbName(String dbName);
    List<AccessLogSourceVO> getSourceList(Criteria cri);
    int getSourceTotal(Criteria cri);
    boolean modifySource(AccessLogSourceVO source);
    boolean removeSource(String sourceId);

    // ========== Alert ==========
    List<AccessLogAlertVO> getAlertList(Criteria cri);
    int getAlertTotal(Criteria cri);
    AccessLogAlertVO getAlert(Long alertId);
    List<AccessLogAlertVO> getLatestAlerts(int limit);
    boolean updateAlertStatus(Long alertId, String status, String userId, String comment);
    int bulkDismissAlerts(List<Long> alertIds, String userId, String comment);
    int bulkApproveAlerts(List<Long> alertIds, String approverId, String comment);

    // ========== Alert Justification Workflow ==========
    AccessLogAlertVO getAlertByToken(String token);
    boolean sendJustificationRequest(Long alertId, String targetEmail, String baseUrl, String requesterId);
    boolean submitJustification(String token, String justification, String justifiedBy);
    boolean approveAlert(Long alertId, String approverId, String comment);
    boolean rejectAlert(Long alertId, String approverId, String comment, String baseUrl);
    void checkSlaAndEscalate();
    Map<String, Object> getMemberEmail(String userId);

    // ========== Alert Rule ==========
    void registerAlertRule(AccessLogAlertRuleVO rule);
    AccessLogAlertRuleVO getAlertRule(String ruleId);
    List<AccessLogAlertRuleVO> getAlertRuleList();
    boolean modifyAlertRule(AccessLogAlertRuleVO rule);
    boolean removeAlertRule(String ruleId);

    // ========== Config ==========
    void registerConfig(AccessLogConfigVO config);
    AccessLogConfigVO getConfigByKey(String configKey);
    List<AccessLogConfigVO> getConfigList();
    List<AccessLogConfigVO> getConfigListByType(String configType);
    boolean modifyConfig(AccessLogConfigVO config);

    // ========== Hash Verify ==========
    Map<String, Object> verifyHashChain(String date);
    List<Map<String, Object>> getHashVerifyList(Criteria cri);

    /** 규칙+사용자별 미처리 알림 일괄 무시 처리 (DB 전체 대상) */
    int dismissByRuleAndUser(String ruleId, String targetUserId, String userId, String comment);

    // ========== Alert Count ==========
    int getNewAlertCount();

    // ========== Download Audit ==========
    void recordDownload(String userId, String userName, String searchCriteria,
                        int recordCount, String fileFormat, String reason, String clientIp);

    // ========== Alert Suppression (알림 예외 규칙) ==========
    /** 예외 등록 (중복 시 기존 건 연장) — 결과 Map: action(CREATED/EXTENDED), suppressionId */
    Map<String, Object> registerOrExtendSuppression(AlertSuppressionVO suppression, String actionBy);
    void registerSuppression(AlertSuppressionVO suppression, String actionBy);
    AlertSuppressionVO getSuppression(Long suppressionId);
    AlertSuppressionVO getActiveSuppression(String ruleId, String targetUserId);
    List<AlertSuppressionVO> getSuppressionList(Criteria cri);
    int getSuppressionTotal(Criteria cri);
    boolean reviewSuppression(Long suppressionId, String reviewedBy, String reviewComment);
    boolean deactivateSuppression(Long suppressionId, String deactivatedBy, String reason);
    boolean extendSuppression(Long suppressionId, String effectiveUntil, String userId);
    boolean isSuppressed(String ruleId, String targetUserId);
    void processExpiredAndReviewDue();
    List<Map<String, Object>> getSuppressionAuditList(Long suppressionId);
}
