package datablocks.dlm.domain;

import lombok.Data;

/**
 * Discovery Scan Execution VO
 * 스캔 작업 실행 이력
 */
@Data
public class DiscoveryScanExecutionVO {
    private String executionId;     // 실행 ID (UUID)
    private String jobId;           // 작업 ID (FK)
    private String jobName;         // 작업명 (조인용)
    private String status;          // PENDING, RUNNING, COMPLETED, FAILED, CANCELLED
    private Integer progress;       // 진행률 (0-100)

    // 스캔 통계
    private Integer totalTables;    // 전체 테이블 수
    private Integer scannedTables;  // 스캔 완료 테이블 수
    private Integer skippedTables;  // 건너뛴 테이블 수
    private Integer totalColumns;   // 전체 컬럼 수
    private Integer scannedColumns; // 스캔된 컬럼 수
    private Integer excludedColumns;// 제외된 컬럼 수
    private Integer piiCount;       // 탐지된 PII 수

    // 실행 설정
    private Integer threadCount;    // 동시 실행 스레드 수

    // 시간 정보
    private String startTime;       // 시작 시간
    private String endTime;         // 종료 시간
    private Long durationMs;        // 소요 시간 (밀리초)

    // 에러 정보
    private String errorMsg;        // 에러 메시지

    // 감사 정보
    private String regUserId;       // 실행자 ID
    private String regDate;         // 실행일시
}
