package datablocks.dlm.schedule;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.exception.OrderDupException;
import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.jdbc.DmlExecutor;
import datablocks.dlm.jdbc.JdbcUtil;
import datablocks.dlm.mapper.*;
import datablocks.dlm.service.ArchiveNamingService;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.SqlUtil;
import datablocks.dlm.util.StrUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;


import java.sql.*;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.LocalDate;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.ArrayList;
import datablocks.dlm.jdbc.DataSourceCache;

@Slf4j
@RequiredArgsConstructor
@Component
public class JobScheduler {

    private final PiiJobMapper jobMapper;
    private final PiiStepTableMapper stepTableMapper;
    private final PiiOrderMapper orderMapper;
    private final PiiOrderStepMapper orderStepMapper;
    private final PiiOrderStepTableMapper orderStepTableMapper;
    private final PiiDatabaseMapper databaseMapper;
    private final PiiOrderThreadMapper orderThreadMapper;
    private final PiiRestoreMapper restoreMapper;
    private final PiiRecoveryMapper recoveryMapper;
    private final PiiTableMapper tableMapper;
    private final PiiConfigMapper configMapper;
    private final PiiOrderStepTableUpdateMapper orderStepTableUpdateMapper;
    private final PiiStepMapper stepMapper;
    private final PiiOrderJobWaitMapper orderJobWaitMapper;
    private final PiiOrderStepTableWaitMapper orderStepTableWaitMapper;
    private final PiiJobWaitMapper jobWaitMapper;
    private final PiiStepTableWaitMapper stepTableWaitMapper;
    private final PiiStepTableUpdateMapper stepTableUpdateMapper;
    private final PiiPolicyMapper policyMapper;
    private final PiiBizDayMapper bizDayMapper;
    private final DmlExecutor dmlExecutor;
    private final PiiContractMapper contractMapper;
    private final PiiExtractMapper extractMapper;
    private final MetaTableMapper metaTableMapper;
    private final ArchiveNamingService archiveNamingService;
    private final MetaPiiStatusMapper metaPiiStatusMapper;
    private final LkPiiScrTypeMapper lkPiiScrTypeMapper;
    private final ProgOrderHistMapper progOrderHistMapper;
    private final InnerStepMapper innerStepMapper;
    private final PlatformTransactionManager transactionManager;

    // DateTimeFormatter는 thread-safe (SimpleDateFormat은 thread-safe하지 않아 Singleton에서 위험)
    private static final DateTimeFormatter FMT_DATE = DateTimeFormatter.ofPattern("yyyy/MM/dd");
    private static final DateTimeFormatter FMT_DATETIME = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");

    private final AtomicBoolean running = new AtomicBoolean(false); // ✅ runEveryMinute 중복 실행 방지 플래그
    private final AtomicBoolean runOrderRunning = new AtomicBoolean(false); // ✅ runOrder 중복 실행 방지 플래그
    /*
     * this function orders jobs based on the job's calendar.
     */

    @Scheduled(cron = "01 00 15 * * *")
    public void order() throws Exception {
        String orderflag = EnvConfig.getConfig("DLM_ORDER_FLAG");
        if (!"Y".equalsIgnoreCase(orderflag)) {
            return;
        }

        Calendar basetime = Calendar.getInstance();
        Calendar runtime = Calendar.getInstance();

        String envFlag = EnvConfig.getConfig("DLM_ENV");
        if ("PROD".equalsIgnoreCase(envFlag)) {
            runtime.add(Calendar.DATE, 1);
        } else {
            // for testing in development env.  must be updated before applying to PROD.
            basetime.add(Calendar.DATE, -1);
        }

        String basedate = LocalDateTime.ofInstant(basetime.toInstant(), ZoneId.systemDefault()).format(FMT_DATE);
        String rundate = LocalDateTime.ofInstant(runtime.toInstant(), ZoneId.systemDefault()).format(FMT_DATE);

        Date today = new Date();
        String curtime = LocalDateTime.ofInstant(today.toInstant(), ZoneId.systemDefault()).format(FMT_DATETIME);

        int dayNum = runtime.get(Calendar.DAY_OF_WEEK);//요일
        int weekNum = runtime.get(Calendar.WEEK_OF_MONTH);
        //int monthNum = time.read(Calendar.MONTH);

        String jobcalendar = "";

        boolean orderfag = false;

        List<PiiJobVO> joblist = jobMapper.getExeJobList(basedate);

        if (joblist.size() > 0)
            LogUtil.log("INFO", " order() " + curtime + "  =========== order() =====start!!!    size:" + joblist.size());
        else {
            LogUtil.log("INFO", " order()" +curtime+"  =========== order() =====end!!!    size:"+ joblist.size());
            return;
        }

        for (PiiJobVO piijob : joblist) {
            LogUtil.log("INFO", "dayNum "+dayNum + piijob.toString());
            if("ARC_DATA_DELETE".equalsIgnoreCase(piijob.getJobid())){continue;}// 별도 스케줄로 수행됨
            jobcalendar = piijob.getCalendar();
            switch (dayNum) {
                case 1:
                    //day = "일";
                    if (jobcalendar.equals("WEEK_SUN") || jobcalendar.equals("WEEKEND") || jobcalendar.equals("ALLDAYS")) {
                        orderfag = true;
                    } else if (weekNum == 2 && "2ND_SUN".equals(jobcalendar)) {
                        orderfag = true;
                    }
                    break;
                case 2:
                    //day = "월";
                    if (jobcalendar.equals("WEEK_MON") || jobcalendar.equals("WEEKDAYS") || jobcalendar.equals("ALLDAYS")) {
                        orderfag = true;
                    }
                    break;
                case 3:
                    //day = "화";
                    if (jobcalendar.equals("WEEK_TUE") || jobcalendar.equals("WEEKDAYS") || jobcalendar.equals("ALLDAYS")) {
                        orderfag = true;
                    }
                    break;
                case 4:
                    //day = "수";
                    if (jobcalendar.equals("WEEK_WED") || jobcalendar.equals("WEEKDAYS") || jobcalendar.equals("ALLDAYS")) {
                        orderfag = true;
                    }
                    break;
                case 5:
                    //day = "목";
                    if (jobcalendar.equals("WEEK_THU") || jobcalendar.equals("WEEKDAYS") || jobcalendar.equals("ALLDAYS")) {
                        orderfag = true;
                    }
                    break;
                case 6:
                    //day = "금";
                    if (jobcalendar.equals("WEEK_FRI") || jobcalendar.equals("WEEKDAYS") || jobcalendar.equals("ALLDAYS")) {
                        orderfag = true;

                    }
                    break;
                case 7:
                    //day = "토";
                    if (jobcalendar.equals("WEEK_SAT") || jobcalendar.equals("WEEKEND") || jobcalendar.equals("ALLDAYS")) {
                        orderfag = true;
                    } else if (weekNum == 2 && "2ND_SAT".equals(jobcalendar)) {
                        orderfag = true;
                    }
                    break;
            }
            if (orderfag) {
                try {
                    orderOneJob(piijob.getJobid(), piijob.getVersion(), basedate, rundate);
                    LogUtil.log("INFO", "orderJob Success============>" + piijob.getJobid());
                } catch (Exception ex) {
                    logger.warn("warn "+"orderJob Exception============>" + piijob.getJobid() + "  " + ex.toString());
                }
                //-----------------------------------------------------------------------------
                orderfag = false;
            }
        }//for(PiiJobVO piijob : joblist)

    }

    @Scheduled(cron = "01 01 19 * * *")
    public void sysArcTabWithSource() throws Exception {
        boolean autoarcflag = "Y".equalsIgnoreCase(EnvConfig.getConfig("DLM_ARC_TAB_AUTO_MGMT_FLAG"));
        if(autoarcflag) {
            Criteria cri = new Criteria(1, 10000);
            List<PiiStepTableVO> piisteptablelist = stepTableMapper.getListWithPaging(cri);
            LogUtil.log("DEBUG", "$$$$$$$$$$$$$$  sysArcTabWithSource  piisteptablelist.size() = "+piisteptablelist.size()+"   cri: "+cri.toString());
            for (PiiStepTableVO piisteptable : piisteptablelist) {
                //New arc table creation
                LogUtil.log("DEBUG", "$$$$$$$$$$$$$$  for (PiiStepTableVO piisteptable : piisteptablelist) { = "+piisteptable);
                if(piisteptable.getExetype().equalsIgnoreCase("ARCHIVE")) {
//                    logger.warn("warn "+"$$$$$$$$$$$$$$  ARCHIVE = "+piisteptable);
                    cri.setSearch4(piisteptable.getDb());
                    cri.setSearch5(piisteptable.getOwner());
                    cri.setSearch6(piisteptable.getTable_name());

                    registerArcTab(piisteptable, cri);
                    registerArcTabCols(piisteptable, cri);
                }
            }
        }

    }

    @Scheduled(cron = "0 0 * * * *")
    public void refreshDashboard() throws Exception {

        try {
            metaPiiStatusMapper.delete();
            metaPiiStatusMapper.insert();
        } catch (Exception ex) {
            logger.warn("warn "+"## 0 refreshDashboard  metaPiiStatusMapper = "+ex.toString());
        }

        try {
            contractMapper.delete_piicontractstat();
            contractMapper.insertStatList12Month();
        } catch (Exception ex) {
            logger.warn("warn "+"## 1 refreshDashboard = "+ex.toString());
        }
        try {
            extractMapper.delete_piicuststat();
            extractMapper.insertCustStatListAllDays();
            extractMapper.insertCustStatListNotExistDay();//20240521 실행일 기준 없는 날짜 추가함
            extractMapper.insertCustStatListAllMonths();

        } catch (Exception ex) {
            logger.warn("warn "+"## 2 refreshDashboard - extract custstat = "+ex.toString());
        }
        try {
            extractMapper.delete_piicuststatyear();
            extractMapper.insertextractrunresultyearstat();
            extractMapper.insertextractrunresultsumstat();

        } catch (Exception ex) {
            logger.warn("warn "+"## 3 refreshDashboard = "+ex.toString());
        }
    }

    private final AtomicBoolean purgeRunning = new AtomicBoolean(false);

    /**
     * 주간 퍼지: 영구파기/복원 완료 후 보존 기간 경과 레코드를 tbl_piiextract에서 삭제.
     * 삭제 전 통계를 TBL_PIIEXTRACT_PURGE_STAT에 적재하여 보고서 카운트 보존.
     */
    @Scheduled(cron = "0 0 3 ? * SUN")
    public void purgeCompletedExtractRecords() {
        if (!purgeRunning.compareAndSet(false, true)) {
            logger.warn("warn "+"## purgeCompletedExtractRecords SKIPPED - already running");
            return;
        }
        try {
            logger.info("info "+"## purgeCompletedExtractRecords START");
            Calendar cal = Calendar.getInstance();

            // 3단계(PII_POLICY3) 영구파기: 1년 경과
            cal.setTime(new Date());
            cal.add(Calendar.MONTH, -12);
            Date cutoff12m = cal.getTime();
            purgeExtractByPolicy("PII_POLICY3", "DELARC", cutoff12m);

            // 1단계(PII_POLICY1) 영구파기: 3개월 경과
            cal.setTime(new Date());
            cal.add(Calendar.MONTH, -3);
            Date cutoff3m = cal.getTime();
            purgeExtractByPolicy("PII_POLICY1", "DELARC", cutoff3m);

            // 2단계(PII_POLICY2) 영구파기: 3개월 경과
            purgeExtractByPolicy("PII_POLICY2", "DELARC", cutoff3m);

            // 복원 완료: 1년 경과 (각 policy별)
            purgeExtractByPolicy("PII_POLICY1", "RESTORE", cutoff12m);
            purgeExtractByPolicy("PII_POLICY2", "RESTORE", cutoff12m);
            purgeExtractByPolicy("PII_POLICY3", "RESTORE", cutoff12m);

            logger.info("info "+"## purgeCompletedExtractRecords END OK");
        } catch (Exception ex) {
            logger.error("error "+"## purgeCompletedExtractRecords FAIL = " + ex.toString(), ex);
        }

        // 비-파기 Job 오더 이력 퍼지: 6개월 경과 (PII/ARC_DATA_DELETE/RESTORE_CUSTID 제외)
        try {
            logger.info("info "+"## purgeCompletedNonPiiOrders START");
            Calendar cal = Calendar.getInstance();
            cal.setTime(new Date());
            cal.add(Calendar.MONTH, -6);
            Date cutoff6m = cal.getTime();
            orderMapper.deleteCompletedNonPiiOrders(cutoff6m);
            logger.info("info "+"## purgeCompletedNonPiiOrders END OK");
        } catch (Exception ex) {
            logger.error("error "+"## purgeCompletedNonPiiOrders FAIL = " + ex.toString(), ex);
        } finally {
            purgeRunning.set(false);
        }
    }

    private void purgeExtractByPolicy(String policyPrefix, String excludeReason, Date cutoffDate) {
        logger.info("info "+"## purge: policy=" + policyPrefix + ", reason=" + excludeReason + ", cutoff=" + cutoffDate);
        TransactionStatus txStatus = transactionManager.getTransaction(new DefaultTransactionDefinition());
        try {
            // Step A: 통계 적재 (삭제 전)
            extractMapper.insertPurgeStats(policyPrefix, excludeReason, cutoffDate);
            // Step B: 고객별 파기 증적 적재 (삭제 전)
            extractMapper.insertPurgeLog(policyPrefix, excludeReason, cutoffDate);
            // Step C: 삭제
            int deleted = extractMapper.deletePurgedRecords(policyPrefix, excludeReason, cutoffDate);
            transactionManager.commit(txStatus);
            logger.info("info "+"## purge deleted: " + deleted + " rows (policy=" + policyPrefix + ", reason=" + excludeReason + ")");
        } catch (Exception ex) {
            transactionManager.rollback(txStatus);
            logger.error("error "+"## purge ROLLBACK: policy=" + policyPrefix + ", reason=" + excludeReason + " - " + ex.toString(), ex);
            // throw하지 않음 — 다른 policy 퍼지는 계속 실행
        }
    }

    @Async
    @Scheduled(fixedRate = 6000, initialDelay = 2000)
    public void runOrder() throws Exception {
        if (!runOrderRunning.compareAndSet(false, true)) {
            logger.warn("Previous runOrder() still running. Skipping this turn.");
            return;
        }
        try {
            doRunOrder();
        } finally {
            runOrderRunning.set(false);
        }
    }

