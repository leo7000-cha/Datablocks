package datablocks.dlm.domain;

import lombok.Data;

/**
 * 수집 상태/오프셋 추적 VO
 */
@Data
public class AccessLogCollectStatusVO {
    private Long statusId;
    private String sourceId;
    private String collectStart;
    private String collectEnd;
    private String lastOffset;
    private Integer collectedCount;
    private String status;
    private String errorMsg;
    private Integer retryCount;
    private String regDate;
}
