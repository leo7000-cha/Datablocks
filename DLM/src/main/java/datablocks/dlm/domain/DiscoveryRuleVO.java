package datablocks.dlm.domain;

import lombok.Data;

/**
 * Discovery Rule VO
 * PII 탐지 규칙
 */
@Data
public class DiscoveryRuleVO {
    private String ruleId;          // 규칙 ID (UUID)
    private String ruleName;        // 규칙명
    private String ruleType;        // META, PATTERN, AI
    private String piiTypeCode;     // PII 유형 코드 (FK)
    private String category;        // 카테고리 (NAME, SSN, PHONE, EMAIL, etc.)
    private String pattern;         // 패턴 (컬럼명 키워드 또는 정규식)
    private String description;     // 설명
    private Double weight;          // 가중치 (0.0-1.0)
    private Integer priority;       // 우선순위
    private String status;          // ACTIVE, INACTIVE
    private String regUserId;       // 등록자 ID
    private String regDate;         // 등록일시
    private String updUserId;       // 수정자 ID
    private String updDate;         // 수정일시
}
