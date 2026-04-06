package datablocks.dlm.domain;

import java.util.List;

import lombok.Data;

/**
 * Discovery Scan Progress VO
 * 스캔 진행 상황 상세 정보
 */
@Data
public class DiscoveryScanProgressVO {
    private String executionId;         // 실행 ID
    private String jobId;               // 작업 ID
    private String jobName;             // 작업명
    private String status;              // 상태 (RUNNING, COMPLETED, FAILED, CANCELLED)
    private int progress;               // 진행률 (0-100)
    private int threadCount;            // 동시 실행 스레드 수

    // 테이블 카운트
    private int totalTables;            // 전체 테이블 수
    private int scannedTables;          // 스캔 완료 테이블 수
    private int remainingTables;        // 남은 테이블 수

    // 컬럼 카운트
    private int totalColumns;           // 전체 컬럼 수
    private int scannedColumns;         // 실제 스캔된 컬럼 수
    private int excludedColumns;        // 제외된 컬럼 수
    private int piiCount;               // 탐지된 PII 수

    // 현재 진행 중인 테이블
    private String currentTable;        // 현재 스캔 중인 테이블명
    private String currentSchema;       // 현재 스캔 중인 스키마

    // 테이블 목록
    private List<TableScanStatus> tableList;  // 테이블별 스캔 상태

    // 시간 정보
    private String startTime;           // 시작 시간
    private long elapsedSeconds;        // 경과 시간 (초)
    private String estimatedRemaining;  // 예상 남은 시간

    // 에러 메시지
    private String errorMsg;

    /**
     * 테이블별 스캔 상태
     */
    @Data
    public static class TableScanStatus {
        private String schemaName;      // 스키마명
        private String tableName;       // 테이블명
        private String status;          // PENDING, SCANNING, COMPLETED, SKIPPED
        private int columnCount;        // 컬럼 수
        private int piiCount;           // 탐지된 PII 수
        private long scanTime;          // 스캔 소요시간 (ms)

        public TableScanStatus() {}

        public TableScanStatus(String schemaName, String tableName) {
            this.schemaName = schemaName;
            this.tableName = tableName;
            this.status = "PENDING";
            this.columnCount = 0;
            this.piiCount = 0;
            this.scanTime = 0;
        }
    }
}
