package datablocks.dlm.engine;

import java.util.Map;

import datablocks.dlm.domain.AccessLogSourceVO;

/**
 * Access Log Collector Interface
 * 접속기록 수집 엔진 인터페이스
 */
public interface AccessLogCollector {

    /**
     * 수집 대상 시스템에서 접속기록을 수집
     * @param source 수집 대상 시스템 정보
     * @return 수집된 레코드 수
     */
    int collect(AccessLogSourceVO source);

    /**
     * 수집 시작
     */
    void startCollection(String sourceId);

    /**
     * 수집 중지
     */
    void stopCollection(String sourceId);

    /**
     * 수집 상태 확인
     */
    boolean isCollecting(String sourceId);

    /**
     * DB_DAC 등록용 SELECT 미리보기 — 등록 전 dry-run.
     * <p>#{LAST_OFFSET} 은 NOW-7d 로 치환, LIMIT 1 강제 적용.
     * <p>응답 필드:
     *   valid (boolean), message,
     *   mappedMaster (List&lt;String&gt;), mappedSidecar (List&lt;String&gt;),
     *   unmapped (List&lt;String&gt;), missingRequired (List&lt;String&gt;),
     *   sampleRow (Map&lt;String,Object&gt;)
     */
    Map<String, Object> previewDacSql(String dbName, String selectSql);
}
