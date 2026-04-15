package datablocks.dlm.schedule;

import datablocks.dlm.domain.AccessLogConfigVO;
import datablocks.dlm.mapper.AccessLogMapper;
import datablocks.dlm.service.AccessLogService;
import datablocks.dlm.util.LogUtil;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.TaskScheduler;
import org.springframework.scheduling.support.CronTrigger;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.concurrent.ScheduledFuture;

/**
 * 접속기록 해시 무결성 자동 검증 스케줄러
 * DB 설정(HASH_VERIFY_SCHEDULE)에서 cron 표현식을 읽어 동적으로 스케줄링
 * (법적 근거: 안전성확보조치 기준 제8조 2항 — 월 1회 이상 점검)
 */
@Component
public class AccessLogHashVerifyScheduler {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogHashVerifyScheduler.class);
    private static final String DEFAULT_CRON = "0 0 3 1 * *"; // 매월 1일 03:00

    @Autowired
    private AccessLogMapper mapper;

    @Autowired
    private AccessLogService accessLogService;

    @Autowired
    private TaskScheduler taskScheduler;

    private ScheduledFuture<?> scheduledFuture;
    private String currentCron;

    @PostConstruct
    public void init() {
        String cron = loadCronFromConfig();
        scheduleTask(cron);
        LogUtil.log("INFO", "HashVerifyScheduler: Initialized with cron [" + cron + "]");
    }

    /**
     * 외부에서 스케줄 갱신 시 호출
     */
    public synchronized void reschedule() {
        String newCron = loadCronFromConfig();
        if (!newCron.equals(currentCron)) {
            if (scheduledFuture != null) {
                scheduledFuture.cancel(false);
            }
            scheduleTask(newCron);
            LogUtil.log("INFO", "HashVerifyScheduler: Rescheduled [" + currentCron + "] → [" + newCron + "]");
        }
    }

    private String loadCronFromConfig() {
        try {
            AccessLogConfigVO cfg = mapper.selectConfigByKey("HASH_VERIFY_SCHEDULE");
            if (cfg != null && cfg.getConfigValue() != null && !cfg.getConfigValue().isBlank()) {
                return cfg.getConfigValue().trim();
            }
        } catch (Exception e) {
            logger.warn("HashVerifyScheduler: Failed to load cron config, using default", e);
        }
        return DEFAULT_CRON;
    }

    private synchronized void scheduleTask(String cron) {
        try {
            scheduledFuture = taskScheduler.schedule(this::executeMonthlyHashVerify, new CronTrigger(cron));
            currentCron = cron;
        } catch (Exception e) {
            logger.error("HashVerifyScheduler: Invalid cron [{}], falling back to default", cron, e);
            scheduledFuture = taskScheduler.schedule(this::executeMonthlyHashVerify, new CronTrigger(DEFAULT_CRON));
            currentCron = DEFAULT_CRON;
        }
    }

    /**
     * 전월의 각 날짜별로 해시 체인 검증 수행
     */
    public void executeMonthlyHashVerify() {
        // 활성화 여부 확인
        AccessLogConfigVO cfg = mapper.selectConfigByKey("HASH_VERIFY_ENABLED");
        if (cfg != null && "N".equals(cfg.getConfigValue())) {
            LogUtil.log("INFO", "HashVerifyScheduler: HASH_VERIFY_ENABLED is N, skipping");
            return;
        }

        LocalDate now = LocalDate.now();
        LocalDate firstDayLastMonth = now.minusMonths(1).withDayOfMonth(1);
        LocalDate lastDayLastMonth = now.withDayOfMonth(1).minusDays(1);

        LogUtil.log("INFO", "HashVerifyScheduler: Starting monthly verification for "
                + firstDayLastMonth + " ~ " + lastDayLastMonth);

        int totalDays = 0;
        int validDays = 0;
        int invalidDays = 0;

        LocalDate date = firstDayLastMonth;
        while (!date.isAfter(lastDayLastMonth)) {
            String dateStr = date.format(DateTimeFormatter.ISO_LOCAL_DATE);
            try {
                Map<String, Object> result = accessLogService.verifyHashChain(dateStr);
                totalDays++;

                String status = (String) result.get("status");
                if ("VALID".equals(status)) {
                    validDays++;
                } else if ("INVALID".equals(status)) {
                    invalidDays++;
                    LogUtil.log("WARN", "HashVerifyScheduler: INVALID hash chain on " + dateStr
                            + " — invalidRecords=" + result.get("invalidRecords")
                            + ", firstInvalidId=" + result.get("firstInvalidId"));
                }
            } catch (Exception e) {
                logger.error("HashVerifyScheduler: Verification failed for date {}", dateStr, e);
                totalDays++;
            }
            date = date.plusDays(1);
        }

        LogUtil.log("INFO", "HashVerifyScheduler: Monthly verification completed — "
                + totalDays + " days checked, "
                + validDays + " valid, "
                + invalidDays + " invalid");

        if (invalidDays > 0) {
            LogUtil.log("WARN", "HashVerifyScheduler: " + invalidDays
                    + " day(s) with hash chain violations detected!");
        }
    }
}
