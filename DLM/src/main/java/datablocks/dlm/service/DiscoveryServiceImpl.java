package datablocks.dlm.service;

import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import datablocks.dlm.domain.*;
import datablocks.dlm.engine.DiscoveryEngine;
import datablocks.dlm.mapper.DiscoveryMapper;
import datablocks.dlm.util.LogUtil;

/**
 * Discovery Service Implementation
 * PII 자동탐지 서비스 구현체
 *
 * Job/Execution 분리 패턴:
 * - Job: 스캔 작업 정의 (템플릿)
 * - Execution: 스캔 실행 이력 (인스턴스)
 */
@Service
public class DiscoveryServiceImpl implements DiscoveryService {

    private static final Logger logger = LoggerFactory.getLogger(DiscoveryServiceImpl.class);

    @Autowired
    private DiscoveryMapper mapper;

    @Autowired
    private DiscoveryEngine discoveryEngine;

    @Autowired
    private PiiDatabaseService databaseService;

    // ========== Dashboard ==========
    @Override
    public DiscoveryStatVO getDashboardStats() {
        LogUtil.log("INFO", "Discovery getDashboardStats");
        return mapper.getDashboardStats();
    }

    @Override
    public java.util.Map<String, Object> getDashboardChartData() {
        LogUtil.log("INFO", "Discovery getDashboardChartData");
        java.util.Map<String, Object> chartData = new java.util.HashMap<>();
        chartData.put("piiTypeDistribution", mapper.selectPiiTypeDistribution());
        chartData.put("scoreDistribution", mapper.selectScoreDistribution());
        chartData.put("topPiiTables", mapper.selectTopPiiTables());
        return chartData;
    }

    // ========== Scan Jobs (템플릿 관리) ==========
    @Override
    @Transactional
    public void registerScanJob(DiscoveryScanJobVO job) {
        LogUtil.log("INFO", "Discovery registerScanJob: " + job.getJobName());
        if (job.getJobId() == null || job.getJobId().isEmpty()) {
            job.setJobId(UUID.randomUUID().toString());
        }
        // Job은 템플릿이므로 실행 상태 없음 - 기본값만 설정
        if (job.getIsActive() == null) {
            job.setIsActive("Y");
        }
        mapper.insertScanJob(job);
    }

    @Override
    public DiscoveryScanJobVO getScanJob(String jobId) {
        LogUtil.log("INFO", "Discovery getScanJob: " + jobId);
        return mapper.selectScanJob(jobId);
    }

    @Override
    public List<DiscoveryScanJobVO> getScanJobList(Criteria cri) {
        LogUtil.log("INFO", "Discovery getScanJobList");
        return mapper.selectScanJobList(cri);
    }

    @Override
    public int getScanJobTotal(Criteria cri) {
        return mapper.selectScanJobTotal(cri);
    }

    @Override
    @Transactional
    public boolean modifyScanJob(DiscoveryScanJobVO job) {
        LogUtil.log("INFO", "Discovery modifyScanJob: " + job.getJobId());
        return mapper.updateScanJob(job) == 1;
    }

    @Override
    @Transactional
    public boolean removeScanJob(String jobId) {
        LogUtil.log("INFO", "Discovery removeScanJob: " + jobId);
        // 관련 실행 이력 및 결과도 삭제
        mapper.deleteScanResultByJobId(jobId);
        mapper.deleteExecutionsByJobId(jobId);
        return mapper.deleteScanJob(jobId) == 1;
    }

