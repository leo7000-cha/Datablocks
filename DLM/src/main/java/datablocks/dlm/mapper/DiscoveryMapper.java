package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.*;
import datablocks.dlm.domain.MetaTableVO;

/**
 * Discovery Mapper Interface
 * PII 자동탐지 매퍼
 *
 * Job/Execution 분리 패턴:
 * - Job: 스캔 작업 정의 (템플릿)
 * - Execution: 스캔 실행 이력 (인스턴스)
 */
public interface DiscoveryMapper {

    // ========== Dashboard ==========
    DiscoveryStatVO getDashboardStats();

    List<java.util.Map<String, Object>> selectPiiTypeDistribution();

    java.util.Map<String, Object> selectScoreDistribution();

    List<java.util.Map<String, Object>> selectTopPiiTables();

    // ========== Scan Jobs (템플릿) ==========
    void insertScanJob(DiscoveryScanJobVO job);

    DiscoveryScanJobVO selectScanJob(@Param("jobId") String jobId);

    List<DiscoveryScanJobVO> selectScanJobList(Criteria cri);

    int selectScanJobTotal(Criteria cri);

    int updateScanJob(DiscoveryScanJobVO job);

    int deleteScanJob(@Param("jobId") String jobId);

    int updateJobLastExecution(@Param("jobId") String jobId,
                               @Param("executionId") String executionId);

    // ========== Scan Executions (실행 이력) ==========
    void insertExecution(DiscoveryScanExecutionVO execution);

    DiscoveryScanExecutionVO selectExecution(@Param("executionId") String executionId);

    List<DiscoveryScanExecutionVO> selectExecutionList(Criteria cri);

    List<DiscoveryScanExecutionVO> selectExecutionListByJobId(@Param("jobId") String jobId);

    int selectExecutionTotal(Criteria cri);

    int updateExecutionStatus(@Param("executionId") String executionId,
                              @Param("status") String status,
                              @Param("progress") Integer progress);

    int updateExecutionFailed(@Param("executionId") String executionId,
                              @Param("errorMsg") String errorMsg);

    int updateExecutionComplete(@Param("executionId") String executionId,
                                @Param("totalTables") int totalTables,
                                @Param("scannedTables") int scannedTables,
                                @Param("skippedTables") int skippedTables,
                                @Param("totalColumns") int totalColumns,
                                @Param("scannedColumns") int scannedColumns,
                                @Param("excludedColumns") int excludedColumns,
                                @Param("piiCount") int piiCount);

    int deleteExecutionsByJobId(@Param("jobId") String jobId);

    // ========== Scan Results ==========
    void insertScanResult(DiscoveryScanResultVO result);

    DiscoveryScanResultVO selectScanResult(@Param("resultId") String resultId);

    List<DiscoveryScanResultVO> selectScanResultList(Criteria cri);

    int selectScanResultTotal(Criteria cri);

    int updateScanResultConfirm(@Param("resultId") String resultId,
                                @Param("confirmStatus") String confirmStatus,
                                @Param("userId") String userId);

    int deleteScanResult(@Param("resultId") String resultId);

    int deleteScanResultByJobId(@Param("jobId") String jobId);

    List<DiscoveryScanResultVO> selectConfirmedPiiColumns(Criteria cri);

    // ========== 오래된 스캔 결과 정리 (최근 N회 유지) ==========

    /** Job별 최근 N회 이전 Execution ID 목록 조회 */
    List<String> selectOldExecutionIds(@Param("jobId") String jobId, @Param("keepCount") int keepCount);

    /** 특정 Execution의 스캔 결과 삭제 */
    int deleteScanResultByExecutionId(@Param("executionId") String executionId);

    /** 특정 Execution 삭제 */
    int deleteExecution(@Param("executionId") String executionId);

    /** Job별 오래된 스캔 결과 일괄 정리 (최근 N회만 유지) */
    int deleteOldScanResultsByJob(@Param("jobId") String jobId, @Param("keepCount") int keepCount);

    /** Job별 오래된 Execution 일괄 정리 */
    int deleteOldExecutionsByJob(@Param("jobId") String jobId, @Param("keepCount") int keepCount);

    // ========== Rules ==========
    void insertRule(DiscoveryRuleVO rule);

    DiscoveryRuleVO selectRule(@Param("ruleId") String ruleId);

    List<DiscoveryRuleVO> selectRuleList(Criteria cri);

    List<DiscoveryRuleVO> selectRuleListByCategory(@Param("category") String category);

    int selectRuleTotal(Criteria cri);

    int updateRule(DiscoveryRuleVO rule);

    int deleteRule(@Param("ruleId") String ruleId);

    // ========== PII Types ==========
    List<DiscoveryPiiTypeVO> selectPiiTypeList();

    DiscoveryPiiTypeVO selectPiiType(@Param("piiTypeCode") String piiTypeCode);

    // ========== Config (설정 관리) ==========
    void insertConfig(DiscoveryConfigVO config);

    DiscoveryConfigVO selectConfig(@Param("configId") String configId);

