package datablocks.dlm.schedule;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.exception.ArcDecGapException;
import datablocks.dlm.exception.GapUpdRowException;
import datablocks.dlm.exception.TableCatalogNullException;
import datablocks.dlm.jdbc.DataSourceCache;
import datablocks.dlm.jdbc.DmlExecutor;
import datablocks.dlm.jdbc.JdbcUtil;
import datablocks.dlm.mapper.*;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.*;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 모든 step type을 처리하는 통합 큐 기반 Worker.
 * ConcurrentLinkedQueue에서 테이블을 poll()하여 처리하며,
 * DataSourceCache를 통해 DB별 커넥션 풀을 공유한다.
 *
 * <p>기존 StepTableRunnable 대비 개선점:
 * <ul>
 *   <li>테이블마다 DriverManager.getConnection() → DataSourceCache 풀링</li>
 *   <li>1500개 Runnable → threadcnt개 Worker</li>
 *   <li>에러 발생 시 stopFlag로 다른 Worker 조기 중단</li>
 *   <li>Worker별 200ms 시차로 Oracle latch 경합 방지</li>
 *   <li>Worker가 커넥션을 보유하며, DB 변경 시에만 재획득 (성능 최적화)</li>
 * </ul>
 */
public class BatchStepWorker implements Runnable {

    private static final Logger logger = LoggerFactory.getLogger(BatchStepWorker.class);

    // --- 공유 리소스 (모든 Worker가 공유) ---
    private final ConcurrentLinkedQueue<PiiOrderStepTableVO> tableQueue;
    private final DataSourceCache dsCache;
    private final PiiOrderStepVO piiorderstep;
    private final String steptableorderby;
    private final AtomicBoolean stopFlag;
    private final int workerIndex;

    // FK 의존성 re-queue 카운터
    private final AtomicInteger requeueCounter;
    private final int maxRequeueAttempts;

    // --- Mappers & Services ---
    private final DmlExecutor dlmexe;
    private final PiiOrderStepTableMapper ordersteptableMapper;
    private final PiiOrderStepMapper orderstepMapper;
    private final PiiDatabaseMapper databaseMapper;
    private final PiiTableMapper tableMapper;
    private final PiiOrderMapper orderMapper;
    private final PiiOrderThreadMapper orderthreadMapper;
    private final PiiOrderStepTableUpdateMapper ordersteptableupdateMapper;
    private final PiiConfigMapper configMapper;
    private final MetaTableMapper metaTableMapper;
    private final LkPiiScrTypeMapper lkPiiScrTypeMapper;

    public BatchStepWorker(
            ConcurrentLinkedQueue<PiiOrderStepTableVO> tableQueue,
            DataSourceCache dsCache,
            PiiOrderStepVO piiorderstep,
            String steptableorderby,
            AtomicBoolean stopFlag,
            int workerIndex,
            AtomicInteger requeueCounter,
            int maxRequeueAttempts,
            DmlExecutor dlmexe,
            PiiOrderStepTableMapper ordersteptableMapper,
            PiiOrderStepMapper orderstepMapper,
            PiiDatabaseMapper databaseMapper,
            PiiTableMapper tableMapper,
            PiiOrderMapper orderMapper,
            PiiOrderThreadMapper orderthreadMapper,
            PiiOrderStepTableUpdateMapper ordersteptableupdateMapper,
            PiiConfigMapper configMapper,
            MetaTableMapper metaTableMapper,
            LkPiiScrTypeMapper lkPiiScrTypeMapper) {

        this.tableQueue = tableQueue;
        this.dsCache = dsCache;
        this.piiorderstep = piiorderstep;
        this.steptableorderby = steptableorderby;
        this.stopFlag = stopFlag;
        this.workerIndex = workerIndex;
        this.requeueCounter = requeueCounter;
        this.maxRequeueAttempts = maxRequeueAttempts;
        this.dlmexe = dlmexe;
        this.ordersteptableMapper = ordersteptableMapper;
        this.orderstepMapper = orderstepMapper;
        this.databaseMapper = databaseMapper;
        this.tableMapper = tableMapper;
        this.orderMapper = orderMapper;
        this.orderthreadMapper = orderthreadMapper;
        this.ordersteptableupdateMapper = ordersteptableupdateMapper;
        this.configMapper = configMapper;
        this.metaTableMapper = metaTableMapper;
        this.lkPiiScrTypeMapper = lkPiiScrTypeMapper;
    }