    private void doRunOrder() throws Exception {
        LocalDate now = LocalDate.now();
        String steptableorderby = "DESC";
        String runflag = EnvConfig.getConfig("DLM_RUN_FLAG");
        if (!"Y".equalsIgnoreCase(runflag)) {
            return;
        }
        String orderbyConfig = EnvConfig.getConfig("DLM_TABLELIST_ORDERBY");
        if (!orderbyConfig.isEmpty()) {
            steptableorderby = orderbyConfig;
        }

        //logger.debug("info$ "+"0===== runOrder() runnable order cnt=" + orderMapper.getRunableListCnt());

        int autoGenJobMaxCnt = StrUtil.parseInt(EnvConfig.getConfig("TESTDATA_AUTO_GEN_JOB_MAX_CNT"));
        if (autoGenJobMaxCnt == 0) {
            autoGenJobMaxCnt = 3;
        }
        int initialAutoGenTestdataRunJobCnt = orderMapper.getAutoGenTestdataRunningCnt();  // 최초 1회만 조회
        int allowedAutoGenTestdataInThisBatch = 0;
        boolean firstAutoGenTestdata = true;

        int restoreJobMaxCnt = StrUtil.parseInt(EnvConfig.getConfig("RESTORE_JOB_MAX_CNT"));
        if (restoreJobMaxCnt == 0) {
            restoreJobMaxCnt = 2;
        }
        int initialRestoreRunJobCnt = orderMapper.getRestoreRunningCnt();  // 최초 1회만 조회
        int allowedRestoreInThisBatch = 0;
        boolean firstRestore = true;

        int testdataPurgeJobMaxCnt = 2;
        int initialTestdataPurgeRunJobCnt = orderMapper.getAutoGenTestdataRunningCnt();  // 최초 1회만 조회
        int allowedTestdataPurgeInThisBatch = 0;
        boolean firstTestdataPurge = true;

        List<PiiOrderVO> orderlist = orderMapper.getRunableList();
        //logger.debug("info$ "+now + " DLM $$$$$ runOrder()   orderlist.size() = "+orderlist.size() );


        for (PiiOrderVO piiorder : orderlist) {
            int orderid = piiorder.getOrderid();
            if (orderThreadMapper.getListCnt(orderid, piiorder.getJobid(), piiorder.getVersion()) > 0) {
                continue;
            }
            if (piiorder.getStatus().equals("Ended OK")) continue;

            /** TESTDATA_PURGE JOB이 한번에 두개 이내에서만 실행 되게 처리  20250823 */
            if (piiorder.getJobid().startsWith("TESTDATA_PURGE:") && !piiorder.getStatus().equals("Running")) {
                /*동시 job max 설정*/
                LogUtil.log("DEBUG", "  initialTestdataPurgeRunJobCnt:"+initialTestdataPurgeRunJobCnt + "     allowedTestdataPurgeInThisBatch:" +allowedTestdataPurgeInThisBatch+ "     testdataPurgeJobMaxCnt:" +testdataPurgeJobMaxCnt);
                if(initialTestdataPurgeRunJobCnt + allowedTestdataPurgeInThisBatch >= testdataPurgeJobMaxCnt){
                    continue;
                }
                allowedTestdataPurgeInThisBatch++;  // 이 배치에서 허용된 작업 수 누적

                if(firstTestdataPurge){
                    firstTestdataPurge = false;
                    LogUtil.log("DEBUG", "TESTDATA_PURGE===="+piiorder.getOrderid() +"    firstAutoGenTestdata="+firstTestdataPurge);
                }
                else {
                    LogUtil.log("DEBUG","TESTDATA_PURGE===="+piiorder.getOrderid() +"continue    firstAutoGenTestdata="+firstTestdataPurge);
                    continue;
                }
            }

            /** GEN_MASTER_KEYMAP 는 키 중복 방지 가능성을 줄이기 위해 전체 order 중에서 TESTDATA_AUTO_GEN job은 5초에 한번씩만 수행 되게 적용함 20240509 */
            if (piiorder.getJobid().startsWith("TESTDATA_AUTO_GEN") && !piiorder.getStatus().equals("Running")) {
                /*동시 job max 설정*/
                LogUtil.log("DEBUG", "  initialAutoGenTestdataRunJobCnt:"+initialAutoGenTestdataRunJobCnt + "     allowedAutoGenTestdataInThisBatch:" +allowedAutoGenTestdataInThisBatch+ "     autoGenJobMaxCnt:" +autoGenJobMaxCnt);
                if(initialAutoGenTestdataRunJobCnt + allowedAutoGenTestdataInThisBatch >= autoGenJobMaxCnt){
                    continue;
                }
                allowedAutoGenTestdataInThisBatch++;  // 이 배치에서 허용된 작업 수 누적

                if(firstAutoGenTestdata){
                    firstAutoGenTestdata = false;
                    LogUtil.log("DEBUG", "TESTDATA_AUTO_GEN===="+piiorder.getOrderid() +"    firstAutoGenTestdata="+firstAutoGenTestdata);
                }
                else {
                    LogUtil.log("DEBUG","TESTDATA_AUTO_GEN===="+piiorder.getOrderid() +"continue    firstAutoGenTestdata="+firstAutoGenTestdata);
                    continue;
                }
            }
            /** 전체 order Restore  job은 5초에 한번씩만 수행 되게 적용함 20240509 */
            if (piiorder.getJobid().startsWith("RESTORE_") && !piiorder.getStatus().equals("Running")) {
                /*동시 job max 설정*/
                LogUtil.log("DEBUG","  initialRestoreRunJobCnt:"+initialRestoreRunJobCnt + "     allowedRestoreInThisBatch:" +allowedRestoreInThisBatch+ "     restoreJobMaxCnt:" +restoreJobMaxCnt);
                if(initialRestoreRunJobCnt + allowedRestoreInThisBatch >= restoreJobMaxCnt){
                    continue;
                }
                allowedRestoreInThisBatch++;  // 이 배치에서 허용된 작업 수 누적

                if(firstRestore){
                    firstRestore = false;
                    LogUtil.log("DEBUG","RESTORE===="+piiorder.getOrderid() +"    firstRestore="+firstRestore);
                }
                else {
                    LogUtil.log("DEBUG","RESTORE==="+piiorder.getOrderid() +"continue    firstRestore="+firstRestore);
                    continue;
                }
            }

            boolean stopflag = false;
            String steptype = "";
            String stepid = "";

            List<PiiOrderStepTableVO> ordersteptablelist;
            //logger.debug("info$ "+"3===== runOrder() ====start!!! ordersteptablelist=");
            orderMapper.updatebefore(orderid);
            //logger.debug("info$ "+"4===== runOrder() ====start!!! updatebefore(orderid)=");
            List<PiiOrderStepVO> ordersteplist = orderStepMapper.getRunnableOrderStepList(orderid);
            //logger.debug("info$ "+"5===== runOrder() ====start!!! ordersteplist.size()= "+ordersteplist.size());
            /* 20230609 예외 상황으로 모든 스텝과 테이블이 Ended OK 이면서 order 상태가 Ended OK가 아닌경우는 바로 업데이트 하고 다음 order로 계속진행 */
            if(ordersteplist.size() == 0){
                orderMapper.updateend(orderid);
                continue;
            }

            /** 무조건   하나의 ORDER만 처리한다....다시 */
            for (PiiOrderStepVO piiorderstep : ordersteplist) {
                //logger.debug("info$ "+orderid + "  piiorderstep  " + piiorderstep.toString() + "   ");
                //logger.debug("info$ "+orderid + "  ordersteptableMapper  " + orderStepTableMapper.getStepTableList(orderid, piiorderstep.getStepid()) + "   ");
                if (piiorderstep.getStatus().equals("Running")) break;

                orderStepMapper.updateend(piiorderstep.getOrderid(), piiorderstep.getJobid(), piiorderstep.getVersion(), piiorderstep.getStepid());
                if (orderThreadMapper.getListCnt(orderid, piiorder.getJobid(), piiorder.getVersion()) > 0) continue;
                if (piiorderstep.getStatus().equals("Ended OK")) continue;
                if (piiorderstep.getStatus().equals("Hold")) {
                    orderMapper.updatestatus(orderid, "Hold");
                    //LogUtil.log("INFO", orderid+ " " +piiorderstep.getStepid() + "   Hold");
                    break;
                }
                //logger.warn("warn "+orderid + " = ordersteplist jobscheduler begin : " +piiorderstep.getStepid());
                if (stopflag) break;


                int threadcnt;
                steptype = piiorderstep.getSteptype();
                stepid = piiorderstep.getStepid();

                LogUtil.log("INFO","JobScheduler ==> " + orderid+ ":" + piiorderstep.getStatus() + ":" + piiorderstep.getStepid());

                // keymap step need to excute order by seq1,seq2,seq3
                if (steptype.equals("GEN_KEYMAP")) {
                    ordersteptablelist = orderStepTableMapper.getStepTableList_keymap(piiorderstep.getOrderid(), piiorderstep.getStepid());
                    threadcnt = Integer.parseInt(piiorderstep.getThreadcnt());
                } else if (steptype.equals("EXE_RESTORE") || steptype.equals("EXE_RECOVERY")) {
                    ordersteptablelist = orderStepTableMapper.getStepTableListasc(piiorderstep.getOrderid(), piiorderstep.getStepid());
                    threadcnt = Integer.parseInt(piiorderstep.getThreadcnt());
                } else if (steptype.equals("EXE_FINISH")) {
                    ordersteptablelist = orderStepTableMapper.getStepTableListasc(piiorderstep.getOrderid(), piiorderstep.getStepid());
                    threadcnt = Integer.parseInt(piiorderstep.getThreadcnt());
                } else if (steptype.equals("EXE_EXTRACT")) {
                    ordersteptablelist = orderStepTableMapper.getStepTableListasc(piiorderstep.getOrderid(), piiorderstep.getStepid());
                    threadcnt = Integer.parseInt(piiorderstep.getThreadcnt());
                } else if (steptype.equals("EXE_SCRAMBLE") || steptype.equals("EXE_ILM") || steptype.equals("EXE_MIGRATE") || steptype.equals("EXE_SYNC")) {LogUtil.log("INFO", now + "EXE_SCRAMBLE: piiorderstep=" +  piiorderstep.toString());
                    ordersteptablelist = orderStepTableMapper.getStepTableListasc(piiorderstep.getOrderid(), piiorderstep.getStepid());
                    threadcnt = Integer.parseInt(piiorderstep.getThreadcnt());
                } else if (steptype.equals("EXE_ARCHIVE") || steptype.equals("EXE_DELETE") || steptype.equals("EXE_UPDATE")) {
                    if (steptableorderby.equalsIgnoreCase("DESC"))
                        ordersteptablelist = orderStepTableMapper.getStepTableList(piiorderstep.getOrderid(), piiorderstep.getStepid());
                    else
                        ordersteptablelist = orderStepTableMapper.getStepTableListasc(piiorderstep.getOrderid(), piiorderstep.getStepid());

                    threadcnt = Integer.parseInt(piiorderstep.getThreadcnt());
                } else {
                    ordersteptablelist = orderStepTableMapper.getStepTableListasc(piiorderstep.getOrderid(), piiorderstep.getStepid());
                    threadcnt = Integer.parseInt(piiorderstep.getThreadcnt());
                }


                orderStepMapper.updatebefore(piiorderstep.getOrderid(), piiorderstep.getJobid(), piiorderstep.getVersion(), piiorderstep.getStepid());

                /**===================================================================================
                 * BatchStepWorker 방식 (모든 step type 통합)
                 * - DataSourceCache로 DB별 HikariDataSource 풀링
                 * - Worker가 커넥션 보유, DB 변경 시에만 재획득
                 * - stopFlag로 에러 시 조기 중단
                 *===================================================================================*/
                    LogUtil.log("INFO", "BatchStepWorker mode: orderid=" + orderid
                            + " steptype=" + steptype + " tables=" + ordersteptablelist.size()
                            + " threads=" + threadcnt);

                    LogUtil.log("INFO", "Initializing AES/DataSourceCache: orderid=" + orderid + " stepid=" + stepid);
                    AES256Util aes = new AES256Util();
                    DataSourceCache dsCache = new DataSourceCache(databaseMapper, aes, threadcnt);
                    LogUtil.log("INFO", "AES/DataSourceCache initialized OK: orderid=" + orderid + " stepid=" + stepid);

                    // 복원/아카이브 step: 커넥션 풀 워밍업 (TARGET + DLMARC)
                    if ("EXE_RESTORE".equals(steptype) || "EXE_RECOVERY".equals(steptype)) {
                        try {
                            PiiDatabaseVO coreDb = databaseMapper.readBySystem("CORE");
                            if (coreDb != null && coreDb.getDb() != null) {
                                LogUtil.log("INFO", "Pool warm-up starting: steptype=" + steptype
                                        + " dbKeys=[DLMARC, " + coreDb.getDb() + "]"
                                        + " poolSize=" + threadcnt);
                                dsCache.warmUp("DLMARC", coreDb.getDb());
                            } else {
                                LogUtil.log("WARN", "Pool warm-up skipped: CORE production DB not found");
                            }
                        } catch (SQLException e) {
                            LogUtil.log("WARN", "Pool warm-up failed (will retry lazily): " + e.getMessage());
                        }
                    }

                    try {
                        // EXE_RECOVERY/RECOVERY_U 사전 필터링
                        List<PiiOrderStepTableVO> filteredList = preFilterRecoveryTables(
                                stepid, piiorderstep, ordersteptablelist);

                        ConcurrentLinkedQueue<PiiOrderStepTableVO> tableQueue =
                                new ConcurrentLinkedQueue<>(filteredList);
                        AtomicBoolean stopFlag = new AtomicBoolean(false);
                        AtomicInteger requeueCounter = new AtomicInteger(0);
                        int maxRequeueAttempts = 3 * filteredList.size();

                        LogUtil.log("INFO", "ThreadPool creating: orderid=" + orderid
                                + " stepid=" + stepid + " threadcnt=" + threadcnt
                                + " tableQueue=" + tableQueue.size());
                        ExecutorService executorService = Executors.newFixedThreadPool(threadcnt);
                        for (int i = 0; i < threadcnt; i++) {
                            BatchStepWorker worker = new BatchStepWorker(
                                    tableQueue, dsCache, piiorderstep, steptableorderby,
                                    stopFlag, i, requeueCounter, maxRequeueAttempts,
                                    dmlExecutor, orderStepTableMapper, orderStepMapper,
                                    databaseMapper, tableMapper, orderMapper,
                                    orderThreadMapper, orderStepTableUpdateMapper,
                                    configMapper, metaTableMapper, lkPiiScrTypeMapper);
                            executorService.submit(worker);
                        }

                        executorService.shutdown();
                        // 타임아웃을 EnvConfig에서 가져오되, 미설정 시 기본 5시간
                        int timeoutHours = 5;
                        String configTimeout = EnvConfig.getConfig("BATCH_EXECUTOR_TIMEOUT_HOURS");
                        if (configTimeout != null && !configTimeout.isEmpty()) {
                            try {
                                timeoutHours = Integer.parseInt(configTimeout);
                            } catch (NumberFormatException ignored) {
                                // 파싱 실패 시 기본값 사용
                            }
                        }
                        LogUtil.log("INFO", "BatchStepWorker awaiting termination: timeout=" + timeoutHours + "h");
                        if (!executorService.awaitTermination(timeoutHours, TimeUnit.HOURS)) {
                            // graceful 종료 시도: 먼저 인터럽트 후 추가 대기
                            LogUtil.log("WARN", "BatchStepWorker timeout after " + timeoutHours
                                    + "h. Attempting graceful interrupt before force shutdown.");
                            executorService.shutdownNow();
                            // 인터럽트 후 추가 2분 대기 (진행 중 트랜잭션 커밋 기회 제공)
                            if (!executorService.awaitTermination(2, TimeUnit.MINUTES)) {
                                LogUtil.log("ERROR", "BatchStepWorker ExecutorService exceeded timeout and was forcefully shut down.");
                            }
                        }
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                        LogUtil.log("ERROR", "BatchStepWorker ExecutorService waiting interrupted: " + e.getMessage());
                    } catch (Exception e) {
                        LogUtil.log("ERROR", "BatchStepWorker failed: " + e.getMessage());
                    } finally {
                        dsCache.close();
                        LogUtil.log("INFO", "BatchStepWorker completed, DataSources closed: orderid=" + orderid
                                + " steptype=" + steptype);
                    }

                // 이 지점에 도달한다는 것은 STEP 내 모든 테이블 작업이 끝났음을 의미합니다.
                // 이 후에 break; 를 만나 스케줄러는 현재 Job의 처리를 마칩니다.
                break;

            }//end of for(PiiOrderStepVO piiorderstep : ordersteplist) {

        }
    }

