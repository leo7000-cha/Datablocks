package datablocks.dlm.domain;

/**
 * 알림 예외(억제) 규칙 VO
 * 개인정보보호법 제29조, 안전성 확보조치 기준 제8조 근거
 */
public class AlertSuppressionVO {

    private Long suppressionId;
    private String ruleId;
    private String ruleCode;
    private String targetUserId;
    private String suppressionType;  // SUPPRESS / EXCEPTION
    private String reason;
    private String severityAtTime;
    private Long sourceAlertId;
    private String approvedBy;
    private String approvedAt;
    private String effectiveFrom;
    private String effectiveUntil;
    private int reviewCycleDays;
    private String lastReviewedAt;
    private String lastReviewedBy;
    private String nextReviewAt;
    private String reviewComment;
    private String isActive;
    private String deactivatedBy;
    private String deactivatedAt;
    private String deactivateReason;
    private String regUserId;
    private String regDate;
    private String updUserId;
    private String updDate;

    // Display fields (joined)
    private String ruleName;
    private String targetUserName;
    private int suppressedCount; // 억제된 알림 건수

    public Long getSuppressionId() { return suppressionId; }
    public void setSuppressionId(Long suppressionId) { this.suppressionId = suppressionId; }
    public String getRuleId() { return ruleId; }
    public void setRuleId(String ruleId) { this.ruleId = ruleId; }
    public String getRuleCode() { return ruleCode; }
    public void setRuleCode(String ruleCode) { this.ruleCode = ruleCode; }
    public String getTargetUserId() { return targetUserId; }
    public void setTargetUserId(String targetUserId) { this.targetUserId = targetUserId; }
    public String getSuppressionType() { return suppressionType; }
    public void setSuppressionType(String suppressionType) { this.suppressionType = suppressionType; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getSeverityAtTime() { return severityAtTime; }
    public void setSeverityAtTime(String severityAtTime) { this.severityAtTime = severityAtTime; }
    public Long getSourceAlertId() { return sourceAlertId; }
    public void setSourceAlertId(Long sourceAlertId) { this.sourceAlertId = sourceAlertId; }
    public String getApprovedBy() { return approvedBy; }
    public void setApprovedBy(String approvedBy) { this.approvedBy = approvedBy; }
    public String getApprovedAt() { return approvedAt; }
    public void setApprovedAt(String approvedAt) { this.approvedAt = approvedAt; }
    public String getEffectiveFrom() { return effectiveFrom; }
    public void setEffectiveFrom(String effectiveFrom) { this.effectiveFrom = effectiveFrom; }
    public String getEffectiveUntil() { return effectiveUntil; }
    public void setEffectiveUntil(String effectiveUntil) { this.effectiveUntil = effectiveUntil; }
    public int getReviewCycleDays() { return reviewCycleDays; }
    public void setReviewCycleDays(int reviewCycleDays) { this.reviewCycleDays = reviewCycleDays; }
    public String getLastReviewedAt() { return lastReviewedAt; }
    public void setLastReviewedAt(String lastReviewedAt) { this.lastReviewedAt = lastReviewedAt; }
    public String getLastReviewedBy() { return lastReviewedBy; }
    public void setLastReviewedBy(String lastReviewedBy) { this.lastReviewedBy = lastReviewedBy; }
    public String getNextReviewAt() { return nextReviewAt; }
    public void setNextReviewAt(String nextReviewAt) { this.nextReviewAt = nextReviewAt; }
    public String getReviewComment() { return reviewComment; }
    public void setReviewComment(String reviewComment) { this.reviewComment = reviewComment; }
    public String getIsActive() { return isActive; }
    public void setIsActive(String isActive) { this.isActive = isActive; }
    public String getDeactivatedBy() { return deactivatedBy; }
    public void setDeactivatedBy(String deactivatedBy) { this.deactivatedBy = deactivatedBy; }
    public String getDeactivatedAt() { return deactivatedAt; }
    public void setDeactivatedAt(String deactivatedAt) { this.deactivatedAt = deactivatedAt; }
    public String getDeactivateReason() { return deactivateReason; }
    public void setDeactivateReason(String deactivateReason) { this.deactivateReason = deactivateReason; }
    public String getRegUserId() { return regUserId; }
    public void setRegUserId(String regUserId) { this.regUserId = regUserId; }
    public String getRegDate() { return regDate; }
    public void setRegDate(String regDate) { this.regDate = regDate; }
    public String getUpdUserId() { return updUserId; }
    public void setUpdUserId(String updUserId) { this.updUserId = updUserId; }
    public String getUpdDate() { return updDate; }
    public void setUpdDate(String updDate) { this.updDate = updDate; }
    public String getRuleName() { return ruleName; }
    public void setRuleName(String ruleName) { this.ruleName = ruleName; }
    public String getTargetUserName() { return targetUserName; }
    public void setTargetUserName(String targetUserName) { this.targetUserName = targetUserName; }
    public int getSuppressedCount() { return suppressedCount; }
    public void setSuppressedCount(int suppressedCount) { this.suppressedCount = suppressedCount; }
}
