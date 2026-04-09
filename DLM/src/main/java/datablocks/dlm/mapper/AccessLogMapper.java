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

    // ========== Scheduler ==========
    List<AccessLogSourceVO> selectActiveSourceList();

    // ========== Alert Count ==========
    int selectNewAlertCount();

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
}
