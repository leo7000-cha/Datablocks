package datablocks.dlm.domain;

import lombok.Data;

/**
 * X-Audit SDK 가 처리계에서 쏘는 이벤트 수신 DTO.
 *
 * <p>Phase 1 통합 (2026-04-24) 후 저장 대상:
 *   type=ACCESS : HTTP 진입/종료 → TBL_ACCESS_LOG (collect_type=WAS_SDK, action_type=HTTP_ACCESS)
 *   type=SQL    : 개별 SQL 실행  → TBL_ACCESS_LOG (collect_type=WAS_SDK, action_type=SELECT/INSERT/...)
 *                                   + TBL_ACCESS_LOG_SQL_DETAIL (SQL 풀 원문 sidecar)
 * reqId 로 "누가-어디서-무엇을-어떤 SQL로" 드릴다운 가능.
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