    @Override
    public void run() {
        String steptype = piiorderstep.getSteptype();

        // Oracle latch 경합 방지: Worker별 시차 시작 (200ms 간격)
        if (workerIndex > 0) {
            try {
                Thread.sleep(workerIndex * 200L);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return;
            }
        }

        LogUtil.log("INFO", "BatchStepWorker started: thread=" + Thread.currentThread().getName()
                + " steptype=" + steptype + " workerIndex=" + workerIndex);

        // Worker-level 커넥션 보유: DB가 같으면 재사용, 다르면 재획득
        Connection connTarget = null;
        Connection connSource = null;
        Connection connIsolation = null;
        Connection connHome = null;
        String curTargetDb = null;
        String curSourceDb = null;
        String curIsolationDb = null;
        String curHomeDb = null;

        try {
            PiiOrderStepTableVO table;
            while ((table = tableQueue.poll()) != null) {
                if (stopFlag.get()) {
                    LogUtil.log("INFO", "BatchStepWorker stopping (error detected): thread="
                            + Thread.currentThread().getName());
                    break;
                }

                // step type별 DB key 결정
                String targetDb = resolveTargetDbKey(table, steptype);
                String sourceDb = resolveSourceDbKey(table, steptype);
                String isolationDb = resolveIsolationDbKey(steptype);
                String homeDb = resolveHomeDbKey(steptype);

                // Target 커넥션: DB 변경 시에만 재획득
                if (targetDb != null && !targetDb.equals(curTargetDb)) {
                    JdbcUtil.close(connTarget);
                    connTarget = dsCache.getConnection(targetDb);
                    curTargetDb = targetDb;
                }
                // Source 커넥션
                if (sourceDb != null && !sourceDb.equals(curSourceDb)) {
                    JdbcUtil.close(connSource);
                    connSource = dsCache.getConnection(sourceDb);
                    curSourceDb = sourceDb;
                } else if (sourceDb == null && connSource != null) {
                    JdbcUtil.close(connSource);
                    connSource = null;
                    curSourceDb = null;
                }
                // Isolation 커넥션 (DLMARC)
                if (isolationDb != null && !isolationDb.equals(curIsolationDb)) {
                    JdbcUtil.close(connIsolation);
                    connIsolation = dsCache.getConnection(isolationDb);
                    curIsolationDb = isolationDb;
                } else if (isolationDb == null && connIsolation != null) {
                    JdbcUtil.close(connIsolation);
                    connIsolation = null;
                    curIsolationDb = null;
                }
                // Home 커넥션 (DLM)
                if (homeDb != null && !homeDb.equals(curHomeDb)) {
                    JdbcUtil.close(connHome);
                    connHome = dsCache.getConnection(homeDb);
                    curHomeDb = homeDb;
                } else if (homeDb == null && connHome != null) {
                    JdbcUtil.close(connHome);
                    connHome = null;
                    curHomeDb = null;
                }

                // 커넥션 유효성 검사 (장시간 배치 대비)
                connTarget = ensureValidConnection(connTarget, curTargetDb);
                if (connSource != null) connSource = ensureValidConnection(connSource, curSourceDb);
                if (connIsolation != null) connIsolation = ensureValidConnection(connIsolation, curIsolationDb);
                if (connHome != null) connHome = ensureValidConnection(connHome, curHomeDb);

                processOneTable(connTarget, connSource, connIsolation, connHome, table);
            }

            LogUtil.log("INFO", "BatchStepWorker completed: thread=" + Thread.currentThread().getName());

        } catch (Exception e) {
            stopFlag.set(true);
            logger.error("BatchStepWorker connection failed: thread={}, error={}",
                    Thread.currentThread().getName(), e.getMessage(), e);
        } finally {
            JdbcUtil.close(connTarget);
            JdbcUtil.close(connSource);
            JdbcUtil.close(connIsolation);
            JdbcUtil.close(connHome);
        }
    }

    // ========================================================================================
    // DB Key 결정 메서드 (step type별로 어떤 DB에 연결할지 결정)
    // ========================================================================================

    private String resolveTargetDbKey(PiiOrderStepTableVO table, String steptype) {
        if ("EXE_ILM".equals(steptype)) {
            return piiorderstep.getDb();                    // step DB (역방향)
        } else if ("EXE_MIGRATE".equals(steptype) || "EXE_SYNC".equals(steptype)) {
            return table.getWhere_col();                    // 테이블마다 다를 수 있음!
        } else {
            return table.getDb();                           // table DB (기본)
        }
    }

    private String resolveSourceDbKey(PiiOrderStepTableVO table, String steptype) {
        if ("EXE_BROADCAST".equals(steptype) || "EXE_SCRAMBLE".equals(steptype)) {
            return piiorderstep.getDb();                    // step DB
        } else if ("EXE_ILM".equals(steptype) || "EXE_MIGRATE".equals(steptype)
                || "EXE_SYNC".equals(steptype)) {
            return table.getDb();                           // table DB
        }
        return null; // Source 불필요
    }

    private String resolveIsolationDbKey(String steptype) {
        if ("EXE_ARCHIVE".equals(steptype) || "EXE_DELETE".equals(steptype)
                || "EXE_UPDATE".equals(steptype)
                || "EXE_RESTORE".equals(steptype) || "EXE_RECOVERY".equals(steptype)) {
            return "DLMARC";
        }
        // EXE_RESTORE_U, EXE_RECOVERY_U 는 stepid로 판별 (piiorderstep.getStepid())
        String stepid = piiorderstep.getStepid();
        if (stepid != null && (stepid.startsWith("EXE_RESTORE_U") || stepid.startsWith("EXE_RECOVERY_U"))) {
            return "DLMARC";
        }
        return null;
    }

    private String resolveHomeDbKey(String steptype) {
        if ("EXE_HOMECAST".equals(steptype)) {
            return "DLM";
        }
        return null;
    }

