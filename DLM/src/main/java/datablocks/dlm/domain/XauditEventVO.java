package datablocks.dlm.domain;

import lombok.Data;

/**
 * X-Audit SDK 가 처리계에서 쏘는 이벤트 수신 DTO.
 *
 * type=ACCESS : HTTP 진입/종료 → TBL_XAUDIT_ACCESS_LOG
 * type=SQL    : 개별 SQL 실행    → TBL_XAUDIT_SQL_LOG
 * reqId 로 두 테이블을 조인하여 "누가-어디서-무엇을-어떤 SQL로" 통합 조회.
 */
@Data
public class XauditEventVO {

    private String  type;          // ACCESS / SQL

    // 공통 식별자
    private String  reqId;
    private String  serviceName;
    private String  userId;
    private String  userName;
    private String  department;
    private String  clientIp;
    private String  sessionId;
    private String  menuId;
    private String  uri;
    private String  httpMethod;
    private String  userAgent;
    private String  accessTime;    // "yyyy-MM-dd HH:mm:ss.SSS"
    private String  partitionKey;  // "yyyyMMdd"

    // ACCESS 전용
    private Integer httpStatus;
    private Long    totalDurationMs;
    private String  resultCode;

    // SQL 전용
    private String  sqlId;
    private String  sqlType;
    private String  sqlText;
    private String  bindParams;
    private Integer affectedRows;
    private Long    durationMs;
    private String  targetDb;
    private String  targetTable;
    private String  piiDetected;
    private String  errorMessage;

    // 서버에서 채워지는 필드
    private Long    logId;
    private String  collectedAt;
    private String  hashPrev;
    private String  hashCur;
}