    /**
     * EXE_RECOVERY / EXE_RECOVERY_U 사전 필터링.
     * 원본 EXE_DELETE/EXE_UPDATE 단계가 "Ended OK"가 아닌 테이블은
     * 즉시 "Ended OK"로 처리하고 큐에서 제외한다.
     */
    private List<PiiOrderStepTableVO> preFilterRecoveryTables(
            String stepid, PiiOrderStepVO piiorderstep,
            List<PiiOrderStepTableVO> ordersteptablelist) {
        List<PiiOrderStepTableVO> filteredList = new ArrayList<>();
        for (PiiOrderStepTableVO table : ordersteptablelist) {
            // EXE_RECOVERY_U를 먼저 확인 (EXE_RECOVERY의 startsWith에 걸리지 않도록)
            if (stepid != null && stepid.startsWith("EXE_RECOVERY_U")) {
                if (!"RECOVERY_U".equalsIgnoreCase(table.getPagitypedetail())) {
                    PiiRecoveryVO recoveryVO = recoveryMapper.readByNewOrderid(table.getOrderid());
                    if (recoveryVO != null) {
                        PiiOrderStepTableVO origTable = orderStepTableMapper.readWithSeq(
                                recoveryVO.getOld_orderid(), "EXE_UPDATE",
                                table.getSeq1(), table.getSeq2(), table.getSeq3());
                        if (origTable == null || !"Ended OK".equalsIgnoreCase(origTable.getStatus())) {
                            orderStepTableMapper.updateend(table.getOrderid(), table.getJobid(), table.getVersion(),
                                    table.getStepid(), table.getSeq1(), table.getSeq2(), table.getSeq3(),
                                    "Ended OK", 0, null);
                            orderStepMapper.updateend(piiorderstep.getOrderid(), piiorderstep.getJobid(),
                                    piiorderstep.getVersion(), piiorderstep.getStepid());
                            orderMapper.updateend(table.getOrderid());
                            continue;
                        }
                    }
                }
            } else if (stepid != null && stepid.startsWith("EXE_RECOVERY")) {
                if (!"RECOVERY".equalsIgnoreCase(table.getPagitypedetail())) {
                    PiiRecoveryVO recoveryVO = recoveryMapper.readByNewOrderid(table.getOrderid());
                    if (recoveryVO != null) {
                        PiiOrderStepTableVO origTable = orderStepTableMapper.readWithSeq(
                                recoveryVO.getOld_orderid(), "EXE_DELETE",
                                table.getSeq1(), table.getSeq2(), table.getSeq3());
                        if (origTable == null || !"Ended OK".equalsIgnoreCase(origTable.getStatus())) {
                            orderStepTableMapper.updateend(table.getOrderid(), table.getJobid(), table.getVersion(),
                                    table.getStepid(), table.getSeq1(), table.getSeq2(), table.getSeq3(),
                                    "Ended OK", 0, null);
                            orderStepMapper.updateend(piiorderstep.getOrderid(), piiorderstep.getJobid(),
                                    piiorderstep.getVersion(), piiorderstep.getStepid());
                            orderMapper.updateend(table.getOrderid());
                            continue;
                        }
                    }
                }
            }
            filteredList.add(table);
        }
        return filteredList;
    }

    /* 파기 고객수가 많으면 수행 시간이 길어져서 lock wait 문제 발생하므로 조심해야함*/
    @Scheduled(cron = "0 45 5 * * *")
    public void runTaskEveyHour() throws Exception {
        restoreMapper.updateExtractBrowseStatus();  // 열람기한 경과 고객 상태를 분리보관으로 수정
    }