    // ========================================================================================
    // processOneTable - 테이블 1개 처리 (StepTableRunnable.run()의 핵심 로직 이식)
    // ========================================================================================

    private void processOneTable(Connection connTarget, Connection connSource,
                                  Connection connIsolation, Connection connHome,
                                  PiiOrderStepTableVO piiordersteptable) {

        String steptype = piiorderstep.getSteptype();
        String stepid = piiorderstep.getStepid();
        long resultcnt = 0;
        boolean arc_exe_flag = false;
        PiiOrderStepVO orderstepexe = null;

        // --- 1. 이미 완료된 테이블 스킵 ---
        try {
            PiiOrderStepTableVO current = ordersteptableMapper.readWithSeq(
                    piiordersteptable.getOrderid(), piiordersteptable.getStepid(),
                    piiordersteptable.getSeq1(), piiordersteptable.getSeq2(),
                    piiordersteptable.getSeq3());
            if ("Ended OK".equals(current.getStatus())) {
                orderstepMapper.updateend(piiorderstep.getOrderid(), piiorderstep.getJobid(),
                        piiorderstep.getVersion(), piiorderstep.getStepid());
                orderMapper.updateend(piiordersteptable.getOrderid());
                orderthreadMapper.delete(piiordersteptable.getOrderid());
                return;
            }
        } catch (Exception e) {
            logger.warn("Skip check failed for table {}: {}", piiordersteptable.getTable_name(), e.getMessage());
        }

        // --- 2. 선행 테이블 실패 확인 (readCntBeforeAsc/Desc) ---
        if (isPrerequisiteFailed(piiordersteptable, steptype)) {
            LogUtil.log("INFO", "BatchStepWorker skipped (prerequisite failed): table="
                    + piiordersteptable.getTable_name() + " orderid=" + piiordersteptable.getOrderid()
                    + " seq=" + piiordersteptable.getSeq1() + "-" + piiordersteptable.getSeq2()
                    + "-" + piiordersteptable.getSeq3());
            ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(),
                    piiordersteptable.getVersion(), piiordersteptable.getStepid(),
                    piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(),
                    "Ended not OK", 0, "Skipped: prerequisite table failed");
            return;
        }

        // --- 3. FK 의존성 확인 (EXE_DELETE/EXE_ARCHIVE만) - re-queue 방식 ---
        PiiOrderStepVO piiorderstepEXE = null;
        if ("EXE_ARCHIVE".equals(steptype)) {
            piiorderstepEXE = orderstepMapper.readByStepEXE(piiordersteptable.getOrderid());
        }

