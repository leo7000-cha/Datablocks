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
}
