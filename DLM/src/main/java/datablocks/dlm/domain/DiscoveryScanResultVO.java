package datablocks.dlm.domain;

import lombok.Data;

/**
 * Discovery Scan Result VO
 * PII 탐지 결과
 */
@Data
public class DiscoveryScanResultVO {
    private String resultId;        // 결과 ID (UUID)
    private String jobId;           // 스캔 작업 ID (FK)
    private String executionId;     // 실행 ID (FK)
    private String dbName;          // 데이터베이스명
    private String schemaName;      // 스키마명
    private String tableName;       // 테이블명
    private String columnName;      // 컬럼명
    private String dataType;        // 데이터 타입
    private String columnComment;   // 컬럼 코멘트
    private String piiTypeCode;     // PII 유형 코드
    private String piiTypeName;     // PII 유형명
    private Integer score;          // 탐지 점수 (0-100)
    private Integer metaScore;      // 메타데이터 점수
    private Integer patternScore;   // 패턴 점수
    private Integer aiScore;        // AI 점수
    private String metaMatch;       // 메타 매칭 여부 (Y/N)
    private String patternMatch;    // 패턴 매칭 여부 (Y/N)
    private String aiMatch;         // AI 매칭 여부 (Y/N)
    private String matchedRule;     // 매칭된 규칙명
    private String matchedPattern;  // 매칭된 패턴
    private String sampleData;      // 샘플 데이터 (마스킹됨)
    private String encryptionStatus;  // 암호화 상태 (NONE, HASHED, ENCRYPTED, UNKNOWN)
    private String encryptionMethod;  // 탐지된 암호화 방법 (SHA-256, MD5, BCrypt, AES/Base64 등)
    private Integer encryptionRatio;  // 암호화 비율 (0-100%, 샘플 중 암호화된 값의 비율)
    private String confirmStatus;   // PENDING, CONFIRMED, EXCLUDED
    private String confirmedBy;     // 확인자 ID
    private String confirmedDate;   // 확인일시
    private String regDate;         // 등록일시
    private String updDate;         // 수정일시
    private String scanDate;        // 스캔 실행일시 (Execution start_time)
    private String jobName;         // 작업명 (조회용)
}
