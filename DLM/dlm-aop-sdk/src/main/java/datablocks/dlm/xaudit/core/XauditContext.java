package datablocks.dlm.xaudit.core;

/**
 * 요청 단위 감사 컨텍스트 스냅샷.
 * Servlet Filter 에서 채워져 {@link XauditContextHolder} 에 저장되고
 * MyBatis Interceptor / DataSource-Proxy Listener 가 읽어간다.
 */
public class XauditContext {

    /** 요청 고유 UUID — access_log ↔ sql_log 조인 키 */
    private final String reqId;
    private final String userId;
    private final String userName;
    private final String department;
    private final String clientIp;
    private final String sessionId;
    private final String menuId;
    private final String uri;
    private final String httpMethod;
    private final String userAgent;
    private final long startedAtMs;
    private final String serviceName;

    public XauditContext(String reqId, String userId, String userName, String department,
                         String clientIp, String sessionId, String menuId,
                         String uri, String httpMethod, String userAgent,
                         String serviceName) {
        this.reqId = reqId;
        this.userId = userId;
        this.userName = userName;
        this.department = department;
        this.clientIp = clientIp;
        this.sessionId = sessionId;
        this.menuId = menuId;
        this.uri = uri;
        this.httpMethod = httpMethod;
        this.userAgent = userAgent;
        this.startedAtMs = System.currentTimeMillis();
        this.serviceName = serviceName;
    }

    public String getReqId()       { return reqId; }
    public String getUserId()      { return userId; }
    public String getUserName()    { return userName; }
    public String getDepartment()  { return department; }
    public String getClientIp()    { return clientIp; }
    public String getSessionId()   { return sessionId; }
    public String getMenuId()      { return menuId; }
    public String getUri()         { return uri; }
    public String getHttpMethod()  { return httpMethod; }
    public String getUserAgent()   { return userAgent; }
    public long   getStartedAtMs() { return startedAtMs; }
    public String getServiceName() { return serviceName; }
}
