package datablocks.dlm.domain;

import lombok.Data;

/**
 * BCI Agent 감사 대상 테이블 VO
 */
@Data
public class BciTargetVO {
    private String targetId;
    private String dbName;
    private String owner;
    private String tableName;
    private String targetType;   // PII / BUSINESS
    private String description;
    private String isActive;
    private String regUserId;
    private String regDate;
    private String updUserId;
    private String updDate;

    // 조회용 (MetaTable JOIN 시)
    private Integer piiColumnCount;
    private String piiColumns;
}
