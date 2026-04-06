package datablocks.dlm.schedule;

import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.*;
// ... 필요한 다른 Mapper와 서비스들을 import ...
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.SqlUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Component
public class TestDataDisposalScheduler {

    // 필요한 Mapper나 Service들을 주입받습니다.
    private final PiiOrderMapper orderMapper;
    private final PiiOrderStepMapper orderStepMapper;
    private final PiiOrderStepTableMapper orderStepTableMapper;
    private final TestDataMapper testDataMapper;
    private final PiiConfigMapper configMapper;


    /**
     * 매일 실행되어 파기 예정일이 도래한 테스트 데이터를 찾아 파기 Order를 생성합니다.
     */
    @Scheduled(cron = "01 01 01 * * *") // 매일 오전 1시 1분 1초 에 실행
    @Transactional
    public void orderTestDataDisposalJob() {
        LogUtil.log("INFO", "자동 생성 테스트 데이터 파기 오더 생성을 시작합니다.");
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");
        String basedate = sdf.format(new Date());

        // 1. 오늘 날짜를 기준으로 파기 대상 목록 전체를 조회
        List<TestDataVO> disposalTargets = testDataMapper.getDisposalList(basedate);
        LogUtil.log("WARN", "테스트데이터 파기 시작..."+disposalTargets.size());
        if (disposalTargets.isEmpty()) {
            LogUtil.log("INFO", "파기 대상 테스트 데이터가 없습니다. 작업을 종료합니다.");
            return;
        }

        for (TestDataVO target : disposalTargets) {
            try {
                createDisposalOrderFor(target.getTestdataid());
            } catch (Exception e) {
                LogUtil.log("WARN", "Target [" + target.getTestdataid() + "]의 Step 생성 중 오류 발생: " + e.getMessage());
                // 이 target에서 오류가 나도 다음 target은 계속 진행
            }
        }

        LogUtil.log("INFO", "자동 생성 테스트 데이터 파기 오더 생성을 완료했습니다.");
    }

