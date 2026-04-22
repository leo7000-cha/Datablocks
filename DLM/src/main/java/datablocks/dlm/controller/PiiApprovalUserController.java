package datablocks.dlm.controller;

import datablocks.dlm.aop.annotation.LogAccess;
import datablocks.dlm.domain.*;
import datablocks.dlm.service.*;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
//import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.security.Principal;
import java.util.List;


@Controller
@RequestMapping("/piiapprovaluser/*")
@AllArgsConstructor
public class PiiApprovalUserController {
    private static final Logger logger = LoggerFactory.getLogger(PiiApprovalUserController.class);
    private PiiApprovalService approvalSV;
    private PiiApprovalUserService approvalUserSV;
    private PiiApprovalStepService approvalStepSV;
    private PiiApprovalLineService approvalLineSV;
    private PiiMemberService memberservice;
    private PiiApprovalReqService approvalReqService;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Criteria cri, Model model) {

        model.addAttribute("Approvallist", approvalUserSV.getList(cri));
        model.addAttribute("cri", cri);
    }

    @GetMapping("/registerapprovalline")
    @PreAuthorize("isAuthenticated()")
    public void registerapprovalline(Criteria cri, Model model) {
        model.addAttribute("Approvallist", approvalSV.getList(cri));
        model.addAttribute("cri", cri);
    }

    @GetMapping("/approvallinelist")
    @PreAuthorize("isAuthenticated()")
    public void approvallinelist(Criteria cri, Model model) {

        LogUtil.log("INFO", "/approvallinelist list(Criteria cri, Model model): " + cri);
        model.addAttribute("list", approvalLineSV.getList(cri));
        model.addAttribute("Approvallist", approvalSV.getList());
        int total = approvalLineSV.getTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
    }
    @GetMapping("/approvalsteplist")
    @PreAuthorize("isAuthenticated()")
    public void approvalsteplist(@RequestParam("aprvlineid") String aprvlineid, Criteria cri, Model model) {

        LogUtil.log("INFO", "/getapprovalsteplist list(Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("approvalline", approvalLineSV.get(aprvlineid));
        model.addAttribute("approvallinelist", approvalLineSV.getList());
//        model.addAttribute("steplist", approvalStepSV.getListByaAprvlineid(aprvlineid));
        model.addAttribute("steplist", approvalStepSV.getStepUserListByaAprvlineid(aprvlineid));

        List<PiiApprovalUserVO> piiapprovaluserlist = null;
        model.addAttribute("piiapprovaluserlist", piiapprovaluserlist);

        cri.setSearch2(aprvlineid);
        int total = 0;//approvalUserSV.getApprovalStepTotalCount(approvalid);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
    }
    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {

        LogUtil.log("INFO", "/piiapprovaluser list(Criteria cri, Model model): " + cri);
        model.addAttribute("Approvallist", approvalSV.getList(cri));
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", approvalUserSV.getList(cri));
        int total = approvalUserSV.getTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
    }

    @ResponseBody
    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    @LogAccess(menu = "PII_APPROVAL_USER", action = "INSERT", importance = "HIGH", business = "PII_APPROVAL")
    public String register(@RequestBody PiiApprovalUserVO piiApprovalUserVO) {
        LogUtil.log("INFO", "@PostMapping register:" + piiApprovalUserVO);
        String rst = "success";
        try {
            approvalUserSV.register(piiApprovalUserVO);
            rst = "success";
        } catch (Exception ex) {
            rst = ex.toString();
            logger.warn("warn "+rst);
        }
        return rst;
    }

    @ResponseBody
    @PostMapping("/registerapprovalline")
    @PreAuthorize("isAuthenticated()")
    @LogAccess(menu = "PII_APPROVAL_USER", action = "INSERT", importance = "HIGH", business = "PII_APPROVAL")
    public String registerapprovalline(@RequestBody PiiApprovalLineVO piiApprovalLineVO) {
        LogUtil.log("INFO", "@PostMapping registerapprovalline:" + piiApprovalLineVO);
        piiApprovalLineVO.setApprovalname(approvalSV.get(piiApprovalLineVO.getApprovalid()).getApprovalname());
        String rst = "success";
        try {
            approvalLineSV.register(piiApprovalLineVO);
            rst = "success";
        } catch (Exception ex) {
            rst = ex.toString();
            logger.warn("warn "+rst);
        }
        return rst;
    }
    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("aprvlineid") String aprvlineid,@RequestParam("seq") String seq, @RequestParam("approverid") String approverid, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piiapprovaluser @GetMapping  /get or modify = " + aprvlineid + "  " + seq+ "  " + approverid);

        PiiApprovalUserVO piiapprovaluser = approvalUserSV.get(aprvlineid, seq);//String aprvlineid, String seq, String approverid
        LogUtil.log("INFO", "/piiapprovaluser @GetMapping  /get or modify  piiapprovaluser = " + piiapprovaluser.toString());
        model.addAttribute("piiapprovaluser", piiapprovaluser);
        model.addAttribute("cri", cri);

        //logger.info(cri.toString());
    }
    @GetMapping({"/approvaluserlist"})
    @PreAuthorize("isAuthenticated()")
    public void approvaluserlist( Criteria cri, Model model) {

        LogUtil.log("INFO", "/piiapprovaluser @GetMapping  /get or modify = " + cri);

        List<PiiApprovalUserVO> piiapprovaluserlist = approvalUserSV.getList(cri);
        LogUtil.log("INFO", "/piiapprovaluser @GetMapping  /get or modify  piiapprovaluser = " + piiapprovaluserlist.toString());
        model.addAttribute("approvalstep", approvalStepSV.get(cri.getSearch1(), cri.getSearch2()));
        model.addAttribute("piiapprovaluserlist", piiapprovaluserlist);
        model.addAttribute("cri", cri);

        //logger.info(cri.toString());
    }

    @GetMapping({"/approvallinebyappidlist"})
    @PreAuthorize("isAuthenticated()")
    public void approvallinebyappidlist( @RequestParam("approvalid") String approvalid, Model model, Principal principal) {

        LogUtil.log("INFO", "/approvallinebyappidlist @GetMapping  /get or modify = " + approvalid);
        model.addAttribute("approvalUserAlllist", approvalUserSV.getAllUser(approvalid));
        PiiMemberVO memebervo = memberservice.get(principal.getName());
        String lastappline = null;
        LogUtil.log("INFO", "/approvallinebyappidlist lastappline = "+ approvalUserSV.getAllUser(approvalid)+ "==="+ lastappline + "  "+memebervo.getUserid());
        try{
            lastappline = approvalReqService.getSameDeptApprovalUser(approvalid, memebervo.getDept_cd()).getAprvlineid();
        }catch (Exception e) {
//            e.printStackTrace();
        }
        try{
            if(StrUtil.checkString(lastappline)) {
                // 과거 이력에서 결재선 조회
                PiiApprovalReqVO lastReq = approvalReqService.getLastApprovalReq(approvalid, memebervo.getUserid());
                if(lastReq != null) {
                    String lastAprvlineid = lastReq.getAprvlineid();
                    // 과거 결재선에 현재 같은 부서 결재자가 있는지 검증
                    if(approvalReqService.hasSameDeptApproverInLine(lastAprvlineid, memebervo.getDept_cd())) {
                        lastappline = lastAprvlineid;
                    }
                }
            }
        }catch (Exception e) {
//            e.printStackTrace();
        }
        model.addAttribute("lastappline", lastappline);
        LogUtil.log("INFO", "/approvallinebyappidlist lastappline = " + lastappline + "  "+memebervo.getUserid());
    }
    @ResponseBody
    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    @LogAccess(menu = "PII_APPROVAL_USER", action = "UPDATE", importance = "HIGH", business = "PII_APPROVAL")
    public String modify(@RequestBody PiiApprovalUserVO piiApprovalUserVO, @RequestParam("approverid_old") String approverid_old, @RequestParam("approvername_old") String approvername_old
            , Criteria cri) {
        LogUtil.log("INFO", "@PostMapping modify:  approverid_old=" + approverid_old + "    approvername_old=" + approvername_old + "  piiApprovalUserVO=" + piiApprovalUserVO);
        String rst = "success";

        try {
            if (approvalUserSV.modify(piiApprovalUserVO))
                rst = "success";
            else
                rst = "Fail";
        } catch (Exception ex) {
            rst = ex.toString();
            logger.warn("warn "+rst);
        }
        return rst;
    }

    @ResponseBody
    @RequestMapping(value = "/modifystepseq")
    @PreAuthorize("isAuthenticated()")
    public String modifystepseq(@RequestBody List<PiiApprovalStepVO> steplist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@RequestMapping(value=modifystepseq" + cri);
        boolean okflag = false;
        for (PiiApprovalStepVO piiapprovalstep : steplist) {
            if (approvalStepSV.modifySeq(piiapprovalstep))
                okflag = true;
            else {
                okflag = false;
                break;
            }
        }
        if (okflag)
            return "Successfully saved";
        else
            return "Process failed";
    }

    @ResponseBody
    @RequestMapping(value = "/saveallstep")
    @PreAuthorize("isAuthenticated()")
    public String saveallstep(@RequestBody List<PiiApprovalStepUserVO> stepuserlist, Criteria cri, Model model) {
        logger.warn("warn "+"@RequestMapping(value=saveallstep" + stepuserlist.toString());

        if (approvalStepSV.saveAllStep(stepuserlist))
            return "Successfully saved";
        else
            return "Process failed";
    }

    @ResponseBody
    @RequestMapping(value = "/savealluser")
    @PreAuthorize("isAuthenticated()")
    public String savealluser(@RequestBody List<PiiApprovalUserVO> userlist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@RequestMapping(value=savealluser" + userlist);
        boolean okflag = false;
        PiiApprovalStepVO stepVO = null;
        for (PiiApprovalUserVO piiapprovaluser : userlist) {
            try {
                stepVO = approvalStepSV.get(piiapprovaluser.getAprvlineid(), piiapprovaluser.getSeq());
            } catch(Exception e) {
                logger.warn("warn "+e.getMessage());
                return "Process failed 00";
            }
            break;
        }

        if(approvalUserSV.removeByStep(stepVO.getAprvlineid(), stepVO.getSeq())) {
            for (PiiApprovalUserVO piiapprovaluser : userlist) {
                try {
                    approvalUserSV.register(piiapprovaluser);
                } catch(Exception e) {
                    logger.warn("warn "+e.getMessage());
                    return "Process failed 11";
                }
                okflag = true;
            }
        }
        if (okflag)
            return "Successfully saved";
        else
            return "Process failed";
    }

    @ResponseBody
    @RequestMapping(value = "/removeline")
    @PreAuthorize("isAuthenticated()")
    public String removeline(@RequestBody List<PiiApprovalLineVO> linelist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@RequestMapping(value=removeline" + linelist);
        boolean okflag = false;
        PiiApprovalLineVO lineVo = null;

        for (PiiApprovalLineVO piiapprovalline : linelist) {
            approvalLineSV.remove(piiapprovalline.getAprvlineid());
            okflag = true;
        }

        if (okflag)
            return "Successfully saved";
        else
            return "Process failed";
    }

    @ResponseBody
    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    @LogAccess(menu = "PII_APPROVAL_USER", action = "DELETE", importance = "HIGH", business = "PII_APPROVAL")
    public String remove(@RequestBody PiiApprovalUserVO piiApprovalUserVO, Criteria cri) {

        LogUtil.log("INFO", "@PostMapping remove..." + piiApprovalUserVO);

        String rst = "success";
        try {
            if (approvalUserSV.remove(piiApprovalUserVO.getAprvlineid(), piiApprovalUserVO.getSeq() ))  //aprvlineid, String seq, String approverid
                rst = "success";
            else
                rst = "Fail";
        } catch (Exception ex) {
            rst = ex.toString();
            logger.warn("warn "+rst);
        }
        return rst;
    }


}
