package datablocks.dlm.domain;

import lombok.Data;

/**
 * Discovery PII Registry VO
 * 확정된 PII 컬럼 레지스트리
 * - Scan Result와 분리하여 PII 컬럼 상태를 독립적으로 관리
 * - CONFIRMED: PII로 확정된 컬럼 (다음 스캔에서 제외)
 * - EXCLUDED: 오탐으로 제외된 컬럼 (다음 스캔에서 제외)
 */
@Data
public class DiscoveryPiiRegistryVO {
    // Primary Key
    private String registryId;

    // Column Identification (Unique Key)
    private String dbName;
    private String schemaName;
    private String tableName;
    private String columnName;

    // Column Metadata
    private String dataType;
    private String columnComment;

    // PII Detection Info
    private String piiTypeCode;
    private String piiTypeName;
    private String detectionMethod;  // META, PATTERN, MANUAL
    private Double confidenceScore;
    private String sampleData;

    // First Detection Info
    private String firstDetectedDate;
    private String firstDetectedExecutionId;
    private String firstDetectedResultId;

    // Registry Status
    private String status;  // CONFIRMED, EXCLUDED

    // Audit Info
    private String registeredBy;
    private String registeredDate;
    private String updatedBy;
    private String updatedDate;
    private String remarks;

    // Timestamp
    private String createdDate;

    /**
     * 컬럼 고유 키 생성 (스캔 시 제외 체크용)
     * Format: DB.SCHEMA.TABLE.COLUMN (uppercase)
     */
    public String getUniqueKey() {
        StringBuilder sb = new StringBuilder();
        sb.append(dbName != null ? dbName : "");
        sb.append(".");
        sb.append(schemaName != null ? schemaName : "");
        sb.append(".");
        sb.append(tableName != null ? tableName : "");
        sb.append(".");
        sb.append(columnName != null ? columnName : "");
        return sb.toString().toUpperCase();
    }

    /**
     * Scan Result에서 Registry로 변환 시 사용할 팩토리 메서드
     */
    public static DiscoveryPiiRegistryVO fromScanResult(DiscoveryScanResultVO result, String status, String userId) {
        DiscoveryPiiRegistryVO registry = new DiscoveryPiiRegistryVO();
        registry.setRegistryId(java.util.UUID.randomUUID().toString());
        registry.setDbName(result.getDbName());
        registry.setSchemaName(result.getSchemaName());
        registry.setTableName(result.getTableName());
        registry.setColumnName(result.getColumnName());
        registry.setDataType(result.getDataType());
        registry.setColumnComment(result.getColumnComment());
        registry.setPiiTypeCode(result.getPiiTypeCode());
        registry.setPiiTypeName(result.getPiiTypeName());

        // Detection method 유추: metaMatch/patternMatch에서
        String detectionMethod = "UNKNOWN";
        if ("Y".equals(result.getMetaMatch()) && "Y".equals(result.getPatternMatch())) {
            detectionMethod = "META+PATTERN";
        } else if ("Y".equals(result.getMetaMatch())) {
            detectionMethod = "META";
        } else if ("Y".equals(result.getPatternMatch())) {
            detectionMethod = "PATTERN";
        }
        registry.setDetectionMethod(detectionMethod);

        // Score를 confidenceScore로 변환
        if (result.getScore() != null) {
            registry.setConfidenceScore(result.getScore().doubleValue());
        }

        registry.setSampleData(result.getSampleData());
        registry.setFirstDetectedDate(result.getScanDate() != null ? result.getScanDate() : result.getRegDate());
        registry.setFirstDetectedExecutionId(result.getExecutionId());
        registry.setFirstDetectedResultId(result.getResultId());
        registry.setStatus(status);
        registry.setRegisteredBy(userId);
        return registry;
    }
}
