package datablocks.dlm.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.*;

/**
 * Access Log Mapper Interface
 * 접속기록관리 매퍼
 */
public interface AccessLogMapper {

    // ========== Dashboard ==========
    AccessLogStatVO getDashboardStats(@Param("sourceId") String sourceId);

    List<Map<String, Object>> selectHourlyAccessTrend(@Param("date") String date);

    List<Map<String, Object>> selectActionTypeDistribution(@Param("date") String date);

    // ========== Access Log (접속기록) ==========
    void insertAccessLog(AccessLogVO log);

    void insertAccessLogBatch(@Param("list") List<AccessLogVO> list);

    AccessLogVO selectAccessLog(@Param("logId") Long logId);

    List<AccessLogVO> selectAccessLogList(Criteria cri);

    int selectAccessLogTotal(Criteria cri);

    String selectLastHash();

    // ========== Access Log Source (수집 대상) ==========
    void insertSource(AccessLogSourceVO source);

    AccessLogSourceVO selectSource(@Param("sourceId") String sourceId);

    AccessLogSourceVO selectSourceByDbName(@Param("dbName") String dbName);

    List<AccessLogSourceVO> selectSourceList(Criteria cri);

    int selectSourceTotal(Criteria cri);

    int updateSource(AccessLogSourceVO source);

    int deleteSource(@Param("sourceId") String sourceId);

    int updateSourceStatus(@Param("sourceId") String sourceId,
                           @Param("status") String status,
                           @Param("errorMsg") String errorMsg);

    int updateSourceCollectInfo(@Param("sourceId") String sourceId,
                                @Param("lastCollectTime") String lastCollectTime,
                                @Param("collectedCount") long collectedCount);

    // ========== Collect Status (수집 상태) ==========
    void insertCollectStatus(AccessLogCollectStatusVO status);

    AccessLogCollectStatusVO selectLatestCollectStatus(@Param("sourceId") String sourceId);

    List<AccessLogCollectStatusVO> selectCollectStatusList(@Param("sourceId") String sourceId);

    // ========== Alert (이상행위 알림) ==========
    void insertAlert(AccessLogAlertVO alert);

    AccessLogAlertVO selectAlert(@Param("alertId") Long alertId);

    List<AccessLogAlertVO> selectAlertList(Criteria cri);

    int selectAlertTotal(Criteria cri);

    List<AccessLogAlertVO> selectLatestAlerts(@Param("limit") int limit);

    int updateAlertStatus(@Param("alertId") Long alertId,
                          @Param("status") String status,
                          @Param("resolvedBy") String resolvedBy,
                          @Param("resolveComment") String resolveComment);

    int bulkUpdateAlertStatus(@Param("alertIds") List<Long> alertIds,
                              @Param("status") String status,
                              @Param("resolvedBy") String resolvedBy,
                              @Param("resolveComment") String resolveComment);

    int bulkUpdateAlertApproval(@Param("alertIds") List<Long> alertIds,
                                @Param("approverId") String approverId,
                                @Param("approvalComment") String approvalComment);

    // -- Justification Workflow --
    AccessLogAlertVO selectAlertByToken(@Param("token") String token);

    int updateAlertNotification(@Param("alertId") Long alertId,
                                @Param("token") String token,
                                @Param("tokenExpiresAt") String tokenExpiresAt,
                                @Param("targetUserEmail") String targetUserEmail,
                                @Param("slaDeadline") String slaDeadline);

    int updateAlertJustification(@Param("alertId") Long alertId,
                                 @Param("justification") String justification,
                                 @Param("justifiedBy") String justifiedBy);

    int updateAlertApproval(@Param("alertId") Long alertId,
                            @Param("status") String status,
                            @Param("approverId") String approverId,
                            @Param("approvalComment") String approvalComment,
                            @Param("newToken") String newToken,
                            @Param("newTokenExpiresAt") String newTokenExpiresAt);

    List<AccessLogAlertVO> selectOverdueAlerts();

    List<AccessLogAlertVO> selectEscalationAlerts();

    int updateAlertEscalation(@Param("alertId") Long alertId,
                              @Param("status") String status,
                              @Param("escalationLevel") int escalationLevel);