    // ========== Scan Executions (실행 관리) ==========
    @Override
    @Transactional
    public String executeScan(String jobId) {
        LogUtil.log("INFO", "Discovery executeScan: " + jobId);

        // 1. 작업 정보 조회
        DiscoveryScanJobVO job = mapper.selectScanJob(jobId);
        if (job == null) {
            LogUtil.log("ERROR", "Scan job not found: " + jobId);
            return null;
        }

        // 2. 대상 DB 정보 조회
        PiiDatabaseVO dbInfo = databaseService.get(job.getTargetDb());
        if (dbInfo == null) {
            LogUtil.log("ERROR", "Database not found: " + job.getTargetDb());
            return null;
        }

        // 3. 새로운 실행(Execution) 생성 (동기 - 즉시 executionId 반환)
        String executionId = UUID.randomUUID().toString();
        DiscoveryScanExecutionVO execution = new DiscoveryScanExecutionVO();
        execution.setExecutionId(executionId);
        execution.setJobId(jobId);
        execution.setStatus("PENDING");
        execution.setProgress(0);
        execution.setThreadCount(job.getThreadCount() != null ? job.getThreadCount() : 5);
        mapper.insertExecution(execution);

        // 4. Job의 마지막 실행 정보 업데이트
        mapper.updateJobLastExecution(jobId, executionId);

        // 5. 스캔 엔진 실행 (비동기 - 별도 스레드에서 실행)
        executeEngineAsync(job, dbInfo, executionId);

        return executionId;
    }

    @Override
    @Transactional
    public String resumeScan(String executionId) {
        LogUtil.log("INFO", "Discovery resumeScan: " + executionId);

        // 1. 기존 Execution 조회
        DiscoveryScanExecutionVO execution = mapper.selectExecution(executionId);
        if (execution == null) {
            LogUtil.log("ERROR", "Execution not found: " + executionId);
            return null;
        }

        // FAILED 또는 CANCELLED 상태만 재시작 가능
        if (!"FAILED".equals(execution.getStatus()) && !"CANCELLED".equals(execution.getStatus())) {
            LogUtil.log("ERROR", "Cannot resume execution with status: " + execution.getStatus());
            return null;
        }

        // 2. Job 정보 조회
        DiscoveryScanJobVO job = mapper.selectScanJob(execution.getJobId());
        if (job == null) {
            LogUtil.log("ERROR", "Scan job not found: " + execution.getJobId());
            return null;
        }

        // 3. 대상 DB 정보 조회
        PiiDatabaseVO dbInfo = databaseService.get(job.getTargetDb());
        if (dbInfo == null) {
            LogUtil.log("ERROR", "Database not found: " + job.getTargetDb());
            return null;
        }

        // 4. 기존 Execution 상태를 PENDING으로 리셋 (동일 executionId 재사용)
        mapper.updateExecutionStatus(executionId, "PENDING", 0);

        // 5. 스캔 엔진 실행 (비동기 - 기존 executionId → 완료된 테이블 자동 스킵)
        executeEngineAsync(job, dbInfo, executionId);

        return executionId;
    }

    /**
     * 스캔 엔진 비동기 실행 (setup 완료 후 별도 스레드에서 실행)
     */
    @Async
    public void executeEngineAsync(DiscoveryScanJobVO job, PiiDatabaseVO dbInfo, String executionId) {
        try {
            discoveryEngine.executeScan(job, dbInfo, executionId);
        } catch (Exception e) {
            logger.error("Scan execution failed: " + executionId, e);
            updateExecutionFailed(executionId, e.getMessage());
        }
    }

    @Override
    public DiscoveryScanExecutionVO getExecution(String executionId) {
        LogUtil.log("INFO", "Discovery getExecution: " + executionId);
        return mapper.selectExecution(executionId);
    }

    @Override
    public List<DiscoveryScanExecutionVO> getExecutionList(Criteria cri) {
        LogUtil.log("INFO", "Discovery getExecutionList");
        return mapper.selectExecutionList(cri);
    }

    @Override
    public List<DiscoveryScanExecutionVO> getExecutionListByJobId(String jobId) {
        LogUtil.log("INFO", "Discovery getExecutionListByJobId: " + jobId);
        return mapper.selectExecutionListByJobId(jobId);
    }

    @Override
    public int getExecutionTotal(Criteria cri) {
        return mapper.selectExecutionTotal(cri);
    }

    @Override
    @Transactional
    public boolean updateExecutionStatus(String executionId, String status, Integer progress) {
        LogUtil.log("INFO", "Discovery updateExecutionStatus: " + executionId + " -> " + status);
        return mapper.updateExecutionStatus(executionId, status, progress) == 1;
    }

