package datablocks.dlm.aop;

/**
 * AOP 동기 단계에서 수집한 원시 정보 스냅샷.
 * HttpServletRequest 는 비동기 스레드에서 null 이 되므로 여기에 미리 옮긴다.
 */
public class AccessLogContext {
    public String uri;
    public String httpMethod;
    public String clientIp;
    public String userAgent;
    public String sessionId;
    public String userAccount;
    public String userName;
    public String department;
    public String menuId;
    public String menuName;
    public String business;
    public String importance;
    public String actionType;
    public String paramsJson;
    public long durationMs;
    public String resultCode;
    public String errorMessage;
}
