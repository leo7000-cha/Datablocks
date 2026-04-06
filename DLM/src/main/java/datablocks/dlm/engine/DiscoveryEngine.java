package datablocks.dlm.engine;

import datablocks.dlm.domain.DiscoveryScanJobVO;
import datablocks.dlm.domain.DiscoveryScanProgressVO;
import datablocks.dlm.domain.DiscoveryScanResultVO;
import datablocks.dlm.domain.PiiDatabaseVO;

import java.util.List;

/**
 * Discovery Engine Interface
 * PII 자동탐지 엔진 인터페이스
 *
 * Job/Execution 분리 패턴:
 * - executionId로 각 실행을 추적
 * - 하나의 Job으로 여러 번 실행 가능
 */
public interface DiscoveryEngine {

    /**
     * 스캔 작업 실행
     * @param job 스캔 작업 정보 (템플릿)
     * @param dbInfo 대상 데이터베이스 정보
     * @param executionId 실행 ID (새로 생성된 Execution의 ID)
     * @return 탐지 결과 목록
     */
    List<DiscoveryScanResultVO> executeScan(DiscoveryScanJobVO job, PiiDatabaseVO dbInfo, String executionId);

    /**
     * 단일 테이블 스캔
     * @param job 스캔 작업 정보
     * @param dbInfo 데이터베이스 정보
     * @param tableName 테이블명
     * @param executionId 실행 ID
     * @return 탐지 결과 목록
     */
    List<DiscoveryScanResultVO> scanTable(DiscoveryScanJobVO job, PiiDatabaseVO dbInfo, String tableName, String executionId);

    /**
     * 스캔 작업 취소
     * @param executionId 실행 ID
     */
    void cancelScan(String executionId);

    /**
     * 스캔 작업 상태 확인
     * @param executionId 실행 ID
     * @return 실행 중 여부
     */
    boolean isRunning(String executionId);

    /**
     * 스캔 진행 상황 조회
     * @param executionId 실행 ID
     * @return 진행 상황 정보 (없으면 null)
     */
    DiscoveryScanProgressVO getScanProgress(String executionId);

}
