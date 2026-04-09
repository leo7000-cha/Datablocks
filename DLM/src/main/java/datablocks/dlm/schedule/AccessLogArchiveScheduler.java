package datablocks.dlm.schedule;

import datablocks.dlm.domain.AccessLogConfigVO;
import datablocks.dlm.mapper.AccessLogMapper;
import datablocks.dlm.util.LogUtil;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

/**
 * 접속기록 자동 아카이빙/퍼지 스케줄러
 * 매월 1일 02:00 실행
 * - 향후 3개월분 파티션 자동 생성
 * - 보관기간 초과 파티션 삭제
 */
@Component
public class AccessLogArchiveScheduler {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogArchiveScheduler.class);
    private static final DateTimeFormatter MONTH_FMT = DateTimeFormatter.ofPattern("yyyyMM");

    @Autowired
    private AccessLogMapper mapper;

    @Scheduled(cron = "0 0 2 1 * *")
    public void executeMonthlyArchive() {
        AccessLogConfigVO archiveCfg = mapper.selectConfigByKey("ARCHIVE_ENABLED");
        if (archiveCfg != null && "N".equals(archiveCfg.getConfigValue())) {
            LogUtil.log("INFO", "AccessLogArchive: ARCHIVE_ENABLED is N, skipping");
            return;
        }

        LogUtil.log("INFO", "AccessLogArchive: Starting monthly archive job");

        try {
            createFuturePartitions();
        } catch (Exception e) {
            logger.error("AccessLogArchive: Failed to create future partitions", e);
        }

        try {
            dropExpiredPartitions();
        } catch (Exception e) {
            logger.error("AccessLogArchive: Failed to drop expired partitions", e);
        }

        LogUtil.log("INFO", "AccessLogArchive: Monthly archive job completed");
    }

    /**
     * 향후 3개월분 파티션 자동 생성
     * REORGANIZE PARTITION p_future INTO (새파티션, p_future)
     */
    private void createFuturePartitions() {
        List<Map<String, Object>> partitions = mapper.selectPartitionInfo();

        LocalDate now = LocalDate.now();
        for (int i = 1; i <= 3; i++) {
            LocalDate futureMonth = now.plusMonths(i);
            String partName = "p" + futureMonth.format(MONTH_FMT);
            String nextMonth = futureMonth.plusMonths(1).withDayOfMonth(1).toString();
            String targetMonth = futureMonth.format(DateTimeFormatter.ofPattern("yyyy-MM"));

            // 이미 존재하는 파티션인지 확인
            boolean exists = partitions.stream()
                    .anyMatch(p -> partName.equals(p.get("partitionName")));

            if (exists) {
                continue;
            }

            String sql = "ALTER TABLE COTDL.TBL_ACCESS_LOG REORGANIZE PARTITION p_future INTO ("
                    + "PARTITION " + partName + " VALUES LESS THAN ('" + nextMonth + "'), "
                    + "PARTITION p_future VALUES LESS THAN (MAXVALUE))";

            try {
                mapper.executePartitionDDL(sql);
                mapper.insertArchiveHistory("CREATE_PARTITION", partName, targetMonth, 0, "SUCCESS", null);
                LogUtil.log("INFO", "AccessLogArchive: Created partition " + partName);
            } catch (Exception e) {
                mapper.insertArchiveHistory("CREATE_PARTITION", partName, targetMonth, 0, "FAILED", e.getMessage());
                logger.error("AccessLogArchive: Failed to create partition {}", partName, e);
            }
        }
    }

    /**
     * 보관기간 초과 파티션 삭제
     */
    private void dropExpiredPartitions() {
        int retentionYears = 5;
        AccessLogConfigVO retentionCfg = mapper.selectConfigByKey("RETENTION_FINANCIAL_YEARS");
        if (retentionCfg != null && retentionCfg.getConfigValue() != null) {
            try {
                retentionYears = Integer.parseInt(retentionCfg.getConfigValue().trim());
            } catch (NumberFormatException ignored) {}
        }

        LocalDate cutoffDate = LocalDate.now().minusYears(retentionYears);
        String cutoffMonth = cutoffDate.format(MONTH_FMT);

        List<Map<String, Object>> partitions = mapper.selectPartitionInfo();

        for (Map<String, Object> partition : partitions) {
            String partName = (String) partition.get("partitionName");

            // p_future 및 비표준 이름 스킵
            if (partName == null || "p_future".equals(partName) || !partName.startsWith("p")) {
                continue;
            }

            // 파티션명에서 월 추출 (p202601 → 202601)
            String partMonth = partName.substring(1);
            if (partMonth.length() != 6) continue;

            if (partMonth.compareTo(cutoffMonth) < 0) {
                // 보관기간 초과
                Long recordCount = mapper.selectPartitionRecordCount(partName);
                long count = recordCount != null ? recordCount : 0;

                String targetMonth = partMonth.substring(0, 4) + "-" + partMonth.substring(4);
                String sql = "ALTER TABLE COTDL.TBL_ACCESS_LOG DROP PARTITION " + partName;

                try {
                    mapper.executePartitionDDL(sql);
                    mapper.insertArchiveHistory("DROP_PARTITION", partName, targetMonth, count, "SUCCESS", null);
                    LogUtil.log("INFO", "AccessLogArchive: Dropped expired partition " + partName + " (" + count + " records)");
                } catch (Exception e) {
                    mapper.insertArchiveHistory("DROP_PARTITION", partName, targetMonth, count, "FAILED", e.getMessage());
                    logger.error("AccessLogArchive: Failed to drop partition {}", partName, e);
                }
            }
        }
    }
}
