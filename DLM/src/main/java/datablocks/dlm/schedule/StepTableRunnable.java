package datablocks.dlm.schedule;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.exception.ArcDecGapException;
import datablocks.dlm.exception.GapUpdRowException;
import datablocks.dlm.exception.TableCatalogNullException;
import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.jdbc.DmlExecutor;
import datablocks.dlm.jdbc.JdbcUtil;
import datablocks.dlm.mapper.*;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.HashMap;
import java.util.List;
import java.util.Hashtable;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class StepTableRunnable implements Runnable {
    private static final Logger logger = LoggerFactory.getLogger(StepTableRunnable.class);
    private DmlExecutor dlmexe;
    private PiiOrderStepTableMapper ordersteptableMapper;
    private PiiOrderStepMapper orderstepMapper;
    private PiiDatabaseMapper databaseMapper;
    private PiiTableMapper tableMapper;
    private PiiOrderMapper orderMapper;
    private PiiOrderThreadMapper orderthreadMapper;
    private PiiOrderStepTableUpdateMapper ordersteptableupdateMapper;
    private PiiConfigMapper configMapper;
    private MetaTableMapper metaTableMapper;
    private LkPiiScrTypeMapper lkPiiScrTypeMapper;
    private PiiOrderStepTableVO piiordersteptable;
    private PiiOrderStepVO piiorderstep;
    private PiiRestoreVO piirestore;

    private Connection connTarget;
    private Connection connSource;
    private Connection connIsolation;
    private Connection connHome;
    private Statement stmt;
    private CallableStatement callableStatement;
    private ResultSet rs;
    private PiiDatabaseVO arcDBvo;
    private PiiDatabaseVO homeDBvo;
    private long resultcnt;
    private int waitcnt;
    private String db;
    private AES256Util aes;
    private String steptableorderby;
    private int threadcnt;
    private int exeno;
    private boolean stopped = false;

    public StepTableRunnable(int threadcnt, int exeno, PiiOrderStepVO piiorderstep, PiiOrderStepTableVO piiordersteptable, AES256Util aes, String steptableorderby,
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

        this.threadcnt = threadcnt;
        this.exeno = exeno;
        this.piiorderstep = piiorderstep;
        this.piiordersteptable = piiordersteptable;
        this.aes = aes;
        this.steptableorderby = steptableorderby;
        this.ordersteptableMapper = ordersteptableMapper;
        this.orderstepMapper = orderstepMapper;
        this.dlmexe = dlmexe;
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
        String stepid = piiorderstep.getStepid();
        if (ordersteptableMapper.readWithSeq(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()).getStatus().equals("Ended OK")) {
            orderstepMapper.updateend(piiorderstep.getOrderid(), piiorderstep.getJobid(), piiorderstep.getVersion(), piiorderstep.getStepid());
            orderMapper.updateend(piiordersteptable.getOrderid());
            orderthreadMapper.delete(piiordersteptable.getOrderid());
            return;
        }
        String site =  EnvConfig.getConfig("SITE");

        LogUtil.log("INFO", "$$$ : StepTableRunnable  orderid:"+piiordersteptable.getOrderid()+"  Seq1:"+piiordersteptable.getSeq1()+"  Seq2:"+piiordersteptable.getSeq2()+"  Seq3:"+piiordersteptable.getSeq3()+"  Stepid:"+piiordersteptable.getStepid()+"  Jobid:"+piiordersteptable.getJobid()+"  Table_name:"+piiordersteptable.getTable_name());
        if (steptype.equals("GEN_KEYMAP")
                || steptype.equals("EXE_RESTORE")
                || steptype.equals("EXE_RECOVERY")
                || steptype.equals("EXE_EXTRACT")
                || steptype.equals("EXE_FINISH")
                || steptype.equals("EXE_BROADCAST")
                || steptype.equals("EXE_MIGRATE")
                || steptype.equals("EXE_SCRAMBLE")  // 20230918 added
                || steptype.equals("EXE_ILM")  // 20240116 added
                || steptype.equals("EXE_SYNC")  // 20240531 added
                || steptype.equals("EXE_HOMECAST")
                || steptype.equals("EXE_COPY_KEYMAP")
                || steptype.equals("ETC")
        ) {
            if (ordersteptableMapper.readCntBeforeAsc(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()) > 0) {
                LogUtil.log("INFO", "warn "+"0 :   not ok cnt  "+ordersteptableMapper.readCntBeforeAsc(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()));
                return;
            }
        } else if (steptype.equals("EXE_ARCHIVE")
                || steptype.equals("EXE_DELETE")
                || steptype.equals("EXE_UPDATE")
        ) {
            if (steptableorderby.equalsIgnoreCase("DESC")) {
                if (ordersteptableMapper.readCntBeforeDesc(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()) > 0) {
                    LogUtil.log("INFO", "1 :   not ok cnt  "+ordersteptableMapper.readCntBeforeAsc(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()));
                    return;
                }
            } else {
                if (ordersteptableMapper.readCntBeforeAsc(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()) > 0) {
                    LogUtil.log("INFO", "3 :   not ok cnt  "+ordersteptableMapper.readCntBeforeAsc(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()));
                    return;
                }
            }
        } else {
            if (ordersteptableMapper.readCntBeforeAsc(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()) > 0) {
                LogUtil.log("INFO", "4 :   not ok cnt  "+ordersteptableMapper.readCntBeforeAsc(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()));
                return;
            }
        }

        //LogUtil.log("INFO", "check pre condition steptype 1111 "+steptype+"  "+piiordersteptable.getTable_name()+"  "+ waitcnt+"  "+piiordersteptable);
        //check pre condition
        PiiOrderStepVO piiorderstepEXE = null;
        if (steptype.equals("EXE_ARCHIVE")) {
            //LogUtil.log("INFO", "check pre condition  2222" + steptype + "  " + piiordersteptable.getTable_name() + "  " + waitcnt);
            piiorderstepEXE = orderstepMapper.readByStepEXE(piiordersteptable.getOrderid());
        }
        if (steptype.equals("EXE_DELETE") || (steptype.equals("EXE_ARCHIVE") && piiorderstepEXE != null)) {
            //LogUtil.log("INFO", "check pre condition 3333 " + steptype + "  " + piiordersteptable.getTable_name() + "  " + waitcnt);
            String stepid_tmp = piiordersteptable.getStepid();
            if (steptype.equals("EXE_ARCHIVE")) {
                stepid_tmp = piiorderstepEXE.getStepid();
            }
            waitcnt = ordersteptableMapper.getWaitTableList(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), stepid_tmp, piiordersteptable.getDb(), piiordersteptable.getOwner(), piiordersteptable.getTable_name());
            if (waitcnt == 0) {
                stopped = true;
                //LogUtil.log("INFO", "check pre condition  stopped = false "+piiordersteptable.getTable_name()+"  "+ waitcnt);
            }
            while (!stopped) {
                try {
                    Thread.sleep(5000);//4초간 멈춤
                } catch (Exception e) {
                    e.printStackTrace();
                }

                waitcnt = ordersteptableMapper.getWaitTableList(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), stepid_tmp, piiordersteptable.getDb(), piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (waitcnt == 0) {
                    stopped = true;
                    LogUtil.log("INFO", "while(!stopped) check pre condition  stopped = true "+piiordersteptable.getTable_name()+"  "+ waitcnt);
                }

                //LogUtil.log("INFO", "while(!stopped) check pre condition  waitcnt :  "+piiordersteptable.getTable_name()+"  "+ waitcnt);
            }
        }
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
            LogUtil.log("INFO", "orderthreadMapper.insert(piiorderthread) 오류 (무시하고 계속 진행): "+ piiorderthread.toString());
            // Lock 경합 방지를 위해 delete 호출 제거 - finally 블록에서 정리됨
        }
        ordersteptableMapper.updatebefore(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());


        if (steptype.equals("EXE_RESTORE")) {// 복원은 플랫폼을 통해 자동 복원시 빠른 처리가 필요하고 keymap 경합이 발생하지 않아 thread 10개 동시 수행으로 세팅됨
            if (threadcnt != 1 && exeno > 1) {
                try {
                    Thread.sleep(10);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        } else { // keymap에 대한 latch경합을 피하기 위해
            if (threadcnt != 1 && exeno <= threadcnt && exeno > 1) {
                try {
                    Thread.sleep(1000 * exeno);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            } else if (threadcnt != 1 && exeno > threadcnt) {
                int irandomcnt = (int) Math.round(Math.random() * 1 * 1000);
                try {
                    Thread.sleep(irandomcnt);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
        PiiDatabaseVO targetDBvo = null;
        PiiDatabaseVO sourceDBvo = null;
        boolean arc_exe_flag = false;// thia flag is for that EXE_ARCHIVE step includes EXE_DELETE or EXE_UPDATE
        //get step info of EXE_DELETE or EXE_UPDATE  아카이브 단계에서도 EXE_DELETE or EXE_UPDATE 를 수행하기 위해 해당 step 정보를 가져옴.
        PiiOrderStepVO orderstepexe = orderstepMapper.readByStepEXE(piiordersteptable.getOrderid());
        //############## Table execution part ####################################################################################################
        try {
            db = piiordersteptable.getDb();
            targetDBvo = databaseMapper.read(db);
            arcDBvo = databaseMapper.read("DLMARC");
            homeDBvo = databaseMapper.read("DLM");
            if (steptype.equals("EXE_BROADCAST") || steptype.equals("EXE_SCRAMBLE")) {
                sourceDBvo = databaseMapper.read(piiorderstep.getDb()); // Use step's db for source DB when exetype is BROADCAST
            } else if (steptype.equals("EXE_ILM")) {
                sourceDBvo = databaseMapper.read(db);
                targetDBvo = databaseMapper.read(piiorderstep.getDb());
            } else if (steptype.equals("EXE_MIGRATE") || steptype.equals("EXE_SYNC")) {
                sourceDBvo = databaseMapper.read(db);
                /** targetDB는 WHERE_COL 에 세팅되어 넘어온다 20240123 */
                targetDBvo = databaseMapper.read(piiordersteptable.getWhere_col());
            }
            connTarget = ConnectionProvider.getConnection(targetDBvo.getDbtype(), targetDBvo.getHostname(), targetDBvo.getPort(), targetDBvo.getId_type(), targetDBvo.getId(), targetDBvo.getDb(), targetDBvo.getDbuser(), aes.decrypt(targetDBvo.getPwd()));
            connTarget.setAutoCommit(false);

            if (steptype.equals("EXE_ARCHIVE") //&& !targetDBvo.getDb().equalsIgnoreCase(arcDBvo.getDb())
                    || steptype.equals("EXE_RESTORE")
                    || steptype.equals("EXE_RECOVERY")
                    || steptype.equals("EXE_DELETE")
                    || steptype.equals("EXE_UPDATE")
            ) {
                try {
                    connIsolation = ConnectionProvider.getConnection(arcDBvo.getDbtype(), arcDBvo.getHostname(), arcDBvo.getPort(), arcDBvo.getId_type(), arcDBvo.getId(), arcDBvo.getDb(), arcDBvo.getDbuser(), aes.decrypt(arcDBvo.getPwd()));
                    connIsolation.setAutoCommit(false);
                } catch (NullPointerException e) {
                    e.printStackTrace();
                    logger.warn("warn "+"connIsolation connection Exception: " + e.getMessage());
                    ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", 0, "java.lang.NullPointerException - connIsolation connection Exception: null");
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                    logger.warn("warn "+"connIsolation connection Exception: " + e.getMessage());
                    ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", 0, e.getMessage());
                    return;
                }
            }
            if (steptype.equals("EXE_BROADCAST") || steptype.equals("EXE_MIGRATE") || steptype.equals("EXE_SYNC") || steptype.equals("EXE_SCRAMBLE") || steptype.equals("EXE_ILM")) {
                try {
                    LogUtil.log("INFO", "sourceDB: " + sourceDBvo.getDb() +"  targetDB: "+ targetDBvo.getDb());
                    connSource = ConnectionProvider.getConnection(sourceDBvo.getDbtype(), sourceDBvo.getHostname(), sourceDBvo.getPort(), sourceDBvo.getId_type(), sourceDBvo.getId(), sourceDBvo.getDb(), sourceDBvo.getDbuser(), aes.decrypt(sourceDBvo.getPwd()));
                    connSource.setAutoCommit(false);
                } catch (NullPointerException e) {
                    e.printStackTrace();
                    logger.warn("warn "+"connSource connection Exception: " + e.getMessage());
                    ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", 0, "java.lang.NullPointerException - connIsolation connection Exception: null");
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                    logger.warn("warn "+"connSource connection Exception: " + e.getMessage());
                    ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", 0, e.getMessage());
                    return;
                }
            }
            if (steptype.equals("EXE_HOMECAST")) {
                try {
                    connHome = ConnectionProvider.getConnection(homeDBvo.getDbtype(), homeDBvo.getHostname(), homeDBvo.getPort(), homeDBvo.getId_type(), homeDBvo.getId(), homeDBvo.getDb(), homeDBvo.getDbuser(), aes.decrypt(homeDBvo.getPwd()));
                    connHome.setAutoCommit(false);
                } catch (NullPointerException e) {
                    e.printStackTrace();
                    logger.warn("warn "+"connSource connection Exception: " + e.getMessage());
                    ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", 0, "java.lang.NullPointerException - connIsolation connection Exception: null");
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                    logger.warn("warn "+"connSource connection Exception: " + e.getMessage());
                    ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", 0, e.getMessage());
                    return;
                }
            }

 /**
        	####################################################################################
        	##############   EXECUTE START!!!!   #########
            ####################################################################################
 */
            piiordersteptable = ordersteptableMapper.readWithSeq(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());

            if (steptype.equals("GEN_KEYMAP")) {
                stmt = connTarget.createStatement();
                resultcnt = (long) stmt.executeUpdate(piiordersteptable.getSqlstr());
                connTarget.commit();
                ordersteptableMapper.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), resultcnt);
            } else if (steptype.equals("EXE_ARCHIVE")) {
                List<PiiTableVO> piitablecols = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE ==> " + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                int delStepFlag = orderMapper.getSteptypeCnt(piiordersteptable.getOrderid(), "EXE_DELETE");
                LogUtil.log("INFO", "@@ steptype EXE_ARCHIVE: dlmexe.exeDLM: "+ piiordersteptable.toString());

                List<PiiOrderStepTableUpdateVO> piisteptableupdatelist = null;
                if (orderstepexe != null) {
                    if ("EXE_UPDATE".equalsIgnoreCase(orderstepexe.getSteptype())) {
                        piisteptableupdatelist = ordersteptableupdateMapper.getList(piiordersteptable.getOrderid(), orderstepexe.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                    }
                }
                //LogUtil.log("INFO", "piisteptableupdatelist.size():"+piisteptableupdatelist.size());
                //LogUtil.log("INFO", "@@ steptype EXE_ARCHIVE: dlmexe.exeDLM: "+ piiordersteptable.toString());
                resultcnt = (long) dlmexe.exeDLM(connTarget, connIsolation, piiordersteptable, piitablecols, piisteptableupdatelist, orderstepexe, delStepFlag, targetDBvo.getDbtype());
                /*All connection commit will be managed in dlmexe.exeDLM*/
                //connTarget.commit();
                //connIsolation.commit();
                arc_exe_flag = true;
            } else if (steptype.equalsIgnoreCase("EXE_RESTORE") || steptype.equalsIgnoreCase("EXE_RECOVERY")) {
                List<PiiTableVO> piitablecols = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE ==> " + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                //LogUtil.log("INFO", "@@@@@ dlmexe.exeRecovery="+piitablecols +"     "+piiorderstep.toString());
                if (piiorderstep.getStepid().substring(0, 13).equalsIgnoreCase("EXE_RESTORE_U") || piiorderstep.getStepid().substring(0, 14).equalsIgnoreCase("EXE_RECOVERY_U")) {
                    List<PiiOrderStepTableUpdateVO> piiordersteptableupdatelist = ordersteptableupdateMapper.getList(piiordersteptable.getOrderid(), piiorderstep.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                    LogUtil.log("WARN",
                            "EXE_RESTORE_U     Orderid:%s   piiordersteptableupdatelist.size():%s   Table_name:%s   updatelist:%s",
                            piiordersteptable.getOrderid(),
                            piiordersteptableupdatelist.size(),
                            piiordersteptable.getTable_name(),
                            piiordersteptableupdatelist.toString()
                    );

                    String gapupdrowexception = "N";
                    try {
                        gapupdrowexception =  EnvConfig.getConfig("RESTOREGAP_UPDROW_EXCEPTION");
                    } catch (NullPointerException ex) {
                        gapupdrowexception = "N";
                    }
                    resultcnt = (long) dlmexe.exeRecoveryUpdate(connIsolation, connTarget, piiordersteptable, piitablecols, piiordersteptableupdatelist, arcDBvo.getDbtype(), gapupdrowexception);
                } else {
                    LogUtil.log("INFO", "EXE_RESTORE==================="+piiordersteptable.toString());
                    resultcnt = (long) dlmexe.exeRecovery(connIsolation, connTarget, piiordersteptable, piitablecols, arcDBvo.getDbtype());
                }
            } else if (steptype.equals("EXE_BROADCAST")) {
                List<PiiTableVO> piitablecols = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE ==> " + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                resultcnt = (long) dlmexe.exeBroadcast(connSource, connTarget, piiordersteptable, piitablecols, sourceDBvo.getDbtype());
            } else if (steptype.equals("EXE_SCRAMBLE")) {//LogUtil.log("INFO", sourceDBvo.getSystem()+"@@@@@@@@@@@@@@@@@@@@@@@@@"+"  "+piiordersteptable.toString());
                List<PiiTableVO> piitablecols_target = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                List<PiiTableVO> piitablecols_source = tableMapper.readTable(piiorderstep.getDb(), piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols_target.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for target doesn't exist in COTDL.TBL_PIITABLE ==> " + db + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                if (piitablecols_source.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for source doesn't exist in COTDL.TBL_PIITABLE ==> " + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                /*PRODUCTION 환경 DB에 개인정보타입, 변환 타입 등 메타정보가 있음*/
                //LogUtil.log("INFO", sourceDBvo.getSystem()+"@@@@@@@@@@@@@@@@@@@@@@@@@");
                String db_prod = databaseMapper.readBySystem(sourceDBvo.getSystem()).getDb();
                LogUtil.log("INFO", sourceDBvo.getSystem()+"  "+db_prod+"  "+piiordersteptable.getOwner()+"  "+piiordersteptable.getTable_name());
                if (metaTableMapper == null) {
                    // 로깅 또는 예외 처리
                    logger.warn("warn "+"metaTableMapper is null @@@@@@@@@@@@@@@@@@@@@@@");
                }

                /** List<MetaTableVO>의 데이터를 Hashtable에 넣기 */
                List<MetaTableVO> metaTableVOList = metaTableMapper.getListOneTable(db_prod, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                Hashtable<String, MetaTableVO> scrambleCols = new Hashtable<>();
                Hashtable<String, MetaTableVO> masterkeyCols = new Hashtable<>();
                for (MetaTableVO metaTable : metaTableVOList) {
                    if(!StrUtil.checkString(metaTable.getScramble_type())) {
                        scrambleCols.put(metaTable.getColumn_name(), metaTable);
                    }
                    if(!StrUtil.checkString(metaTable.getMasterkey())) {
                        masterkeyCols.put(metaTable.getColumn_name(), metaTable);
                    }
                }

                /** 개인정보타입코드 별로 데이터 저장 -> 암복호화수행 타입, 암복호화 함수명 사용을 위함 */
                List<LkPiiScrTypeVO> lkPiiScrTypeVOList = lkPiiScrTypeMapper.getList();
                Hashtable<String, LkPiiScrTypeVO> lkPiiScrTypeCols = new Hashtable<>();
                for (LkPiiScrTypeVO lkPiiScrTypeVO : lkPiiScrTypeVOList) {
                    lkPiiScrTypeCols.put(lkPiiScrTypeVO.getPiicode(), lkPiiScrTypeVO);
                }

                /** sqlldr file path setting*/
                String os = System.getProperty("os.name").toLowerCase();
                String sqlldr_path = "N";
                /*try {
                    sqlldr_path =  EnvConfig.getConfig("SQLLDR_PATH");
                } catch (NullPointerException ex) {
                    if (os.contains("win")) {
                        sqlldr_path = "D:/tmp";
                    } else {
                        sqlldr_path = "/tmp";
                    }
                }
                if (os.contains("win")) {
                    sqlldr_path = "D:/tmp";
                }*/
                /** 테스트데이터 자동 신청 JOB인 경우에는 MASTERKEYAMP  가져가야...*/
                Map<String, String> dataMap = null;
                if (piiordersteptable.getJobid().startsWith("TESTDATA_AUTO_GEN")) {
                    dataMap = new HashMap<>();
                    String sql = "SELECT KEY_NAME, VAL1, NEWVAL1 FROM COTDL.TBL_PIIMASTERKEYMAP WHERE ORDERID=?";

                    try (PreparedStatement preparedStatement = connTarget.prepareStatement(sql)) {
                        // ORDERID 값을 설정
                        preparedStatement.setInt(1, piiordersteptable.getOrderid());
                        try (ResultSet resultSet = preparedStatement.executeQuery()) {
                            while (resultSet.next()) {
                                /*String combinedKey = resultSet.getString("KEY_NAME") +":"+ resultSet.getString("VAL1");
                                String newval1 = resultSet.getString("NEWVAL1");*/
                                String combinedKey = resultSet.getString(1) +":"+ resultSet.getString(2);
                                String newval1 = resultSet.getString(3);

                                // 데이터를 Map에 추가
                                dataMap.put(combinedKey, newval1);
//                                LogUtil.log("INFO", "#dataMap.put$ Table: {}, key_name: {}, combinedKey: {}, newval1: {}",
//                                        piiordersteptable.getTable_name(), piiordersteptable.getWhere_key_name(), combinedKey, newval1);
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    LogUtil.log("INFO", "#dataMap.results==> Table: {}, key_name: {}, dataMap.size(): {}",
                            piiordersteptable.getTable_name(), piiordersteptable.getWhere_key_name(), dataMap.size());
                }

                int commit_loop_cnt = StrUtil.parseInt( EnvConfig.getConfig("SCRAMBLE_COMMIT_LOOP_CNT"));

                resultcnt = dlmexe.exeScramble(connSource, connTarget, piiordersteptable, piitablecols_source, piitablecols_target, sourceDBvo, targetDBvo, scrambleCols, masterkeyCols, lkPiiScrTypeCols, sqlldr_path, dataMap, commit_loop_cnt, site);
            } else if (steptype.equals("EXE_ILM") ) {//LogUtil.log("INFO", sourceDBvo.getSystem()+"@@@@@@@@@@@@@@@@@@@@@@@@@  "+piiorderstep.getDb()+"  "+piiordersteptable.toString());
                List<PiiTableVO> piitablecols_source = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                /** Archiving DB in step*/
                List<PiiTableVO> piitablecols_target = tableMapper.readTable(piiorderstep.getDb(), piiordersteptable.getOwner(), piiordersteptable.getTable_name());

                if (piitablecols_target.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for target doesn't exist in COTDL.TBL_PIITABLE ==> " + db + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                if (piitablecols_source.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for source doesn't exist in COTDL.TBL_PIITABLE ==> " + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }

                String stopHourFromTo = null;
                try {
                    stopHourFromTo =  EnvConfig.getConfig("ILM_STOPHOUR_FROM_TO");
                } catch (NullPointerException ex) {
                    stopHourFromTo = null;
                }
                int commit_loop_cnt = StrUtil.parseInt( EnvConfig.getConfig("ILM_COMMIT_LOOP_CNT"));

                boolean sourceDelflag = true;
                resultcnt = dlmexe.exeILM(connSource, connTarget, piiordersteptable, piitablecols_source, piitablecols_target, sourceDBvo, targetDBvo, sourceDelflag, stopHourFromTo, commit_loop_cnt);
            } else if (steptype.equals("EXE_MIGRATE") ) {//LogUtil.log("INFO", sourceDBvo.getSystem()+"@@@@@@@@@@@@@@@@@@@@@@@@@  "+piiorderstep.getDb()+"  "+piiordersteptable.toString());
                List<PiiTableVO> piitablecols_source = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                /** Target tables can be different.  */
                List<PiiTableVO> piitablecols_target = tableMapper.readTable(piiordersteptable.getWhere_col(), piiordersteptable.getWhere_key_name(), piiordersteptable.getSqlstr());

                if (piitablecols_target.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for target doesn't exist in COTDL.TBL_PIITABLE ==> " + piiordersteptable.getWhere_col() + ":" + piiordersteptable.getWhere_key_name() + "." + piiordersteptable.getSqlstr());
                }
                if (piitablecols_source.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for source doesn't exist in COTDL.TBL_PIITABLE ==> " + db + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }

                String stopHourFromTo = null;
                try {
                    stopHourFromTo =  EnvConfig.getConfig("MIGRATE_STOPHOUR_FROM_TO");
                } catch (NullPointerException ex) {
                    stopHourFromTo = null;
                }
                int commit_loop_cnt = StrUtil.parseInt( EnvConfig.getConfig("MIGRATE_COMMIT_LOOP_CNT"));

                boolean sourceDelflag = false;
                resultcnt = dlmexe.exeILM(connSource, connTarget, piiordersteptable, piitablecols_source, piitablecols_target, sourceDBvo, targetDBvo, sourceDelflag, stopHourFromTo, commit_loop_cnt);
            } else if (steptype.equals("EXE_SYNC") ) {//LogUtil.log("INFO", sourceDBvo.getSystem()+"@@@@@@@@@@@@@@@@@@@@@@@@@  "+piiorderstep.getDb()+"  "+piiordersteptable.toString());
                List<PiiTableVO> piitablecols_source = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                /** Archiving DB in step*/
                List<PiiTableVO> piitablecols_target = tableMapper.readTable(piiordersteptable.getWhere_col(), piiordersteptable.getWhere_key_name(), piiordersteptable.getSqlstr());

                if (piitablecols_target.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for target doesn't exist in COTDL.TBL_PIITABLE ==> " + db + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                if (piitablecols_source.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information for source doesn't exist in COTDL.TBL_PIITABLE ==> " + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }

                String stopHourFromTo = null;
                try {
                    stopHourFromTo =  EnvConfig.getConfig("MIGRATE_STOPHOUR_FROM_TO");
                } catch (NullPointerException ex) {
                    stopHourFromTo = null;
                }
                int commit_loop_cnt = StrUtil.parseInt( EnvConfig.getConfig("MIGRATE_COMMIT_LOOP_CNT"));

                boolean sourceDelflag = false;
                resultcnt = dlmexe.exeSYNC(connSource, connTarget, piiordersteptable, piitablecols_source, piitablecols_target, sourceDBvo, targetDBvo, sourceDelflag, stopHourFromTo, commit_loop_cnt);
            } else if (steptype.equals("EXE_HOMECAST")) {
                List<PiiTableVO> piitablecols = tableMapper.readTable(homeDBvo.getDb(), piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE ==> " + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                //LogUtil.log("INFO", "StepTableRunnable: "+ "EXE_HOMECAST   piitablecols.size()=" + piitablecols.size());
                resultcnt = (long) dlmexe.exeBroadcast(connTarget, connHome, piiordersteptable, piitablecols, targetDBvo.getDbtype());
            } else if (steptype.equals("EXE_DELETE") || steptype.equals("EXE_UPDATE")) {
                List<PiiTableVO> piitablecols = tableMapper.readTable(db, piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                if (piitablecols.size() == 0) {
                    throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE ==> " + piiorderstep.getDb() + ":" + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
                }
                if (steptype.equals("EXE_DELETE")) {LogUtil.log("INFO", "@@ steptype EXE_DELETE: dlmexe.exeDLM: "+ piiordersteptable.toString());
                    resultcnt = (long) dlmexe.exeDLM(connTarget, connIsolation, piiordersteptable, piitablecols, null, orderstepexe, 1, targetDBvo.getDbtype());
                } else if (steptype.equals("EXE_UPDATE")) {LogUtil.log("INFO", "@@ steptype EXE_UPDATE: dlmexe.exeDLM: "+ piiordersteptable.toString());
                    List<PiiOrderStepTableUpdateVO> piisteptableupdatelist = ordersteptableupdateMapper.getList(piiordersteptable.getOrderid(), piiorderstep.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                    LogUtil.log("INFO", "dlmexe.exeDLM( before..: " + piiordersteptable.getTable_name()+"---"+piiordersteptable.getCommitcnt());
                    resultcnt = (long) dlmexe.exeDLM(connTarget, connIsolation, piiordersteptable, piitablecols, piisteptableupdatelist, orderstepexe, 0, targetDBvo.getDbtype());
                }
            } else if (steptype.equals("EXE_EXTRACT")) {
                /** Masterkey 생성 3가지 타입 중 채번테이블, max+1 은 업데이트 프로시져 먼저 수행하고 piiordersteptable.getSqlstr()의 #currentval 을 replace해서 수행 시킨다 */
                if("GEN_MASTER_KEYMAP".equalsIgnoreCase(stepid)){
                    stmt = connTarget.createStatement();
                    // Regular expression to match comment block
                    String regex = "/\\*\\s*(.*?)\\s*\\*/";
                    Pattern pattern = Pattern.compile(regex, Pattern.DOTALL); // Allow . to match newline characters
                    Matcher matcher = pattern.matcher(piiordersteptable.getSqlstr());

                    if (matcher.find()) {
                        String sqlString = matcher.group(1);
                        LogUtil.log("INFO", "GEN_MASTER_KEYMAP sqlString: " + sqlString);
                        String[] sqlStatements = sqlString.split(";");
                        LogUtil.log("INFO", "GEN_MASTER_KEYMAP String[] sqlStatements " + sqlStatements.toString());
                        String currentValue="0";
                        String preValue = "";
                        // Process each extracted SQL statement
                        for (int i = 0; i < sqlStatements.length; i++) {
                            String trimmedStatement = sqlStatements[i].trim(); // Remove leading/trailing whitespace
                            if (!trimmedStatement.isEmpty() && trimmedStatement.contains("##### CURVAL #####")) {/** 채번테이블 현재값 */
                                String removeText = "##### CURVAL #####";
                                LogUtil.log("INFO", "SQL Statement " + (i + 1) + ":"+ trimmedStatement);
                                String exeSql = trimmedStatement.replace(removeText, "");
                                if (!exeSql.isEmpty()) {
                                    try (ResultSet resultSet = stmt.executeQuery(exeSql)) {
                                        if (resultSet.next()) { // 결과가 있는지 확인
                                            currentValue = resultSet.getString(1);
                                            LogUtil.log("INFO", "updatedValue: " + currentValue);
                                        } else {
                                            // 결과가 없는 경우 처리
                                            LogUtil.log("INFO", "No data found.");
                                        }
                                    } catch (SQLException e) {
                                        // 예외 처리
                                        logger.error("Error executing query##### CURVAL #####: " + e.getMessage());
                                    }
                                }
                            } else if (!trimmedStatement.isEmpty() && trimmedStatement.contains("##### UPDATE #####")) { /** 채번테이블 업데이트 문  현재값 + 채번할 데이터 건수*/
                                String removeText = "##### UPDATE #####";
                                LogUtil.log("INFO", "SQL Statement " + (i + 1) + ":"+ trimmedStatement);
                                String exeSql = trimmedStatement.replace(removeText, "");
                                if (!exeSql.isEmpty()) {
                                    stmt.executeUpdate(exeSql);
                                }
                            } else if (!trimmedStatement.isEmpty() && trimmedStatement.contains("##### PREVAL #####")) {/** PREVAL  */
                                String removeText = "##### PREVAL #####";
                                LogUtil.log("INFO", "SQL Statement " + (i + 1) + ":"+ trimmedStatement);
                                String exeSql = trimmedStatement.replace(removeText, "");
                                if (!exeSql.isEmpty()) {
                                    try (ResultSet resultSet = stmt.executeQuery(exeSql)) {
                                        if (resultSet.next()) { // 결과가 있는지 확인
                                            preValue = resultSet.getString(1);
                                            LogUtil.log("INFO", "preValue: " + preValue);
                                        } else {
                                            // 결과가 없는 경우 처리
                                            LogUtil.log("INFO", "No data found.");
                                        }
                                    } catch (SQLException e) {
                                        // 예외 처리
                                        logger.error("Error executing query ##### PREVAL #####: " + e.getMessage());
                                    }
                                }
                            }
                        }
                        String sqlstrnew = piiordersteptable.getSqlstr().replaceAll("(?i)#CURVAL", currentValue);
                        sqlstrnew = sqlstrnew.replaceAll("(?i)#PREVAL", "'"+preValue+"'");
                        LogUtil.log("INFO", "sqlstrnew: " + sqlstrnew);
                        stmt = connTarget.createStatement();
                        resultcnt = (long) stmt.executeUpdate(sqlstrnew);
                        connTarget.commit();
                        ordersteptableMapper.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), resultcnt);

                    } else {
                        stmt = connTarget.createStatement();
                        resultcnt = (long) stmt.executeUpdate(piiordersteptable.getSqlstr());
                        connTarget.commit();
                        ordersteptableMapper.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), resultcnt);
                    }
                } else {
                    stmt = connTarget.createStatement();
                    resultcnt = (long) stmt.executeUpdate(piiordersteptable.getSqlstr());
                    connTarget.commit();
                    ordersteptableMapper.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), resultcnt);
                }
            } else if (steptype.equals("ETC")) {
                stmt = connTarget.createStatement();
                resultcnt = (long) stmt.executeUpdate(piiordersteptable.getSqlstr());
                connTarget.commit();
                ordersteptableMapper.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), resultcnt);
            } else if (steptype.equals("EXE_TD_UPDATE")) {
                stmt = connTarget.createStatement();
                resultcnt = (long) stmt.executeUpdate(piiordersteptable.getSqlstr());
                connTarget.commit();
                ordersteptableMapper.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), resultcnt);
            } else {
                stmt = connTarget.createStatement();
                resultcnt = (long) stmt.executeUpdate(piiordersteptable.getSqlstr());
                connTarget.commit();
                ordersteptableMapper.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), resultcnt);
            }

            if (threadcnt != 1) {
                int sleeptime = 500;
                //if(steptype.equals("EXE_ARCHIVE") || steptype.equals("EXE_DELETE") || steptype.equals("EXE_RECOVERY")) sleeptime = 2000;
                try {
                    Thread.sleep(sleeptime);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

            if (resultcnt < 0) {
                JdbcUtil.rollback(connTarget);
                JdbcUtil.rollback(connIsolation);
                JdbcUtil.rollback(connSource);
                ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", 0, "Table execute fail");
            } else {LogUtil.log("INFO", steptype+"  run() - ordersteptableMapper.updateend: resultcnt=>"+ resultcnt);
                connTarget.commit();
                ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended OK", resultcnt, null);
                if (arc_exe_flag) {
                    if (orderstepexe != null) {
                        ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), orderstepexe.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended OK", resultcnt, null);
                        ordersteptableMapper.updatecnt(piiordersteptable.getOrderid(), orderstepexe.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), resultcnt);
                    }
                }
            }

        } catch (TableCatalogNullException e) {
            logger.warn("warn "+"run() - TableCatalogNullException: " + e.getMessage());
            ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", resultcnt, e.getMessage());
            if (steptype.equals("EXE_ARCHIVE")) {
                ordersteptableMapper.updateendBySteptype(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", resultcnt, e.getMessage());
            }

            //------------------------------------------------------


            //==========================================
            JdbcUtil.rollback(connTarget);
            JdbcUtil.rollback(connSource);
            JdbcUtil.rollback(connIsolation);
            JdbcUtil.rollback(connHome);
            JdbcUtil.close(connTarget);
            JdbcUtil.close(connSource);
            JdbcUtil.close(connIsolation);
            JdbcUtil.close(connHome);
            JdbcUtil.close(stmt);
            JdbcUtil.close(callableStatement);
            e.printStackTrace();
            //return;
        } catch (ArcDecGapException e) {
            logger.warn("warn "+"run() - ArcDecGapException: " + e.getMessage());
            ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", resultcnt, e.getMessage());
            if (steptype.equals("EXE_ARCHIVE")) {
                ordersteptableMapper.updateendBySteptype(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", resultcnt, e.getMessage());
            }
            JdbcUtil.rollback(connTarget);
            JdbcUtil.rollback(connSource);
            JdbcUtil.rollback(connIsolation);
            JdbcUtil.rollback(connHome);
            JdbcUtil.close(connTarget);
            JdbcUtil.close(connSource);
            JdbcUtil.close(connIsolation);
            JdbcUtil.close(connHome);
            JdbcUtil.close(stmt);
            JdbcUtil.close(callableStatement);
            e.printStackTrace();
            //return;
        } catch (GapUpdRowException e) {
            logger.warn("warn "+"run() - GapUpdRowException: " + e.getMessage());
            ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", resultcnt, e.getMessage());

            JdbcUtil.rollback(connTarget);
            JdbcUtil.rollback(connSource);
            JdbcUtil.rollback(connIsolation);
            JdbcUtil.rollback(connHome);
            JdbcUtil.close(connTarget);
            JdbcUtil.close(connSource);
            JdbcUtil.close(connIsolation);
            JdbcUtil.close(connHome);
            JdbcUtil.close(stmt);
            JdbcUtil.close(callableStatement);
            e.printStackTrace();
            //return;
        } catch (NullPointerException e) {
            logger.warn("warn "+"run() - NullPointerException: " + e.getMessage());
            ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", resultcnt, e.getMessage() /*"NullPointerException - CONNECTION INFO"*/);
            if (steptype.equals("EXE_ARCHIVE")) {
                ordersteptableMapper.updateendBySteptype(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", resultcnt, e.getMessage());
            }
            JdbcUtil.rollback(connTarget);
            JdbcUtil.rollback(connSource);
            JdbcUtil.rollback(connIsolation);
            JdbcUtil.rollback(connHome);
            JdbcUtil.close(connTarget);
            JdbcUtil.close(connSource);
            JdbcUtil.close(connIsolation);
            JdbcUtil.close(connHome);
            JdbcUtil.close(stmt);
            JdbcUtil.close(callableStatement);
            e.printStackTrace();
            //return;
        } catch (Exception e) {
            logger.warn("warn "+"run() - Exception: " + e.getMessage() + "     commited count: " + resultcnt);
            ordersteptableMapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", resultcnt, e.getMessage());
            if (steptype.equals("EXE_ARCHIVE")) {
                ordersteptableMapper.updateendBySteptype(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), "Ended not OK", resultcnt, e.getMessage());
            }
            JdbcUtil.rollback(connTarget);
            JdbcUtil.rollback(connSource);
            JdbcUtil.rollback(connIsolation);
            JdbcUtil.rollback(connHome);
            JdbcUtil.close(connTarget);
            JdbcUtil.close(connSource);
            JdbcUtil.close(connIsolation);
            JdbcUtil.close(connHome);
            JdbcUtil.close(stmt);
            JdbcUtil.close(callableStatement);
            e.printStackTrace();
            //return;
        } finally {
            JdbcUtil.commit(connTarget);
            JdbcUtil.commit(connSource);
            JdbcUtil.commit(connIsolation);
            JdbcUtil.commit(connHome);
            JdbcUtil.close(connTarget);
            JdbcUtil.close(connSource);
            JdbcUtil.close(connIsolation);
            JdbcUtil.close(connHome);
            JdbcUtil.close(stmt);
            JdbcUtil.close(callableStatement);
            JdbcUtil.close(rs);

            try {
                Thread.sleep(300);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            orderstepMapper.updateend(piiorderstep.getOrderid(), piiorderstep.getJobid(), piiorderstep.getVersion(), piiorderstep.getStepid());

            if (arc_exe_flag) {
                if (orderstepexe != null) {
                    orderstepMapper.updateend(piiorderstep.getOrderid(), piiorderstep.getJobid(), piiorderstep.getVersion(), orderstepexe.getStepid());
                }
            }

            orderMapper.updateend(piiordersteptable.getOrderid());

            String stepstatus = orderstepMapper.read(piiorderstep.getOrderid(), piiorderstep.getJobid(), piiorderstep.getVersion(), piiorderstep.getStepid()).getStatus();

            //KEYMAP 테이블 THREAD 수만큼 생성
            if (stepstatus.equals("Ended OK") && steptype.equals("GEN_KEYMAP")) {

            }
            if (stepstatus.equals("Ended OK") || stepstatus.equals("Ended not OK")) {
                orderthreadMapper.delete(piiordersteptable.getOrderid());
            }


        }

    }// end of run()
}