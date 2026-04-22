package datablocks.dlm.controller;

import datablocks.dlm.aop.annotation.LogAccess;
import datablocks.dlm.domain.*;
import datablocks.dlm.service.PiiApprovalReqService;
import datablocks.dlm.service.PiiPolicyService;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.security.Principal;
import java.util.Locale;


@Controller
@RequestMapping("/piipolicy/*")
@AllArgsConstructor
public class PiiPolicyController {
    private static final Logger logger = LoggerFactory.getLogger(PiiPolicyController.class);
    private PiiPolicyService service;
    private PiiApprovalReqService approvalreqSV;
    // international message
    //@Autowired SessionLocaleResolver localeResolver;
    @Autowired
    MessageSource messageSource;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model) {
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Locale locale, HttpServletRequest request, Criteria cri, Model model) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("INFO", "/piipolicy list(Criteria cri, Model model): " + cri);
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    @LogAccess(menu = "PII_POLICY", action = "INSERT", importance = "HIGH", business = "PII_POLICY")
    public String register(PiiPolicyVO piipolicy, RedirectAttributes rttr) {
        LogUtil.log("INFO", "register: " + piipolicy);
        service.register(piipolicy);
        rttr.addFlashAttribute("result", "success");
        return "redirect:/piipolicy/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("policy_id") String policy_id, @RequestParam("version") String version, Criteria cri, Model model) {
        LogUtil.log("INFO", "/piipolicy @GetMapping  /get or modify = " + policy_id + " " + version);
        model.addAttribute("piipolicy", service.get(policy_id, version));
        model.addAttribute("cri", cri);
        model.addAttribute("maxversion", service.getMaxVersionByPolicy(policy_id));
        model.addAttribute("listallversion", service.getAllVersionList(policy_id));
        //logger.info(cri.toString());
    }

    @ResponseBody
    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    @LogAccess(menu = "PII_POLICY", action = "UPDATE", importance = "HIGH", business = "PII_POLICY")
    public String modify(@RequestBody PiiPolicyVO piipolicy, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping modify:" + piipolicy);
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        if (service.modify(piipolicy)) {
            rttr.addFlashAttribute("result", "success");
            return "success";
        }
        return "fail";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    @LogAccess(menu = "PII_POLICY", action = "DELETE", importance = "HIGH", business = "PII_POLICY")
    public String remove(PiiPolicyVO piipolicy, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping remove..." + piipolicy.getPolicy_id());
        if (service.remove(piipolicy.getPolicy_id(), piipolicy.getVersion())) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piipolicy/list";
    }

    @GetMapping("/checkout")
    @PreAuthorize("isAuthenticated()")
    public String checkout(@RequestParam("policy_id") String policy_id, @RequestParam("version") String version, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@GetMapping(checkout)..." + policy_id + "-" + version);

        service.checkout(policy_id, version);

        rttr.addFlashAttribute("result", "success");

        rttr.addAttribute("policy_id", policy_id);
        rttr.addAttribute("version", Integer.toString(Integer.parseInt(version) + 1));

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piipolicy/modify";
    }

    @GetMapping("/checkin")
    @PreAuthorize("isAuthenticated()")
    public String checkin(@RequestParam("policy_id") String policy_id
            , @RequestParam("version") String version
            , @RequestParam("reqreason") String reqreason
            , @RequestParam("aprvlineid") String aprvlineid
            , Criteria cri, RedirectAttributes rttr, Principal principal) {

        LogUtil.log("INFO", "@GetMapping(checkin)..." + policy_id + "-" + version);
        service.checkin(policy_id, version);

        PiiApprovalReqVO piiapprovalreqvo = new PiiApprovalReqVO();
        piiapprovalreqvo.setReqid(""+(approvalreqSV.getMaxReqid()+1));
        piiapprovalreqvo.setAprvlineid(aprvlineid);
        piiapprovalreqvo.setSeq("1");
        piiapprovalreqvo.setApprovalid("POLICY_APPROVAL");
        piiapprovalreqvo.setPhase("APPLY");
        piiapprovalreqvo.setJobid(policy_id);
        piiapprovalreqvo.setVersion(version);
        piiapprovalreqvo.setRequesterid(principal.getName());
        piiapprovalreqvo.setRequestername(principal.getName());
        piiapprovalreqvo.setRegdate("");
        piiapprovalreqvo.setUpddate("");
        piiapprovalreqvo.setReqreason(reqreason);
        approvalreqSV.register(piiapprovalreqvo);


        rttr.addAttribute("policy_id", policy_id);
        rttr.addAttribute("version", version);

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piipolicy/get";
    }
}
