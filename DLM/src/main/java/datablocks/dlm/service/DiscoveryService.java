package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.*;

/**
 * Discovery Service Interface
 * PII 자동탐지 서비스
 *
 * Job/Execution 분리 패턴:
 * - Job: 스캔 작업 정의 (템플릿) - 재사용 가능한 설정
 * - Execution: 스캔 실행 이력 (인스턴스) - 각 실행의 상태/결과
 */
public interface DiscoveryService {

    // ========== Dashboard ==========
    /**
     * 대시보드 통계 조회
     */
    DiscoveryStatVO getDashboardStats();

    /**
     * 대시보드 차트 데이터 조회
     */
    java.util.Map<String, Object> getDashboardChartData();

    // ========== Scan Jobs (템플릿) ==========
    /**
     * 스캔 작업 등록
     */
    void registerScanJob(DiscoveryScanJobVO job);

    /**
     * 스캔 작업 조회
     */
    DiscoveryScanJobVO getScanJob(String jobId);

    /**
     * 스캔 작업 목록 조회
     */
    List<DiscoveryScanJobVO> getScanJobList(Criteria cri);

    /**
     * 스캔 작업 수 조회
     */
    int getScanJobTotal(Criteria cri);

    /**
     * 스캔 작업 수정
     */
    boolean modifyScanJob(DiscoveryScanJobVO job);

    /**
     * 스캔 작업 삭제
     */
    boolean removeScanJob(String jobId);

    // ========== Scan Executions (실행 이력) ==========
    /**
     * 스캔 실행 (새 Execution 생성 후 시작)
     * @return executionId 실행 ID
     */
    String executeScan(String jobId);

    /**
     * 스캔 재시작 (이전 FAILED/CANCELLED Execution의 완료된 테이블을 스킵하고 이어서 실행)
     * @return executionId (기존 것 재사용)
     */
    String resumeScan(String executionId);

    /**
     * 실행 정보 조회
     */
    DiscoveryScanExecutionVO getExecution(String executionId);

    /**
     * 실행 목록 조회
     */
    List<DiscoveryScanExecutionVO> getExecutionList(Criteria cri);

    /**
     * Job별 실행 목록 조회
     */
    List<DiscoveryScanExecutionVO> getExecutionListByJobId(String jobId);

    /**
     * 실행 수 조회
     */
    int getExecutionTotal(Criteria cri);

    /**
     * 실행 상태 업데이트
     */
    boolean updateExecutionStatus(String executionId, String status, Integer progress);

    /**
     * 실행 실패 처리
     */
    boolean updateExecutionFailed(String executionId, String errorMsg);

    /**
     * 스캔 취소
     */
    void cancelScan(String executionId);

    /**
     * 스캔 진행 상황 조회
     */
    DiscoveryScanProgressVO getScanProgress(String executionId);

    // ========== Scan Results ==========
    /**
     * 탐지 결과 등록
     */
    void registerScanResult(DiscoveryScanResultVO result);

    /**
     * 탐지 결과 배치 등록
     */
    void registerScanResultBatch(List<DiscoveryScanResultVO> results);

    /**
     * 탐지 결과 조회
     */
    DiscoveryScanResultVO getScanResult(String resultId);

    /**
     * 탐지 결과 목록 조회
     */
    List<DiscoveryScanResultVO> getScanResultList(Criteria cri);

    /**
     * 탐지 결과 수 조회
     */
    int getScanResultTotal(Criteria cri);

    /**
     * 탐지 결과 확인 처리
     */
    boolean confirmScanResult(String resultId, String confirmStatus, String userId);

    /**
     * 탐지 결과 일괄 확인 처리
     */
    boolean confirmScanResultBatch(List<String> resultIds, String confirmStatus, String userId);

    // ========== Rules ==========
    /**
     * 규칙 등록
     */
    void registerRule(DiscoveryRuleVO rule);

    /**
     * 규칙 조회
     */
    DiscoveryRuleVO getRule(String ruleId);

    /**
     * 규칙 목록 조회
     */
    List<DiscoveryRuleVO> getRuleList(Criteria cri);

    /**
     * 카테고리별 규칙 목록 조회
     */
    List<DiscoveryRuleVO> getRuleListByCategory(String category);

    /**
     * 규칙 수정
     */
    boolean modifyRule(DiscoveryRuleVO rule);

    /**
     * 규칙 삭제
     */
    boolean removeRule(String ruleId);

    // ========== PII Types ==========
    /**
     * PII 유형 목록 조회
     */
    List<DiscoveryPiiTypeVO> getPiiTypeList();

    /**
     * PII 유형 조회
     */
    DiscoveryPiiTypeVO getPiiType(String piiTypeCode);