    @Scheduled(cron = "01 55 14 * * *")
    @Transactional
    public void orderArcDelJob() throws Exception {
        String jobtime = "12:01";
        String threadcnt = "4";
        if (!"Y".equalsIgnoreCase(EnvConfig.getConfig("DLM_ORDER_FLAG"))) {
            return;
        }
        if (!"Y".equalsIgnoreCase(EnvConfig.getConfig("DLM_ORDER_ARCDELJOB_FLAG"))) {
            return;
        }
        String jobtimeConfig = EnvConfig.getConfig("DLM_ARCDELJOB_TIME");
        if (!jobtimeConfig.isEmpty()) {
            jobtime = jobtimeConfig;
        }
        String threadcntConfig = EnvConfig.getConfig("DLM_ARCDELJOB_THREADCNT");
        if (!threadcntConfig.isEmpty()) {
            threadcnt = threadcntConfig;
        }
        String site = EnvConfig.getConfig("SITE");
        if (site.isEmpty()) {
            site = null;
        }
        Calendar basetime = Calendar.getInstance();
        Calendar runtime = Calendar.getInstance();

        runtime.add(Calendar.DATE, 1);

        String basedate = LocalDateTime.ofInstant(basetime.toInstant(), ZoneId.systemDefault()).format(FMT_DATE);
        String rundate = LocalDateTime.ofInstant(runtime.toInstant(), ZoneId.systemDefault()).format(FMT_DATE);

        PiiOrderVO piiorder = new PiiOrderVO();
        PiiOrderStepVO piiorderstep = new PiiOrderStepVO();
        PiiOrderStepTableVO piiordersteptable = new PiiOrderStepTableVO();
        PiiDatabaseVO arcDBvo = databaseMapper.read("DLMARC");
        PiiDatabaseVO dlmDBvo = databaseMapper.read("DLM");
        PiiDatabaseVO coreDBvo = databaseMapper.readBySystem("CORE");

        String jobid_new = "ARC_DATA_DELETE";
        String jobname_new = "분리보관_데이터_파기";
        int newOrderId = orderMapper.getMaxOrderid() + 1;

        PiiConfigVO configVO = configMapper.read("DLM_CURRENT_ORDERID");
        if (configVO != null && configVO.getValue() != null) {
            try {
                int maxOrderId = Integer.parseInt(configVO.getValue()) + 1;
                newOrderId = Math.max(newOrderId, maxOrderId);
            } catch (NumberFormatException ex) {
                logger.warn("DLM_CURRENT_ORDERID has invalid value: {}. Using default order ID: {}", configVO.getValue(), newOrderId);
            }
        } else {
            logger.warn("DLM_CURRENT_ORDERID is not defined in config tables. Using default order ID: {}", newOrderId);
        }
        configMapper.updateVal("DLM_CURRENT_ORDERID", String.valueOf(newOrderId));

        int seq = 1;
        piiorder.setOrderid(newOrderId);
        piiorder.setBasedate(basedate);
        piiorder.setRuncnt(0);
        piiorder.setJobid(jobid_new);
        piiorder.setVersion("1");
        piiorder.setJobname(jobname_new);
        piiorder.setSystem("ARCHIVE_DB");
        piiorder.setKeymap_id(null);
        piiorder.setJobtype("PII");
        piiorder.setPolicy_id(null);
        piiorder.setRuntype("DLM_BATCH");
        piiorder.setCalendar("ALLDAYS");
        piiorder.setTime(jobtime);
        //piiorder.setStatus("Hold");
        piiorder.setStatus("Wait condition");
        piiorder.setConfirmflag("N");
        piiorder.setHoldflag("N");
        piiorder.setForceokflag("N");
        piiorder.setKillflag("N");
        piiorder.setEststarttime(rundate + " " + jobtime + ":00");
        piiorder.setRunningtime(null);
        piiorder.setRealstarttime(null);
        piiorder.setRealendtime(null);
        piiorder.setJob_owner_id1(null);
        piiorder.setJob_owner_name1(null);
        piiorder.setJob_owner_id2(null);
        piiorder.setJob_owner_name2(null);
        piiorder.setJob_owner_id3(null);
        piiorder.setJob_owner_name3(null);
        piiorder.setOrderdate(null);
        piiorder.setOrderuserid(null);
        LogUtil.log("INFO", "orderMapper.insert(piiorder) => "+ piiorder.toString());
        orderMapper.insert(piiorder);

        String stepid_new = "EXE_ARC_DELETE";
        String stepname_new = "EXE_ARC_DELETE";
        String steptype_new = "EXE_ARC_DELETE";
        String exetype_new = "ARC_DELETE";

        piiorderstep.setOrderid(newOrderId);
        piiorderstep.setStatus("Wait condition");
        piiorderstep.setConfirmflag("N");
        piiorderstep.setHoldflag("N");
        piiorderstep.setForceokflag("N");
        piiorderstep.setKillflag("N");
        piiorderstep.setBasedate(basedate);
        piiorderstep.setThreadcnt(threadcnt);
        piiorderstep.setCommitcnt("3000");
        piiorderstep.setRuncnt("0");
        piiorderstep.setJobid(jobid_new);
        piiorderstep.setVersion("1");
        piiorderstep.setStepid(stepid_new);
        piiorderstep.setStepname(stepname_new);
        piiorderstep.setSteptype(steptype_new);
        piiorderstep.setStepseq("1");
        piiorderstep.setDb(arcDBvo.getDb());
        piiorderstep.setTotaltabcnt("0");
        piiorderstep.setSuccesstabcnt("0");
//        	piiorderstep.setRunningtime(" ");
//        	piiorderstep.setRealstarttime(" ");
//        	piiorderstep.setRealendtime(" ");
        piiorderstep.setOrderuserid(null);
        orderStepMapper.insert(piiorderstep);

        //JOB's all tables in EXE_ARCIVE steptype.
        List<PiiStepTableVO> steptablelist = stepTableMapper.getArcStepTableList();
        for (PiiStepTableVO piisteptable : steptablelist) {
            piiordersteptable.setOrderid(newOrderId);
            piiordersteptable.setStatus("Wait condition");
            piiordersteptable.setForceokflag("N");
            piiordersteptable.setBasedate(basedate);
            piiordersteptable.setJobid(jobid_new);
            piiordersteptable.setVersion("1");
            piiordersteptable.setStepid(stepid_new);
            piiordersteptable.setStepname(stepname_new);
            piiordersteptable.setSteptype(steptype_new);
            piiordersteptable.setStepseq("1");
            piiordersteptable.setDb(arcDBvo.getDb());
            String archiveOwner = archiveNamingService.getArchiveSchemaName(ArchiveNamingService.CONFIG_TYPE_PII, arcDBvo.getDb(), piisteptable.getOwner());
            piiordersteptable.setOwner(archiveOwner);
            piiordersteptable.setTable_name(piisteptable.getTable_name());
            piiordersteptable.setPagitype(null);
            piiordersteptable.setPagitypedetail(null);
            piiordersteptable.setExetype(exetype_new);
            piiordersteptable.setArchiveflag(null);
            piiordersteptable.setPreceding(null);
            piiordersteptable.setSuccedding(null);
            piiordersteptable.setSeq1(1);
            piiordersteptable.setSeq2(100);
            piiordersteptable.setSeq3(seq++);
            piiordersteptable.setPipeline(null);
            piiordersteptable.setPk_col(null);
            piiordersteptable.setWhere_col(null);
            piiordersteptable.setWhere_key_name(null);
            piiordersteptable.setParallelcnt(null);
            piiordersteptable.setCommitcnt("3000");

            //Transformation by DB Type
            String dbtype = databaseMapper.read(piiordersteptable.getDb()).getDbtype();
            String wherestr = " pii_destruct_date <= TO_DATE('" + basedate + " 23:59:59','yyyy/mm/dd HH24:MI:SS')";
            if (piiordersteptable.getExetype().equals("BROADCAST")) {
                //dbtype = databaseMapper.read("DLM").getDbtype();
                dbtype = databaseMapper.read(piiorderstep.getDb()).getDbtype();
            }
            wherestr = SqlUtil.convertDateformat(dbtype, wherestr);
            piiordersteptable.setWherestr(wherestr);
            String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, arcDBvo.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
            piiordersteptable.setSqlstr("delete from " + archiveTablePath + " where " + wherestr);
            // Arc fields are not used
//	        	piiordersteptable.setArccnt(null);
//	        	piiordersteptable.setArctime(null);
//	        	piiordersteptable.setArcstart(null);
//	        	piiordersteptable.setArcend(null);

            piiordersteptable.setExecnt("0");
//	        	piiordersteptable.setExetime(null);
//	        	piiordersteptable.setExestart(null);
//	        	piiordersteptable.setExeend(null);
//	        	piiordersteptable.setSqlmsg(null);
            /* 20250302 added*/
            piiordersteptable.setHintselect(piisteptable.getHintselect());
            piiordersteptable.setHintinsert(piisteptable.getHintinsert());
            String uval1 = piisteptable.getUval1();
            String processedVal1 = ""; // 초기화

            if (uval1 != null) {
                processedVal1 = uval1.replaceAll("(?i)#BASEDATE", basedate);
            } else {
                // null일 경우 처리 로직 (예: 빈 문자열 또는 특정 기본값 할당)
                processedVal1 = "";
            }
            piiordersteptable.setUval1(processedVal1);
            piiordersteptable.setUval2(piisteptable.getUval2());
            piiordersteptable.setUval3(piisteptable.getUval3());
            piiordersteptable.setUval4(piisteptable.getUval4());
            piiordersteptable.setUval5(piisteptable.getUval5());
            orderStepTableMapper.insert(piiordersteptable);

        }


        // step 2. EXE_FINISH for EXE_ARC_DELETE
        piiorderstep.setOrderid(newOrderId);
        piiorderstep.setStatus("Wait condition");
        piiorderstep.setConfirmflag("N");
        piiorderstep.setHoldflag("N");
        piiorderstep.setForceokflag("N");
        piiorderstep.setKillflag("N");
        piiorderstep.setBasedate(basedate);
        piiorderstep.setThreadcnt("1");
        piiorderstep.setCommitcnt("3000");
        piiorderstep.setRuncnt("0");
        piiorderstep.setJobid(jobid_new);
        piiorderstep.setVersion("1");
        piiorderstep.setStepid("EXE_FINISH");
        piiorderstep.setStepname("EXE_FINISH");
        piiorderstep.setSteptype("EXE_FINISH");
        piiorderstep.setStepseq("2");
        piiorderstep.setTotaltabcnt("1");
        piiorderstep.setSuccesstabcnt("0");
//	     	piiorderstep.setRunningtime(" ");
//	     	piiorderstep.setRealstarttime(" ");
//	     	piiorderstep.setRealendtime(" ");
        piiorderstep.setOrderuserid(null);
        orderStepMapper.insert(piiorderstep);

        int seq2 = 100;

        //-----STEPTABLE 1  FOR TBL_PIIEXTRACT CORE
        piiordersteptable.setOrderid(newOrderId);
        piiordersteptable.setStatus("Wait condition");
        piiordersteptable.setForceokflag("N");
        piiordersteptable.setBasedate(basedate);
        piiordersteptable.setJobid(jobid_new);
        piiordersteptable.setVersion("1");
        piiordersteptable.setStepid("EXE_FINISH");
        piiordersteptable.setStepname("EXE_FINISH");
        piiordersteptable.setSteptype("EXE_FINISH");
        piiordersteptable.setStepseq("2");
        piiordersteptable.setDb(coreDBvo.getDb());
        piiordersteptable.setOwner("COTDL");
        piiordersteptable.setTable_name("TBL_PIIEXTRACT");
        piiordersteptable.setPagitype(null);
        piiordersteptable.setPagitypedetail(null);
        piiordersteptable.setExetype("FINISH");
        piiordersteptable.setArchiveflag(null);
        piiordersteptable.setPreceding(null);
        piiordersteptable.setSuccedding(null);
        piiordersteptable.setSeq1(10);
        piiordersteptable.setSeq2(seq2);
        piiordersteptable.setSeq3(10);
        piiordersteptable.setPipeline(null);
        piiordersteptable.setWhere_col(null);
        piiordersteptable.setWhere_key_name(null);
        piiordersteptable.setParallelcnt(null);
        piiordersteptable.setCommitcnt("3000");

        //Transformation by DB Type
        String dbtype = coreDBvo.getDbtype();
        String wherestr = " EXPECTED_ARC_DEL_DATE <= TO_DATE('" + basedate + " 23:59:59','yyyy/mm/dd HH24:MI:SS')";

        piiordersteptable.setWherestr(wherestr);
        piiordersteptable.setSqlstr(SqlUtil.convertDateformat(dbtype,
                "update COTDL.TBL_PIIEXTRACT set EXCLUDE_REASON='DELARC' , ARC_DEL_DATE=TO_DATE('" + basedate + "','yyyy/mm/dd')" + " where " + wherestr + " and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null"
                )
        );
        LogUtil.log("INFO", piiordersteptable.getSqlstr());
        orderStepTableMapper.insert(piiordersteptable);

        //-----STEPTABLE 2  FOR TBL_PIIEXTRACT DLM
        piiordersteptable.setOrderid(newOrderId);
        piiordersteptable.setStatus("Wait condition");
        piiordersteptable.setForceokflag("N");
        piiordersteptable.setBasedate(basedate);
        piiordersteptable.setJobid(jobid_new);
        piiordersteptable.setVersion("1");
        piiordersteptable.setStepid("EXE_FINISH");
        piiordersteptable.setStepname("EXE_FINISH");
        piiordersteptable.setSteptype("EXE_FINISH");
        piiordersteptable.setStepseq("2");
        piiordersteptable.setDb(dlmDBvo.getDb());
        piiordersteptable.setOwner("COTDL");
        piiordersteptable.setTable_name("TBL_PIIEXTRACT");
        piiordersteptable.setPagitype(null);
        piiordersteptable.setPagitypedetail(null);
        piiordersteptable.setExetype("FINISH");
        piiordersteptable.setArchiveflag(null);
        piiordersteptable.setPreceding(null);
        piiordersteptable.setSuccedding(null);
        piiordersteptable.setSeq1(10);
        seq2 = seq2 + 100;
        piiordersteptable.setSeq2(seq2);
        piiordersteptable.setSeq3(10);
        piiordersteptable.setPipeline(null);
        piiordersteptable.setWhere_col(null);
        piiordersteptable.setWhere_key_name(null);
        piiordersteptable.setParallelcnt(null);
        piiordersteptable.setCommitcnt("3000");

        //Transformation by DB Type
        dbtype = dlmDBvo.getDbtype();
        wherestr = " EXPECTED_ARC_DEL_DATE <= TO_DATE('" + basedate + " 23:59:59','yyyy/mm/dd HH24:MI:SS')";

        piiordersteptable.setWherestr(wherestr);
        /** 하나카드 1Qnet은 CUST_PIN=null 이부분 제거 => 공통고객번호로 사용함, 그 외는 주민번호이므로 영구파기 시 삭제 20230613 */
        if("HANACARD_1Qnet".equalsIgnoreCase(site)) {
            piiordersteptable.setSqlstr(SqlUtil.convertDateformat(dbtype,
                            "update COTDL.TBL_PIIEXTRACT set EXCLUDE_REASON='DELARC' , ARC_DEL_DATE=TO_DATE('" + basedate + "','yyyy/mm/dd')" + " where " + wherestr + " and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null"
                    )
            );
        }else{
            piiordersteptable.setSqlstr(SqlUtil.convertDateformat(dbtype,
                            "update COTDL.TBL_PIIEXTRACT set CUST_PIN=null, EXCLUDE_REASON='DELARC' , ARC_DEL_DATE=TO_DATE('" + basedate + "','yyyy/mm/dd')" + " where " + wherestr + " and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null"
                    )
            );
        }
        LogUtil.log("INFO", piiordersteptable.getSqlstr());
        orderStepTableMapper.insert(piiordersteptable);

        //-----------------------------------------------------------------------------------------------------------
        /** STEPTABLE from SteptableETC (고객마스터 테이블 고객상태 업데이트)*/
        //-----------------------------------------------------------------------------------------------------------
        if(stepTableMapper.readEtcCnt("ARC_DATA_DELETE","EXE_FINISH") == 1) {
            PiiStepTableVO stepTableETCVO = stepTableMapper.readEtc("ARC_DATA_DELETE", "EXE_FINISH");
            piiordersteptable.setOrderid(newOrderId);
            piiordersteptable.setStatus("Wait condition");
            piiordersteptable.setForceokflag("N");
            piiordersteptable.setBasedate(basedate);
            piiordersteptable.setJobid(jobid_new);
            piiordersteptable.setVersion("1");
            piiordersteptable.setStepid("EXE_FINISH");
            piiordersteptable.setStepname("EXE_FINISH");
            piiordersteptable.setSteptype("EXE_FINISH");
            piiordersteptable.setStepseq("2");
            piiordersteptable.setDb(stepTableETCVO.getDb());
            piiordersteptable.setOwner(stepTableETCVO.getOwner());
            piiordersteptable.setTable_name(stepTableETCVO.getTable_name());
            piiordersteptable.setPagitype(null);
            piiordersteptable.setPagitypedetail(null);
            piiordersteptable.setExetype("FINISH");
            piiordersteptable.setArchiveflag(null);
            piiordersteptable.setPreceding(null);
            piiordersteptable.setSuccedding(null);
            piiordersteptable.setSeq1(10);
            seq2 = seq2 + 100;
            piiordersteptable.setSeq2(seq2);
            piiordersteptable.setSeq3(10);
            piiordersteptable.setPipeline(null);
            piiordersteptable.setWhere_col(null);
            piiordersteptable.setWhere_key_name(null);
            piiordersteptable.setParallelcnt(null);
            piiordersteptable.setCommitcnt("3000");

            //Transformation by DB Type
            dbtype = databaseMapper.read(stepTableETCVO.getDb()).getDbtype();
            wherestr = "EXCLUDE_REASON='DELARC' and ARC_DEL_DATE=TO_DATE('" + basedate + "','yyyy/mm/dd')";
            wherestr = SqlUtil.convertDateformat(dbtype, wherestr);
            String sqlstr = stepTableETCVO.getSqlstr()
                    + " (select custid from cotdl.tbl_piiextract " + " \r\n"
                    + "   where "+ wherestr + " \r\n"
                    + " )";
            piiordersteptable.setWherestr("  ");
            piiordersteptable.setSqlstr(sqlstr);
            LogUtil.log("INFO", piiordersteptable.getSqlstr());
            orderStepTableMapper.insert(piiordersteptable);
        }
        //-----------------------------------------------------------------------------------------------------------
        /** STEPTABLE from SteptableETC (insert into TBL_PIICONTRACT  실물파기를 위한 영구파기 고객 계약정보 추출) */
        //-----------------------------------------------------------------------------------------------------------
        if(stepTableMapper.readEtcCnt("ARC_DATA_DELETE_CONTRACT","EXE_FINISH") == 1) {
            PiiStepTableVO stepTableETCVO = stepTableMapper.readEtc("ARC_DATA_DELETE_CONTRACT", "EXE_FINISH");
            piiordersteptable.setOrderid(newOrderId);
            piiordersteptable.setStatus("Wait condition");
            piiordersteptable.setForceokflag("N");
            piiordersteptable.setBasedate(basedate);
            piiordersteptable.setJobid(jobid_new);
            piiordersteptable.setVersion("1");
            piiordersteptable.setStepid("EXE_FINISH");
            piiordersteptable.setStepname("EXE_FINISH");
            piiordersteptable.setSteptype("EXE_FINISH");
            piiordersteptable.setStepseq("2");
            piiordersteptable.setDb(stepTableETCVO.getDb());   // CORE에서
            piiordersteptable.setOwner(stepTableETCVO.getOwner());
            piiordersteptable.setTable_name(stepTableETCVO.getTable_name());
            piiordersteptable.setPagitype(null);
            piiordersteptable.setPagitypedetail(null);
            piiordersteptable.setExetype("FINISH");
            piiordersteptable.setArchiveflag(null);
            piiordersteptable.setPreceding(null);
            piiordersteptable.setSuccedding(null);
            piiordersteptable.setSeq1(10);
            seq2 = seq2 + 100;
            piiordersteptable.setSeq2(seq2);
            piiordersteptable.setSeq3(10);
            piiordersteptable.setPipeline(null);
            piiordersteptable.setWhere_col(null);
            piiordersteptable.setWhere_key_name(null);
            piiordersteptable.setParallelcnt(null);
            piiordersteptable.setCommitcnt("3000");

            //Transformation by DB Type
            dbtype = databaseMapper.read(stepTableETCVO.getDb()).getDbtype();
            String sqlstr = stepTableETCVO.getSqlstr();
            sqlstr = SqlUtil.convertDateformat(dbtype, sqlstr);
            sqlstr = sqlstr.replaceAll("(?i)#BASEDATE", basedate);
            piiordersteptable.setWherestr(" ");
            piiordersteptable.setSqlstr(sqlstr);
            LogUtil.log("INFO", piiordersteptable.getSqlstr());
            orderStepTableMapper.insert(piiordersteptable);
        }
        boolean broadcaststepexist = false;
        int broadcaststepseq2 = 0;
        if(stepTableMapper.readEtcCnt("ARC_DATA_DELETE_CONTRACT","EXE_FINISH") == 1) {
            PiiStepTableVO stepTableETCVO = stepTableMapper.readEtc("ARC_DATA_DELETE_CONTRACT", "EXE_FINISH");
            // step 3. EXE_BROADCAST for TBL_PIICONTRACT
            broadcaststepexist = true;
            piiorderstep.setOrderid(newOrderId);
            piiorderstep.setDb(stepTableETCVO.getDb());
            piiorderstep.setStatus("Wait condition");
            piiorderstep.setConfirmflag("N");
            piiorderstep.setHoldflag("N");
            piiorderstep.setForceokflag("N");
            piiorderstep.setKillflag("N");
            piiorderstep.setBasedate(basedate);
            piiorderstep.setThreadcnt("1");
            piiorderstep.setCommitcnt("3000");
            piiorderstep.setRuncnt("0");
            piiorderstep.setJobid(jobid_new);
            piiorderstep.setVersion("1");
            piiorderstep.setStepid("EXE_BROADCAST");
            piiorderstep.setStepname("EXE_BROADCAST");
            piiorderstep.setSteptype("EXE_BROADCAST");
            piiorderstep.setStepseq("3");
            piiorderstep.setTotaltabcnt("1");
            piiorderstep.setSuccesstabcnt("0");
            //	     	piiorderstep.setRunningtime(" ");
            //	     	piiorderstep.setRealstarttime(" ");
            //	     	piiorderstep.setRealendtime(" ");
            piiorderstep.setOrderuserid(null);
            orderStepMapper.insert(piiorderstep);

            //-----STEPTABLE 1 for insert into TBL_PIICONTRACT
            piiordersteptable.setOrderid(newOrderId);
            piiordersteptable.setStatus("Wait condition");
            piiordersteptable.setForceokflag("N");
            piiordersteptable.setBasedate(basedate);
            piiordersteptable.setJobid(jobid_new);
            piiordersteptable.setVersion("1");
            piiordersteptable.setStepid("EXE_BROADCAST");
            piiordersteptable.setStepname("EXE_BROADCAST");
            piiordersteptable.setSteptype("EXE_BROADCAST");
            piiordersteptable.setStepseq("3");
            piiordersteptable.setDb(dlmDBvo.getDb());
            piiordersteptable.setOwner("COTDL");
            piiordersteptable.setTable_name("TBL_PIICONTRACT");
            piiordersteptable.setPagitype(null);
            piiordersteptable.setPagitypedetail(null);
            piiordersteptable.setExetype("BROADCAST");
            piiordersteptable.setArchiveflag(null);
            piiordersteptable.setPreceding(null);
            piiordersteptable.setSuccedding(null);
            piiordersteptable.setSeq1(10);
            broadcaststepseq2 = broadcaststepseq2 + 100;
            piiordersteptable.setSeq2(broadcaststepseq2);
            piiordersteptable.setSeq3(10);
            piiordersteptable.setPipeline(null);
            piiordersteptable.setWhere_col(null);
            piiordersteptable.setWhere_key_name(null);
            piiordersteptable.setParallelcnt(null);
            piiordersteptable.setCommitcnt("3000");

            //Transformation by DB Type
            dbtype = coreDBvo.getDbtype();
            wherestr = "to_char(BASEDATE,'yyyy/mm/dd') = '" + basedate + "'";
            wherestr = SqlUtil.convertDateformat(dbtype, wherestr);

            piiordersteptable.setWherestr(wherestr);
            piiordersteptable.setSqlstr(
                    "INSERT INTO COTDL.TBL_PIICONTRACT\n" +
                            "\tSELECT * FROM COTDL.TBL_PIICONTRACT\n" +
                            "\t WHERE " + wherestr
            );
            LogUtil.log("INFO", piiordersteptable.getSqlstr());
            orderStepTableMapper.insert(piiordersteptable);
        }

        if(stepTableMapper.readEtcCnt("ARC_DATA_DELETE_EDMS","EXE_BROADCAST") == 1) {
            PiiStepTableVO stepTableETCVO = stepTableMapper.readEtc("ARC_DATA_DELETE_EDMS", "EXE_BROADCAST");
            // step 3. EXE_BROADCAST for TBL_PIICONTRACT
            if(!broadcaststepexist) {
                piiorderstep.setOrderid(newOrderId);
                piiorderstep.setDb(coreDBvo.getDb());
                piiorderstep.setStatus("Wait condition");
                piiorderstep.setConfirmflag("N");
                piiorderstep.setHoldflag("N");
                piiorderstep.setForceokflag("N");
                piiorderstep.setKillflag("N");
                piiorderstep.setBasedate(basedate);
                piiorderstep.setThreadcnt("1");
                piiorderstep.setCommitcnt("3000");
                piiorderstep.setRuncnt("0");
                piiorderstep.setJobid(jobid_new);
                piiorderstep.setVersion("1");
                piiorderstep.setStepid("EXE_BROADCAST");
                piiorderstep.setStepname("EXE_BROADCAST");
                piiorderstep.setSteptype("EXE_BROADCAST");
                piiorderstep.setStepseq("3");
                piiorderstep.setTotaltabcnt("1");
                piiorderstep.setSuccesstabcnt("0");
                //	     	piiorderstep.setRunningtime(" ");
                //	     	piiorderstep.setRealstarttime(" ");
                //	     	piiorderstep.setRealendtime(" ");
                piiorderstep.setOrderuserid(null);
                orderStepMapper.insert(piiorderstep);
            }
            //-----STEPTABLE 1 for insert into TBL_PIICONTRACT
            piiordersteptable.setOrderid(newOrderId);
            piiordersteptable.setStatus("Wait condition");
            piiordersteptable.setForceokflag("N");
            piiordersteptable.setBasedate(basedate);
            piiordersteptable.setJobid(jobid_new);
            piiordersteptable.setVersion("1");
            piiordersteptable.setStepid("EXE_BROADCAST");
            piiordersteptable.setStepname("EXE_BROADCAST");
            piiordersteptable.setSteptype("EXE_BROADCAST");
            piiordersteptable.setStepseq("3");
            piiordersteptable.setDb(stepTableETCVO.getDb());
            piiordersteptable.setOwner(stepTableETCVO.getOwner());
            piiordersteptable.setTable_name(stepTableETCVO.getTable_name());
            piiordersteptable.setPagitype(null);
            piiordersteptable.setPagitypedetail(null);
            piiordersteptable.setExetype("BROADCAST");
            piiordersteptable.setArchiveflag(null);
            piiordersteptable.setPreceding(null);
            piiordersteptable.setSuccedding(null);
            piiordersteptable.setSeq1(10);
            broadcaststepseq2 = broadcaststepseq2 + 100;
            piiordersteptable.setSeq2(broadcaststepseq2);
            piiordersteptable.setSeq3(10);
            piiordersteptable.setPipeline(null);
            piiordersteptable.setWhere_col(null);
            piiordersteptable.setWhere_key_name(null);
            piiordersteptable.setParallelcnt(null);
            piiordersteptable.setCommitcnt("3000");

            //Transformation by DB Type
            dbtype = coreDBvo.getDbtype();
            wherestr = stepTableETCVO.getWherestr();

            wherestr = SqlUtil.convertDateformat(dbtype, wherestr);
            String basedate_ymd = basedate.replace("/", "");
            wherestr = wherestr.replaceAll("(?i)#BASEDATEYMD", basedate_ymd);
            wherestr = wherestr.replaceAll("(?i)#BASEDATE", basedate);
            piiordersteptable.setWherestr(wherestr);
            piiordersteptable.setSqlstr(
                    "INSERT INTO COTDL.TBL_PIIKEYMAP_HIST\n" +
                            "\tSELECT * FROM COTDL.TBL_PIIKEYMAP_HIST\n" +
                            "\t WHERE " + wherestr
            );
//            logger.warn("warn "+piiordersteptable.getSqlstr());
            orderStepTableMapper.insert(piiordersteptable);
        }
    }