    @Override
    @Transactional
    public boolean updateExecutionFailed(String executionId, String errorMsg) {
        LogUtil.log("ERROR", "Discovery updateExecutionFailed: " + executionId + " - " + errorMsg);
        return mapper.updateExecutionFailed(executionId, errorMsg) == 1;
    }

    @Override
    @Transactional
    public void cancelScan(String executionId) {
        LogUtil.log("INFO", "Discovery cancelScan: " + executionId);
        // 엔진에 취소 신호 전송
        discoveryEngine.cancelScan(executionId);
        updateExecutionStatus(executionId, "CANCELLED", null);
    }

    @Override
    public DiscoveryScanProgressVO getScanProgress(String executionId) {
        LogUtil.log("INFO", "Discovery getScanProgress: " + executionId);
        return discoveryEngine.getScanProgress(executionId);
    }

    // ========== Scan Results ==========
    @Override
    @Transactional
    public void registerScanResult(DiscoveryScanResultVO result) {
        LogUtil.log("INFO", "Discovery registerScanResult: " + result.getTableName() + "." + result.getColumnName());
        if (result.getResultId() == null || result.getResultId().isEmpty()) {
            result.setResultId(UUID.randomUUID().toString());
        }
        result.setConfirmStatus("PENDING");
        mapper.insertScanResult(result);
    }

    @Override
    @Transactional
    public void registerScanResultBatch(List<DiscoveryScanResultVO> results) {
        LogUtil.log("INFO", "Discovery registerScanResultBatch: " + results.size() + " results");
        for (DiscoveryScanResultVO result : results) {
            registerScanResult(result);
        }
    }

    @Override
    public DiscoveryScanResultVO getScanResult(String resultId) {
        LogUtil.log("INFO", "Discovery getScanResult: " + resultId);
        return mapper.selectScanResult(resultId);
    }

    @Override
    public List<DiscoveryScanResultVO> getScanResultList(Criteria cri) {
        LogUtil.log("INFO", "Discovery getScanResultList");
        return mapper.selectScanResultList(cri);
    }

    @Override
    public int getScanResultTotal(Criteria cri) {
        return mapper.selectScanResultTotal(cri);
    }

    @Override
    @Transactional
    public boolean confirmScanResult(String resultId, String confirmStatus, String userId) {
        LogUtil.log("INFO", "Discovery confirmScanResult: " + resultId + " -> " + confirmStatus);
        return mapper.updateScanResultConfirm(resultId, confirmStatus, userId) == 1;
    }

    @Override
    @Transactional
    public boolean confirmScanResultBatch(List<String> resultIds, String confirmStatus, String userId) {
        LogUtil.log("INFO", "Discovery confirmScanResultBatch: " + resultIds.size() + " results -> " + confirmStatus);
        int count = 0;
        for (String resultId : resultIds) {
            if (mapper.updateScanResultConfirm(resultId, confirmStatus, userId) == 1) {
                count++;
            }
        }
        return count == resultIds.size();
    }

    // ========== Rules ==========
    @Override
    @Transactional
    public void registerRule(DiscoveryRuleVO rule) {
        LogUtil.log("INFO", "Discovery registerRule: " + rule.getRuleName());
        if (rule.getRuleId() == null || rule.getRuleId().isEmpty()) {
            rule.setRuleId(UUID.randomUUID().toString());
        }
        mapper.insertRule(rule);
    }

    @Override
    public DiscoveryRuleVO getRule(String ruleId) {
        LogUtil.log("INFO", "Discovery getRule: " + ruleId);
        return mapper.selectRule(ruleId);
    }

    @Override
    public List<DiscoveryRuleVO> getRuleList(Criteria cri) {
        LogUtil.log("INFO", "Discovery getRuleList");
        return mapper.selectRuleList(cri);
    }

    @Override
    public List<DiscoveryRuleVO> getRuleListByCategory(String category) {
        LogUtil.log("INFO", "Discovery getRuleListByCategory: " + category);
        return mapper.selectRuleListByCategory(category);
    }

    @Override
    @Transactional
    public boolean modifyRule(DiscoveryRuleVO rule) {
        LogUtil.log("INFO", "Discovery modifyRule: " + rule.getRuleId());
        return mapper.updateRule(rule) == 1;
    }

