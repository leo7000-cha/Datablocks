package datablocks.dlm.domain;

import lombok.Data;

/**
 * Discovery Configuration VO
 * 스캔 설정 (시스템 설정)
 */
@Data
public class DiscoveryConfigVO {
    private String configId;        // 설정 ID
    private String configKey;       // 설정 키
    private String configValue;     // 설정 값
    private String configType;      // 설정 유형 (THREAD, EXCLUDE_TYPE, EXCLUDE_SIZE, EXCLUDE_PATTERN, GENERAL)
    private String description;     // 설명
    private String isActive;        // 활성화 여부 (Y/N)
    private String regUserId;       // 등록자 ID
    private String regDate;         // 등록일시
    private String updUserId;       // 수정자 ID
    private String updDate;         // 수정일시

    // 상수 정의
    public static final String TYPE_THREAD = "THREAD";
    public static final String TYPE_EXCLUDE_DATATYPE = "EXCLUDE_DATATYPE";
    public static final String TYPE_EXCLUDE_SIZE = "EXCLUDE_SIZE";
    public static final String TYPE_EXCLUDE_PATTERN = "EXCLUDE_PATTERN";
    public static final String TYPE_GENERAL = "GENERAL";

    // 기본 설정 키
    public static final String KEY_DEFAULT_THREAD_COUNT = "DEFAULT_THREAD_COUNT";
    public static final String KEY_SKIP_CONFIRMED_PII = "SKIP_CONFIRMED_PII";
    public static final String KEY_MIN_COLUMN_LENGTH = "MIN_COLUMN_LENGTH";
}