    /**
     * 매 분 0초에 실행 (Asia/Seoul)
     * 이전 실행이 아직 끝나지 않았으면 이번 턴은 건너뜀(중복 방지)
     */
    @Scheduled(cron = "0 * * * * *", zone = "Asia/Seoul")
    public void runEveryMinute() {
        if (!running.compareAndSet(false, true)) {
            logger.warn("Previous minute-run still running. Skipping this turn.");
            return;
        }
        long started = System.currentTimeMillis();
        try {
            // ✅ 여기에 매 분마다 돌릴 task 들을 정의/호출
            runTasks();
        } catch (Exception e) {
            logger.error("Minute tasks failed", e);
        } finally {
            running.set(false);
            logger.info("Minute tasks took {} ms", System.currentTimeMillis() - started);
        }
    }

    private void runTasks() throws Exception {

        // 1) 대상 조회
        List<ProgOrderHistOkVO> rows = progOrderHistMapper.getListEndedOK();
        if (rows == null || rows.isEmpty()) {
            logger.debug("No Ended OK rows.");
            return;
        }
        for (ProgOrderHistOkVO row : rows) {
            final String orderId = row.getOrderid()+"";
            final String progJobNm = row.getProg_job_nm();
            final String db = row.getDb();
            final String updateQuery = row.getUpdate_query();
            final String insertQuery = row.getInsert_query();
            //final PiiOrderStepTableVO = orderStepTableMapper.read(orderId)
            //logger.warn("ProgOrderHistOkVO ={}", row.toString());
            if (updateQuery == null || updateQuery.isBlank()) {
                logger.warn("Skip: empty updateQuery for orderId={} progJobNm={}", orderId, progJobNm);
                continue;
            }
            if (insertQuery == null || insertQuery.isBlank()) {
                logger.warn("Skip: empty insertQuery for orderId={} progJobNm={}", orderId, progJobNm);
                continue;
            }
            PiiDatabaseVO dbVO = databaseMapper.read(db);
            if (dbVO == null) {
                logger.warn("DB config not found for db={}", db);
                return;
            }

            try {
                /**
                 *  업데이트는 정해저 있어서 PROG_JOB_NM 만 입력 받으면 된다.
                 *  UPDATE_QUERY="UPDATE coownser.MCMM_ETT_JOB_MST_M SET RESULT_DVCD='Y' WHERE PROG_JOB_NM = ?"
                 *  */
                String finalSql = SqlUtil.bind(updateQuery, progJobNm);
                long affected = dmlExecutor.exeQuery(dbVO, finalSql);

            } catch (Exception e) {
                logger.warn("Update failed: orderId={} db={} msg={}", orderId, db, e.getMessage(), e);
            }

            try {

                List<PiiOrderStepTableVO> stepTableVOS = orderStepTableMapper.getListInMigrateStep(row.getOrderid());
                for (PiiOrderStepTableVO stepTableVO : stepTableVOS) {
                    String BASE_DT	= stepTableVO.getBasedate()	;	/*	기준일자 표준	*/
                    String PROG_JOB_NM	= stepTableVO.getJobid()	;	/*	프로그램작업명	*/
                    String DW_JOB_STRT_DTTM	= stepTableVO.getExestart()	;	/*	DW작업시작일시	*/
                    String DW_JOB_END_DTTM	= stepTableVO.getExeend()	;	/*	DW작업종료일시	*/
                    String DATA_EXT_CCNT	= stepTableVO.getExecnt()	;	/*	데이터추출건수	*/

                    /**
                     *   로그 테이블 적재...
                     *   INSERT_LOG_QUERY="INSERT INTO coownser.SOME_LOG_TABLE (JOB_NAME, STATUS, LOG_TIME) VALUES (?, 'DONE', NOW())"
                     * */
                    String finalSql = SqlUtil.bind(insertQuery
                                                        ,DW_JOB_STRT_DTTM	/*	DW작업시작일시	*/
                                                        ,DW_JOB_END_DTTM	/*	DW작업종료일시	*/
                                                        ,DATA_EXT_CCNT	/*	데이터추출건수	*/
                                                        ,DATA_EXT_CCNT	/*	데이터적재건수	*/
                                                        ,DW_JOB_END_DTTM	/*	파라미터종료일자	*/
                                                        ,DW_JOB_STRT_DTTM	/*	파라미터종료시각	*/
                                                        ,DW_JOB_END_DTTM	/*	DW적재일시	*/
                                                        ,PROG_JOB_NM
                                                    );

                    // 바인딩된 최종 SQL을 실행합니다.
                    long affected = dmlExecutor.exeQuery(dbVO, finalSql);

                    // (선택 사항) 각 쿼리 실행 결과를 로깅할 수 있습니다.
                     logger.info("Executed for progJobNm: {}, Affected rows: {}", progJobNm, affected);
                    // 첫 번째 루프 실행 후 바로 종료
                    break;
                }
            } catch (Exception e) {
                logger.warn("Insert failed: orderId={} db={} msg={}", orderId, db, e.getMessage(), e);
            }
        }


    }
    @Transactional
    public void orderOneJob(String jobid, String version, String basedate, String rundate) {

        PiiOrderVO piiorder = new PiiOrderVO();
        PiiOrderStepVO piiorderstep = new PiiOrderStepVO();
        PiiOrderStepTableVO piiordersteptable = new PiiOrderStepTableVO();
        PiiOrderJobWaitVO piiorderjobwait = new PiiOrderJobWaitVO();
        PiiOrderStepTableWaitVO piiorderStepTableWaitMapper = new PiiOrderStepTableWaitVO();
        PiiOrderStepTableUpdateVO piiordersteptableupdate = new PiiOrderStepTableUpdateVO();
        PiiJobVO piijob = jobMapper.read(jobid, version);
        if(!"SYNC".equalsIgnoreCase(piijob.getJobtype())) {
            if (orderMapper.getSameOrderCnt(jobid, version, basedate) > 0)
                throw new OrderDupException("It's already been ordered by that date");
        }

        int newOrderId = orderMapper.getMaxOrderid() + 1;

        PiiConfigVO configVO = configMapper.read("DLM_CURRENT_ORDERID");
        if (configVO != null && configVO.getValue() != null) {
            try {
                int maxOrderId = Integer.parseInt(configVO.getValue()) + 1;
                newOrderId = Math.max(newOrderId, maxOrderId);
            } catch (NumberFormatException ex) {
                logger.warn("DLM_CURRENT_ORDERID has invalid value: {}. Using default order ID: {}", configVO.getValue(), newOrderId);
            }
        } else {
            logger.warn("DLM_CURRENT_ORDERID is not defined in config tables. Using default order ID: {}", newOrderId);
        }
        configMapper.updateVal("DLM_CURRENT_ORDERID", String.valueOf(newOrderId));

        PiiPolicyVO piipolicy;

        String wherestr = "";
        String sqlstr = "";

        Date today = new Date();
        String basedate_ymd = basedate.replace("/", "");

        LogUtil.log("INFO", "basedate"+basedate+"rundate"+rundate);
        piiorder.setOrderid(newOrderId);
        piiorder.setBasedate(basedate);
        piiorder.setRuncnt(0);
        piiorder.setJobid(piijob.getJobid());
        piiorder.setVersion(piijob.getVersion());
        piiorder.setJobname(piijob.getJobname());
        piiorder.setSystem(piijob.getSystem());
        piiorder.setPolicy_id(piijob.getPolicy_id());
        piiorder.setKeymap_id(piijob.getKeymap_id());
        piiorder.setJobtype(piijob.getJobtype());
        piiorder.setRuntype(piijob.getRuntype());
        piiorder.setCalendar(piijob.getCalendar());
        piiorder.setTime(piijob.getTime());
        piiorder.setStatus("Wait condition");

        if (orderMapper.getRecoveredCntWithJobidBasedate(piijob.getJobid(), basedate) == 0) {
            piiorder.setConfirmflag(piijob.getConfirmflag());
        } else {
            piiorder.setConfirmflag("Y");
        }
        piiorder.setHoldflag("N");
        piiorder.setForceokflag("N");
        piiorder.setKillflag("N");
        String jobTime = StrUtil.checkString(piijob.getTime()) ? "00:00" : piijob.getTime();
        piiorder.setEststarttime(rundate + " " + jobTime + ":00");
        piiorder.setRunningtime(" ");
        piiorder.setRealstarttime(" ");
        piiorder.setRealendtime(" ");
        piiorder.setJob_owner_id1(piijob.getJob_owner_id1());
        piiorder.setJob_owner_name1(piijob.getJob_owner_name1());
        piiorder.setJob_owner_id2(piijob.getJob_owner_id2());
        piiorder.setJob_owner_name2(piijob.getJob_owner_name2());
        piiorder.setJob_owner_id3(piijob.getJob_owner_id3());
        piiorder.setJob_owner_name3(piijob.getJob_owner_name3());

        piiorder.setOrderdate(" ");
        piiorder.setOrderuserid(piijob.getReguserid());
        orderMapper.insert(piiorder);
        LogUtil.log("INFO", "2");
        List<PiiStepVO> steplist = stepMapper.getJobList(piijob.getJobid(), piijob.getVersion());
        for (PiiStepVO piistep : steplist) {
            if (piistep.getStatus().equals("INACTIVE"))
                continue;

            piiorderstep.setOrderid(newOrderId);

            if (piistep.getStatus().equals("HOLD"))
                piiorderstep.setStatus("Hold");
            else
                piiorderstep.setStatus("Wait condition");

            piiorderstep.setConfirmflag("N");
            piiorderstep.setHoldflag("N");
            piiorderstep.setForceokflag("N");
            piiorderstep.setKillflag("N");
            piiorderstep.setBasedate(basedate);
            piiorderstep.setThreadcnt(piistep.getThreadcnt());
            piiorderstep.setCommitcnt(piistep.getCommitcnt());
            piiorderstep.setRuncnt("0");
            piiorderstep.setJobid(piistep.getJobid());
            piiorderstep.setVersion(piistep.getVersion());
            piiorderstep.setStepid(piistep.getStepid());
            piiorderstep.setStepname(piistep.getStepname());
            piiorderstep.setSteptype(piistep.getSteptype());
            piiorderstep.setStepseq(piistep.getStepseq());
            piiorderstep.setDb(piistep.getDb());
            piiorderstep.setTotaltabcnt("" + stepTableMapper.getTotalTabCnt(piijob.getJobid(), piijob.getVersion(), piistep.getStepid()));
            piiorderstep.setSuccesstabcnt("0");
            piiorderstep.setRunningtime(" ");
            piiorderstep.setRealstarttime(" ");
            piiorderstep.setRealendtime(" ");
            piiorderstep.setOrderuserid(piijob.getReguserid());
            /** 20231004 scramble 관련 추가*/
            piiorderstep.setData_handling_method(piistep.getData_handling_method());
            piiorderstep.setProcessing_method(piistep.getProcessing_method());
            piiorderstep.setFk_disable_flag(piistep.getFk_disable_flag());
            piiorderstep.setIndex_unusual_flag(piistep.getIndex_unusual_flag());
            piiorderstep.setVal1(piistep.getVal1());
            piiorderstep.setVal2(piistep.getVal2());
            piiorderstep.setVal3(piistep.getVal3());
            piiorderstep.setVal4(piistep.getVal4());
            piiorderstep.setVal5(piistep.getVal5());

            orderStepMapper.insert(piiorderstep);
            LogUtil.log("INFO", "3");
            List<PiiStepTableVO> steptablelist = stepTableMapper.getJobStepTableList(piijob.getJobid(), piijob.getVersion(), piistep.getStepid());
            for (PiiStepTableVO piisteptable : steptablelist) {
                piiordersteptable.setOrderid(newOrderId);
                piiordersteptable.setStatus("Wait condition");
                piiordersteptable.setForceokflag("N");
                piiordersteptable.setBasedate(basedate);
                piiordersteptable.setJobid(piistep.getJobid());
                piiordersteptable.setVersion(piistep.getVersion());
                piiordersteptable.setStepid(piistep.getStepid());
                piiordersteptable.setStepname(piistep.getStepname());
                piiordersteptable.setSteptype(piistep.getSteptype());
                piiordersteptable.setStepseq(piistep.getStepseq());
                piiordersteptable.setDb(piisteptable.getDb());
                piiordersteptable.setOwner(piisteptable.getOwner());
                piiordersteptable.setTable_name(piisteptable.getTable_name());
                if (piistep.getSteptype().equals("EXE_SCRAMBLE") || piistep.getSteptype().equals("EXE_ILM") || piistep.getSteptype().equals("EXE_MIGRATE") || piistep.getSteptype().equals("EXE_SYNC")) {// Exceptionallly used for EXE_SCRAMBLE step  20231017
                    if (!StrUtil.checkString(piisteptable.getPagitype())) {
                        piiordersteptable.setPagitype(piisteptable.getPagitype());
                    }else {
                        piiordersteptable.setPagitype(piistep.getFk_disable_flag());
                    }
                    if (!StrUtil.checkString(piisteptable.getPagitypedetail())) {
                        piiordersteptable.setPagitypedetail(piisteptable.getPagitypedetail());
                    }else {
                        piiordersteptable.setPagitypedetail(piistep.getIndex_unusual_flag());
                    }
                }else {
                    piiordersteptable.setPagitype(piisteptable.getPagitype());
                    piiordersteptable.setPagitypedetail(piisteptable.getPagitypedetail());
                }
                piiordersteptable.setExetype(piisteptable.getExetype());
                piiordersteptable.setArchiveflag(piisteptable.getArchiveflag());
                if (piistep.getSteptype().equals("GEN_KEYMAP")) {// Exceptionallly used for GEN_KEYMAP step
                    piiordersteptable.setPreceding(piisteptable.getKeymap_id());
                    piiordersteptable.setSuccedding(piisteptable.getKey_name());
                }
                if (piistep.getSteptype().equals("EXE_SCRAMBLE") || piistep.getSteptype().equals("EXE_ILM") || piistep.getSteptype().equals("EXE_MIGRATE") || piistep.getSteptype().equals("EXE_SYNC")) {// Exceptionallly used for EXE_SCRAMBLE step  20231017
                    if (!StrUtil.checkString(piisteptable.getPreceding())) {
                        piiordersteptable.setPreceding(piisteptable.getPreceding());
                    }else {
                        piiordersteptable.setPreceding(piistep.getData_handling_method());
                    }
                    if (!StrUtil.checkString(piisteptable.getSuccedding())) {
                        piiordersteptable.setSuccedding(piisteptable.getSuccedding());
                    }else {
                        piiordersteptable.setSuccedding(piistep.getProcessing_method());
                    }
                }
                piiordersteptable.setSeq1(piisteptable.getSeq1());
                piiordersteptable.setSeq2(piisteptable.getSeq2());
                piiordersteptable.setSeq3(piisteptable.getSeq3());
                if (piistep.getSteptype().equals("EXE_SCRAMBLE") || piistep.getSteptype().equals("EXE_ILM") || piistep.getSteptype().equals("EXE_MIGRATE") || piistep.getSteptype().equals("EXE_SYNC")) {// Exceptionallly used for EXE_SCRAMBLE step  20231017
                    if (!StrUtil.checkString(piisteptable.getPipeline())) {
                        piiordersteptable.setPipeline(piisteptable.getPipeline());
                    }else {
                        piiordersteptable.setPipeline(piistep.getVal1());
                    }
                }else {
                    piiordersteptable.setPipeline(piisteptable.getPipeline());
                }
                piiordersteptable.setPk_col(piisteptable.getPk_col());
                piiordersteptable.setWhere_col(piisteptable.getWhere_col());
                piiordersteptable.setWhere_key_name(piisteptable.getWhere_key_name());
                piiordersteptable.setParallelcnt(piisteptable.getParallelcnt());
                if (piisteptable.getCommitcnt() == null || piisteptable.getCommitcnt().length() == 0) {
                    piiordersteptable.setCommitcnt(piistep.getCommitcnt());
                } else {
                    piiordersteptable.setCommitcnt(piisteptable.getCommitcnt());
                }

                String dbtype = null;
                try {
                    dbtype = databaseMapper.read(piisteptable.getDb()).getDbtype();
                } catch (Exception ex) {
                    logger.warn("warn "+"piisteptable.getDb()=>" + piisteptable.getDb() + "  " + ex.getMessage());
                    throw ex;
                }
                String del_deadline = "NULL";
                String arc_del_deadline = "NULL";
                String del_deadline_unit = "NULL";
                String arc_del_deadline_unit = "NULL";

                if (piijob.getJobtype().equalsIgnoreCase("PII")) {
                    piipolicy = policyMapper.readCurrent(piijob.getPolicy_id());
                    del_deadline_unit = piipolicy.getDel_deadline_unit();
                    arc_del_deadline_unit = piipolicy.getArc_del_deadline_unit();
                    //Transformation by DB Type
                    logger.info(dbtype +" : "+ del_deadline_unit +" : "+ piipolicy.getDel_deadline() +" : "+ bizDayMapper.getDeadline(basedate_ymd, piipolicy.getDel_deadline()));
                    del_deadline = SqlUtil.getDelDeadlineDate(dbtype, del_deadline_unit, piipolicy.getDel_deadline(), bizDayMapper.getDeadline(basedate_ymd, piipolicy.getDel_deadline()));
                    logger.info(dbtype +" : del_deadline="+del_deadline);
                    if(piijob.getPolicy_id().equalsIgnoreCase("PII_POLICY3")) {
                        arc_del_deadline = SqlUtil.getArcDelDeadlineDatePolicy3(dbtype, piipolicy.getArchive_flag(), arc_del_deadline_unit, piipolicy.getArc_del_deadline(), bizDayMapper.getArcDeadline(basedate_ymd, piipolicy.getArc_del_deadline()));
                    }else{
                        arc_del_deadline = SqlUtil.getArcDelDeadlineDate(dbtype, piipolicy.getArchive_flag(), arc_del_deadline_unit, piipolicy.getArc_del_deadline(), bizDayMapper.getArcDeadline(basedate_ymd, piipolicy.getArc_del_deadline()));
                    }
                }

                try {
                    wherestr = piisteptable.getWherestr();
                    if (!StrUtil.checkString(wherestr)) {
                        if (!StrUtil.checkString(del_deadline))
                            wherestr = wherestr.replaceAll("(?i)#DEL_DEADLINE", del_deadline);
                        if (!StrUtil.checkString(arc_del_deadline))
                            wherestr = wherestr.replaceAll("(?i)#ARC_DEL_DEADLINE", arc_del_deadline);
                        if (!StrUtil.checkString(piistep.getDb()))
                            wherestr = wherestr.replaceAll("(?i)#DATABASEID", piistep.getDb());
                        if (!StrUtil.checkString(piijob.getKeymap_id()))
                            wherestr = wherestr.replaceAll("(?i)#KEYMAP_ID", piijob.getKeymap_id());
                        /** keymap에 이미 영구파기일이 extract 테이블에서부터 세팅 되어 있어서 아래부분 필요없음, 특히 소급 파기서 문제됨 20231208*/
                        /*//테이블별 별도 영구파기 기한 반영 20220114 by Cha
                        if (piisteptable.getExetype().equals("ARCHIVE") || piisteptable.getExetype().equals("UPDATE") || piisteptable.getExetype().equals("DELETE")) {
                            if (!StrUtil.checkString(piisteptable.getPagitypedetail())) {
                                wherestr = wherestr.replaceAll("(?i)B.EXPECTED_ARC_DEL_DATE", SqlUtil.getArcDelDeadlineDate(dbtype, "Y", "M", piisteptable.getPagitypedetail(), ""));
                            }
                        }*/

                        String extractMaxCnt = EnvConfig.getConfig("DLM_EXTRACT_MAX_CNT");
                        if (!extractMaxCnt.isEmpty()) {
                            wherestr = wherestr.replaceAll("(?i)#DLM_EXTRACT_MAX_CNT", extractMaxCnt);
                        }
                        wherestr = wherestr.replaceAll("(?i)#BASEDATEYMD", basedate_ymd);
                        wherestr = wherestr.replaceAll("(?i)#BASEDATE", basedate);
                        wherestr = wherestr.replaceAll("(?i)#ORDERID", newOrderId + "");
                        wherestr = wherestr.replaceAll("(?i)#JOBID", piistep.getJobid());
                        wherestr = wherestr.replaceAll("(?i)#STEPID", piistep.getStepid());
                        wherestr = wherestr.replaceAll("(?i)#DBNAME", piisteptable.getDb());// 20220517 for Catalog batch
                    }
                } catch (NullPointerException ex) {
                    logger.warn("warn "+"Wherestr is NULL => NullPointerException: "+piiordersteptable.getJobid()+" "+piiordersteptable.getTable_name());
                }

                //BROADCAST의 경우만 step의 원천db 정보를 읽고 그 외는 모두 테이블레벨의 db 정보를 읽는데 위에서 이미 세팅되었다.
                if (piisteptable.getExetype().equals("BROADCAST")) {
                    dbtype = databaseMapper.read(piiorderstep.getDb()).getDbtype();
                }

                wherestr = SqlUtil.convertDateformat(dbtype, wherestr);

                piiordersteptable.setWherestr(wherestr);
                try {
                    sqlstr = piisteptable.getSqlstr();
                    if (!StrUtil.checkString(sqlstr)) {
                        if (!StrUtil.checkString(del_deadline))
                            sqlstr = sqlstr.replaceAll("(?i)#DEL_DEADLINE", del_deadline);
                        if (!StrUtil.checkString(arc_del_deadline))
                            sqlstr = sqlstr.replaceAll("(?i)#ARC_DEL_DEADLINE", arc_del_deadline);
                        if (!StrUtil.checkString(piistep.getDb()))
                            sqlstr = sqlstr.replaceAll("(?i)#DATABASEID", piistep.getDb());
                        if (!StrUtil.checkString(piijob.getKeymap_id()))
                            sqlstr = sqlstr.replaceAll("(?i)#KEYMAP_ID", piijob.getKeymap_id());
                        /** keymap에 이미 영구파기일이 extract 테이블에서부터 세팅 되어 있어서 아래부분 필요없음, 특히 소급 파기서 문제됨 20231208*/
                        /*//테이블별 별도 영구파기 기한 반영 20220114 by Cha
                        if (piisteptable.getExetype().equals("ARCHIVE") || piisteptable.getExetype().equals("UPDATE") || piisteptable.getExetype().equals("DELETE")) {
                            if (!StrUtil.checkString(piisteptable.getPagitypedetail())) {
                                sqlstr = sqlstr.replaceAll("(?i)B.EXPECTED_ARC_DEL_DATE", SqlUtil.getArcDelDeadlineDate(dbtype, "Y", "M", piisteptable.getPagitypedetail(), ""));
                            }
                        }*/

                        String extractMaxCntForSql = EnvConfig.getConfig("DLM_EXTRACT_MAX_CNT");
                        if (!extractMaxCntForSql.isEmpty()) {
                            sqlstr = sqlstr.replaceAll("(?i)#DLM_EXTRACT_MAX_CNT", extractMaxCntForSql);
                        }

                        sqlstr = sqlstr.replaceAll("(?i)#BASEDATE", basedate);
                        sqlstr = sqlstr.replaceAll("(?i)#ORDERID", newOrderId + "");
                        sqlstr = sqlstr.replaceAll("(?i)#JOBID", piistep.getJobid());
                        sqlstr = sqlstr.replaceAll("(?i)#STEPID", piistep.getStepid());
                        sqlstr = sqlstr.replaceAll("(?i)#DBNAME", piisteptable.getDb());// 20220517 for Catalog batch
                    }
                } catch (NullPointerException ex) {
                    logger.warn("warn "+"Sqlstr is NULL => NullPointerException: " + piiordersteptable.getJobid() + " " + piiordersteptable.getTable_name());
                    throw ex;
                }
                sqlstr = SqlUtil.convertDateformat(dbtype, sqlstr);
                piiordersteptable.setSqlstr(sqlstr);

                //20210423 Add hint by cha
                if (piistep.getSteptype().equals("GEN_KEYMAP") || piistep.getSteptype().equals("EXE_ARCHIVE") || piistep.getSteptype().equals("EXE_DELETE") || piistep.getSteptype().equals("EXE_UPDATE")) {
                    String hint = "";
                    String joinHint = null;

                    // 1. ConfigKey 결정
                    if (piiordersteptable.getWherestr().toUpperCase().contains("COTDL.TBL_PIIKEYMAP B")) {
                        joinHint = EnvConfig.getConfig("DLM_KEYMAP_JOIN_HINT");
                    } else if (piiordersteptable.getWherestr().toUpperCase().contains("COTDL.TBL_PIIKEYMAP_HIST B")) {
                        joinHint = EnvConfig.getConfig("DLM_KEYMAP_HIST_JOIN_HINT");
                    }

                    // 2. joinHint 처리
                    if (!StrUtil.checkString(joinHint)) {
                        hint = joinHint.replace("/*+", "").replace("*/", "").trim();
                    }

                    // 3. 병렬 처리 힌트 추가
                    if (!StrUtil.checkString(piisteptable.getParallelcnt())) {
                        hint += " parallel(" + piisteptable.getParallelcnt().replace("/*+", "").replace("*/", "").trim() + ")";
                    }

                    // 4. 추가 선택 힌트 처리
                    if (!StrUtil.checkString(piisteptable.getHintselect())) {
                        hint += " " + piisteptable.getHintselect().replace("/*+", "").replace("*/", "").trim();
                    }

                    // 5. 최종 힌트 포맷팅 및 SQL 업데이트
                    if (!StrUtil.checkString(hint)) {
                        hint = "/*+ " + hint + " */";
                        String replacement = "SELECT " + hint + " ";

                        piiordersteptable.setWherestr(
                                piiordersteptable.getWherestr().replaceFirst("(?i)SELECT ", replacement)
                        );
                        piiordersteptable.setSqlstr(
                                piiordersteptable.getSqlstr().replaceFirst("(?i)SELECT ", replacement)
                        );
                    }
                }
                LogUtil.log("INFO", "5");
                // Arc fields are not used
//	        	piiordersteptable.setArccnt(null);
//	        	piiordersteptable.setArctime(null);
//	        	piiordersteptable.setArcstart(null);
//	        	piiordersteptable.setArcend(null);

                piiordersteptable.setExecnt("0");
                piiordersteptable.setExetime(null);
                piiordersteptable.setExestart(null);
                piiordersteptable.setExeend(null);
                piiordersteptable.setSqlmsg(null);
                /** Target이 입력되지 않은 default 인 경우는...... step의 TargetDB 정보와   piisteptable의 owner, table_name 정보를 세팅한다. 20240123  */
                if (piistep.getSteptype().equals("EXE_MIGRATE") || piistep.getSteptype().equals("EXE_SYNC")) {
                    if(StrUtil.checkString(piisteptable.getWhere_col())) {
                        piiordersteptable.setWhere_col(piistep.getDb());
                        piiordersteptable.setWhere_key_name(piisteptable.getOwner());
                        piiordersteptable.setSqlstr(piisteptable.getTable_name());
                    }
                }
                /* 20250302 added*/
                piiordersteptable.setHintselect(piisteptable.getHintselect());
                piiordersteptable.setHintinsert(piisteptable.getHintinsert());
                String uval1 = piisteptable.getUval1();
                String processedVal1 = ""; // 초기화

                if (uval1 != null) {
                    processedVal1 = uval1.replaceAll("(?i)#BASEDATE", basedate);
                } else {
                    // null일 경우 처리 로직 (예: 빈 문자열 또는 특정 기본값 할당)
                    processedVal1 = "";
                }
                piiordersteptable.setUval1(processedVal1);
                /** Create tmp 작업 시 parallel hit max 값을 지정한다.*/
                piiordersteptable.setUval2(piistep.getVal2());
                piiordersteptable.setUval3(piisteptable.getUval3());
                piiordersteptable.setUval4(piisteptable.getUval4());
                piiordersteptable.setUval5(piisteptable.getUval5());
                orderStepTableMapper.insert(piiordersteptable);
            }
        }
        //-------order wait tables----------------------------------------------------------------------
        List<PiiJobWaitVO> jobwaitlist = jobWaitMapper.getList(piijob.getJobid(), piijob.getVersion());
        for (PiiJobWaitVO piijobwait : jobwaitlist) {
            piiorderjobwait.setOrderid(newOrderId);
            piiorderjobwait.setJobid(piijobwait.getJobid());
            piiorderjobwait.setVersion(piijobwait.getVersion());
            piiorderjobwait.setType(piijobwait.getType());
            piiorderjobwait.setJobid_w(piijobwait.getJobid_w());
            piiorderjobwait.setJobname_w(piijobwait.getJobname_w());

            orderJobWaitMapper.insert(piiorderjobwait);
        }
        List<PiiStepTableWaitVO> steptablewaitlist = stepTableWaitMapper.getJobList(piijob.getJobid(), piijob.getVersion());
        for (PiiStepTableWaitVO steptablewait : steptablewaitlist) {
            piiorderStepTableWaitMapper.setOrderid(newOrderId);
            piiorderStepTableWaitMapper.setJobid(steptablewait.getJobid());
            piiorderStepTableWaitMapper.setVersion(steptablewait.getVersion());
            piiorderStepTableWaitMapper.setStepid(steptablewait.getStepid());
            piiorderStepTableWaitMapper.setDb(steptablewait.getDb());
            piiorderStepTableWaitMapper.setOwner(steptablewait.getOwner());
            piiorderStepTableWaitMapper.setTable_name(steptablewait.getTable_name());
            piiorderStepTableWaitMapper.setType(steptablewait.getType());
            piiorderStepTableWaitMapper.setDb_w(steptablewait.getDb_w());
            piiorderStepTableWaitMapper.setOwner_w(steptablewait.getOwner_w());
            piiorderStepTableWaitMapper.setTable_name_w(steptablewait.getTable_name_w());

            orderStepTableWaitMapper.insert(piiorderStepTableWaitMapper);
        }
        List<PiiStepTableUpdateVO> steptableupdatelist = stepTableUpdateMapper.getJobList(piijob.getJobid(), piijob.getVersion());
        for (PiiStepTableUpdateVO steptableupdate : steptableupdatelist) {
            piiordersteptableupdate.setOrderid(newOrderId);
            piiordersteptableupdate.setJobid(steptableupdate.getJobid());
            piiordersteptableupdate.setVersion(steptableupdate.getVersion());
            piiordersteptableupdate.setStepid(steptableupdate.getStepid());
            piiordersteptableupdate.setSeq1(steptableupdate.getSeq1());
            piiordersteptableupdate.setSeq2(steptableupdate.getSeq2());
            piiordersteptableupdate.setSeq3(steptableupdate.getSeq3());
            piiordersteptableupdate.setColumn_name(steptableupdate.getColumn_name());
            piiordersteptableupdate.setUpdate_val(steptableupdate.getUpdate_val());
            piiordersteptableupdate.setStatus(steptableupdate.getStatus());

            orderStepTableUpdateMapper.insert(piiordersteptableupdate);

        }
        LogUtil.log("INFO", "7");
        //-----------------------------------------------------------------------------
    }

