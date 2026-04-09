package datablocks.dlm.schedule;

import datablocks.dlm.domain.AccessLogConfigVO;
import datablocks.dlm.domain.AccessLogSourceVO;
import datablocks.dlm.engine.AccessLogCollector;
import datablocks.dlm.engine.AccessLogDetectionEngine;
import datablocks.dlm.mapper.AccessLogMapper;
import datablocks.dlm.util.LogUtil;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * 접속기록 스케줄 수집 + 이상행위 탐지
 * 매분 실행, COLLECT_INTERVAL_MIN 설정값으로 실제 수집 주기 제어
 */
@Component
public class AccessLogScheduler {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogScheduler.class);

    private final AtomicBoolean running = new AtomicBoolean(false);
    private LocalDateTime lastExecutionTime = null;

    @Autowired
    private AccessLogMapper mapper;

    @Autowired
    private AccessLogCollector collector;

    @Autowired
    private AccessLogDetectionEngine detectionEngine;

    @Scheduled(cron = "0 * * * * *")
    public void scheduledCollect() {
        // 스케줄러 활성화 확인
        AccessLogConfigVO schedulerCfg = mapper.selectConfigByKey("SCHEDULER_ENABLED");
        if (schedulerCfg != null && "N".equals(schedulerCfg.getConfigValue())) {
            return;
        }

        // 수집 간격 확인
        int intervalMin = 5;
        AccessLogConfigVO intervalCfg = mapper.selectConfigByKey("COLLECT_INTERVAL_MIN");
        if (intervalCfg != null && intervalCfg.getConfigValue() != null) {
            try {
                intervalMin = Integer.parseInt(intervalCfg.getConfigValue().trim());
            } catch (NumberFormatException ignored) {}
        }

        // 마지막 실행으로부터 interval 미경과 시 스킵
        if (lastExecutionTime != null
                && lastExecutionTime.plusMinutes(intervalMin).isAfter(LocalDateTime.now())) {
            return;
        }

        // 동시 실행 방지
        if (!running.compareAndSet(false, true)) {
            LogUtil.log("WARN", "AccessLogScheduler: Previous collection still running, skipping");
            return;
        }

        try {
            lastExecutionTime = LocalDateTime.now();
            LogUtil.log("INFO", "AccessLogScheduler: Starting scheduled collection");

            List<AccessLogSourceVO> sources = mapper.selectActiveSourceList();
            int totalCollected = 0;

            for (AccessLogSourceVO source : sources) {
                try {
                    int collected = collector.collect(source);
                    totalCollected += collected;
                } catch (Exception e) {
                    logger.error("AccessLogScheduler: Collection failed for source: {}", source.getSourceId(), e);
                }
            }

            LogUtil.log("INFO", "AccessLogScheduler: Collected " + totalCollected + " records from " + sources.size() + " sources");

            // 수집 후 이상행위 탐지 실행
            try {
                int detected = detectionEngine.detectAll();
                if (detected > 0) {
                    LogUtil.log("INFO", "AccessLogScheduler: " + detected + " anomalies detected");
                }
            } catch (Exception e) {
                logger.error("AccessLogScheduler: Detection failed", e);
            }

        } finally {
            running.set(false);
        }
    }
}
