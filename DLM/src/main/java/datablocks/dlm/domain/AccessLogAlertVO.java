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

    // 소명 워크플로우
    private String notificationSentAt;   // 소명요청 이메일 발송 시간
    private String notificationToken;    // 소명 페이지 접근용 토큰
    private String tokenExpiresAt;       // 토큰 만료시간
    private String targetUserEmail;      // 대상자 이메일
    private String justification;        // 대상자 소명(사유) 내용
    private String justificationSummary; // 소명 요약 (리스트 표시용)
    private String justifiedAt;          // 소명 제출 시간
    private String justifiedBy;          // 소명 제출자
    private String approverId;           // 승인자 ID
    private String approvalComment;      // 승인자 코멘트
    private String approvedAt;           // 승인 시간
    private String slaDeadline;          // SLA 마감시간
    private Integer escalationLevel;     // 에스컬레이션 단계

    // 조회용 조인 필드
    private String ruleName;
}
