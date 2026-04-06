package datablocks.dlm.controller;

import datablocks.dlm.domain.*;
import datablocks.dlm.service.DepartmentService;
import datablocks.dlm.service.PiiApprovalReqService;
import datablocks.dlm.service.PiiContractService;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.security.Principal;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Controller
@RequestMapping("/piicontract/*")
@AllArgsConstructor
public class PiiContractController {
    private static final Logger logger = LoggerFactory.getLogger(PiiContractController.class);
    private PiiContractService service;
    private PiiApprovalReqService approvalreqSV;
    private DepartmentService departmentService;
    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model) {
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {

        LogUtil.log("INFO", "/piicontract list(Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/piicontract total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("listMgmtDept", service.getDistinctMgmtDept());

    }
    @GetMapping("/statlist")
    @PreAuthorize("isAuthenticated()")
    public void statlist(Criteria cri, Model model) {

        LogUtil.log("INFO", "/piicontract statlist(Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용

        Date today = new Date();
        SimpleDateFormat yyyymm = new SimpleDateFormat("yyyy/MM");
//        SimpleDateFormat yyyy = new SimpleDateFormat("yyyy");
        String curmonth = yyyymm.format(today);
//        String curyear = yyyy.format(today);
        if(StrUtil.checkString(cri.getSearch4()) && StrUtil.checkString(cri.getSearch5())) {
            cri.setSearch4(curmonth);
            cri.setSearch5(curmonth);
        }
        model.addAttribute("list", service.getStatList(cri));
        int total = service.getStatTotal(cri);
        //LogUtil.log("INFO", "/piicontract total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("listMgmtDept", service.getDistinctMgmtDept());

    }
    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(PiiContractVO piicontract, RedirectAttributes rttr) {

        LogUtil.log("INFO", "register: " + piicontract);
        service.register(piicontract);
        rttr.addFlashAttribute("result", "success");
        return "redirect:/piicontract/list";
    }
    @ResponseBody
    @PostMapping("/updatestatusasy")
    @PreAuthorize("isAuthenticated()")
    public String updatestatusasy(@RequestBody List<PiiContractVO> contractlist, Criteria cri, Model model, Principal principal) {
        LogUtil.log("INFO", "/piicontract updatestatusasy: " + cri );
        return service.modifyStatusListAsY(contractlist, principal);
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("custid") String custid, @RequestParam("contractno") String contractno, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piicontract @GetMapping  /get or modify = " + custid +"  "+contractno);
        PiiContractVO piicontract = service.get(custid, contractno);
        model.addAttribute("piicontract", piicontract);
        model.addAttribute("cri", cri);

        //logger.info(cri.toString());

    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiContractVO piicontract, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping modify:" + piicontract);

        if (service.modify(piicontract))
            rttr.addFlashAttribute("result", "success");
        else
            rttr.addFlashAttribute("result", "fail");

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piicontract/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiContractVO piicontract, Criteria cri, RedirectAttributes rttr) {

        LogUtil.log("INFO", "@PostMapping remove..." + piicontract);
        if (service.remove(piicontract.getCustid(),piicontract.getContractno())) {
            rttr.addFlashAttribute("result", "success");
        } else
            logger.warn("warn "+"/piicontract @PostMapping  /remove == fail to remove - service.remove(piicontract.getKey()");
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piicontract/list";
    }

    @GetMapping("/checkin")
    @PreAuthorize("isAuthenticated()")
    public String checkin(@RequestParam("reqreason") String reqreason
            , @RequestParam("aprvlineid") String aprvlineid
            , Criteria cri, RedirectAttributes rttr, Principal principal) {

        LogUtil.log("INFO", "@GetMapping(checkin)..." + aprvlineid);

        PiiApprovalReqVO piiapprovalreqvo = new PiiApprovalReqVO();
        piiapprovalreqvo.setReqid(""+(approvalreqSV.getMaxReqid()+1));
        piiapprovalreqvo.setAprvlineid(aprvlineid);
        piiapprovalreqvo.setSeq("1");
        piiapprovalreqvo.setApprovalid("REALDOC_APPROVAL");
        piiapprovalreqvo.setPhase("APPLY");
        piiapprovalreqvo.setJobid("");
        piiapprovalreqvo.setVersion("");
        piiapprovalreqvo.setRequesterid(principal.getName());
        piiapprovalreqvo.setRequestername(principal.getName());
        piiapprovalreqvo.setRegdate("");
        piiapprovalreqvo.setUpddate("");
        piiapprovalreqvo.setReqreason(reqreason);
        approvalreqSV.register(piiapprovalreqvo);

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch2());
        rttr.addAttribute("search4", cri.getSearch2());
        rttr.addAttribute("search5", cri.getSearch2());
        rttr.addAttribute("search6", cri.getSearch2());
        rttr.addAttribute("search7", cri.getSearch2());
        rttr.addAttribute("search8", cri.getSearch2());
        return "redirect:/piicontract/list";
    }

}
