package datablocks.dlm.domain;

import lombok.Data;

/**
 * 이상행위 탐지 규칙 VO
 */
@Data
public class AccessLogAlertRuleVO {
    private String ruleId;
    private String ruleCode;
    private String ruleName;
    private String description;
    private String severity;         // HIGH/MEDIUM/LOW/INFO
    private String conditionType;    // VOLUME/TIME_RANGE/ACCESS_DENIED/PII_GRADE/REPEAT/NEW_IP/INACTIVE
    private Integer thresholdValue;
    private Integer timeWindowMin;
    private String timeRangeStart;
    private String timeRangeEnd;
    private String targetAction;
    private String targetPiiGrade;
    private String isActive;
    private Integer sortOrder;
    private String regUserId;
    private String regDate;
    private String updUserId;
    private String updDate;
}
