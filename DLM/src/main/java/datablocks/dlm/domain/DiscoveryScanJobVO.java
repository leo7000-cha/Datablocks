package datablocks.dlm.domain;

import lombok.Data;

/**
 * Discovery Scan Job VO
 * PII 탐지 스캔 작업 정의 (템플릿)
 */
@Data
public class DiscoveryScanJobVO {
    private String jobId;           // 작업 ID (UUID)
    private String jobName;         // 작업명
    private String description;     // 작업 설명

    // 대상 설정
    private String targetDb;        // 대상 데이터베이스
    private String targetSchema;    // 대상 스키마 (콤마 구분)
    private String targetTables;    // 대상 테이블 (패턴 또는 목록)

    // 스캔 설정
    private String scanMode;        // FULL, INCREMENTAL
    private Integer sampleSize;     // 패턴 매칭용 샘플 크기
    private Integer threadCount;    // 동시 실행 스레드 수 (기본 5)

    // 탐지 방법 설정
    private String enableMeta;      // 메타데이터 분석 활성화 (Y/N)
    private String enablePattern;   // 패턴 매칭 활성화 (Y/N)
    private String enableAi;        // AI 분류 활성화 (Y/N)

    // 제외 설정 (옵션 오버라이드)
    private String excludeDataTypes;   // 제외할 데이터 타입 (콤마 구분)
    private Integer minColumnLength;   // 최소 컬럼 길이 (기본 2)
    private Integer maxColumnLength;   // 최대 컬럼 길이 (기본 4000)
    private String excludePatterns;    // 제외할 컬럼명 패턴 (콤마 구분)
    private String skipConfirmedPii;   // 확인된 PII 컬럼 건너뛰기 (Y/N)

    // 상태 (작업 자체의 활성화 상태)
    private String isActive;        // 활성화 여부 (Y/N)

    // 마지막 실행 정보 (조회용)
    private String lastExecutionId;     // 마지막 실행 ID
    private String lastExecutionStatus; // 마지막 실행 상태
    private String lastExecutionDate;   // 마지막 실행일시
    private Integer executionCount;     // 총 실행 횟수

    // 감사 정보
    private String regUserId;       // 등록자 ID
    private String regDate;         // 등록일시
    private String updUserId;       // 수정자 ID
    private String updDate;         // 수정일시

    // 기본값 설정
    public DiscoveryScanJobVO() {
        this.threadCount = 5;
        this.minColumnLength = 2;
        this.maxColumnLength = 4000;
        this.skipConfirmedPii = "Y";
        this.isActive = "Y";
        this.enableMeta = "Y";
        this.enablePattern = "Y";
        this.enableAi = "N";
    }
}