    // ========== Integration ==========
    /**
     * Meta Table에 PII 정보 동기화
     */
    int syncToMetaTable(List<String> resultIds);

    /**
     * 확인된 PII 컬럼 목록 조회 (Meta 동기화용)
     */
    List<DiscoveryScanResultVO> getConfirmedPiiColumns(Criteria cri);

    /**
     * 데이터베이스의 스키마 목록 조회
     */
    List<String> getSchemaList(String dbName);

    // ========== Config (설정 관리) ==========
    /**
     * 설정 등록
     */
    void registerConfig(DiscoveryConfigVO config);

    /**
     * 설정 조회
     */
    DiscoveryConfigVO getConfig(String configId);

    /**
     * 키로 설정 조회
     */
    DiscoveryConfigVO getConfigByKey(String configKey);

    /**
     * 전체 설정 목록 조회
     */
    List<DiscoveryConfigVO> getConfigList();

    /**
     * 타입별 설정 목록 조회
     */
    List<DiscoveryConfigVO> getConfigListByType(String configType);

    /**
     * 설정 수정
     */
    boolean modifyConfig(DiscoveryConfigVO config);

    /**
     * 설정 삭제
     */
    boolean removeConfig(String configId);

    // ========== PII Registry (확정된 PII 컬럼 레지스트리) ==========
    // Scan Result와 분리하여 PII 컬럼 상태를 독립적으로 관리

    /**
     * Scan Result를 Registry에 등록 (Confirm/Exclude 시 호출)
     * - CONFIRMED 또는 EXCLUDED 상태로 등록
     * - 이미 등록된 컬럼이면 상태 업데이트
     */
    void registerToRegistry(String resultId, String status, String userId);

    /**
     * 여러 Scan Result를 일괄로 Registry에 등록
     */
    void registerToRegistryBatch(List<String> resultIds, String status, String userId);

    /**
     * Registry에서 컬럼 삭제 (Reset 시 호출)
     * - 원본 Scan Result를 PENDING으로 변경
     * - 다음 스캔에서 해당 컬럼이 다시 탐지됨
     */
    boolean removeFromRegistry(String registryId, String userId);

    /**
     * Registry 상세 조회
     */
    DiscoveryPiiRegistryVO getPiiRegistry(String registryId);

    /**
     * Registry 목록 조회 (PII Columns 페이지용)
     */
    List<DiscoveryPiiRegistryVO> getPiiRegistryList(Criteria cri);

    /**
     * Registry 총 개수
     */
    int getPiiRegistryTotal(Criteria cri);

    /**
     * Registry 상태별 개수
     */
    int getPiiRegistryCountByStatus(String status, Criteria cri);

    /**
     * Registry 상태 변경 (CONFIRMED <-> EXCLUDED)
     */
    boolean updateRegistryStatus(String registryId, String status, String userId);

    /**
     * 스캔 엔진용: 등록된 PII 컬럼 키 Set 조회
     * - CONFIRMED + EXCLUDED 모두 반환 (둘 다 스캔에서 제외)
     */
    java.util.Set<String> getRegisteredPiiColumnKeys(String dbName);

    /**
     * 수동으로 PII 컬럼 등록 (Add Manual)
     */
    void registerManualPiiColumn(DiscoveryPiiRegistryVO registry);

    // ========== Meta Table Sync (DOMAIN 컬럼 업데이트) ==========

    /**
     * 단일 Registry 항목을 Meta Table의 DOMAIN 컬럼에 동기화
     * 포맷: "PII_TYPE|SCORE" (예: "주민등록번호|85.5")
     * @return 업데이트된 행 수
     */
    int syncRegistryToMetaDomain(String registryId);

    /**
     * 여러 Registry 항목을 일괄로 Meta Table DOMAIN에 동기화
     * @return 업데이트된 총 행 수
     */
    int syncRegistryToMetaDomainBatch(List<String> registryIds);

    /**
     * 특정 DB의 모든 CONFIRMED Registry를 Meta Table DOMAIN에 동기화
     * @return 업데이트된 총 행 수
     */
    int syncAllConfirmedToMetaDomain(String dbName);

    // ========== 오래된 스캔 결과 정리 ==========

    /**
     * Job별 오래된 스캔 결과 정리 (최근 N회만 유지)
     * @param jobId Job ID
     * @param keepCount 유지할 스캔 횟수 (기본 3)
     * @return 삭제된 결과 수
     */
    int cleanupOldScanResults(String jobId, int keepCount);

    /**
     * 모든 Job의 오래된 스캔 결과 정리
     * @param keepCount 유지할 스캔 횟수 (기본 3)
     * @return 삭제된 총 결과 수
     */
    int cleanupAllOldScanResults(int keepCount);

}