    public int registerArcTab(PiiStepTableVO piisteptable, Criteria cri) {

        LogUtil.log("INFO", "registerArcTab......cri  "  +"    "+ cri);
        int resultcnt = 0;
        if(tableMapper.getTotalCountNewArcTab(cri) == 0){
            PiiDatabaseVO dbVO = databaseMapper.read(piisteptable.getDb());
            PiiDatabaseVO dbArcVO = databaseMapper.read("DLMARC");
            PiiDatabaseVO dbHomeVO = databaseMapper.read("DLM");
            AES256Util aes = null;
            try {
                aes = new AES256Util();
            } catch(Exception e) {

            }
            Connection conn = null;
            Connection connArc = null;
            Connection connHome = null;
            Statement stmt = null;
            Statement stmtArc = null;
            ResultSet rs = null;
            StringBuilder sqlInsert = new StringBuilder();

            PreparedStatement stmtArcIns = null;
            PreparedStatement stmtArcHome = null;
            try {
//                logger.warn("warn "+"Connection creation dbVO"+ dbVO.toString());
//                logger.warn("warn "+"Connection creation dbArcVO"+ dbArcVO.toString());
//                logger.warn("warn "+"Connection creation dbHomeVO"+ dbHomeVO.toString());
                conn = ConnectionProvider.getConnection(dbVO.getDbtype(), dbVO.getHostname(), dbVO.getPort(), dbVO.getId_type(), dbVO.getId(), dbVO.getDb(), dbVO.getDbuser(), aes.decrypt(dbVO.getPwd()));
                connArc = ConnectionProvider.getConnection(dbArcVO.getDbtype(), dbArcVO.getHostname(), dbArcVO.getPort(), dbArcVO.getId_type(), dbArcVO.getId(), dbArcVO.getDb(), dbArcVO.getDbuser(), aes.decrypt(dbArcVO.getPwd()));
                connHome = ConnectionProvider.getConnection(dbHomeVO.getDbtype(), dbHomeVO.getHostname(), dbHomeVO.getPort(), dbHomeVO.getId_type(), dbHomeVO.getId(), dbHomeVO.getDb(), dbHomeVO.getDbuser(), aes.decrypt(dbHomeVO.getPwd()));
                conn.setAutoCommit(false);
                connArc.setAutoCommit(false);
                connHome.setAutoCommit(false);
            } catch(Exception e) {
                e.printStackTrace();
            }
            try {
                String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
                sqlInsert.append("CREATE TABLE " + archiveTablePath + SqlUtil.getArcTabCreateSql(dbArcVO.getDbtype()," (PII_ORDER_ID DECIMAL(15) ,PII_BASE_DATE DATETIME ,PII_CUST_ID VARCHAR(50) ,PII_JOB_ID VARCHAR(200) ,PII_DESTRUCT_DATE DATETIME ") );
                stmt = conn.createStatement();
                rs = stmt.executeQuery(SqlUtil.getArcTabCreate(dbVO.getDbtype(), piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name()));

                rs.setFetchSize(600);
                while( rs.next() ) {// ROW 단위 데이터 SELECT
                    sqlInsert.append(", "+rs.getString(1));
                }
                sqlInsert.append(SqlUtil.getArcTabCreateSql(dbArcVO.getDbtype(),") ENGINE=INNODB DEFAULT CHARACTER SET = UTF8MB4"));
                stmtArc = connArc.createStatement();
                resultcnt = stmtArc.executeUpdate(sqlInsert.toString());
                conn.commit();
                connArc.commit();

                // insert catalog info into TBL_PIITABLE
                StringBuilder sqlArcInsert = new StringBuilder();
                StringBuilder sqlHomeInsert = new StringBuilder();
                sqlArcInsert.append("insert into " + "cotdl.tbl_piitable "+ "values (");
                sqlArcInsert.append("?" );//DB
                sqlArcInsert.append(",?" );//OWNER
                sqlArcInsert.append(",?" );//TABLE_NAME
                sqlArcInsert.append(",?" );//COLUMN_NAME
                sqlArcInsert.append(",?" );//COLUMN_ID
                sqlArcInsert.append(",?" );//PK_YN
                sqlArcInsert.append(",?" );//PK_POSITION
                sqlArcInsert.append(",?" );//FULL_DATA_TYPE
                sqlArcInsert.append(",?" );//DATA_TYPE
                sqlArcInsert.append(",?" );//DATA_LENGTH
                sqlArcInsert.append(",?" );//NULLABLE
                sqlArcInsert.append(",?" );//COMMENTS
                sqlArcInsert.append(",?" );//REGDATE
                sqlArcInsert.append(",?" );//UPDDATE
                sqlArcInsert.append(",?" );//REGUSERID
                sqlArcInsert.append(",?" );//UPDUSERID
                sqlArcInsert.append(" ) ");

                sqlHomeInsert.append("insert into " + "cotdl.tbl_piitable "+ "values (");
                sqlHomeInsert.append("?" );//DB
                sqlHomeInsert.append(",?" );//OWNER
                sqlHomeInsert.append(",?" );//TABLE_NAME
                sqlHomeInsert.append(",?" );//COLUMN_NAME
                sqlHomeInsert.append(",?" );//COLUMN_ID
                sqlHomeInsert.append(",?" );//PK_YN
                sqlHomeInsert.append(",?" );//PK_POSITION
                sqlHomeInsert.append(",?" );//FULL_DATA_TYPE
                sqlHomeInsert.append(",?" );//DATA_TYPE
                sqlHomeInsert.append(",?" );//DATA_LENGTH
                sqlHomeInsert.append(",?" );//NULLABLE
                sqlHomeInsert.append(",?" );//COMMENTS
                sqlHomeInsert.append(",?" );//REGDATE
                sqlHomeInsert.append(",?" );//UPDDATE
                sqlHomeInsert.append(",?" );//REGUSERID
                sqlHomeInsert.append(",?" );//UPDUSERID
                sqlHomeInsert.append(" ) ");
//				logger.warn("warn "+"insert catalog info into TBL_PIITABLE: sqlArcInsert: "+ sqlArcInsert.toString());
//				logger.warn("warn "+"insert catalog info into TBL_PIITABLE: sqlArcInsert: "+ sqlHomeInsert.toString());

                stmtArc = connArc.createStatement();
                stmtArcIns = connArc.prepareStatement(sqlArcInsert.toString());
                stmtArcHome = connHome.prepareStatement(sqlHomeInsert.toString());
                rs = stmtArc.executeQuery(SqlUtil.getInsDlmarcPiitable(ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDbtype(), "DLMARC", piisteptable.getOwner(), piisteptable.getTable_name()));
                rs.setFetchSize(600);
//				logger.warn("warn "+"SqlUtil.getInsDlmarcPiitable: "+ SqlUtil.getInsDlmarcPiitable(ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDbtype(), "DLMARC", piisteptable.getOwner(), piisteptable.getTable_name()));
                /*
                    DLMARC의 테이블을 DLMARC, DLM의 PIITABLE에 INSERT 한다.
                */
                while( rs.next() ) {// ROW 단위 데이터 SELECT
                    stmtArcIns.setString(1, rs.getString(1));
                    stmtArcIns.setString(2, rs.getString(2));
                    stmtArcIns.setString(3, rs.getString(3));
                    stmtArcIns.setString(4, rs.getString(4));
                    stmtArcIns.setBigDecimal(5, rs.getBigDecimal(5));
                    stmtArcIns.setString(6, rs.getString(6));
                    stmtArcIns.setBigDecimal(7, rs.getBigDecimal(7));
                    stmtArcIns.setString(8, rs.getString(8));
                    stmtArcIns.setString(9, rs.getString(9));
                    stmtArcIns.setBigDecimal(10, rs.getBigDecimal(10));
                    stmtArcIns.setString(11, rs.getString(11));
                    stmtArcIns.setString(12, rs.getString(12));
                    stmtArcIns.setDate(13, rs.getDate(13));
                    stmtArcIns.setDate(14, rs.getDate(14));
                    stmtArcIns.setString(15, rs.getString(15));
                    stmtArcIns.setString(16, rs.getString(16));

                    stmtArcHome.setString(1, rs.getString(1));
                    stmtArcHome.setString(2, rs.getString(2));
                    stmtArcHome.setString(3, rs.getString(3));
                    stmtArcHome.setString(4, rs.getString(4));
                    stmtArcHome.setBigDecimal(5, rs.getBigDecimal(5));
                    stmtArcHome.setString(6, rs.getString(6));
                    stmtArcHome.setBigDecimal(7, rs.getBigDecimal(7));
                    stmtArcHome.setString(8, rs.getString(8));
                    stmtArcHome.setString(9, rs.getString(9));
                    stmtArcHome.setBigDecimal(10, rs.getBigDecimal(10));
                    stmtArcHome.setString(11, rs.getString(11));
                    stmtArcHome.setString(12, rs.getString(12));
                    stmtArcHome.setDate(13, rs.getDate(13));
                    stmtArcHome.setDate(14, rs.getDate(14));
                    stmtArcHome.setString(15, rs.getString(15));
                    stmtArcHome.setString(16, rs.getString(16));

                    stmtArcIns.addBatch();
                    stmtArcHome.addBatch();
                }
                stmtArcIns.executeBatch() ;
                stmtArcIns.clearBatch();
                stmtArcHome.executeBatch() ;
                stmtArcHome.clearBatch();

                connArc.commit();
                connHome.commit();
            } catch(SQLException e) {
                JdbcUtil.rollback(conn);
                JdbcUtil.rollback(connArc);
                JdbcUtil.rollback(connHome);
                e.printStackTrace();
            } finally {
                JdbcUtil.commit(conn);
                JdbcUtil.commit(connArc);
                JdbcUtil.commit(connHome);
                JdbcUtil.close(rs);
                JdbcUtil.close(stmt);
                JdbcUtil.close(stmtArc);
                JdbcUtil.close(stmtArcIns);
                JdbcUtil.close(stmtArcHome);
                JdbcUtil.close(conn);
                JdbcUtil.close(connArc);
                JdbcUtil.close(connHome);
            }

        }
        return resultcnt;
    }

