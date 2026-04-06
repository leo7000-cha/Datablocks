package datablocks.dlm.controller;

import datablocks.dlm.domain.*;
import datablocks.dlm.jdbc.DmlExecutor;
import datablocks.dlm.mapper.*;
import datablocks.dlm.schedule.StepTableRunnable;
import datablocks.dlm.service.*;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Controller
@RequestMapping("/dlmapi")
@AllArgsConstructor
public class ApiController {
    private static final Logger logger = LoggerFactory.getLogger(ApiController.class);
    private PiiExtractService extractService;
    private PiiRestoreService restoreService;
    private PiiApprovalUserService approvalUserService;
    private PiiApprovalStepReqService approvalStepReqService;
    @Autowired
    private PiiOrderMapper orderMapper ;
    @Autowired
    private PiiOrderStepMapper orderstepMapper ;
    @Autowired
    private PiiOrderStepTableMapper ordersteptableMapper ;
    @Autowired
    private PiiDatabaseMapper databaseMapper ;
    @Autowired
    private PiiOrderThreadMapper orderthreadMapper ;
    @Autowired
    private PiiStepTableMapper stepTableMapper;
    @Autowired
    private PiiTableMapper tableMapper ;
    @Autowired
    private  PiiOrderStepTableUpdateMapper ordersteptableupdateMapper ;
    @Autowired
    private DmlExecutor dlmexe;
    @Autowired
    private MetaTableMapper metaTableMapper;
    @Autowired
    private PiiConfigMapper configMapper ;
    @Autowired
    private LkPiiScrTypeMapper lkPiiScrTypeMapper;
//    @GetMapping(value="/{ssn}", produces = "application/json; charset=UTF-8")
    @ResponseBody
    @RequestMapping(method = RequestMethod.POST, path = "/retore")
    public PiiApiResponseCustidVO retore(@RequestBody PiiApiRequestCustidVO apiRequestVO) {
        LogUtil.log("INFO", " /retore = apiRequestVO: " + apiRequestVO);
        PiiApiResponseCustidVO res = new PiiApiResponseCustidVO();
        String custid = null;
        int ssncnt = 0;
        PiiExtractVO extractVO = null;
        int orderid = 0;
        int processCnt = 5;
        try {
            String reqtype = apiRequestVO.getReqtype().toUpperCase();
            String reqfrom = apiRequestVO.getReqfrom().toUpperCase();
            String valtype = apiRequestVO.getValtype().toUpperCase();
            apiRequestVO.setReqtype(reqtype);
            apiRequestVO.setReqfrom(reqfrom);
            apiRequestVO.setValtype(valtype);

            res.setReqtype(reqtype);
/**************************************************************************************************************************************
 *  1. 대상고객 추출
 *  from cotdl.tbl_piiextract  where SUBSTRING( jobid, 1, 11 ) = 'PII_POLICY3'
 * 		                         and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null
 * ************************************************************************************************************************************/
            Set<String> validValTypes = Set.of("SSN", "CUSTID", "DI", "CI");

            String valtype_tmp = apiRequestVO.getValtype();
            if (valtype_tmp == null || !validValTypes.contains(valtype_tmp.toUpperCase())) {
                res.setExistyn("N");
                res.setStatus("fail");
                res.setMsg("valtype is not correct");
                return res;
            }

            if("SEARCH".equals(reqtype)){
                ssncnt = extractService.getCountBySsnToRestore(apiRequestVO.getVal(), apiRequestVO.getValtype());

                if(ssncnt < 1){
                    res.setExistyn("N");
                    res.setStatus("success");
                    res.setMsg("Not exist on DLM server");
                    return res;
                }else {
                    extractVO = extractService.getBySsnToRestore(apiRequestVO.getVal(), apiRequestVO.getValtype());
                    res.setCustid(extractVO.getCustid());
                    res.setCustname(extractVO.getCust_nm());
                    res.setExistyn("Y");
                    res.setStatus("success");
                    res.setMsg("exist on DLM server");
                    return res;
                }
            }else if("RESTORE".equals(reqtype)){
               // ssncnt = extractService.getCountByCustidToRestore(apiRequestVO.getSsn());
                ssncnt = extractService.getCountBySsnToRestore(apiRequestVO.getVal(), apiRequestVO.getValtype());
                if(ssncnt < 1){
                    res.setExistyn("N");
                    res.setStatus("fail");
                    res.setMsg("Not exist on DLM server");
                    LogUtil.log("INFO", "RESTORE==> "+"Not exist on DLM server  " +apiRequestVO);
                    return res;
                }else {
                    extractVO = extractService.getBySsnToRestore(apiRequestVO.getVal(), apiRequestVO.getValtype());
                }
            }else if("SEARCH&RESTORE".equals(reqtype)){
                ssncnt = extractService.getCountBySsnToRestore(apiRequestVO.getVal(), apiRequestVO.getValtype());
                if(ssncnt < 1){
                    res.setExistyn("N");
                    res.setStatus("success");
                    res.setMsg("Not exist on the server");
                    return res;
                }else {
                    extractVO = extractService.getBySsnToRestore(apiRequestVO.getVal(), apiRequestVO.getValtype());
                }
            }else{ LogUtil.log("INFO", "else==>"+reqtype);
                res.setExistyn("N");
                res.setStatus("fail");
                res.setMsg("reqtype is not correct");
                return res;
            }
            /*---------------------------------------------------------------------------------------
            여기까지 왔으면 복원 진행 시작입니다.
            ---------------------------------------------------------------------------------------*/
            // 동시 요청에 의한 Lock 회피를 위한 랜덤 대기
            try {
                int waitTime = new Random().nextInt(500); // 0~499ms 랜덤 대기
                Thread.sleep(waitTime);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt(); // 인터럽트 플래그 복원
                LogUtil.log("ERROR", "Thread interrupted: " + e.getMessage());
            }

            // 기본 응답값 세팅
            custid = extractVO.getCustid();
            res.setCustid(custid);
            res.setCustname(extractVO.getCust_nm());
            res.setExistyn("Y");
            res.setStatus("success");
            res.setMsg("successfully restored");

            // 요청자 정보
            String requserid = apiRequestVO.getRequserid();
            String requsername = apiRequestVO.getRequsername();
            String reqFrom = apiRequestVO.getReqfrom();
            String aprvlineid;
            String reqreason;

            String custname = extractVO.getCust_nm();

            switch (reqFrom != null ? reqFrom.toUpperCase() : "") {
                case "PLATFORM":
                    aprvlineid = "자동복원결재라인";
                    reqreason = String.format("%s[%s] 비대면 Platform을 통한 고객의 유입으로 자동 복원신청합니다.", custname, custid);
                    if (!StrUtil.checkString(requserid)) requserid = "PLATFORM";
                    if (!StrUtil.checkString(requsername)) requsername = "PLATFORM";
                    processCnt = 8;
                    break;
                case "USER":
                    aprvlineid = "복원결재라인";
                    reqreason = String.format("%s[%s] 고객에 대한 복원신청합니다.", custname, custid);
                    LogUtil.log("INFO", "RESTORE==> "+aprvlineid +"  "+reqreason);
                    break;
                default:
                    aprvlineid = "자동복원결재라인";
                    reqreason = String.format("%s[%s] 고객의 유입으로 자동 복원신청합니다.", custname, custid);
                    break;
            }

            // 승인자 목록 조회 및 복원 프로세스 준비
            String applytype = "RESTORE";
            List<PiiApprovalUserVO> approvalUserList = approvalUserService.getListByAprvlineid(aprvlineid);
            PiiOrderVO piiorder = null;
/**************************************************************************************************************************************
 *  2. tbl_piirestore 테이블 등록, piiapprovalreq 테이블 등록, CORE"의 cotdl.tbl_piiextract 업데이트
 *  restoreService.registerFromPlatform
 *    a. insert into tbl_piirestore using extractVO( orderid, Cust_id, Cust_nm, keymapid.....)
 *    b. approvalreqmapper.insert(piiapprovalreqvo); ==> setApprovalid("RESTORE_APPROVAL");setPhase("FINAL_APPROVAL");
 *    c. updateRestoreCustStatus => "CORE" 의 cotdl.tbl_piiextract  "set exclude_reason = '" + status + "' " + , restore_date= "+ SqlUtil.getCurrentDate(dbVO.getDbtype()) +" " +
 * 				                                                        "where orderid= " + orderid + " and custid= '" + custid + "'" +
 * 				                                                        "and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null";
 * ************************************************************************************************************************************/
            // 복원자동신청 등록 - 모든 단계 step 결재 구현됨 20230212
            logger.warn("INFO "+"before ##11 registerFromPlatform( => extractVO:"+ extractVO.toString());
            PiiApprovalReqVO approvalreqVO = restoreService.registerFromPlatform(extractVO, reqreason, aprvlineid, applytype, approvalUserList.size(), requserid, requsername);
            logger.warn("INFO "+"after ##11 registerFromPlatform( => approvalreqVO:"+approvalreqVO.toString());
            /**************************************************************************************************************************************
             *  3. approvalUserList(단계별 결재자 정보 config)별 결재 처리
             * ************************************************************************************************************************************/
            for(int i=0; i<approvalUserList.size(); i++) {
                PiiApprovalUserVO approvalUserVO = approvalUserList.get(i);
                // 복원자동신청 결재승인
                PiiApprovalStepReqVO piiapprovalstepreq = new PiiApprovalStepReqVO();
                piiapprovalstepreq.setReqid(approvalreqVO.getReqid());
                piiapprovalstepreq.setAprvlineid(approvalUserVO.getAprvlineid());
                piiapprovalstepreq.setSeq(approvalUserVO.getSeq());
                piiapprovalstepreq.setStepname("");
                piiapprovalstepreq.setStatus("APPROVED");
                piiapprovalstepreq.setApproverid(approvalUserVO.getApproverid());
                piiapprovalstepreq.setApprovername(approvalUserVO.getApprovername());
                piiapprovalstepreq.setRegdate("now()");
                piiapprovalstepreq.setComment("");
                approvalStepReqService.register(piiapprovalstepreq);
            }

            /** 실제 복원 JOB을 Order하고  restore 상태를 "APPROVED_RESTORE"로 변경  tbl_piiextract의 상태 복원으로 변경 CORE, DLM 변경 */
            /**************************************************************************************************************************************
             *  4. restoreService.approve(approvalreqVO) => update cotdl.tbl_piirestore  set phase= 'APPROVED', status= 'ORDERED'
             * ************************************************************************************************************************************/
            if (restoreService.approve(approvalreqVO)) {
                PiiRestoreVO piirestore = restoreService.get(StrUtil.parseInt(approvalreqVO.getJobid()));
                try {
                    /**************************************************************************************************************************************
                     *  5. restoreService.orderRestoreJob(piirestore, reqFrom) => 복원 Job의 Order 데이터를 모두 생성함
                     * ************************************************************************************************************************************/
                    piiorder = restoreService.orderRestoreJob(piirestore, reqFrom);
                    /**************************************************************************************************************************************
                     *  6. CORE, DLM 의 cotdl.tbl_piiextract의 상태 APPROVED_RESTORE 으로 변경
                     * ************************************************************************************************************************************/
                    restoreService.updateRestoreCustStatus(piirestore.getOld_orderid(), piirestore.getCustid(), "APPROVED_RESTORE");
                } catch (Exception e) {
                    logger.warn("warn "+"/RESTORE_APPROVAL = fail " + approvalreqVO + " - " + piirestore.toString() + " - " + e.getMessage().toString());
                    res.setStatus("fail");
                    res.setMsg("fail to order the applicaton of restoration");
                    e.printStackTrace();
                    return res;
                }
            } else {
                logger.warn("warn "+"/RESTORE_APPROVAL = fail " + approvalreqVO);
                res.setStatus("fail");
                res.setMsg("fail to approve the applicaton of restoration");
                return res;
            }
            LogUtil.log("INFO", "apiRequestVO.getReqfrom(): " + apiRequestVO.getReqfrom());

            /**************************************************************************************************************************************
             *  7. PLATFORM 에서 유입되는 경우만 복원 order를 즉시 수행함  그 외는 MAX CNT 기준  Scheduler의 runOrder로 자동 수행
             * ************************************************************************************************************************************/
            if(!"PLATFORM".equalsIgnoreCase(apiRequestVO.getReqfrom())){
                return res;
            }

            LogUtil.log("INFO", "imediately execute: " + apiRequestVO.getReqfrom());
            orderid = piiorder.getOrderid();
            if (orderthreadMapper.getListCnt(orderid, piiorder.getJobid(), piiorder.getVersion()) > 0) return res;
            if (piiorder.getStatus().equals("Ended OK")) return res;
            boolean stopflag = false;
            String steptype = "";
            String stepid = "";

            List<PiiOrderStepTableVO> ordersteptablelist;

            /** status= 'Running', realstarttime= NOW() */
            orderMapper.updatebefore(orderid);
            List<PiiOrderStepVO> ordersteplist = orderstepMapper.getRunnableOrderStepList(orderid);
            for (PiiOrderStepVO piiorderstep : ordersteplist) {
                LogUtil.log("INFO", "@@@ 1 (PiiOrderStepVO piiorderstep : ordersteplist)  " + piiorderstep.toString());
                orderstepMapper.updateend(piiorderstep.getOrderid(), piiorderstep.getJobid(), piiorderstep.getVersion(), piiorderstep.getStepid());
                if (orderthreadMapper.getListCnt(orderid, piiorder.getJobid(), piiorder.getVersion()) > 0) continue;
                if (piiorderstep.getStatus().equals("Ended OK")) continue;

                // 처리계 고객원장의 접근 통제 상태로...미리 RESTORE 상태를 만듬
                if(stepTableMapper.readEtcCnt("RESTORE_CUSTID","EXE_FINISH") == 1) {

                    PiiStepTableVO stepTableETCVO = stepTableMapper.readEtc("RESTORE_CUSTID", "EXE_FINISH");
                    PiiDatabaseVO dbVO = databaseMapper.read(stepTableETCVO.getDb()); // 해당 db가 core가 아닐수도 있으니 이게 정확한 방법임 20230509 //databaseMapper.readBySystem("CORE");
                    String strQuery = stepTableETCVO.getSqlstr() + " ('" + custid + "')";
                    try {
                        dlmexe.exeQuery(dbVO, strQuery);LogUtil.log("INFO", "처리계 고객원장의 접근 통제 상태 푸는 부분 - strQuery: " +strQuery);
                    } catch (Exception e) {
                        logger.warn("warn "+"처리계 고객원장의 접근 통제 상태로...미리 RESTORE 상태를 만듬 - Exception: " + e.getMessage());
                        res.setStatus("fail");
                        res.setMsg("fail to update status of customer's master table on core system");
                        return res;
                    }
                }

                //----------------------------------------------------------------------------
                int threadcnt;
                steptype = piiorderstep.getSteptype();
                stepid = piiorderstep.getStepid();
                String steptableorderby = "ASC";

                ordersteptablelist = ordersteptableMapper.getStepTableListasc(piiorderstep.getOrderid(), piiorderstep.getStepid());
                threadcnt = Integer.parseInt(piiorderstep.getThreadcnt());

                orderstepMapper.updatebefore(piiorderstep.getOrderid(), piiorderstep.getJobid(), piiorderstep.getVersion(), piiorderstep.getStepid());

                /* Thread Pool을 Fix한다. */
                ExecutorService executorService = Executors.newFixedThreadPool(threadcnt);
                int exeno = 1;

                for (PiiOrderStepTableVO piiordersteptable : ordersteptablelist) {
                    LogUtil.log("INFO", "@@@ 2 (PiiOrderStepTableVO piiordersteptable : ordersteptablelist)  " + piiordersteptable.toString());
                    //############## Table execution part ####################################################################################################
                    AES256Util aes = new AES256Util();
                    StepTableRunnable tableex = new StepTableRunnable(threadcnt, exeno++, piiorderstep, piiordersteptable, aes, steptableorderby
                            , dlmexe, ordersteptableMapper, orderstepMapper
                            , databaseMapper, tableMapper, orderMapper
                            , orderthreadMapper, ordersteptableupdateMapper
                            , configMapper, metaTableMapper, lkPiiScrTypeMapper
                    );
                    executorService.submit(tableex);
                }
                executorService.shutdown();
                break;

            }//end of for(PiiOrderStepVO piiorderstep : ordersteplist) {

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        }catch (Exception exception){
            logger.warn("warn "+"Exception=>"+exception.getMessage());
            exception.printStackTrace();
            res.setExistyn("N");
            res.setStatus("fail");
            res.setMsg("Exception occurred =>"+exception.getMessage());
        }

        boolean stopped = false;
        while (!stopped) {
            try {
                Thread.sleep(600);//4초간 멈춤
            } catch (Exception e) {
                e.printStackTrace();
            }
            // 복원완료 상태로 회신을 위해 10개 테이블 완료 상태체크
            int waitcnt = ordersteptableMapper.getRestoreTableNotCompleteCount(orderid);
            if (waitcnt == 0) {
                stopped = true;
//                logger.warn("warn "+"while(!stopped) check pre condition  stopped = true "+" orderid= "+ orderid+" waitcnt= "+ waitcnt);
            }
//            LogUtil.log("INFO", "while(!stopped) check pre condition  waitcnt :  "+"  "+ waitcnt);
        }

        return res;
    }

    @GetMapping("/without")
    public String withoutType() {
        return "{\"name\":\"wonyoung\"}";
    }

    @GetMapping(value ="/with", produces = "application/json; charset=UTF-8")
    public String withType() { //Content-Type에 대한 정의를 추가.
        return "{\"name\":\"wonyoung\"}";
    }
}