    @Override
    @Transactional
    public boolean removeRule(String ruleId) {
        LogUtil.log("INFO", "Discovery removeRule: " + ruleId);
        return mapper.deleteRule(ruleId) == 1;
    }

    // ========== PII Types ==========
    @Override
    public List<DiscoveryPiiTypeVO> getPiiTypeList() {
        LogUtil.log("INFO", "Discovery getPiiTypeList");
        return mapper.selectPiiTypeList();
    }

    @Override
    public DiscoveryPiiTypeVO getPiiType(String piiTypeCode) {
        LogUtil.log("INFO", "Discovery getPiiType: " + piiTypeCode);
        return mapper.selectPiiType(piiTypeCode);
    }

    // ========== Integration ==========
    @Override
    @Transactional
    public int syncToMetaTable(List<String> resultIds) {
        LogUtil.log("INFO", "Discovery syncToMetaTable: " + resultIds.size() + " results");
        // TODO: TBL_METATABLE에 PII 정보 동기화
        int syncCount = 0;
        for (String resultId : resultIds) {
            DiscoveryScanResultVO result = getScanResult(resultId);
            if (result != null && "CONFIRMED".equals(result.getConfirmStatus())) {
                // mapper.syncToMetaTable(result);
                syncCount++;
            }
        }
        return syncCount;
    }

    @Override
    public List<DiscoveryScanResultVO> getConfirmedPiiColumns(Criteria cri) {
        LogUtil.log("INFO", "Discovery getConfirmedPiiColumns");
        return mapper.selectConfirmedPiiColumns(cri);
    }

    // 제외할 시스템/내부 스키마 목록
    private static final java.util.Set<String> EXCLUDED_SCHEMAS = new java.util.HashSet<>(java.util.Arrays.asList(
            // Oracle 시스템 스키마
            "SYS", "SYSTEM", "OUTLN", "DIP", "ORACLE_OCM", "DBSNMP", "APPQOSSYS",
            "WMSYS", "EXFSYS", "CTXSYS", "XDB", "ANONYMOUS", "ORDSYS", "ORDDATA",
            "ORDPLUGINS", "SI_INFORMTN_SCHEMA", "MDSYS", "OLAPSYS", "MDDATA",
            "SPATIAL_WFS_ADMIN_USR", "SPATIAL_CSW_ADMIN_USR", "SYSMAN", "MGMT_VIEW",
            "APEX_PUBLIC_USER", "APEX_030200", "APEX_040000", "APEX_040100", "APEX_040200",
            "FLOWS_FILES", "OWBSYS", "OWBSYS_AUDIT", "SCOTT", "LBACSYS", "DVSYS",
            "DVF", "AUDSYS", "GSMADMIN_INTERNAL", "GSMCATUSER", "GSMUSER", "SYSBACKUP",
            "SYSDG", "SYSKM", "SYSRAC", "OJVMSYS", "XS$NULL", "GGSYS", "DBSFWUSER",
            "REMOTE_SCHEDULER_AGENT", "SYS$UMF",
            // MySQL/MariaDB 시스템 스키마
            "information_schema", "mysql", "performance_schema", "sys",
            // 애플리케이션 내부 스키마 (X-One/DLM 관련)
            "DLM", "DLMARC", "ABLEQ", "COTDL"
    ));