    public int registerArcTabCols(PiiStepTableVO piisteptable, Criteria cri) {

        LogUtil.log("DEBUG", "registerArcTabCols......cri  " + cri);
        int resultcnt = 0;
        if(tableMapper.getTotalCountNewArcTabCols(cri)>0){
            LogUtil.log("DEBUG", "$$$$$$$$ 2 registerArcTabCols......piisteptable  " + piisteptable.toString());
            PiiDatabaseVO dbVO = databaseMapper.read(piisteptable.getDb());
            PiiDatabaseVO dbArcVO = databaseMapper.read("DLMARC");
            PiiDatabaseVO dbHomeVO = databaseMapper.read("DLM");
            AES256Util aes = null;
            try {
                aes = new AES256Util();
            } catch(Exception e) {

            }
            Connection conn = null;
            Connection connArc = null;
            Connection connHome = null;
            Statement stmt = null;
            Statement stmtArc = null;
            ResultSet rs = null;
            PreparedStatement stmtArcIns = null;
            PreparedStatement stmtArcHome = null;

            try {
                conn = ConnectionProvider.getConnection(dbVO.getDbtype(), dbVO.getHostname(), dbVO.getPort(), dbVO.getId_type(), dbVO.getId(), dbVO.getDb(), dbVO.getDbuser(), aes.decrypt(dbVO.getPwd()));
                connArc = ConnectionProvider.getConnection(dbArcVO.getDbtype(), dbArcVO.getHostname(), dbArcVO.getPort(), dbArcVO.getId_type(), dbArcVO.getId(), dbArcVO.getDb(), dbArcVO.getDbuser(), aes.decrypt(dbArcVO.getPwd()));
                connHome = ConnectionProvider.getConnection(dbHomeVO.getDbtype(), dbHomeVO.getHostname(), dbHomeVO.getPort(), dbHomeVO.getId_type(), dbHomeVO.getId(), dbHomeVO.getDb(), dbHomeVO.getDbuser(), aes.decrypt(dbHomeVO.getPwd()));
                conn.setAutoCommit(false);
                connArc.setAutoCommit(false);
                connHome.setAutoCommit(false);
            } catch(Exception e) {
                logger.warn("warn "+"Connection creation exception");
                logger.warn("warn "+dbVO.toString());
                logger.warn("warn "+dbArcVO.toString());
                logger.warn("warn "+dbHomeVO.toString());
                e.printStackTrace();
            }
            try {
                // Create table
                stmt = conn.createStatement();
                stmtArc = connArc.createStatement();
                List<PiiTableNewArcTabVO> newArcTabVOList = tableMapper.getListNewArcTabCols(cri);
                for (PiiTableNewArcTabVO newArcTabVO : newArcTabVOList) {
                    rs = stmt.executeQuery(SqlUtil.getArcTabColsCreate(ArchiveNamingService.CONFIG_TYPE_PII, dbVO.getDbtype(), piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name(),newArcTabVO.getColumn_name()));
                    rs.setFetchSize(600);

                    while( rs.next() ) {// ROW 단위 데이터 SELECT
                        resultcnt += stmtArc.executeUpdate(rs.getString(1));
                    }
                }
                conn.commit();
                connArc.commit();

                // insert catalog info into TBL_PIITABLE
                StringBuilder sqlArcInsert = new StringBuilder();
                StringBuilder sqlHomeInsert = new StringBuilder();
                sqlArcInsert.append("insert into " + "cotdl.tbl_piitable "+ "values (");
                sqlArcInsert.append("?" );//DB
                sqlArcInsert.append(",?" );//OWNER
                sqlArcInsert.append(",?" );//TABLE_NAME
                sqlArcInsert.append(",?" );//COLUMN_NAME
                sqlArcInsert.append(",?" );//COLUMN_ID
                sqlArcInsert.append(",?" );//PK_YN
                sqlArcInsert.append(",?" );//PK_POSITION
                sqlArcInsert.append(",?" );//FULL_DATA_TYPE
                sqlArcInsert.append(",?" );//DATA_TYPE
                sqlArcInsert.append(",?" );//DATA_LENGTH
                sqlArcInsert.append(",?" );//NULLABLE
                sqlArcInsert.append(",?" );//COMMENTS
                sqlArcInsert.append(",?" );//REGDATE
                sqlArcInsert.append(",?" );//UPDDATE
                sqlArcInsert.append(",?" );//REGUSERID
                sqlArcInsert.append(",?" );//UPDUSERID
                sqlArcInsert.append(" ) ");

                sqlHomeInsert.append("insert into " + "cotdl.tbl_piitable "+ "values (");
                sqlHomeInsert.append("?" );//DB
                sqlHomeInsert.append(",?" );//OWNER
                sqlHomeInsert.append(",?" );//TABLE_NAME
                sqlHomeInsert.append(",?" );//COLUMN_NAME
                sqlHomeInsert.append(",?" );//COLUMN_ID
                sqlHomeInsert.append(",?" );//PK_YN
                sqlHomeInsert.append(",?" );//PK_POSITION
                sqlHomeInsert.append(",?" );//FULL_DATA_TYPE
                sqlHomeInsert.append(",?" );//DATA_TYPE
                sqlHomeInsert.append(",?" );//DATA_LENGTH
                sqlHomeInsert.append(",?" );//NULLABLE
                sqlHomeInsert.append(",?" );//COMMENTS
                sqlHomeInsert.append(",?" );//REGDATE
                sqlHomeInsert.append(",?" );//UPDDATE
                sqlHomeInsert.append(",?" );//REGUSERID
                sqlHomeInsert.append(",?" );//UPDUSERID
                sqlHomeInsert.append(" ) ");
//				logger.warn("warn "+"insert catalog info into TBL_PIITABLE: sqlArcInsert: "+ sqlArcInsert.toString());
//				logger.warn("warn "+"insert catalog info into TBL_PIITABLE: sqlArcInsert: "+ sqlHomeInsert.toString());

                stmtArc = connArc.createStatement();
                stmtArcIns = connArc.prepareStatement(sqlArcInsert.toString());LogUtil.log("INFO", "stmtArcIns");
                stmtArcHome = connHome.prepareStatement(sqlHomeInsert.toString());LogUtil.log("INFO", "stmtArcHome");
//				logger.warn("warn "+"SqlUtil.getInsDlmarcPiitable(db "+SqlUtil.getInsDlmarcPiitable(ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDbtype(), "DLMARC", piisteptable.getOwner(), piisteptable.getTable_name()));

                for (PiiTableNewArcTabVO newArcTabVO : newArcTabVOList) {
                    rs = stmtArc.executeQuery(SqlUtil.getInsDlmarcPiitableCols(ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDbtype(), "DLMARC", piisteptable.getOwner(), piisteptable.getTable_name(), newArcTabVO.getColumn_name()));
                    rs.setFetchSize(600);
                    while (rs.next()) {// ROW 단위 데이터 SELECT
                        stmtArcIns.setString(1, rs.getString(1));
                        stmtArcIns.setString(2, rs.getString(2));
                        stmtArcIns.setString(3, rs.getString(3));
                        stmtArcIns.setString(4, rs.getString(4));
                        stmtArcIns.setBigDecimal(5, rs.getBigDecimal(5));
                        stmtArcIns.setString(6, rs.getString(6));
                        stmtArcIns.setBigDecimal(7, rs.getBigDecimal(7));
                        stmtArcIns.setString(8, rs.getString(8));
                        stmtArcIns.setString(9, rs.getString(9));
                        stmtArcIns.setBigDecimal(10, rs.getBigDecimal(10));
                        stmtArcIns.setString(11, rs.getString(11));
                        stmtArcIns.setString(12, rs.getString(12));
                        stmtArcIns.setDate(13, rs.getDate(13));
                        stmtArcIns.setDate(14, rs.getDate(14));
                        stmtArcIns.setString(15, rs.getString(15));
                        stmtArcIns.setString(16, rs.getString(16));

                        stmtArcHome.setString(1, rs.getString(1));
                        stmtArcHome.setString(2, rs.getString(2));
                        stmtArcHome.setString(3, rs.getString(3));
                        stmtArcHome.setString(4, rs.getString(4));
                        stmtArcHome.setBigDecimal(5, rs.getBigDecimal(5));
                        stmtArcHome.setString(6, rs.getString(6));
                        stmtArcHome.setBigDecimal(7, rs.getBigDecimal(7));
                        stmtArcHome.setString(8, rs.getString(8));
                        stmtArcHome.setString(9, rs.getString(9));
                        stmtArcHome.setBigDecimal(10, rs.getBigDecimal(10));
                        stmtArcHome.setString(11, rs.getString(11));
                        stmtArcHome.setString(12, rs.getString(12));
                        stmtArcHome.setDate(13, rs.getDate(13));
                        stmtArcHome.setDate(14, rs.getDate(14));
                        stmtArcHome.setString(15, rs.getString(15));
                        stmtArcHome.setString(16, rs.getString(16));

                        stmtArcIns.addBatch();
                        stmtArcHome.addBatch();
                    }
                    stmtArcIns.executeBatch();
                    stmtArcIns.clearBatch();
                    stmtArcHome.executeBatch();
                    stmtArcHome.clearBatch();

                    connArc.commit();
                    connHome.commit();
                }

            } catch(SQLException e) {
                JdbcUtil.rollback(conn);
                JdbcUtil.rollback(connArc);
                JdbcUtil.rollback(connHome);
                e.printStackTrace();
            } finally {

                JdbcUtil.commit(conn);
                JdbcUtil.commit(connArc);
                JdbcUtil.commit(connHome);
                JdbcUtil.close(rs);
                JdbcUtil.close(stmt);
                JdbcUtil.close(stmtArc);
                JdbcUtil.close(stmtArcIns);
                JdbcUtil.close(stmtArcHome);
                JdbcUtil.close(conn);
                JdbcUtil.close(connArc);
                JdbcUtil.close(connHome);

            }

        }
        return resultcnt;
    }