    // ========== Alert Rule (탐지 규칙) ==========
    void insertAlertRule(AccessLogAlertRuleVO rule);

    AccessLogAlertRuleVO selectAlertRule(@Param("ruleId") String ruleId);

    List<AccessLogAlertRuleVO> selectAlertRuleList();

    int updateAlertRule(AccessLogAlertRuleVO rule);

    int deleteAlertRule(@Param("ruleId") String ruleId);

    // ========== Config (설정) ==========
    void insertConfig(AccessLogConfigVO config);

    AccessLogConfigVO selectConfig(@Param("configId") String configId);

    AccessLogConfigVO selectConfigByKey(@Param("configKey") String configKey);

    List<AccessLogConfigVO> selectConfigList();

    List<AccessLogConfigVO> selectConfigListByType(@Param("configType") String configType);

    int updateConfig(AccessLogConfigVO config);

    int deleteConfig(@Param("configId") String configId);

    // ========== Hash Verify (무결성 검증) ==========
    void insertHashVerify(@Param("verifyDate") String verifyDate,
                          @Param("totalRecords") long totalRecords,
                          @Param("validRecords") long validRecords,
                          @Param("invalidRecords") long invalidRecords,
                          @Param("firstInvalidId") Long firstInvalidId,
                          @Param("status") String status);

    List<Map<String, Object>> selectHashVerifyList(Criteria cri);

    // ========== Download (다운로드 감사) ==========
    void insertDownloadLog(@Param("userId") String userId,
                           @Param("userName") String userName,
                           @Param("searchCriteria") String searchCriteria,
                           @Param("recordCount") int recordCount,
                           @Param("fileFormat") String fileFormat,
                           @Param("reason") String reason,
                           @Param("clientIp") String clientIp);

    // ========== Partition & Archive ==========
    List<Map<String, Object>> selectPartitionInfo();

    void executePartitionDDL(@Param("sql") String sql);

    Long selectPartitionRecordCount(@Param("partitionName") String partitionName);

    void insertArchiveHistory(@Param("actionType") String actionType,
                              @Param("partitionName") String partitionName,
                              @Param("targetMonth") String targetMonth,
                              @Param("recordCount") long recordCount,
                              @Param("status") String status,
                              @Param("errorMsg") String errorMsg);

    // ========== Agent Heartbeat ==========
    int updateAgentHeartbeat(@Param("agentId") String agentId,
                             @Param("agentStatus") String agentStatus);

    AccessLogSourceVO selectSourceByAgentId(@Param("agentId") String agentId);

    // ========== Audit Policy ==========
    /** MetaTable에서 PII 테이블 목록 (스키마.테이블 그룹) */
    List<java.util.Map<String, Object>> selectMetaPiiTables(@Param("dbName") String dbName);

    /** Audit 대상 테이블 저장 (VAL4 = 'AUDIT' / NULL) */
    int updateAuditTarget(@Param("dbName") String dbName, @Param("owner") String owner,
                          @Param("tableName") String tableName, @Param("auditYn") String auditYn);

    /** Audit 대상 일괄 초기화 */
    int clearAuditTargets(@Param("dbName") String dbName);

    // ========== BCI Target ==========
    List<BciTargetVO> selectBciTargets(@Param("dbName") String dbName);
    int insertBciTarget(BciTargetVO target);
    int deleteBciTarget(@Param("targetId") String targetId);
    int clearBciTargets(@Param("dbName") String dbName);
    List<java.util.Map<String, Object>> selectBciPolicyColumns(@Param("dbName") String dbName);
    List<java.util.Map<String, Object>> selectAllTablesForBci(@Param("dbName") String dbName);

    // ========== Exclude SQL Patterns ==========
    List<java.util.Map<String, Object>> selectExcludeSqlPatterns(@Param("sourceType") String sourceType);
    int insertExcludeSqlPattern(@Param("sourceType") String sourceType, @Param("pattern") String pattern,
                                @Param("matchType") String matchType, @Param("description") String description,
                                @Param("regUserId") String regUserId);
    int updateExcludeSqlPattern(@Param("patternId") int patternId, @Param("pattern") String pattern,
                                @Param("matchType") String matchType, @Param("description") String description,
                                @Param("isActive") String isActive);
    int deleteExcludeSqlPattern(@Param("patternId") int patternId);