        if ("EXE_DELETE".equals(steptype)
                || ("EXE_ARCHIVE".equals(steptype) && piiorderstepEXE != null)) {
            String stepid_tmp = piiordersteptable.getStepid();
            if ("EXE_ARCHIVE".equals(steptype)) {
                stepid_tmp = piiorderstepEXE.getStepid();
            }
            int waitcnt = ordersteptableMapper.getWaitTableList(
                    piiordersteptable.getOrderid(), piiordersteptable.getJobid(),
                    piiordersteptable.getVersion(), stepid_tmp,
                    piiordersteptable.getDb(), piiordersteptable.getOwner(),
                    piiordersteptable.getTable_name());
            if (waitcnt > 0) {
                int attempts = requeueCounter.incrementAndGet();
                if (attempts <= maxRequeueAttempts && !stopFlag.get()) {
                    tableQueue.offer(piiordersteptable);
                    // FK 의존성 미충족 시 잠시 대기 (DB 부하 방지)
                    try { Thread.sleep(200); } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                    }
                    return;
                } else {
                    LogUtil.log("WARN", "BatchStepWorker FK dependency not resolved: table="
                            + piiordersteptable.getTable_name() + " attempts=" + attempts);
                    ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(),
                            piiordersteptable.getVersion(), piiordersteptable.getStepid(),
                            piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(),
                            "Ended not OK", 0, "FK dependency not resolved after max attempts");
                    return;
                }
            }
        }

        // --- 4. Thread 추적 레코드 등록 ---
        PiiOrderThreadVO piiorderthread = new PiiOrderThreadVO();
        piiorderthread.setOrderid(piiordersteptable.getOrderid());
        piiorderthread.setJobid(piiordersteptable.getJobid());
        piiorderthread.setVersion(piiordersteptable.getVersion());
        piiorderthread.setStepid(piiordersteptable.getStepid());
        piiorderthread.setSeq1(piiordersteptable.getSeq1());
        piiorderthread.setSeq2(piiordersteptable.getSeq2());
        piiorderthread.setSeq3(piiordersteptable.getSeq3());
        piiorderthread.setStatus("");
        piiorderthread.setExestart("");
        try {
            orderthreadMapper.insert(piiorderthread);
        } catch (Exception e) {
            LogUtil.log("INFO", "orderthreadMapper.insert error (ignored): " + piiorderthread.toString());
        }

        // --- 5. 상태를 Before로 업데이트 ---
        ordersteptableMapper.updatebefore(piiordersteptable.getOrderid(), piiordersteptable.getJobid(),
                piiordersteptable.getVersion(), piiordersteptable.getStepid(),
                piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());

        LogUtil.log("INFO", "BatchStepWorker processing: thread=" + Thread.currentThread().getName()
                + " steptype=" + steptype + " table=" + piiordersteptable.getTable_name()
                + " orderid=" + piiordersteptable.getOrderid());

        // EXE_ARCHIVE용: orderstepexe 조회 (EXE_DELETE/EXE_UPDATE 서브 step)
        orderstepexe = orderstepMapper.readByStepEXE(piiordersteptable.getOrderid());

        // EXE_ARCHIVE의 서브 step(EXE_DELETE/EXE_UPDATE) 테이블에도 시작 시간 기록
        if ("EXE_ARCHIVE".equals(steptype) && orderstepexe != null) {
            ordersteptableMapper.updatebefore(piiordersteptable.getOrderid(), piiordersteptable.getJobid(),
                    piiordersteptable.getVersion(), orderstepexe.getStepid(),
                    piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
        }

        // --- 6. 테이블 레코드 재조회 (최신 상태) ---
        piiordersteptable = ordersteptableMapper.readWithSeq(piiordersteptable.getOrderid(),
                piiordersteptable.getStepid(), piiordersteptable.getSeq1(),
                piiordersteptable.getSeq2(), piiordersteptable.getSeq3());

        // --- 7. Step type별 실행 ---
        try {
            String db = piiordersteptable.getDb();
            PiiDatabaseVO targetDBvo = null;
            PiiDatabaseVO sourceDBvo = null;

            // DB VO 결정 (step type별)
            if ("EXE_ILM".equals(steptype)) {
                sourceDBvo = databaseMapper.read(db);
                targetDBvo = databaseMapper.read(piiorderstep.getDb());
            } else if ("EXE_MIGRATE".equals(steptype) || "EXE_SYNC".equals(steptype)) {
                sourceDBvo = databaseMapper.read(db);
                targetDBvo = databaseMapper.read(piiordersteptable.getWhere_col());
            } else if ("EXE_BROADCAST".equals(steptype) || "EXE_SCRAMBLE".equals(steptype)) {
                sourceDBvo = databaseMapper.read(piiorderstep.getDb());
                targetDBvo = databaseMapper.read(db);
            } else {
                targetDBvo = databaseMapper.read(db);
            }

            // ========== Step type별 실행 분기 ==========
            if ("GEN_KEYMAP".equals(steptype)) {
                try (Statement stmt = connTarget.createStatement()) {
                    resultcnt = stmt.executeUpdate(piiordersteptable.getSqlstr());
                }
                connTarget.commit();
                ordersteptableMapper.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(),
                        piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), resultcnt);

            } else if ("EXE_ARCHIVE".equals(steptype)) {
                List<PiiTableVO> piitablecols = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE ==> "
                            + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                int delStepFlag = orderMapper.getSteptypeCnt(piiordersteptable.getOrderid(), "EXE_DELETE");

                List<PiiOrderStepTableUpdateVO> piisteptableupdatelist = null;
                if (orderstepexe != null && "EXE_UPDATE".equalsIgnoreCase(orderstepexe.getSteptype())) {
                    piisteptableupdatelist = ordersteptableupdateMapper.getList(piiordersteptable.getOrderid(),
                            orderstepexe.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                }

                resultcnt = dlmexe.exeDLM(connTarget, connIsolation, piiordersteptable, piitablecols,
                        piisteptableupdatelist, orderstepexe, delStepFlag, targetDBvo.getDbtype());
                arc_exe_flag = true;

            } else if ("EXE_RESTORE".equalsIgnoreCase(steptype) || "EXE_RECOVERY".equalsIgnoreCase(steptype)) {
                List<PiiTableVO> piitablecols = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE ==> "
                            + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }

                PiiDatabaseVO arcDBvo = databaseMapper.read("DLMARC");
                if (stepid.substring(0, Math.min(13, stepid.length())).equalsIgnoreCase("EXE_RESTORE_U")
                        || stepid.substring(0, Math.min(14, stepid.length())).equalsIgnoreCase("EXE_RECOVERY_U")) {
                    List<PiiOrderStepTableUpdateVO> piiordersteptableupdatelist = ordersteptableupdateMapper.getList(
                            piiordersteptable.getOrderid(), piiorderstep.getStepid(),
                            piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                    LogUtil.log("WARN", "EXE_RESTORE_U Orderid:%s piiordersteptableupdatelist.size():%s Table_name:%s updatelist:%s",
                            piiordersteptable.getOrderid(), piiordersteptableupdatelist.size(),
                            piiordersteptable.getTable_name(), piiordersteptableupdatelist.toString());

                    String gapupdrowexception = "N";
                    try {
                        gapupdrowexception = EnvConfig.getConfig("RESTOREGAP_UPDROW_EXCEPTION");
                    } catch (NullPointerException ex) {
                        gapupdrowexception = "N";
                    }
                    resultcnt = dlmexe.exeRecoveryUpdate(connIsolation, connTarget, piiordersteptable,
                            piitablecols, piiordersteptableupdatelist, arcDBvo.getDbtype(), gapupdrowexception);
                } else {
                    LogUtil.log("INFO", "EXE_RESTORE===================" + piiordersteptable.toString());
                    resultcnt = dlmexe.exeRecovery(connIsolation, connTarget, piiordersteptable, piitablecols, arcDBvo.getDbtype());
                }

            } else if ("EXE_BROADCAST".equals(steptype)) {
                List<PiiTableVO> piitablecols = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE ==> "
                            + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                resultcnt = dlmexe.exeBroadcast(connSource, connTarget, piiordersteptable, piitablecols, sourceDBvo.getDbtype());

            } else if ("EXE_SCRAMBLE".equals(steptype)) {
                resultcnt = executeScramble(connSource, connTarget, piiordersteptable, sourceDBvo, targetDBvo, db);

            } else if ("EXE_ILM".equals(steptype)) {
                List<PiiTableVO> piitablecols_source = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                List<PiiTableVO> piitablecols_target = tableMapper.readTable(piiorderstep.getDb(), piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols_target.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for target doesn't exist in COTDL.TBL_PIITABLE ==> "
                            + db + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                if (piitablecols_source.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for source doesn't exist in COTDL.TBL_PIITABLE ==> "
                            + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }

                String stopHourFromTo = null;
                try { stopHourFromTo = EnvConfig.getConfig("ILM_STOPHOUR_FROM_TO"); } catch (NullPointerException ex) { /* null */ }
                int commit_loop_cnt = StrUtil.parseInt(EnvConfig.getConfig("ILM_COMMIT_LOOP_CNT"));
                boolean sourceDelflag = true;
                resultcnt = dlmexe.exeILM(connSource, connTarget, piiordersteptable, piitablecols_source, piitablecols_target,
                        sourceDBvo, targetDBvo, sourceDelflag, stopHourFromTo, commit_loop_cnt);

            } else if ("EXE_MIGRATE".equals(steptype)) {
                List<PiiTableVO> piitablecols_source = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                List<PiiTableVO> piitablecols_target = tableMapper.readTable(piiordersteptable.getWhere_col(),
                        piiordersteptable.getWhere_key_name(), piiordersteptable.getSqlstr());
                if (piitablecols_target.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for target doesn't exist in COTDL.TBL_PIITABLE ==> "
                            + piiordersteptable.getWhere_col() + ":" + piiordersteptable.getWhere_key_name() + "." + piiordersteptable.getSqlstr());
                }
                if (piitablecols_source.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for source doesn't exist in COTDL.TBL_PIITABLE ==> "
                            + db + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }

                String stopHourFromTo = null;
                try { stopHourFromTo = EnvConfig.getConfig("MIGRATE_STOPHOUR_FROM_TO"); } catch (NullPointerException ex) { /* null */ }
                int commit_loop_cnt = StrUtil.parseInt(EnvConfig.getConfig("MIGRATE_COMMIT_LOOP_CNT"));
                boolean sourceDelflag = false;
                resultcnt = dlmexe.exeILM(connSource, connTarget, piiordersteptable, piitablecols_source, piitablecols_target,
                        sourceDBvo, targetDBvo, sourceDelflag, stopHourFromTo, commit_loop_cnt);

            } else if ("EXE_SYNC".equals(steptype)) {
                List<PiiTableVO> piitablecols_source = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                List<PiiTableVO> piitablecols_target = tableMapper.readTable(piiordersteptable.getWhere_col(),
                        piiordersteptable.getWhere_key_name(), piiordersteptable.getSqlstr());
                if (piitablecols_target.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for target doesn't exist in COTDL.TBL_PIITABLE ==> "
                            + db + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                if (piitablecols_source.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for source doesn't exist in COTDL.TBL_PIITABLE ==> "
                            + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }

                String stopHourFromTo = null;
                try { stopHourFromTo = EnvConfig.getConfig("MIGRATE_STOPHOUR_FROM_TO"); } catch (NullPointerException ex) { /* null */ }
                int commit_loop_cnt = StrUtil.parseInt(EnvConfig.getConfig("MIGRATE_COMMIT_LOOP_CNT"));
                boolean sourceDelflag = false;
                resultcnt = dlmexe.exeSYNC(connSource, connTarget, piiordersteptable, piitablecols_source, piitablecols_target,
                        sourceDBvo, targetDBvo, sourceDelflag, stopHourFromTo, commit_loop_cnt);

            } else if ("EXE_HOMECAST".equals(steptype)) {
                PiiDatabaseVO homeDBvo = databaseMapper.read("DLM");
                List<PiiTableVO> piitablecols = tableMapper.readTable(homeDBvo.getDb(), piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE ==> "
                            + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                resultcnt = dlmexe.exeBroadcast(connTarget, connHome, piiordersteptable, piitablecols, targetDBvo.getDbtype());

            } else if ("EXE_DELETE".equals(steptype) || "EXE_UPDATE".equals(steptype)) {
                List<PiiTableVO> piitablecols = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE ==> "
                            + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                if ("EXE_DELETE".equals(steptype)) {
                    LogUtil.log("INFO", "@@ steptype EXE_DELETE: dlmexe.exeDLM: " + piiordersteptable.toString());
                    resultcnt = dlmexe.exeDLM(connTarget, connIsolation, piiordersteptable, piitablecols,
                            null, orderstepexe, 1, targetDBvo.getDbtype());
                } else {
                    LogUtil.log("INFO", "@@ steptype EXE_UPDATE: dlmexe.exeDLM: " + piiordersteptable.toString());
                    List<PiiOrderStepTableUpdateVO> piisteptableupdatelist = ordersteptableupdateMapper.getList(
                            piiordersteptable.getOrderid(), piiorderstep.getStepid(),
                            piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                    LogUtil.log("INFO", "dlmexe.exeDLM( before..: " + piiordersteptable.getTable_name() + "---" + piiordersteptable.getCommitcnt());
                    resultcnt = dlmexe.exeDLM(connTarget, connIsolation, piiordersteptable, piitablecols,
                            piisteptableupdatelist, orderstepexe, 0, targetDBvo.getDbtype());
                }

            } else if ("EXE_EXTRACT".equals(steptype)) {
                resultcnt = executeExtract(connTarget, piiordersteptable, stepid);

            } else {
                // EXE_FINISH, EXE_COPY_KEYMAP, ETC, EXE_TD_UPDATE 및 기타
                try (Statement stmt = connTarget.createStatement()) {
                    resultcnt = stmt.executeUpdate(piiordersteptable.getSqlstr());
                }
                connTarget.commit();
                ordersteptableMapper.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(),
                        piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), resultcnt);
            }

            // --- 성공 처리 ---
            if (resultcnt < 0) {
                JdbcUtil.rollback(connTarget);
                JdbcUtil.rollback(connIsolation);
                JdbcUtil.rollback(connSource);
                JdbcUtil.rollback(connHome);
                ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(),
                        piiordersteptable.getVersion(), piiordersteptable.getStepid(),
                        piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(),
                        "Ended not OK", 0, "Table execute fail");
            } else {
                LogUtil.log("INFO", steptype + " run() - ordersteptableMapper.updateend: resultcnt=>" + resultcnt);
                connTarget.commit();
                JdbcUtil.commit(connSource);
                JdbcUtil.commit(connIsolation);
                JdbcUtil.commit(connHome);
                ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(),
                        piiordersteptable.getVersion(), piiordersteptable.getStepid(),
                        piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(),
                        "Ended OK", resultcnt, null);
                if (arc_exe_flag && orderstepexe != null) {
                    ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(),
                            piiordersteptable.getVersion(), orderstepexe.getStepid(),
                            piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(),
                            "Ended OK", resultcnt, null);
                    ordersteptableMapper.updatecnt(piiordersteptable.getOrderid(), orderstepexe.getStepid(),
                            piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), resultcnt);
                }
            }

        } catch (TableCatalogNullException e) {
            stopFlag.set(true);
            handleException(piiordersteptable, steptype, orderstepexe, arc_exe_flag, e, resultcnt,
                    connTarget, connSource, connIsolation, connHome);

        } catch (ArcDecGapException e) {
            stopFlag.set(true);
            handleException(piiordersteptable, steptype, orderstepexe, arc_exe_flag, e, resultcnt,
                    connTarget, connSource, connIsolation, connHome);

        } catch (GapUpdRowException e) {
            stopFlag.set(true);
            handleException(piiordersteptable, steptype, orderstepexe, arc_exe_flag, e, resultcnt,
                    connTarget, connSource, connIsolation, connHome);

        } catch (NullPointerException e) {
            stopFlag.set(true);
            handleException(piiordersteptable, steptype, orderstepexe, arc_exe_flag, e, resultcnt,
                    connTarget, connSource, connIsolation, connHome);

        } catch (Exception e) {
            stopFlag.set(true);
            handleException(piiordersteptable, steptype, orderstepexe, arc_exe_flag, e, resultcnt,
                    connTarget, connSource, connIsolation, connHome);

        } finally {
            // 커넥션은 close하지 않음 (다음 테이블에서 재사용)
            // Step/Order 상태 업데이트
            orderstepMapper.updateend(piiorderstep.getOrderid(), piiorderstep.getJobid(),
                    piiorderstep.getVersion(), piiorderstep.getStepid());

            if (arc_exe_flag && orderstepexe != null) {
                orderstepMapper.updateend(piiorderstep.getOrderid(), piiorderstep.getJobid(),
                        piiorderstep.getVersion(), orderstepexe.getStepid());
            }

            orderMapper.updateend(piiordersteptable.getOrderid());

            String stepstatus = orderstepMapper.read(piiorderstep.getOrderid(), piiorderstep.getJobid(),
                    piiorderstep.getVersion(), piiorderstep.getStepid()).getStatus();
            if ("Ended OK".equals(stepstatus) || "Ended not OK".equals(stepstatus)) {
                orderthreadMapper.delete(piiordersteptable.getOrderid());
            }
        }
    }

    // ========================================================================================
    // 선행 테이블 실패 확인
    // ========================================================================================

    private boolean isPrerequisiteFailed(PiiOrderStepTableVO table, String steptype) {
        if ("EXE_ARCHIVE".equals(steptype) || "EXE_DELETE".equals(steptype)
                || "EXE_UPDATE".equals(steptype)) {
            if ("DESC".equalsIgnoreCase(steptableorderby)) {
                return ordersteptableMapper.readCntBeforeDesc(
                        table.getOrderid(), table.getJobid(), table.getVersion(),
                        table.getStepid(), table.getSeq1(), table.getSeq2(), table.getSeq3()) > 0;
            }
        }
        return ordersteptableMapper.readCntBeforeAsc(
                table.getOrderid(), table.getJobid(), table.getVersion(),
                table.getStepid(), table.getSeq1(), table.getSeq2(), table.getSeq3()) > 0;
    }

    // ========================================================================================
    // 예외 처리
    // ========================================================================================

    private void handleException(PiiOrderStepTableVO table, String steptype,
                                  PiiOrderStepVO orderstepexe, boolean arc_exe_flag,
                                  Exception e, long resultcnt,
                                  Connection connTarget, Connection connSource,
                                  Connection connIsolation, Connection connHome) {
        String exMsg = e.getMessage();
        if (exMsg != null && exMsg.length() > 2000) {
            exMsg = exMsg.substring(0, 2000);
        }

        logger.warn("BatchStepWorker - {}: table={}, error={}, committedCount={}",
                e.getClass().getSimpleName(), table.getTable_name(), exMsg, resultcnt);

        ordersteptableMapper.updateend(table.getOrderid(), table.getJobid(),
                table.getVersion(), table.getStepid(),
                table.getSeq1(), table.getSeq2(), table.getSeq3(),
                "Ended not OK", resultcnt, exMsg);

        // EXE_ARCHIVE 에러 시 서브 step(EXE_DELETE/EXE_UPDATE)도 업데이트
        if ("EXE_ARCHIVE".equals(steptype)) {
            ordersteptableMapper.updateendBySteptype(table.getOrderid(), table.getJobid(),
                    table.getVersion(), table.getSeq1(), table.getSeq2(), table.getSeq3(),
                    "Ended not OK", resultcnt, exMsg);
        }

        JdbcUtil.rollback(connTarget);
        JdbcUtil.rollback(connSource);
        JdbcUtil.rollback(connIsolation);
        JdbcUtil.rollback(connHome);

        e.printStackTrace();
    }

    // ========================================================================================
    // EXE_EXTRACT 실행 (GEN_MASTER_KEYMAP #CURVAL/#PREVAL 파싱 포함)
    // ========================================================================================

    private long executeExtract(Connection connTarget, PiiOrderStepTableVO table, String stepid)
            throws Exception {
        long resultcnt;

        if ("GEN_MASTER_KEYMAP".equalsIgnoreCase(stepid)) {
            Statement stmt = connTarget.createStatement();
            String regex = "/\\*\\s*(.*?)\\s*\\*/";
            Pattern pattern = Pattern.compile(regex, Pattern.DOTALL);
            Matcher matcher = pattern.matcher(table.getSqlstr());

            if (matcher.find()) {
                String sqlString = matcher.group(1);
                LogUtil.log("INFO", "GEN_MASTER_KEYMAP sqlString: " + sqlString);
                String[] sqlStatements = sqlString.split(";");
                String currentValue = "0";
                String preValue = "";

                for (int i = 0; i < sqlStatements.length; i++) {
                    String trimmedStatement = sqlStatements[i].trim();
                    if (!trimmedStatement.isEmpty() && trimmedStatement.contains("##### CURVAL #####")) {
                        String exeSql = trimmedStatement.replace("##### CURVAL #####", "");
                        if (!exeSql.isEmpty()) {
                            try (ResultSet rs = stmt.executeQuery(exeSql)) {
                                if (rs.next()) {
                                    currentValue = rs.getString(1);
                                    LogUtil.log("INFO", "updatedValue: " + currentValue);
                                }
                            } catch (SQLException e) {
                                logger.error("Error executing query ##### CURVAL #####: " + e.getMessage());
                            }
                        }
                    } else if (!trimmedStatement.isEmpty() && trimmedStatement.contains("##### UPDATE #####")) {
                        String exeSql = trimmedStatement.replace("##### UPDATE #####", "");
                        if (!exeSql.isEmpty()) {
                            stmt.executeUpdate(exeSql);
                        }
                    } else if (!trimmedStatement.isEmpty() && trimmedStatement.contains("##### PREVAL #####")) {
                        String exeSql = trimmedStatement.replace("##### PREVAL #####", "");
                        if (!exeSql.isEmpty()) {
                            try (ResultSet rs = stmt.executeQuery(exeSql)) {
                                if (rs.next()) {
                                    preValue = rs.getString(1);
                                    LogUtil.log("INFO", "preValue: " + preValue);
                                }
                            } catch (SQLException e) {
                                logger.error("Error executing query ##### PREVAL #####: " + e.getMessage());
                            }
                        }
                    }
                }

                String sqlstrnew = table.getSqlstr().replaceAll("(?i)#CURVAL", currentValue);
                sqlstrnew = sqlstrnew.replaceAll("(?i)#PREVAL", "'" + preValue + "'");
                LogUtil.log("INFO", "sqlstrnew: " + sqlstrnew);
                stmt = connTarget.createStatement();
                resultcnt = stmt.executeUpdate(sqlstrnew);
                connTarget.commit();
                ordersteptableMapper.updatecnt(table.getOrderid(), table.getStepid(),
                        table.getSeq1(), table.getSeq2(), table.getSeq3(), resultcnt);
            } else {
                try (Statement stmtFallback = connTarget.createStatement()) {
                    resultcnt = stmtFallback.executeUpdate(table.getSqlstr());
                }
                connTarget.commit();
                ordersteptableMapper.updatecnt(table.getOrderid(), table.getStepid(),
                        table.getSeq1(), table.getSeq2(), table.getSeq3(), resultcnt);
            }
        } else {
            try (Statement stmt = connTarget.createStatement()) {
                resultcnt = stmt.executeUpdate(table.getSqlstr());
            }
            connTarget.commit();
            ordersteptableMapper.updatecnt(table.getOrderid(), table.getStepid(),
                    table.getSeq1(), table.getSeq2(), table.getSeq3(), resultcnt);
        }
        return resultcnt;
    }

    // ========================================================================================
    // EXE_SCRAMBLE 실행
    // ========================================================================================

    private long executeScramble(Connection connSource, Connection connTarget,
                                  PiiOrderStepTableVO table,
                                  PiiDatabaseVO sourceDBvo, PiiDatabaseVO targetDBvo,
                                  String db) throws Exception {
        List<PiiTableVO> piitablecols_target = tableMapper.readTable(db, table.getOwner(), table.getTable_name());
        List<PiiTableVO> piitablecols_source = tableMapper.readTable(piiorderstep.getDb(), table.getOwner(), table.getTable_name());
        if (piitablecols_target.size() == 0) {
            throw new TableCatalogNullException("Table catalog for target not found: " + db + ":" + table.getOwner() + "." + table.getTable_name());
        }
        if (piitablecols_source.size() == 0) {
            throw new TableCatalogNullException("Table catalog for source not found: " + piiorderstep.getDb() + ":" + table.getOwner() + "." + table.getTable_name());
        }

        String db_prod = databaseMapper.readBySystem(sourceDBvo.getSystem()).getDb();
        List<MetaTableVO> metaTableVOList = metaTableMapper.getListOneTable(db_prod, table.getOwner(), table.getTable_name());
        Hashtable<String, MetaTableVO> scrambleCols = new Hashtable<>();
        Hashtable<String, MetaTableVO> masterkeyCols = new Hashtable<>();
        for (MetaTableVO m : metaTableVOList) {
            if (!StrUtil.checkString(m.getScramble_type())) scrambleCols.put(m.getColumn_name(), m);
            if (!StrUtil.checkString(m.getMasterkey())) masterkeyCols.put(m.getColumn_name(), m);
        }

        List<LkPiiScrTypeVO> lkList = lkPiiScrTypeMapper.getList();
        Hashtable<String, LkPiiScrTypeVO> lkPiiScrTypeCols = new Hashtable<>();
        for (LkPiiScrTypeVO lk : lkList) lkPiiScrTypeCols.put(lk.getPiicode(), lk);

        String sqlldr_path = "N";
        Map<String, String> dataMap = null;
        if (table.getJobid().startsWith("TESTDATA_AUTO_GEN")) {
            dataMap = new HashMap<>();
            String sql = "SELECT KEY_NAME, VAL1, NEWVAL1 FROM COTDL.TBL_PIIMASTERKEYMAP WHERE ORDERID=?";
            try (PreparedStatement ps = connTarget.prepareStatement(sql)) {
                ps.setInt(1, table.getOrderid());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        dataMap.put(rs.getString(1) + ":" + rs.getString(2), rs.getString(3));
                    }
                }
            } catch (SQLException e) {
                logger.warn("MasterKeyMap lookup failed: {}", e.getMessage());
            }
        }

        int commit_loop_cnt = StrUtil.parseInt(EnvConfig.getConfig("SCRAMBLE_COMMIT_LOOP_CNT"));
        String site = EnvConfig.getConfig("SITE");

        long resultcnt = dlmexe.exeScramble(connSource, connTarget, table,
                piitablecols_source, piitablecols_target, sourceDBvo, targetDBvo,
                scrambleCols, masterkeyCols, lkPiiScrTypeCols, sqlldr_path,
                dataMap, commit_loop_cnt, site);
        connTarget.commit();
        return resultcnt;
    }

    // ========================================================================================
    // 커넥션 유효성 검사 (장시간 배치 대비)
    // ========================================================================================

    private Connection ensureValidConnection(Connection conn, String dbKey) throws SQLException {
        if (conn != null && !conn.isClosed() && conn.isValid(5)) {
            return conn;
        }
        logger.warn("Connection invalid, acquiring new one from pool: db={}, thread={}",
                dbKey, Thread.currentThread().getName());
        JdbcUtil.close(conn);
        Connection newConn = dsCache.getConnection(dbKey);
        return newConn;
    }
}
