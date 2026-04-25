package datablocks.dlm.domain;

import lombok.Data;

/**
 * 접속기록 VO — Flat Facade.
 *
 * <p>내부적으로 2 개 테이블에 매핑됨:
 *   · {@code TBL_ACCESS_LOG}        (Master, 고정 길이 컬럼 전용, row ≈ 1KB)
 *   · {@code TBL_ACCESS_LOG_DETAIL} (Sidecar, TEXT/가변 필드, 필요 시만 INSERT)
 *
 * <p>개발자는 단일 VO 로 다루며, Mapper 가 {@code insertAccessLogMaster} 후
 * {@link #hasDetail()} 가 true 이면 {@code insertAccessLogDetail} 을 실행한다.
 *
 * <p>4 가지 수집 경로 공통 VO — 경로별 필드 사용 양상:
 *   · DB_AUDIT / DB_DAC : user_account + target_* + sqlText + searchCondition
 *   · WAS_AGENT         : + targetColumns (BCI 가로챈 컬럼)
 *   · WAS_SDK           : + reqId/serviceName/menuId/uri/http_* + bindParams/fullUri/userAgent
 */
@Data
public class AccessLogVO {

    // ========== Master — TBL_ACCESS_LOG ==========

    // PK
    private Long    logId;
    // WHO
    private String  sourceSystemId;
    private String  userAccount;
    private String  userName;
    private String  department;
    // WHEN
    private String  accessTime;        // "yyyy-MM-dd HH:mm:ss.SSS"
    // WHERE
    private String  clientIp;
    private String  sessionId;
    // WHAT
    private String  actionType;        // SELECT/INSERT/UPDATE/DELETE/DOWNLOAD/EXPORT/HTTP_ACCESS
    private String  targetDb;
    private String  targetSchema;
    private String  targetTable;
    private Integer affectedRows;
    private String  resultCode;        // SUCCESS/FAIL/DENIED
    // PII 플래그 (요약)
    private String  piiTypeCodes;      // CSV, max 200
    private String  piiGrade;          // 1/2/3
    private String  piiDetectedFlag;   // Y/N
    // 수집 메타
    private String  collectType;       // DB_AUDIT/DB_DAC/WAS_AGENT/WAS_SDK
    private String  accessChannel;     // WEB/WAS/DB_DIRECT/API/BATCH
    // 무결성 + 시각
    private String  hashValue;
    private String  prevHash;
    private String  collectedAt;
    private String  partitionKey;      // YYYYMMDD
    // WAS_SDK HTTP 컨텍스트
    private String  reqId;
    private String  serviceName;
    private String  menuId;
    private String  uri;               // path only
    private String  httpMethod;
    private Integer httpStatus;
    private Long    durationMs;        // HTTP 전체 or SQL 개별

    // ========== Sidecar — TBL_ACCESS_LOG_DETAIL ==========

    private String  sqlId;
    private String  sqlText;           // MEDIUMTEXT
    private String  bindParams;
    private String  searchCondition;   // ≤ 4000
    private String  targetColumns;     // ≤ 4000
    private String  fullUri;           // ≤ 2000
    private String  userAgent;         // ≤ 500
    private String  errorMessage;      // ≤ 500

    // ========== 조회용 조인 (읽기 전용) ==========
    private String  sourceName;

    /** Sidecar INSERT 가 필요한지 판단 — 대형 필드 중 하나라도 있으면 true. */
    public boolean hasDetail() {
        return notBlank(sqlText) || notBlank(bindParams) || notBlank(searchCondition)
                || notBlank(targetColumns) || notBlank(fullUri) || notBlank(userAgent)
                || notBlank(sqlId) || notBlank(errorMessage);
    }

    private static boolean notBlank(String s) { return s != null && !s.isEmpty(); }
}