    // ========== Scheduler ==========
    List<AccessLogSourceVO> selectActiveSourceList();

    // ========== Alert Count ==========
    int selectNewAlertCount();

    /** 규칙+사용자별 미처리 알림 일괄 DISMISSED */
    int dismissByRuleAndUser(@Param("ruleId") String ruleId,
                             @Param("targetUserId") String targetUserId,
                             @Param("resolvedBy") String resolvedBy,
                             @Param("comment") String comment);

    // ========== Compliance Stats (법규 준수현황) ==========
    AccessLogStatVO getComplianceStats();

    // ========== Member Email Lookup ==========
    Map<String, Object> selectMemberEmail(@Param("userId") String userId);

    // ========== Detection Queries ==========
    List<Map<String, Object>> detectVolumeAnomaly(@Param("timeWindowMin") int timeWindowMin,
                                                   @Param("threshold") int threshold);

    List<Map<String, Object>> detectTimeRangeAnomaly(@Param("timeStart") String timeStart,
                                                      @Param("timeEnd") String timeEnd);

    List<Map<String, Object>> detectAccessDenied(@Param("timeWindowMin") int timeWindowMin,
                                                  @Param("threshold") int threshold);

    List<Map<String, Object>> detectPiiGradeAnomaly(@Param("piiGrade") String piiGrade,
                                                     @Param("timeWindowMin") int timeWindowMin,
                                                     @Param("threshold") int threshold);

    List<Map<String, Object>> detectRepeatAccess(@Param("timeWindowMin") int timeWindowMin,
                                                  @Param("threshold") int threshold);

    List<Map<String, Object>> detectNewIp();

    List<Map<String, Object>> detectInactiveAccount(@Param("inactiveDays") int inactiveDays);

    // ========== Alert Suppression (알림 예외 규칙) ==========
    void insertSuppression(AlertSuppressionVO suppression);

    AlertSuppressionVO selectSuppression(@Param("suppressionId") Long suppressionId);

    List<AlertSuppressionVO> selectSuppressionList(Criteria cri);

    int selectSuppressionTotal(Criteria cri);

    int updateSuppressionReview(@Param("suppressionId") Long suppressionId,
                                @Param("reviewedBy") String reviewedBy,
                                @Param("reviewComment") String reviewComment,
                                @Param("nextReviewAt") String nextReviewAt);

    int deactivateSuppression(@Param("suppressionId") Long suppressionId,
                              @Param("deactivatedBy") String deactivatedBy,
                              @Param("deactivateReason") String deactivateReason);

    int extendSuppression(@Param("suppressionId") Long suppressionId,
                          @Param("effectiveUntil") String effectiveUntil,
                          @Param("updUserId") String updUserId);

    /** 탐지 시 억제 규칙 확인: 해당 사용자+규칙에 활성 억제가 있는지 */
    int countActiveSuppression(@Param("ruleId") String ruleId,
                               @Param("targetUserId") String targetUserId);

    /** 해당 사용자+규칙의 활성 억제 규칙 조회 (중복 방지/연장용) */
    AlertSuppressionVO selectActiveSuppressionByRuleAndUser(@Param("ruleId") String ruleId,
                                                            @Param("targetUserId") String targetUserId);

    /** 검토 기한 도래 억제 규칙 조회 */
    List<AlertSuppressionVO> selectSuppressionsDueForReview();

    /** 만료된 억제 규칙 자동 비활성화 */
    int deactivateExpiredSuppressions();

    // ========== Suppression Audit Log ==========
    void insertSuppressionAudit(@Param("suppressionId") Long suppressionId,
                                @Param("actionType") String actionType,
                                @Param("actionDetail") String actionDetail,
                                @Param("actionBy") String actionBy);

    List<Map<String, Object>> selectSuppressionAuditList(@Param("suppressionId") Long suppressionId);
}