    /**
     * 매일 새벽 4시 — 고아 TMP 테이블 자동 정리
     * innerstep 10(TMP 생성) 은 있으나 innerstep 40(TMP DROP) 이 없는 건을 찾아
     * SOURCE DB에서 TMP 테이블을 DROP 하고 innerstep 40을 등록한다.
     */
    @Scheduled(cron = "0 0 4 * * *")
    public void cleanupOrphanTmpTables() {
        LogUtil.log("INFO", "[TMP-CLEANUP] Orphan TMP table cleanup started");
        List<InnerStepVO> orphans = innerStepMapper.getOrphanedTmpSteps();
        if (orphans == null || orphans.isEmpty()) {
            LogUtil.log("INFO", "[TMP-CLEANUP] No orphan TMP steps found");
            return;
        }
        LogUtil.log("INFO", "[TMP-CLEANUP] Found " + orphans.size() + " orphan TMP step(s)");

        AES256Util aes;
        try {
            aes = new AES256Util();
        } catch (Exception e) {
            LogUtil.log("ERROR", "[TMP-CLEANUP] AES256Util init failed: " + e.getMessage());
            return;
        }

        int cleanedCount = 0;
        int skippedCount = 0;
        for (InnerStepVO orphan : orphans) {
            try {
                // Running/Wait 상태 order → skip
                PiiOrderVO order = orderMapper.read(orphan.getOrderid());
                if (order != null) {
                    String status = order.getStatus();
                    if ("Running".equalsIgnoreCase(status) || "Wait".equalsIgnoreCase(status)) {
                        LogUtil.log("INFO", "[TMP-CLEANUP] Skip orderid=" + orphan.getOrderid() + " status=" + status);
                        skippedCount++;
                        continue;
                    }
                }

                // ordersteptable에서 table_name, db 획득
                PiiOrderStepTableVO stepTable = orderStepTableMapper.readWithSeq(
                        orphan.getOrderid(), orphan.getStepid(),
                        orphan.getSeq1(), orphan.getSeq2(), orphan.getSeq3());
                if (stepTable == null) {
                    LogUtil.log("WARN", "[TMP-CLEANUP] No stepTable found: orderid=" + orphan.getOrderid()
                            + " stepid=" + orphan.getStepid() + " seq=" + orphan.getSeq1() + "/" + orphan.getSeq2() + "/" + orphan.getSeq3());
                    continue;
                }

                // SOURCE DB 접속정보
                PiiDatabaseVO dbVO = databaseMapper.read(stepTable.getDb());
                if (dbVO == null) {
                    LogUtil.log("WARN", "[TMP-CLEANUP] No database info for db=" + stepTable.getDb());
                    continue;
                }

                // SOURCE DB 연결 → TMP DROP
                try (Connection conn = ConnectionProvider.getConnection(
                        dbVO.getDbtype(), dbVO.getHostname(), dbVO.getPort(),
                        dbVO.getId_type(), dbVO.getId(), dbVO.getDb(),
                        dbVO.getDbuser(), aes.decrypt(dbVO.getPwd()))) {

                    String tableName = stepTable.getTable_name();
                    // new naming: X_{orderid}_{tableName}
                    String newTmpName = SqlUtil.makeTmpTableName(tableName, orphan.getOrderid());
                    SqlUtil.dropTable(conn, dbVO.getDbtype(), "COTDL", newTmpName);

                    // old naming fallback: {tableName}{orderid}
                    String oldTmpName = tableName + orphan.getOrderid();
                    SqlUtil.dropTable(conn, dbVO.getDbtype(), "COTDL", oldTmpName);
                }

                // inner step 40 등록: status="Ended OK", message="Auto cleanup"
                InnerStepVO step40 = new InnerStepVO();
                step40.setOrderid(orphan.getOrderid());
                step40.setStepid(orphan.getStepid());
                step40.setSeq1(orphan.getSeq1());
                step40.setSeq2(orphan.getSeq2());
                step40.setSeq3(orphan.getSeq3());
                step40.setInner_step_seq(40);
                step40.setInner_step_name("Drop Tmp Table");
                step40.setStatus("Ended OK");
                step40.setMessage("Auto cleanup");
                innerStepMapper.insert(step40);

                cleanedCount++;
                LogUtil.log("INFO", "[TMP-CLEANUP] Cleaned orderid=" + orphan.getOrderid()
                        + " table=" + stepTable.getTable_name());

            } catch (Exception e) {
                LogUtil.log("WARN", "[TMP-CLEANUP] Failed orderid=" + orphan.getOrderid() + ": " + e.getMessage());
            }
        }
        LogUtil.log("INFO", "[TMP-CLEANUP] Completed: cleaned=" + cleanedCount + " skipped=" + skippedCount);
    }
}