    @Override
    public List<String> getSchemaList(String dbName) {
        LogUtil.log("INFO", "Discovery getSchemaList: " + dbName);
        List<String> schemas = new java.util.ArrayList<>();

        PiiDatabaseVO dbInfo = databaseService.get(dbName);
        if (dbInfo == null) {
            return schemas;
        }

        java.sql.Connection conn = null;
        try {
            // 비밀번호 복호화
            datablocks.dlm.util.AES256Util aes = new datablocks.dlm.util.AES256Util();
            String decryptedPwd = aes.decrypt(dbInfo.getPwd());

            conn = datablocks.dlm.jdbc.ConnectionProvider.getConnection(
                    dbInfo.getDbtype(),
                    dbInfo.getHostname(),
                    dbInfo.getPort(),
                    dbInfo.getId_type(),
                    dbInfo.getId(),
                    dbInfo.getDb(),
                    dbInfo.getDbuser(),
                    decryptedPwd
            );

            java.sql.DatabaseMetaData metaData = conn.getMetaData();
            java.sql.ResultSet rs = metaData.getSchemas();

            while (rs.next()) {
                String schemaName = rs.getString("TABLE_SCHEM");
                if (schemaName != null && !schemaName.isEmpty() && !isExcludedSchema(schemaName)) {
                    schemas.add(schemaName);
                }
            }
            rs.close();

            // Oracle의 경우 getSchemas가 비어있을 수 있으므로 사용자 목록 조회
            if (schemas.isEmpty() && "ORACLE".equalsIgnoreCase(dbInfo.getDbtype())) {
                java.sql.Statement stmt = conn.createStatement();
                rs = stmt.executeQuery("SELECT USERNAME FROM ALL_USERS ORDER BY USERNAME");
                while (rs.next()) {
                    String schemaName = rs.getString("USERNAME");
                    if (!isExcludedSchema(schemaName)) {
                        schemas.add(schemaName);
                    }
                }
                rs.close();
                stmt.close();
            }

        } catch (Exception e) {
            logger.error("Error getting schema list", e);
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (Exception e) {
                    // ignore
                }
            }
        }

