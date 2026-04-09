package datablocks.dlm.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
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

    @Autowired
    private AccessLogMapper mapper;

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
    @Transactional
    public boolean updateAlertStatus(Long alertId, String status, String userId, String comment) {
        LogUtil.log("INFO", "AccessLog updateAlertStatus: " + alertId + " -> " + status);
        return mapper.updateAlertStatus(alertId, status, userId, comment) == 1;
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

    // ========== Utility ==========
    /**
     * SHA-256 해시 체인 생성
     * hash = SHA256(logId + userAccount + accessTime + actionType + prevHash)
     */
    private String computeHash(AccessLogVO log) {
        try {
            String input = String.valueOf(log.getLogId() != null ? log.getLogId() : "")
                    + (log.getUserAccount() != null ? log.getUserAccount() : "")
                    + (log.getAccessTime() != null ? log.getAccessTime() : "")
                    + (log.getActionType() != null ? log.getActionType() : "")
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
