package datablocks.dlm.domain;

import lombok.Data;

/**
 * 접속기록 메인 VO (5W1H + 해시체인)
 */
@Data
public class AccessLogVO {
    private Long logId;              // 로그 ID (PK, AUTO_INCREMENT)
    private String sourceSystemId;   // 수집원 시스템 ID
    private String userAccount;      // 접속자 계정 (Who)
    private String userName;         // 접속자 이름
    private String department;       // 소속 부서
    private String accessTime;       // 접속일시 (When)
    private String clientIp;         // 접속지 IP (Where)
    private String actionType;       // 수행업무 (What): SELECT/UPDATE/DELETE/INSERT/DOWNLOAD/EXPORT
    private String targetDb;         // 대상 DB명
    private String targetSchema;     // 대상 스키마
    private String targetTable;      // 대상 테이블
    private String targetColumns;    // 접근한 컬럼 목록
    private String piiTypeCodes;     // 관련 PII 유형 코드
    private String piiGrade;         // 개인정보 등급 (1/2/3)
    private Integer affectedRows;    // 영향받은 행 수
    private String searchCondition;  // 검색 조건문 (Whom)
    private String sqlText;          // 실행 SQL
    private String accessChannel;    // 접근 경로 (WEB/WAS/DB_DIRECT/API/BATCH)
    private String sessionId;        // 세션 ID
    private String resultCode;       // 수행 결과 (SUCCESS/FAIL/DENIED)
    private String hashValue;        // SHA-256 해시
    private String prevHash;         // 이전 레코드 해시 (해시 체인)
    private String collectedAt;      // DLM 수집 시간
    private String partitionKey;     // 파티셔닝 키 (YYYYMMDD)

    // 조회용 조인 필드
    private String sourceName;       // 수집원 시스템명 (조회용)
}
