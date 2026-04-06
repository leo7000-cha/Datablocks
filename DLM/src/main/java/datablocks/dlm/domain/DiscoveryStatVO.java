package datablocks.dlm.domain;

import lombok.Data;

/**
 * Discovery Statistics VO
 * 대시보드 통계용
 */
@Data
public class DiscoveryStatVO {
    private Integer totalScans;         // 전체 스캔 수
    private Integer totalTablesScanned; // 스캔된 테이블 수
    private Integer totalColumnsScanned;// 스캔된 컬럼 수
    private Integer piiColumnsDetected; // 탐지된 PII 컬럼 수
    private Integer confirmedPii;       // 확인된 PII 수
    private Integer pendingReview;      // 대기 중 수
    private Integer excludedCount;      // 제외된 수
    private Integer runningJobs;        // 실행 중 작업 수
    private String lastScanDate;        // 마지막 스캔 일시
}