        return schemas;
    }

    /**
     * 제외할 스키마 여부 확인
     */
    private boolean isExcludedSchema(String schemaName) {
        if (schemaName == null) return true;
        String upper = schemaName.toUpperCase();
        // 정확히 일치하거나 APEX_, SYS로 시작하는 경우 제외
        return EXCLUDED_SCHEMAS.contains(upper)
                || upper.startsWith("APEX_")
                || upper.startsWith("SYS$")
                || upper.startsWith("ORDS_")
                || upper.startsWith("FLOWS_");
    }

    // ========== Config (설정 관리) ==========
    @Override
    @Transactional
    public void registerConfig(DiscoveryConfigVO config) {
        LogUtil.log("INFO", "Discovery registerConfig: " + config.getConfigKey());
        if (config.getConfigId() == null || config.getConfigId().isEmpty()) {
            config.setConfigId(UUID.randomUUID().toString());
        }
        mapper.insertConfig(config);
    }

    @Override
    public DiscoveryConfigVO getConfig(String configId) {
        LogUtil.log("INFO", "Discovery getConfig: " + configId);
        return mapper.selectConfig(configId);
    }

    @Override
    public DiscoveryConfigVO getConfigByKey(String configKey) {
        LogUtil.log("INFO", "Discovery getConfigByKey: " + configKey);
        return mapper.selectConfigByKey(configKey);
    }

    @Override
    public List<DiscoveryConfigVO> getConfigList() {
        LogUtil.log("INFO", "Discovery getConfigList");
        return mapper.selectConfigList();
    }

    @Override
    public List<DiscoveryConfigVO> getConfigListByType(String configType) {
        LogUtil.log("INFO", "Discovery getConfigListByType: " + configType);
        return mapper.selectConfigListByType(configType);
    }

    @Override
    @Transactional
    public boolean modifyConfig(DiscoveryConfigVO config) {
        LogUtil.log("INFO", "Discovery modifyConfig: " + config.getConfigId());
        return mapper.updateConfig(config) == 1;
    }

    @Override
    @Transactional
    public boolean removeConfig(String configId) {
        LogUtil.log("INFO", "Discovery removeConfig: " + configId);
        return mapper.deleteConfig(configId) == 1;
    }

    // ========== PII Registry (확정된 PII 컬럼 레지스트리) ==========
    // Scan Result와 분리하여 PII 컬럼 상태를 독립적으로 관리

    @Override
    @Transactional
    public void registerToRegistry(String resultId, String status, String userId) {
        LogUtil.log("INFO", "Discovery registerToRegistry: " + resultId + " -> " + status);

        // 1. Scan Result 조회
        DiscoveryScanResultVO result = mapper.selectScanResult(resultId);
        if (result == null) {
            throw new IllegalArgumentException("Scan result not found: " + resultId);
        }

        // 2. Registry VO 생성
        DiscoveryPiiRegistryVO registry = DiscoveryPiiRegistryVO.fromScanResult(result, status, userId);

        // 3. Registry에 등록 (UPSERT - 이미 있으면 상태 업데이트)
        mapper.insertPiiRegistry(registry);

        // 4. 동일 컬럼의 모든 Scan Result confirm_status 일괄 업데이트
        String schemaForUpdate = result.getSchemaName() != null ? result.getSchemaName() : "";
        int updatedCount = mapper.updateScanResultConfirmByColumn(
                result.getDbName(), schemaForUpdate,
                result.getTableName(), result.getColumnName(),
                status, userId);
        LogUtil.log("INFO", "Bulk updated scan results: " + result.getTableName() + "." + result.getColumnName()
                + " (" + updatedCount + " rows -> " + status + ")");

        // 5. Meta Table VAL2 동기화
        // schemaName null 방어 (기존 스캔 결과 데이터 대응)
        String schemaName = result.getSchemaName() != null ? result.getSchemaName() : "";

        if ("CONFIRMED".equals(status)) {
            // CONFIRMED: VAL2에 piiType|score 저장
            int syncCount = mapper.syncPiiRegistryToMetaDomain(
                    result.getDbName(),
                    schemaName,
                    result.getTableName(),
                    result.getColumnName(),
                    result.getPiiTypeName(),
                    result.getScore()
            );
            LogUtil.log("INFO", "Synced to Meta VAL2: " + result.getTableName() + "." + result.getColumnName()
                    + " (updated " + syncCount + " rows)");
            if (syncCount == 0) {
                LogUtil.log("WARN", "Meta VAL2 sync matched 0 rows - db=" + result.getDbName()
                        + ", owner=" + schemaName + ", table=" + result.getTableName()
                        + ", column=" + result.getColumnName());
            }
        } else if ("EXCLUDED".equals(status)) {
            // EXCLUDED: VAL2 초기화
            int clearCount = mapper.clearMetaVal2(
                    result.getDbName(),
                    schemaName,
                    result.getTableName(),
                    result.getColumnName()
            );
            LogUtil.log("INFO", "Cleared Meta VAL2: " + result.getTableName() + "." + result.getColumnName()
                    + " (updated " + clearCount + " rows)");
        }

        LogUtil.log("INFO", "Registered to PII Registry: " + result.getTableName() + "." + result.getColumnName() + " -> " + status);
    }

    @Override
    @Transactional
    public void registerToRegistryBatch(List<String> resultIds, String status, String userId) {
        LogUtil.log("INFO", "Discovery registerToRegistryBatch: " + resultIds.size() + " results -> " + status);
        for (String resultId : resultIds) {
            try {
                registerToRegistry(resultId, status, userId);
            } catch (Exception e) {
                logger.error("Failed to register result to registry: " + resultId, e);
            }
        }
    }

    @Override
    @Transactional
    public boolean removeFromRegistry(String registryId, String userId) {
        LogUtil.log("INFO", "Discovery removeFromRegistry: " + registryId + " by " + userId);

        // 1. Registry 조회하여 원본 Result ID 가져오기
        DiscoveryPiiRegistryVO registry = mapper.selectPiiRegistry(registryId);
        if (registry == null) {
            return false;
        }

        // 2. 원본 Scan Result가 있으면 PENDING으로 변경
        String originalResultId = registry.getFirstDetectedResultId();
        if (originalResultId != null && !originalResultId.isEmpty()) {
            mapper.updateScanResultConfirm(originalResultId, "PENDING", userId);
            LogUtil.log("INFO", "Reset original scan result to PENDING: " + originalResultId);
        }

        // 3. Meta Table VAL2 초기화
        mapper.clearMetaVal2(
                registry.getDbName(),
                registry.getSchemaName(),
                registry.getTableName(),
                registry.getColumnName()
        );
        LogUtil.log("INFO", "Cleared Meta VAL2: " + registry.getTableName() + "." + registry.getColumnName());

        // 4. Registry에서 삭제
        return mapper.deletePiiRegistry(registryId) == 1;
    }

    @Override
    public DiscoveryPiiRegistryVO getPiiRegistry(String registryId) {
        LogUtil.log("INFO", "Discovery getPiiRegistry: " + registryId);
        return mapper.selectPiiRegistry(registryId);
    }

    @Override
    public List<DiscoveryPiiRegistryVO> getPiiRegistryList(Criteria cri) {
        LogUtil.log("INFO", "Discovery getPiiRegistryList");
        return mapper.selectPiiRegistryList(cri);
    }

    @Override
    public int getPiiRegistryTotal(Criteria cri) {
        return mapper.selectPiiRegistryTotal(cri);
    }

    @Override
    public int getPiiRegistryCountByStatus(String status, Criteria cri) {
        LogUtil.log("INFO", "Discovery getPiiRegistryCountByStatus: " + status);
        cri.setSearch4(status);
        return mapper.selectPiiRegistryCountByStatus(cri);
    }

    @Override
    @Transactional
    public boolean updateRegistryStatus(String registryId, String status, String userId) {
        LogUtil.log("INFO", "Discovery updateRegistryStatus: " + registryId + " -> " + status);

        // 1. Registry 조회 (컬럼 정보 필요)
        DiscoveryPiiRegistryVO registry = mapper.selectPiiRegistry(registryId);
        if (registry == null) {
            return false;
        }

        // 2. Registry 상태 업데이트
        int updated = mapper.updatePiiRegistryStatus(registryId, status, userId);

        // 3. Meta Table VAL2 동기화
        if (updated == 1) {
            if ("CONFIRMED".equals(status)) {
                // CONFIRMED로 변경: VAL2에 piiType|score 저장
                mapper.syncPiiRegistryToMetaDomain(
                        registry.getDbName(),
                        registry.getSchemaName(),
                        registry.getTableName(),
                        registry.getColumnName(),
                        registry.getPiiTypeName(),
                        registry.getConfidenceScore()
                );
                LogUtil.log("INFO", "Synced to Meta VAL2: " + registry.getTableName() + "." + registry.getColumnName());
            } else if ("EXCLUDED".equals(status)) {
                // EXCLUDED로 변경: VAL2 초기화
                mapper.clearMetaVal2(
                        registry.getDbName(),
                        registry.getSchemaName(),
                        registry.getTableName(),
                        registry.getColumnName()
                );
                LogUtil.log("INFO", "Cleared Meta VAL2: " + registry.getTableName() + "." + registry.getColumnName());
            }
        }

        return updated == 1;
    }

    @Override
    public java.util.Set<String> getRegisteredPiiColumnKeys(String dbName) {
        LogUtil.log("INFO", "Discovery getRegisteredPiiColumnKeys: " + dbName);
        List<String> keys = mapper.selectRegisteredPiiColumnKeys(dbName);
        return new java.util.HashSet<>(keys);
    }

    @Override
    @Transactional
    public void registerManualPiiColumn(DiscoveryPiiRegistryVO registry) {
        LogUtil.log("INFO", "Discovery registerManualPiiColumn: " + registry.getTableName() + "." + registry.getColumnName());
        if (registry.getRegistryId() == null || registry.getRegistryId().isEmpty()) {
            registry.setRegistryId(UUID.randomUUID().toString());
        }
        registry.setDetectionMethod("MANUAL");
        registry.setStatus("CONFIRMED");
        mapper.insertPiiRegistry(registry);
    }

    // ========== Meta Table Sync (DOMAIN 컬럼 업데이트) ==========

    @Override
    @Transactional
    public int syncRegistryToMetaDomain(String registryId) {
        LogUtil.log("INFO", "Discovery syncRegistryToMetaDomain: " + registryId);

        // Registry 조회
        DiscoveryPiiRegistryVO registry = mapper.selectPiiRegistry(registryId);
        if (registry == null) {
            LogUtil.log("WARN", "Registry not found: " + registryId);
            return 0;
        }

        // CONFIRMED 상태인지 확인
        if (!"CONFIRMED".equals(registry.getStatus())) {
            LogUtil.log("WARN", "Registry is not CONFIRMED status: " + registryId);
            return 0;
        }

        // Meta Table DOMAIN 컬럼 업데이트
        // 포맷: "PII_TYPE|SCORE" (예: "주민등록번호|85.5")
        int result = mapper.syncPiiRegistryToMetaDomain(
                registry.getDbName(),
                registry.getSchemaName(),
                registry.getTableName(),
                registry.getColumnName(),
                registry.getPiiTypeName(),
                registry.getConfidenceScore()
        );

        if (result > 0) {
            LogUtil.log("INFO", "Synced to Meta Domain: " + registry.getTableName() + "." + registry.getColumnName()
                    + " -> " + registry.getPiiTypeName() + "|" + registry.getConfidenceScore());
        }

        return result;
    }

    @Override
    @Transactional
    public int syncRegistryToMetaDomainBatch(List<String> registryIds) {
        LogUtil.log("INFO", "Discovery syncRegistryToMetaDomainBatch: " + registryIds.size() + " items");
        int totalSynced = 0;

        for (String registryId : registryIds) {
            try {
                totalSynced += syncRegistryToMetaDomain(registryId);
            } catch (Exception e) {
                logger.error("Failed to sync registry to meta domain: " + registryId, e);
            }
        }

        LogUtil.log("INFO", "Total synced to Meta Domain: " + totalSynced);
        return totalSynced;
    }

    @Override
    @Transactional
    public int syncAllConfirmedToMetaDomain(String dbName) {
        LogUtil.log("INFO", "Discovery syncAllConfirmedToMetaDomain: " + dbName);

        int result = mapper.syncAllConfirmedToMeta(dbName);

        LogUtil.log("INFO", "Synced all CONFIRMED to Meta Domain: " + result + " columns for DB: " + dbName);
        return result;
    }

    // ========== 오래된 스캔 결과 정리 ==========

    @Override
    @Transactional
    public int cleanupOldScanResults(String jobId, int keepCount) {
        LogUtil.log("INFO", "Discovery cleanupOldScanResults: jobId=" + jobId + ", keepCount=" + keepCount);

        int totalDeleted = 0;

        try {
            // 1. 오래된 Execution ID 목록 조회
            List<String> oldExecutionIds = mapper.selectOldExecutionIds(jobId, keepCount);

            if (oldExecutionIds == null || oldExecutionIds.isEmpty()) {
                LogUtil.log("INFO", "No old executions to cleanup for job: " + jobId);
                return 0;
            }

            LogUtil.log("INFO", "Found " + oldExecutionIds.size() + " old executions to cleanup");

            // 2. 각 Execution의 스캔 결과 삭제
            for (String executionId : oldExecutionIds) {
                // 테이블 스캔 완료 기록 삭제
                mapper.deleteTableScanComplete(executionId);

                int deletedResults = mapper.deleteScanResultByExecutionId(executionId);
                totalDeleted += deletedResults;
                LogUtil.log("DEBUG", "Deleted " + deletedResults + " results for execution: " + executionId);

                // 3. Execution 삭제
                mapper.deleteExecution(executionId);
            }

            LogUtil.log("INFO", "Cleanup completed for job " + jobId + ": deleted " + totalDeleted + " results, " + oldExecutionIds.size() + " executions");

        } catch (Exception e) {
            logger.error("Failed to cleanup old scan results for job: " + jobId, e);
        }

        return totalDeleted;
    }

    @Override
    @Transactional
    public int cleanupAllOldScanResults(int keepCount) {
        LogUtil.log("INFO", "Discovery cleanupAllOldScanResults: keepCount=" + keepCount);

        int totalDeleted = 0;

        try {
            // 모든 Job 목록 조회
            Criteria cri = new Criteria();
            cri.setAmount(1000);
            List<DiscoveryScanJobVO> jobs = mapper.selectScanJobList(cri);

            for (DiscoveryScanJobVO job : jobs) {
                int deleted = cleanupOldScanResults(job.getJobId(), keepCount);
                totalDeleted += deleted;
            }

            LogUtil.log("INFO", "Total cleanup completed: deleted " + totalDeleted + " results from " + jobs.size() + " jobs");

        } catch (Exception e) {
            logger.error("Failed to cleanup all old scan results", e);
        }

        return totalDeleted;
    }

}
