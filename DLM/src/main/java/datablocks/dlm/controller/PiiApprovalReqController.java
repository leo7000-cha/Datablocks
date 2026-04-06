package datablocks.dlm.controller;

import datablocks.dlm.domain.*;

import datablocks.dlm.service.*;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

@Controller
@RequestMapping("/piiapprovalreq/*")
@AllArgsConstructor
public class PiiApprovalReqController {
    private static final Logger logger = LoggerFactory.getLogger(PiiApprovalReqController.class);
    private PiiApprovalReqService service;

    private PiiApprovalUserService approvalUserSV;
    private PiiApprovalStepService approvalStepSV;
    private PiiApprovalStepReqService approvalStepReqSV;
    private PiiJobService jobservice;
    private PiiPolicyService policyservice;
    private TestDataService testDataService;
    private PiiRestoreService restoreSV;
    private PiiExtractService extractService;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register() {

    }

    @GetMapping({"/list"})
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model, HttpServletRequest request) {
        //if(request.isUserInRole("ROLE_ADMIN"))
        cri.setSearch2(request.getRemoteUser()); // setting approver

        LogUtil.log("INFO", "/piiapprovalreq list(Criteria cri, Model model, HttpServletRequest request): " + request.getRemoteUser() +" " +cri);
        //model.addAttribute("list", service.getList());
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        //LogUtil.log("INFO", "/piiapprovalreq service.getList(cri): " + service.getList(cri).toString());
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/piiapprovalreq total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piiapprovalreq pageMaker: " + pageMaker);
    }

    @GetMapping({"/myrequestlist"})
    @PreAuthorize("isAuthenticated()")
    public void myrequestlist(Criteria cri, Model model, HttpServletRequest request) {
        //if(request.isUserInRole("ROLE_ADMIN"))
        LogUtil.log("INFO", "/piiapprovalreq myrequestlist 1(Criteria cri, Model model, HttpServletRequest request): " + request.getRemoteUser() +" " + cri);
        if(StrUtil.checkString(cri.getSearch1())) {
            cri.setSearch1(request.getRemoteUser());// setting requestor
        }
        //LogUtil.log("INFO", "/piiapprovalreq myrequestlist 2(Criteria cri, Model model, HttpServletRequest request): " + request.getRemoteUser() +" " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/piiapprovalreq total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piiapprovalreq pageMaker: " + pageMaker);
    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(PiiApprovalReqVO piiapprovalreq, RedirectAttributes rttr) {

        LogUtil.log("INFO", "register: " + piiapprovalreq);

        service.register(piiapprovalreq);

        rttr.addFlashAttribute("result", "success");

        return "redirect:/piiapprovalreq/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("reqid") String reqid, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piiapprovalreq @GetMapping  /get or modify = "+reqid);
        PiiApprovalReqVO approvalReqVO = service.get(reqid);
        model.addAttribute("piiapprovalreq", approvalReqVO);
        //model.addAttribute("approvallinelist", approvalLineService.getListbyApprovalid(approvalReqVO.getApprovalid()));
        //model.addAttribute("approvaluserlist", approvalUserService.getListbyApprovalline(approvalReqVO.getApprovalid()));

        model.addAttribute("cri", cri);
        //logger.info(cri.toString());
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiApprovalReqVO piiapprovalreq, Criteria cri, RedirectAttributes rttr) {
        //LogUtil.log("INFO", "@PostMapping modify:" + piiapprovalreq);

        if (service.modify(piiapprovalreq)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        return "redirect:/piiapprovalreq/list";
    }

    @PostMapping("/approve")
    @PreAuthorize("isAuthenticated()")
    public String approve(@RequestBody List<PiiApprovalReqVO> applist, Criteria cri, RedirectAttributes rttr, Authentication authentication) {
        logger.info("info "+"/approve  " + applist.size());
        String rst = "redirect:/piiapprovalreq/list";
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
//        private PiiApprovalReqService service;
//        private PiiApprovalLineService approvalLineSV;
//        private PiiApprovalUserService approvalUserSV;
//        private PiiApprovalStepService approvalStepSV;
//        private PiiApprovalStepReqService approvalStepReqSV;

        for (PiiApprovalReqVO approvalreqVO : applist) {
            PiiApprovalUserVO userVO = approvalUserSV.get(approvalreqVO.getAprvlineid(), approvalreqVO.getSeq());
            logger.info("info "+"userVO  " + userVO.toString());
            String approver = userVO.getApproverid();
            if (approvalreqVO.getApprovalid().equals("JOB_APPROVAL")) {
                if (approver.equalsIgnoreCase(userDetails.getUsername())) {
                    // 1.TBL_PIIAPPROVALSTEPREQ insert
                    PiiApprovalStepReqVO piiapprovalstepreq = new PiiApprovalStepReqVO();
                    piiapprovalstepreq.setReqid(approvalreqVO.getReqid());
                    piiapprovalstepreq.setAprvlineid(approvalreqVO.getAprvlineid());
                    piiapprovalstepreq.setSeq(approvalreqVO.getSeq());
                    piiapprovalstepreq.setStepname("");
                    piiapprovalstepreq.setStatus("APPROVED");
                    piiapprovalstepreq.setApproverid(userVO.getApproverid());
                    piiapprovalstepreq.setApprovername(userVO.getApprovername());
                    piiapprovalstepreq.setRegdate("now()");
                    piiapprovalstepreq.setComment("");
                    approvalStepReqSV.register(piiapprovalstepreq);

                    //2.
                    if(approvalStepSV.getNextStepCount(approvalreqVO.getAprvlineid(), approvalreqVO.getSeq()) > 0){ // 다음 단계 seq 세팅
                        approvalreqVO.setSeq((Integer.parseInt(approvalreqVO.getSeq()) + 1)+"");
                        approvalreqVO.setPhase("APPLY");
                        service.modify(approvalreqVO);
                        rttr.addFlashAttribute("result", "success");
                    }
                    else{ // 최종단계 이므로 phase  업데이트
                        approvalreqVO.setPhase("FINAL_APPROVAL");
                        service.modify(approvalreqVO);
                        // JOB , STEP 상태 변경
                        if (jobservice.approve(approvalreqVO)) { // job update
                            rttr.addFlashAttribute("result", "success");
                            LogUtil.log("INFO", "/JOB_APPROVAL = success  " + approvalreqVO.toString());
                        } else {
                            logger.warn("warn "+"/JOB_APPROVAL = fail " + approvalreqVO);
                            rst = "/JOB_APPROVAL = fail " + approvalreqVO;
                            break;
                        }
                    }


                }
                else {
                    logger.warn("warn "+"getApproverid != getUsername " +  approver + "  " + userDetails.getUsername());
                }
            }
            else if (approvalreqVO.getApprovalid().equals("POLICY_APPROVAL")) {

                if (approver.equalsIgnoreCase(userDetails.getUsername())) {
                    // 1.TBL_PIIAPPROVALSTEPREQ insert
                    PiiApprovalStepReqVO piiapprovalstepreq = new PiiApprovalStepReqVO();
                    piiapprovalstepreq.setReqid(approvalreqVO.getReqid());
                    piiapprovalstepreq.setAprvlineid(approvalreqVO.getAprvlineid());
                    piiapprovalstepreq.setSeq(approvalreqVO.getSeq());
                    piiapprovalstepreq.setStepname("");
                    piiapprovalstepreq.setStatus("APPROVED");
                    piiapprovalstepreq.setApproverid(userVO.getApproverid());
                    piiapprovalstepreq.setApprovername(userVO.getApprovername());
                    piiapprovalstepreq.setRegdate("now()");
                    piiapprovalstepreq.setComment("");
                    approvalStepReqSV.register(piiapprovalstepreq);

                    //2.
                    if(approvalStepSV.getNextStepCount(approvalreqVO.getAprvlineid(), approvalreqVO.getSeq()) > 0){ // 다음 단계 seq 세팅
                        approvalreqVO.setSeq((Integer.parseInt(approvalreqVO.getSeq()) + 1)+"");
                        approvalreqVO.setPhase("APPLY");
                        service.modify(approvalreqVO);
                        rttr.addFlashAttribute("result", "success");
                    }
                    else{ // 최종단계 이므로 phase  업데이트
                        approvalreqVO.setPhase("FINAL_APPROVAL");
                        service.modify(approvalreqVO);
                        // JOB , STEP 상태 변경
                        if (policyservice.approve(approvalreqVO)) { // job update
                            rttr.addFlashAttribute("result", "success");
//                            LogUtil.log("INFO", "/POLICY_APPROVAL = success  " + approvalreqVO.toString());
                        } else {
//                            logger.warn("warn "+"/POLICY_APPROVAL = fail " + approvalreqVO);
                            rst = "/POLICY_APPROVAL = fail " + approvalreqVO;
                            break;
                        }
                    }

                }
                else {
                    logger.warn("warn "+"getApproverid != getUsername " +  approver + "  " + userDetails.getUsername());
                }
            }
            else if (approvalreqVO.getApprovalid().equals("REALDOC_APPROVAL") ) {

                if (approver.equalsIgnoreCase(userDetails.getUsername())) {
                    // 1.TBL_PIIAPPROVALSTEPREQ insert
                    PiiApprovalStepReqVO piiapprovalstepreq = new PiiApprovalStepReqVO();
                    piiapprovalstepreq.setReqid(approvalreqVO.getReqid());
                    piiapprovalstepreq.setAprvlineid(approvalreqVO.getAprvlineid());
                    piiapprovalstepreq.setSeq(approvalreqVO.getSeq());
                    piiapprovalstepreq.setStepname("");
                    piiapprovalstepreq.setStatus("APPROVED");
                    piiapprovalstepreq.setApproverid(userVO.getApproverid());
                    piiapprovalstepreq.setApprovername(userVO.getApprovername());
                    piiapprovalstepreq.setRegdate("now()");
                    piiapprovalstepreq.setComment("");
                    approvalStepReqSV.register(piiapprovalstepreq);

                    //2.
                    if(approvalStepSV.getNextStepCount(approvalreqVO.getAprvlineid(), approvalreqVO.getSeq()) > 0){ // 다음 단계 seq 세팅
                        approvalreqVO.setSeq((Integer.parseInt(approvalreqVO.getSeq()) + 1)+"");
                        approvalreqVO.setPhase("APPLY");
                        service.modify(approvalreqVO);
                    }
                    else{ // 최종단계 이므로 phase  업데이트
                        approvalreqVO.setPhase("FINAL_APPROVAL");
                        service.modify(approvalreqVO);
                     }
                    rttr.addFlashAttribute("result", "success");
                } else {
                    logger.warn("warn "+"getApproverid != getUsername " +  approver + "  " + userDetails.getUsername());
                }
            }
            else if (approvalreqVO.getApprovalid().equals("RESTORE_APPROVAL")) {
                if (approver.equalsIgnoreCase(userDetails.getUsername())) {
                    // 1.TBL_PIIAPPROVALSTEPREQ insert
                    PiiApprovalStepReqVO piiapprovalstepreq = new PiiApprovalStepReqVO();
                    piiapprovalstepreq.setReqid(approvalreqVO.getReqid());
                    piiapprovalstepreq.setAprvlineid(approvalreqVO.getAprvlineid());
                    piiapprovalstepreq.setSeq(approvalreqVO.getSeq());
                    piiapprovalstepreq.setStepname("");
                    piiapprovalstepreq.setStatus("APPROVED");
                    piiapprovalstepreq.setApproverid(userVO.getApproverid());
                    piiapprovalstepreq.setApprovername(userVO.getApprovername());
                    piiapprovalstepreq.setRegdate("now()");
                    piiapprovalstepreq.setComment("");
                    approvalStepReqSV.register(piiapprovalstepreq);
                    //2.
                    if(approvalStepSV.getNextStepCount(approvalreqVO.getAprvlineid(), approvalreqVO.getSeq()) > 0){ // 다음 단계 seq 세팅
                        approvalreqVO.setSeq((Integer.parseInt(approvalreqVO.getSeq()) + 1)+"");
                        approvalreqVO.setPhase("APPLY");
                        service.modify(approvalreqVO);
                        rttr.addFlashAttribute("result", "success");
                    }
                    else{ // 최종단계 이므로 phase  업데이트
                        approvalreqVO.setPhase("FINAL_APPROVAL");
                        service.modify(approvalreqVO);
                        // restore 상태 변경
                        if (restoreSV.approve(approvalreqVO)) { // job update
                            rttr.addFlashAttribute("result", "success");
                            PiiRestoreVO piirestore = restoreSV.get(StrUtil.parseInt(approvalreqVO.getJobid()));
                            if("RESTORE".equalsIgnoreCase(extractService.getByCustidOrderid(piirestore.getCustid(),piirestore.getOld_orderid()).getExclude_reason())) {

                            }else{
                                try {
                                    logger.warn("info "+"## 1. restoreSV.orderRestoreJob(piirestore, 'USER') " + piirestore.toString());
                                    restoreSV.orderRestoreJob(piirestore, "USER");

                                    logger.warn("info "+"## 2. restoreSV.updateRestoreCustStatus(piirestore.getOld_orderid(), piirestore.getCustid(), 'APPROVED_RESTORE') " + piirestore.getOld_orderid() +" "+ piirestore.getCustid());
                                    //CORE, DLM 의 cotdl.tbl_piiextract의 상태 APPROVED_RESTORE 으로 변경
                                    restoreSV.updateRestoreCustStatus(piirestore.getOld_orderid(), piirestore.getCustid(), "APPROVED_RESTORE");
                                } catch (Exception e) {
                                    logger.warn("warn "+"/RESTORE_APPROVAL = fail to order " + approvalreqVO.toString() + " " + piirestore.toString()+" "+e.getMessage());
                                    rst = "/RESTORE_APPROVAL = fail to order" + approvalreqVO + " " + e.getMessage();
                                    e.printStackTrace();
                                    break;
                                }
                            }
                        } else {
                            rst = "/RESTORE_APPROVAL = fail " + approvalreqVO;
                        }
                    }

                } else {
                    logger.warn("warn "+"getApproverid != getUsername " +  approver + "  " + userDetails.getUsername());
                }
            }
            else if (approvalreqVO.getApprovalid().equals("BROWSE_APPROVAL")) {
                if (approver.equalsIgnoreCase(userDetails.getUsername())) {

                } else {
                    logger.warn("warn "+"getApproverid != getUsername " + approver + "  " + userDetails.getUsername());
                }

                if (approver.equalsIgnoreCase(userDetails.getUsername())) {
                    // 1.TBL_PIIAPPROVALSTEPREQ insert
                    PiiApprovalStepReqVO piiapprovalstepreq = new PiiApprovalStepReqVO();
                    piiapprovalstepreq.setReqid(approvalreqVO.getReqid());
                    piiapprovalstepreq.setAprvlineid(approvalreqVO.getAprvlineid());
                    piiapprovalstepreq.setSeq(approvalreqVO.getSeq());
                    piiapprovalstepreq.setStepname("");
                    piiapprovalstepreq.setStatus("APPROVED");
                    piiapprovalstepreq.setApproverid(userVO.getApproverid());
                    piiapprovalstepreq.setApprovername(userVO.getApprovername());
                    piiapprovalstepreq.setRegdate("now()");
                    piiapprovalstepreq.setComment("");
                    approvalStepReqSV.register(piiapprovalstepreq);

                    //2.
                    if(approvalStepSV.getNextStepCount(approvalreqVO.getAprvlineid(), approvalreqVO.getSeq()) > 0){ // 다음 단계 seq 세팅
                        approvalreqVO.setSeq((Integer.parseInt(approvalreqVO.getSeq()) + 1)+"");
                        approvalreqVO.setPhase("APPLY");
                        service.modify(approvalreqVO);
                        rttr.addFlashAttribute("result", "success");
                    }
                    else{ // 최종단계 이므로 phase  업데이트
                        approvalreqVO.setPhase("FINAL_APPROVAL");
                        service.modify(approvalreqVO);
                        // BROWSE 상태 변경
                        if (restoreSV.approve(approvalreqVO)) { // job update
                            rttr.addFlashAttribute("result", "success");
                            LogUtil.log("INFO", "/BROWSE_APPROVAL = success  " + approvalreqVO.toString());

                            PiiRestoreVO piirestore = restoreSV.get(StrUtil.parseInt(approvalreqVO.getJobid()));
                            piirestore.setStatus("APPROVED_BROWSE");
                            restoreSV.modifyApprovalInfo(piirestore);
                            //CORE, DLM 의 cotdl.tbl_piiextract의 상태 APPROVED_RESTORE 으로 변경
                            restoreSV.updateRestoreCustStatus(piirestore.getOld_orderid(), piirestore.getCustid(), "APPROVED_BROWSE");
                        } else {
                            logger.warn("warn "+"/BROWSE_APPROVAL = fail " + approvalreqVO);
                            rst = "/BROWSE_APPROVAL = fail " + approvalreqVO;
                        }
                    }

                } else {
                    logger.warn("warn "+"getApproverid != getUsername " +  approver + "  " + userDetails.getUsername());
                }
            }
            else if (approvalreqVO.getApprovalid().equals("TESTDATA_APPROVAL")) {
                if (approver.equalsIgnoreCase(userDetails.getUsername())) {
                    // 1.TBL_PIIAPPROVALSTEPREQ insert
                    PiiApprovalStepReqVO piiapprovalstepreq = new PiiApprovalStepReqVO();
                    piiapprovalstepreq.setReqid(approvalreqVO.getReqid());
                    piiapprovalstepreq.setAprvlineid(approvalreqVO.getAprvlineid());
                    piiapprovalstepreq.setSeq(approvalreqVO.getSeq());
                    piiapprovalstepreq.setStepname("");
                    piiapprovalstepreq.setStatus("APPROVED");
                    piiapprovalstepreq.setApproverid(userVO.getApproverid());
                    piiapprovalstepreq.setApprovername(userVO.getApprovername());
                    piiapprovalstepreq.setRegdate("now()");
                    piiapprovalstepreq.setComment("");
                    approvalStepReqSV.register(piiapprovalstepreq);
                    //2.
                    if(approvalStepSV.getNextStepCount(approvalreqVO.getAprvlineid(), approvalreqVO.getSeq()) > 0){ // 다음 단계 seq 세팅
                        approvalreqVO.setSeq((Integer.parseInt(approvalreqVO.getSeq()) + 1)+"");
                        approvalreqVO.setPhase("APPLY");
                        service.modify(approvalreqVO);
                        rttr.addFlashAttribute("result", "success");
                    }
                    else{ // 최종단계 이므로 phase  업데이트
                        approvalreqVO.setPhase("FINAL_APPROVAL");
                        logger.warn("warn [TESTDATA_APPROVAL] 1. Before service.modify - reqid={}, jobid={}, phase={}",
                            approvalreqVO.getReqid(), approvalreqVO.getJobid(), approvalreqVO.getPhase());
                        service.modify(approvalreqVO);
                        logger.warn("warn [TESTDATA_APPROVAL] 2. After service.modify - PiiApprovalReq updated");

                        // TestData 승인 전 상태 확인
                        TestDataVO beforeApprove = testDataService.get(StrUtil.parseInt(approvalreqVO.getJobid()));
                        logger.warn("warn [TESTDATA_APPROVAL] 3. Before approve - testdataid={}, phase={}, status={}",
                            beforeApprove.getTestdataid(), beforeApprove.getPhase(), beforeApprove.getStatus());

                        // restore 상태 변경
                        boolean approveResult = testDataService.approve(approvalreqVO);
                        logger.warn("warn [TESTDATA_APPROVAL] 4. approve() returned: {}", approveResult);

                        if (approveResult) { // job update
                            rttr.addFlashAttribute("result", "success");
                            TestDataVO testDataVO = testDataService.get(StrUtil.parseInt(approvalreqVO.getJobid()));
                            logger.warn("warn [TESTDATA_APPROVAL] 5. After approve - testdataid={}, phase={}, status={}, new_orderid={}",
                                testDataVO.getTestdataid(), testDataVO.getPhase(), testDataVO.getStatus(), testDataVO.getNew_orderid());
                            try {
                                logger.warn("warn [TESTDATA_APPROVAL] 6. Before orderTestdataJob");
                                testDataService.orderTestdataJob(testDataVO);
                                logger.warn("warn [TESTDATA_APPROVAL] 7. After orderTestdataJob - SUCCESS");
                            } catch (Exception e) {
                                logger.warn("warn [TESTDATA_APPROVAL] 7. orderTestdataJob FAILED: {}", e.getMessage());
                                logger.warn("warn "+"/TESTDATA_APPROVAL = fail to order " + approvalreqVO + " " + testDataVO.toString()+" "+e.getMessage());
                                e.printStackTrace();
                                rst = "/TESTDATA_APPROVAL = fail to order" + approvalreqVO + " " + e.getMessage();
                                break;
                            }

                        } else {
                            logger.warn("warn [TESTDATA_APPROVAL] 4-FAIL. approve() returned false - jobid={}", approvalreqVO.getJobid());
                            rst = "/TESTDATA_APPROVAL = fail " + approvalreqVO;
                        }
                    }

                } else {
                    logger.warn("warn "+"get Approverid != getUsername " +  approver + "  " + userDetails.getUsername());
                }
            }
            else {//if (approvalreqVO.getApprovalid().equals("REPORT_APPROVAL") ) {

                if (approver.equalsIgnoreCase(userDetails.getUsername())) {
                    // 1.TBL_PIIAPPROVALSTEPREQ insert
                    PiiApprovalStepReqVO piiapprovalstepreq = new PiiApprovalStepReqVO();
                    piiapprovalstepreq.setReqid(approvalreqVO.getReqid());
                    piiapprovalstepreq.setAprvlineid(approvalreqVO.getAprvlineid());
                    piiapprovalstepreq.setSeq(approvalreqVO.getSeq());
                    piiapprovalstepreq.setStepname("");
                    piiapprovalstepreq.setStatus("APPROVED");
                    piiapprovalstepreq.setApproverid(userVO.getApproverid());
                    piiapprovalstepreq.setApprovername(userVO.getApprovername());
                    piiapprovalstepreq.setRegdate("now()");
                    piiapprovalstepreq.setComment("");
                    approvalStepReqSV.register(piiapprovalstepreq);

                    //2.
                    if(approvalStepSV.getNextStepCount(approvalreqVO.getAprvlineid(), approvalreqVO.getSeq()) > 0){ // 다음 단계 seq 세팅
                        approvalreqVO.setSeq((Integer.parseInt(approvalreqVO.getSeq()) + 1)+"");
                        approvalreqVO.setPhase("APPLY");
                        service.modify(approvalreqVO);
                    }
                    else{ // 최종단계 이므로 phase  업데이트
                        approvalreqVO.setPhase("FINAL_APPROVAL");
                        service.modify(approvalreqVO);
                    }
                    rttr.addFlashAttribute("result", "success");
                } else {
                    logger.warn("warn "+"getApproverid != getUsername " +  approver + "  " + userDetails.getUsername());
                }
            }

        }

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());

        return rst;
    }

    @PostMapping("/reject")
    @PreAuthorize("isAuthenticated()")
    public String reject(@RequestBody List<PiiApprovalReqVO> applist, Criteria cri, RedirectAttributes rttr) {
        String rst = "redirect:/piiapprovalreq/list";
        for (PiiApprovalReqVO approvalreqVO : applist) {
            if (approvalreqVO.getApprovalid().equals("JOB_APPROVAL")) {
                if (jobservice.reject(approvalreqVO)) { // job update
                    rttr.addFlashAttribute("result", "success");
                    //LogUtil.log("INFO", "/JOB_APPROVAL = success  "+ approvalreqVO);
                } else {
                    LogUtil.log("INFO", "/JOB_APPROVAL = fail  @@@@@@@@@@@@@@@@@@  " + approvalreqVO);
                    rst = "/JOB_APPROVAL = fail " + approvalreqVO;
                    break;
                }
            }
            else if (approvalreqVO.getApprovalid().equals("POLICY_APPROVAL")) {
                if (policyservice.reject(approvalreqVO)) { // job update
                    rttr.addFlashAttribute("result", "success");
                    //LogUtil.log("INFO", "/POLICY_APPROVAL = success  "+ approvalreqVO);
                } else {
                    LogUtil.log("INFO", "/POLICY_APPROVAL = fail  @@@@@@@@@@@@@@@@@@  " + approvalreqVO);
                    rst = "/POLICY_APPROVAL = fail " + approvalreqVO;
                    break;
                }
            }
            else if (approvalreqVO.getApprovalid().equals("RESTORE_APPROVAL") || approvalreqVO.getApprovalid().equals("BROWSE_APPROVAL") ) {
                if (restoreSV.reject(approvalreqVO)) { // job update

                    PiiRestoreVO piirestore = restoreSV.get(StrUtil.parseInt(approvalreqVO.getJobid()));
                    //CORE, DLM 의 cotdl.tbl_piiextract의 상태 원상복구 으로 변경
                    restoreSV.updateRestoreCustStatus(piirestore.getOld_orderid(), piirestore.getCustid(), null);

                    rttr.addFlashAttribute("result", "success");
                    //LogUtil.log("INFO", "/RESTORE_APPROVAL = success  "+ approvalreqVO);
                } else {
                    LogUtil.log("INFO", "/RESTORE_APPROVAL = fail  @@@@@@@@@@@@@@@@@@  " + approvalreqVO);
                    rst = "/RESTORE_APPROVAL = fail " + approvalreqVO;
                    break;
                }
            }
            else if (approvalreqVO.getApprovalid().equals("TESTDATA_APPROVAL")) {
                if (testDataService.reject(approvalreqVO)) { // job update
                    rttr.addFlashAttribute("result", "success");
                    //LogUtil.log("INFO", "/POLICY_APPROVAL = success  "+ approvalreqVO);
                } else {
                    LogUtil.log("INFO", "/POLICY_APPROVAL = fail  @@@@@@@@@@@@@@@@@@  " + approvalreqVO);
                    rst = "/POLICY_APPROVAL = fail " + approvalreqVO;
                    break;
                }
            }
        }

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());

        return rst;
    }

}
