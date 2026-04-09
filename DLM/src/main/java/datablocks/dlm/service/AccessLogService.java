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

    // ========== Access Log ==========
    void registerAccessLog(AccessLogVO log);
    void registerAccessLogBatch(List<AccessLogVO> logs);
    AccessLogVO getAccessLog(Long logId);
    List<AccessLogVO> getAccessLogList(Criteria cri);
    int getAccessLogTotal(Criteria cri);

    // ========== Source ==========
    void registerSource(AccessLogSourceVO source);
    AccessLogSourceVO getSource(String sourceId);
    List<AccessLogSourceVO> getSourceList(Criteria cri);
    int getSourceTotal(Criteria cri);
    boolean modifySource(AccessLogSourceVO source);
    boolean removeSource(String sourceId);

    // ========== Alert ==========
    List<AccessLogAlertVO> getAlertList(Criteria cri);
    int getAlertTotal(Criteria cri);
    List<AccessLogAlertVO> getLatestAlerts(int limit);
    boolean updateAlertStatus(Long alertId, String status, String userId, String comment);

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

    // ========== Alert Count ==========
    int getNewAlertCount();

    // ========== Download Audit ==========
    void recordDownload(String userId, String userName, String searchCriteria,
                        int recordCount, String fileFormat, String reason, String clientIp);
}
