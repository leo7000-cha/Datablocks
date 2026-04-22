package datablocks.dlm.xaudit.core;

/**
 * DLM 수집 서버로 전송되는 단일 이벤트.
 *
 * 두 종류:
 *  - ACCESS : HTTP 진입/종료 (access_log 에 해당)
 *  - SQL    : 개별 SQL 실행 (sql_log 에 해당)
 *
 * reqId 로 조인되며, DLM 서버는 기존 {@code /api/agent/logs} 엔드포인트가
 * 배치를 받도록 되어 있으므로 JSON 은 거기에 맞춰 직렬화.
 */
public class XauditEvent {

    public enum Type { ACCESS, SQL }

    public Type   type;
    public String reqId;
    public String serviceName;
    public String userId;
    public String userName;
    public String department;
    public String clientIp;
    public String sessionId;
    public String menuId;
    public String uri;
    public String httpMethod;
    public String userAgent;
    public String accessTime;          // "yyyy-MM-dd HH:mm:ss.SSS"
    public String partitionKey;        // "yyyyMMdd"

    // ACCESS 전용
    public Integer httpStatus;
    public Long totalDurationMs;
    public String resultCode;          // SUCCESS / FAIL

    // SQL 전용
    public String  sqlId;              // MyBatis MappedStatement ID
    public String  sqlType;            // SELECT / INSERT / UPDATE / DELETE / OTHER
    public String  sqlText;
    public String  bindParams;
    public Integer affectedRows;
    public Long    durationMs;
    public String  targetDb;
    public String  targetTable;
    public String  piiDetected;        // JUMIN, CARD 등 탐지된 패턴 CSV
    public String  errorMessage;
}
