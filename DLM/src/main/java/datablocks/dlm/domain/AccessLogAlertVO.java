package datablocks.dlm.domain;

import lombok.Data;

/**
 * 이상행위 알림 VO
 */
@Data
public class AccessLogAlertVO {
    private Long alertId;
    private String ruleId;
    private String ruleCode;
    private String severity;
    private String alertTitle;
    private String alertDetail;
    private String targetUserId;
    private String targetUserName;
    private String relatedLogIds;
    private String detectedTime;
    private String status;           // NEW/ACKNOWLEDGED/RESOLVED/DISMISSED
    private String resolvedBy;
    private String resolvedTime;
    private String resolveComment;
    private String regDate;
    private String updDate;

    // 조회용 조인 필드
    private String ruleName;
}
