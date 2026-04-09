package datablocks.dlm.agent.context;

public class UserContext {

    private static final ThreadLocal<UserContext> HOLDER = new ThreadLocal<>();

    private String userId;
    private String userName;
    private String clientIp;
    private String sessionId;

    public static UserContext current() {
        return HOLDER.get();
    }

    public static void set(UserContext ctx) {
        HOLDER.set(ctx);
    }

    public static void clear() {
        HOLDER.remove();
    }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getClientIp() { return clientIp; }
    public void setClientIp(String clientIp) { this.clientIp = clientIp; }

    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }
}