    public void createDisposalOrderFor(int testdataid) {
        LogUtil.log("INFO", "createDisposalOrderFor==="+ testdataid);
        TestDataVO target = testDataMapper.read(testdataid);
        // 2. (핵심) 조회 결과가 null인지 반드시 확인
        if (target == null) {
            // null이면, 명확한 오류 메시지와 함께 예외를 발생시켜 작업을 중단
            logger.warn("파기 오더를 생성하려 했으나, testdataid [{}]에 해당하는 데이터를 찾을 수 없습니다.", testdataid);
            throw new IllegalArgumentException("ID [" + testdataid + "]에 해당하는 파기 대상을 찾을 수 없습니다.");
        }
        List<PiiOrderStepTableVO> orderStepTableVOList = orderStepTableMapper.getStepTableList(target.getNew_orderid(), "EXE_TRANSFORM");
        PiiOrderVO piiorder = new PiiOrderVO();
        PiiOrderStepVO piiorderstep = new PiiOrderStepVO();

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");
        String basedate = sdf.format(new Date());

        int newOrderId = orderMapper.getMaxOrderid() + 1;
        try {
            String currentOrderIdValue = configMapper.read("DLM_CURRENT_ORDERID").getValue();
            int maxOrderId = Integer.parseInt(currentOrderIdValue) + 1;
            newOrderId = Math.max(newOrderId, maxOrderId);
        } catch (NullPointerException ex) {
            logger.warn("DLM_CURRENT_ORDERID is not defined in config tables. Using default order ID: " + newOrderId);
        } finally {
            configMapper.updateVal("DLM_CURRENT_ORDERID", String.valueOf(newOrderId));
        }
        LogUtil.log("INFO", "basedate"+basedate);
        String jobid = "TESTDATA_PURGE:"+target.getTestdataid();
        /**
         * PiiOrderVO 생성 및 insert
         * */
        piiorder.setOrderid(newOrderId);
        piiorder.setBasedate(basedate);
        piiorder.setRuncnt(0);
        piiorder.setJobid(jobid);
        piiorder.setVersion("1");
        piiorder.setJobname(jobid);
        piiorder.setSystem("CORE");
//        piiorder.setPolicy_id();
//        piiorder.setKeymap_id();
        piiorder.setJobtype("BATCH");
        piiorder.setRuntype("DLM_BATCH");
        piiorder.setCalendar("ALLDAYS");
        piiorder.setTime("00:03");
        piiorder.setStatus("Wait condition");
        piiorder.setConfirmflag("N");
        piiorder.setHoldflag("N");
        piiorder.setForceokflag("N");
        piiorder.setKillflag("N");
        piiorder.setEststarttime(basedate + " " + "00:01");
        piiorder.setRunningtime(" ");
        piiorder.setRealstarttime(" ");
        piiorder.setRealendtime(" ");
        piiorder.setJob_owner_id1("system");
        piiorder.setJob_owner_name1("system");
//        piiorder.setJob_owner_id2("system");
//        piiorder.setJob_owner_name2("system");
//        piiorder.setJob_owner_id3("system");
//        piiorder.setJob_owner_name3("system");
//        piiorder.setOrderdate(" ");
        piiorder.setOrderuserid("system");
        orderMapper.insert(piiorder);
        /**
         * PiiOrderStepVO 생성 및 insert
         * */
        String stepid = "PURGE_STEP:" + target.getTestdataid(); // Step을 식별할 고유 ID
        String stepname = "파기 대상: " + target.getTestdataid();
        String steptype = "EXE_FINISH";
        piiorderstep.setOrderid(newOrderId);
        piiorderstep.setStatus("Wait condition");
        piiorderstep.setConfirmflag("N");
        piiorderstep.setHoldflag("N");
        piiorderstep.setForceokflag("N");
        piiorderstep.setKillflag("N");
        piiorderstep.setBasedate(basedate);
        piiorderstep.setThreadcnt("10");
        piiorderstep.setCommitcnt("3000");
        piiorderstep.setRuncnt("0");
        piiorderstep.setJobid(jobid);
        piiorderstep.setVersion("1");
        piiorderstep.setStepid(stepid);
        piiorderstep.setStepname(stepname);
        piiorderstep.setSteptype(steptype);
        piiorderstep.setStepseq("1");
        piiorderstep.setDb(target.getTargetdb());
        piiorderstep.setTotaltabcnt("0");
        piiorderstep.setSuccesstabcnt("0");
//        	piiorderstep.setRunningtime(" ");
//        	piiorderstep.setRealstarttime(" ");
//        	piiorderstep.setRealendtime(" ");
//        piiorderstep.setOrderuserid(null);
        orderStepMapper.insert(piiorderstep);
        /**
         * PiiOrderStepTableVO 생성 및 insert
         * */
        String TargetDb = null; // 변수 초기화

        // 리스트가 null이 아니고 비어있지 않은지 반드시 확인!
        if (orderStepTableVOList != null && !orderStepTableVOList.isEmpty()) {
            // 첫 번째 객체에서 값을 한 번만 할당합니다.
            TargetDb = orderStepTableVOList.get(0).getDb();
        }
        for (PiiOrderStepTableVO piiordersteptable : orderStepTableVOList) {
            piiordersteptable.setOrderid(newOrderId);
            piiordersteptable.setStatus("Wait condition");
            piiordersteptable.setForceokflag("N");
            piiordersteptable.setBasedate(basedate);
            piiordersteptable.setJobid(jobid);
            piiordersteptable.setVersion("1");
            piiordersteptable.setStepid(stepid);
            piiordersteptable.setStepname(stepname);
            piiordersteptable.setSteptype(steptype);
            piiordersteptable.setStepseq("1");
//            piiordersteptable.setDb(piiordersteptable.getDb());
//            piiordersteptable.setOwner(piiordersteptable.getOwner());
//            piiordersteptable.setTable_name(piiordersteptable.getTable_name());
            piiordersteptable.setPagitype(null);
            piiordersteptable.setPagitypedetail(null);
            piiordersteptable.setExetype("FINISH");
            piiordersteptable.setArchiveflag(null);
            piiordersteptable.setPreceding(null);
            piiordersteptable.setSuccedding(null);
//            piiordersteptable.setSeq1(piiordersteptable.getSeq1());
//            piiordersteptable.setSeq2(piiordersteptable.getSeq2());
//            piiordersteptable.setSeq3(piiordersteptable.getSeq3());
            piiordersteptable.setPipeline(null);
            piiordersteptable.setPk_col(null);
            piiordersteptable.setWhere_col(null);
            piiordersteptable.setWhere_key_name(null);
            piiordersteptable.setParallelcnt(null);
            piiordersteptable.setCommitcnt("3000");

            //logger.warn("createDisposalOrderFor===55"+ piiordersteptable.getOwner() +" "+ piiordersteptable.getTable_name() +" "+ piiordersteptable.getWherestr());
            piiordersteptable.setSqlstr(SqlUtil.genTestdataDeleteQuery(piiordersteptable.getOwner(), piiordersteptable.getTable_name(), piiordersteptable.getWherestr()));
            piiordersteptable.setWherestr(null);
            piiordersteptable.setExecnt("0");

//            piiordersteptable.setHintselect(piiordersteptable.getHintselect());
//            piiordersteptable.setHintinsert(piiordersteptable.getHintinsert());
//            piiordersteptable.setUval1(piiordersteptable.getUval1());
//            piiordersteptable.setUval2(piiordersteptable.getUval2());
//            piiordersteptable.setUval3(piiordersteptable.getUval3());
//            piiordersteptable.setUval4(piiordersteptable.getUval4());
//            piiordersteptable.setUval5(piiordersteptable.getUval5());
            orderStepTableMapper.insert(piiordersteptable);
        }


        /**  EXE_FINISH
         * PiiOrderStepVO 생성 및 insert
         * */
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
        piiorderstep.setJobid(jobid);
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

        PiiOrderStepTableVO piiordersteptable = new PiiOrderStepTableVO();
        piiordersteptable.setOrderid(newOrderId);
        piiordersteptable.setStatus("Wait condition");
        piiordersteptable.setForceokflag("N");
        piiordersteptable.setBasedate(basedate);
        piiordersteptable.setJobid(jobid);
        piiordersteptable.setVersion("1");
        piiordersteptable.setStepid("EXE_FINISH");
        piiordersteptable.setStepname("EXE_FINISH");
        piiordersteptable.setSteptype("EXE_FINISH");
        piiordersteptable.setStepseq("2");
        piiordersteptable.setDb("DLM");
        piiordersteptable.setOwner("COTDL");
        piiordersteptable.setTable_name("TBL_TESTDATA");
        piiordersteptable.setPagitype(null);
        piiordersteptable.setPagitypedetail(null);
        piiordersteptable.setExetype("FINISH");
        piiordersteptable.setArchiveflag(null);
        piiordersteptable.setPreceding(null);
        piiordersteptable.setSuccedding(null);
        piiordersteptable.setSeq1(10);
        piiordersteptable.setSeq2(100);
        piiordersteptable.setSeq3(10);
        piiordersteptable.setPipeline(null);
        piiordersteptable.setWhere_col(null);
        piiordersteptable.setWhere_key_name(null);
        piiordersteptable.setParallelcnt(null);
        piiordersteptable.setCommitcnt("3000");
        piiordersteptable.setWherestr(null);
        piiordersteptable.setSqlstr("update cotdl.tbl_testdata\n" +
                "\t\tset\n" +
                "\t\t\tstatus = 'DISPOSED',\n" +
                "\t\t\tdisposal_status = 'Y',\n" +
                "\t\t\tdisposal_exec_date = NOW()\n" +
                "\t\twhere testdataid= "+target.getTestdataid());
        orderStepTableMapper.insert(piiordersteptable);

        piiordersteptable.setOrderid(newOrderId);
        piiordersteptable.setStatus("Wait condition");
        piiordersteptable.setForceokflag("N");
        piiordersteptable.setBasedate(basedate);
        piiordersteptable.setJobid(jobid);
        piiordersteptable.setVersion("1");
        piiordersteptable.setStepid("EXE_FINISH");
        piiordersteptable.setStepname("EXE_FINISH");
        piiordersteptable.setSteptype("EXE_FINISH");
        piiordersteptable.setStepseq("2");
        piiordersteptable.setDb("DLM");
        piiordersteptable.setOwner("COTDL");
        piiordersteptable.setTable_name("TBL_PIIMASTERKEYMAP");
        piiordersteptable.setPagitype(null);
        piiordersteptable.setPagitypedetail(null);
        piiordersteptable.setExetype("FINISH");
        piiordersteptable.setArchiveflag(null);
        piiordersteptable.setPreceding(null);
        piiordersteptable.setSuccedding(null);
        piiordersteptable.setSeq1(10);
        piiordersteptable.setSeq2(200);
        piiordersteptable.setSeq3(10);
        piiordersteptable.setPipeline(null);
        piiordersteptable.setWhere_col(null);
        piiordersteptable.setWhere_key_name(null);
        piiordersteptable.setParallelcnt(null);
        piiordersteptable.setCommitcnt("3000");
        piiordersteptable.setWherestr(null);
        piiordersteptable.setSqlstr("delete from cotdl.tbl_piimasterkeymap where orderid = "+target.getNew_orderid());
        orderStepTableMapper.insert(piiordersteptable);


        piiordersteptable.setDb(TargetDb);
        piiordersteptable.setSeq2(300);
        orderStepTableMapper.insert(piiordersteptable);

        /** 파기 신청 상태로 업데이트*/
        target.setStatus("DISPOSING");
        testDataMapper.update(target);
    }
}