    DiscoveryConfigVO selectConfigByKey(@Param("configKey") String configKey);

    List<DiscoveryConfigVO> selectConfigList();

    List<DiscoveryConfigVO> selectConfigListByType(@Param("configType") String configType);

    int updateConfig(DiscoveryConfigVO config);

    int deleteConfig(@Param("configId") String configId);

    // ========== PII Registry (확정된 PII 컬럼 레지스트리) ==========
    // Scan Result와 분리하여 PII 컬럼 상태를 독립적으로 관리

    /** Registry 등록/업데이트 (UPSERT) */
    void insertPiiRegistry(DiscoveryPiiRegistryVO registry);

    /** Registry 상세 조회 */
    DiscoveryPiiRegistryVO selectPiiRegistry(@Param("registryId") String registryId);

    /** Registry 목록 조회 (PII Columns 페이지용) */
    List<DiscoveryPiiRegistryVO> selectPiiRegistryList(Criteria cri);

    /** Registry 총 개수 */
    int selectPiiRegistryTotal(Criteria cri);

    /** Registry 상태별 개수 */
    int selectPiiRegistryCountByStatus(Criteria cri);

    /** 컬럼으로 Registry 조회 (중복 체크용) */
    DiscoveryPiiRegistryVO selectPiiRegistryByColumn(@Param("dbName") String dbName,
                                                     @Param("schemaName") String schemaName,
                                                     @Param("tableName") String tableName,
                                                     @Param("columnName") String columnName);

    /** Registry 상태 업데이트 */
    int updatePiiRegistryStatus(@Param("registryId") String registryId,
                                @Param("status") String status,
                                @Param("updatedBy") String updatedBy);

    /** Registry 삭제 (Reset 시 사용) */
    int deletePiiRegistry(@Param("registryId") String registryId);

    /** 스캔 엔진용: 등록된 PII 컬럼 키 목록 (CONFIRMED + EXCLUDED 모두 스킵 대상) */
    List<String> selectRegisteredPiiColumnKeys(@Param("dbName") String dbName);

    /** 스캔 엔진용: 등록된 PII 컬럼 상세 목록 */
    List<DiscoveryPiiRegistryVO> selectRegisteredPiiColumns(@Param("dbName") String dbName);

    /** Dashboard용: Registry 통계 */
    java.util.Map<String, Object> selectRegistryStats();

    // ========== Meta Table Sync (DOMAIN 컬럼 업데이트) ==========

    /**
     * CONFIRMED된 PII Registry 정보를 Meta Table의 VAL2 컬럼에 동기화
     * 포맷: "PII_TYPE|SCORE" (예: "주민등록번호|85")
     */
    int syncPiiRegistryToMetaDomain(@Param("dbName") String dbName,
                                    @Param("schemaName") String schemaName,
                                    @Param("tableName") String tableName,
                                    @Param("columnName") String columnName,
                                    @Param("piiTypeName") String piiTypeName,
                                    @Param("score") Number score);

    /** Registry 목록 일괄 동기화 (CONFIRMED 상태만) */
    int syncAllConfirmedToMeta(@Param("dbName") String dbName);

    /** Registry 정보로 Meta VAL2 조회 (동기화 여부 확인용) */
    String selectMetaDomainByColumn(@Param("dbName") String dbName,
                                    @Param("schemaName") String schemaName,
                                    @Param("tableName") String tableName,
                                    @Param("columnName") String columnName);

    /** Meta Table VAL2 초기화 (EXCLUDED 또는 RESET 시) */
    int clearMetaVal2(@Param("dbName") String dbName,
                      @Param("schemaName") String schemaName,
                      @Param("tableName") String tableName,
                      @Param("columnName") String columnName);

    // ========== Meta Table 기반 스캔 (원천DB 카탈로그 직접 조회 대체) ==========

    /** TBL_METATABLE에서 DB/OWNER별 테이블 목록 조회 */
    List<String> selectMetaTableNames(@Param("db") String db,
                                      @Param("owner") String owner,
                                      @Param("tablePattern") String tablePattern);

    /** TBL_METATABLE에서 DB/OWNER별 전체 컬럼 정보 한 번에 로드 */
    List<MetaTableVO> selectMetaColumnsByDbOwner(@Param("db") String db,
                                                 @Param("owner") String owner);

    // ========== Execution 테이블 단위 완료 추적 (재시작 시 스킵용) ==========

    /** 테이블 스캔 완료 기록 */
    void insertTableScanComplete(@Param("executionId") String executionId,
                                 @Param("schemaName") String schemaName,
                                 @Param("tableName") String tableName,
                                 @Param("columnCount") int columnCount,
                                 @Param("piiCount") int piiCount,
                                 @Param("scanTimeMs") long scanTimeMs);

    /** 특정 Execution에서 완료된 테이블 목록 조회 */
    List<String> selectCompletedTables(@Param("executionId") String executionId);

    /** 특정 Execution의 테이블 완료 기록 삭제 */
    int deleteTableScanComplete(@Param("executionId") String executionId);

}
