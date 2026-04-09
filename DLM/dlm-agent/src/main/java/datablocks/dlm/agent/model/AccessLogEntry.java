package datablocks.dlm.agent.model;

public class AccessLogEntry {

    private String sql;
    private String userId;
    private String userName;
    private String clientIp;
    private String sessionId;
    private long elapsedMs;
    private long timestamp;
    private boolean success;
    private String actionType;

    // PII 분석 결과
    private String targetTable;
    private String targetColumns;
    private String piiTypeCodes;
    private String piiGrade;

    // Agent 식별
    private String agentId;

    public AccessLogEntry() {}

    public String getSql() { return sql; }
    public void setSql(String sql) { this.sql = sql; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getClientIp() { return clientIp; }
    public void setClientIp(String clientIp) { this.clientIp = clientIp; }

    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }

    public long getElapsedMs() { return elapsedMs; }
    public void setElapsedMs(long elapsedMs) { this.elapsedMs = elapsedMs; }

    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }

    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }

    public String getActionType() { return actionType; }
    public void setActionType(String actionType) { this.actionType = actionType; }

    public String getTargetTable() { return targetTable; }
    public void setTargetTable(String targetTable) { this.targetTable = targetTable; }

    public String getTargetColumns() { return targetColumns; }
    public void setTargetColumns(String targetColumns) { this.targetColumns = targetColumns; }

    public String getPiiTypeCodes() { return piiTypeCodes; }
    public void setPiiTypeCodes(String piiTypeCodes) { this.piiTypeCodes = piiTypeCodes; }

    public String getPiiGrade() { return piiGrade; }
    public void setPiiGrade(String piiGrade) { this.piiGrade = piiGrade; }

    public String getAgentId() { return agentId; }
    public void setAgentId(String agentId) { this.agentId = agentId; }
}
