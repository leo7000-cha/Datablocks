package datablocks.dlm.domain;

import lombok.Data;

/**
 * Discovery PII Type VO
 * PII 유형 마스터
 */
@Data
public class DiscoveryPiiTypeVO {
    private String piiTypeCode;     // PII 유형 코드
    private String piiTypeName;     // PII 유형명
    private String piiTypeNameEn;   // PII 유형명 (영문)
    private String category;        // 카테고리 (PERSONAL, FINANCIAL, CONTACT, etc.)
    private String description;     // 설명
    private String scrambleType;    // 권장 변환 타입
    private Integer sortOrder;      // 정렬 순서
    private String status;          // ACTIVE, INACTIVE
    private String regDate;         // 등록일시
    private String updDate;         // 수정일시
}
