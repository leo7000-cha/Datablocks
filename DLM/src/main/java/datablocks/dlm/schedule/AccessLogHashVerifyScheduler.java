package datablocks.dlm.schedule;

import datablocks.dlm.domain.AccessLogConfigVO;
import datablocks.dlm.mapper.AccessLogMapper;
import datablocks.dlm.service.AccessLogService;
import datablocks.dlm.util.LogUtil;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Map;

/**
 * 접속기록 해시 무결성 자동 검증 스케줄러
 * 매월 1일 03:00 실행 — 전월 접속기록 전수 검증
 * (법적 근거: 안전성확보조치 기준 제8조 2항 — 월 1회 이상 점검)
 */
@Component
public class AccessLogHashVerifyScheduler {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogHashVerifyScheduler.class);

    @Autowired
    private AccessLogMapper mapper;

    @Autowired
    private AccessLogService accessLogService;

    /**
     * 매월 1일 03:00 실행
     * 전월의 각 날짜별로 해시 체인 검증 수행
     */
    @Scheduled(cron = "0 0 3 1 * *")
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
                // totalRecords=0인 날은 스킵됨 (result.status = "VALID", records=0)
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
