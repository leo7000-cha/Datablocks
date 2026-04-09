package datablocks.dlm.engine;

/**
 * 접속기록 이상행위 탐지 엔진 인터페이스
 */
public interface AccessLogDetectionEngine {

    /**
     * 특정 소스에 대한 이상행위 탐지
     * @param sourceId 수집 대상 ID (null이면 전체)
     * @return 감지된 알림 건수
     */
    int detectAnomalies(String sourceId);

    /**
     * 전체 소스에 대한 이상행위 탐지
     * @return 감지된 알림 건수
     */
    int detectAll();
}
