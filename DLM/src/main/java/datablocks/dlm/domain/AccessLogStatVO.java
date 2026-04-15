package datablocks.dlm.domain;

import lombok.Data;

/**
 * 대시보드 통계 VO
 */
@Data
public class AccessLogStatVO {
    // 요약 카드
    private Long todayAccessCount;
    private Integer alertCount;
    private Integer unresolvedAlertCount;
    private Integer activeSourceCount;
    private Integer totalSourceCount;

    // 기간별
    private Long totalAccessCount;
    private Long selectCount;
    private Long updateCount;
    private Long deleteCount;
    private Long downloadCount;

    // 추가 정보
    private String lastCollectTime;
    private String hashVerifyStatus;
    private String lastHashVerifyTime;
    private Integer piiAccessCount;

    // ========== 법규 준수현황 (Compliance) ==========
    // 제8조 제2항: 접속기록 보관
    private Integer retentionYears;          // 설정된 보관기간 (년)
    // 제8조 제3항: 월 1회 이상 점검
    private Integer thisMonthHashVerifyCount; // 이번 달 해시 검증 횟수
    private String lastMonthlyReviewDate;     // 최근 점검 일자
    // 제8조 제4항: 위·변조 방지
    private Integer invalidHashCount;         // 위변조 탐지 건수
    // 탐지 규칙 관련
    private Integer activeRuleCount;          // 활성 탐지 규칙 수
    private Integer totalRuleCount;           // 전체 탐지 규칙 수
    // 소명 처리 관련
    private Integer overdueAlertCount;        // 기한 초과 알림 수
    private Integer escalatedAlertCount;      // 에스컬레이션 알림 수
    private Integer justifiedWaitingCount;    // 소명 대기(승인 필요) 건수

    // 알림 상태별 건수 (대시보드용)
    private Integer alertNewCount;            // 신규
    private Integer alertNotifiedCount;       // 소명요청
    private Integer alertJustifiedCount;      // 소명완료 (승인 대기)
    private Integer alertResolvedCount;       // 승인완료
    private Integer alertDismissedCount;      // 무시
    private Integer alertReJustifyCount;      // 재소명
    private Integer alertOverdueCount;        // 소명기한초과
    private Integer alertEscalatedCount;      // 미응답경고
    // 다운로드 통제
    private Integer thisMonthDownloadCount;   // 이번 달 다운로드 건수
    // 접속기록 최초/최종 일자
    private String oldestAccessDate;          // 가장 오래된 접속기록 일자
    private String latestAccessDate;          // 가장 최근 접속기록 일자
}
