package datablocks.dlm.domain;

import lombok.Data;

/**
 * 수집 대상 시스템 VO
 */
@Data
public class AccessLogSourceVO {
    private String sourceId;         // 수집원 ID (UUID)
    private String sourceName;       // 시스템명
    private String sourceType;       // 수집 방식 (DB_AUDIT, DB_DAC, WAS_AGENT)
    private String dbName;           // 연계 DB명
    private String dbType;           // DB 유형
    private String hostname;         // 호스트명
    private String port;             // 포트
    private String schemaName;       // 대상 스키마명 (PII 메타데이터 매칭용)
    private String agentId;          // BCI Agent ID
    private String agentLastHeartbeat; // Agent 마지막 heartbeat 시간
    private String agentStatus;      // Agent 상태 (ACTIVE/INACTIVE)
    private String description;      // 설명
    private Integer collectInterval; // 수집 주기 (분)
    private String tableFilter;      // 수집 대상 테이블 필터 (콤마 구분)
    private String excludeAccounts;  // 제외 계정 (콤마 구분: SYS,SYSTEM,DLM_BATCH)
    // DAC(접근제어 연동 감사) 전용
    private String dacSelectSql;     // 사용자 정의 SELECT문 (접근제어 솔루션 로그 조회)
    private String isActive;         // 활성화 여부 (Y/N)
    private String status;           // 수집 상태 (RUNNING/STOPPED/ERROR)
    private String lastCollectTime;  // 마지막 수집 시간
    private Long totalCollected;     // 누적 수집 건수
    private String errorMsg;         // 마지막 에러 메시지
    private String regUserId;        // 등록자 ID
    private String regDate;          // 등록일시
    private String updUserId;        // 수정자 ID
    private String updDate;          // 수정일시
}
