package datablocks.dlm.domain;

import lombok.Data;

/**
 * 접속기록관리 설정 VO
 */
@Data
public class AccessLogConfigVO {
    private String configId;
    private String configKey;
    private String configValue;
    private String configType;
    private String description;
    private String isActive;
    private Integer sortOrder;
    private String regUserId;
    private String regDate;
    private String updUserId;
    private String updDate;
}
