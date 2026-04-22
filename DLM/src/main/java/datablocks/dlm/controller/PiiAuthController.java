package datablocks.dlm.controller;

import datablocks.dlm.util.LogUtil;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
//import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import datablocks.dlm.aop.annotation.LogAccess;
import datablocks.dlm.domain.AuthToChangeVO;
import datablocks.dlm.domain.AuthVO;
import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.service.PiiAuthService;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


@Controller
@RequestMapping("/piiauth/*")
@AllArgsConstructor
public class PiiAuthController {
    private static final Logger logger = LoggerFactory.getLogger(PiiAuthController.class);
    private PiiAuthService service;


    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model) {
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {

        cri.setOffset((cri.getPagenum()-1)*cri.getAmount());
        LogUtil.log("INFO", "/piiauth list(Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/piiauth total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piiauth pageMaker: " + pageMaker);
    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    @LogAccess(menu = "PII_AUTH", action = "INSERT", importance = "HIGH", business = "PII_AUTH")
    public String register(AuthVO piiauth, RedirectAttributes rttr) {

        service.register(piiauth);

        rttr.addFlashAttribute("result", "success");

        return "redirect:/piiauth/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("userid") String userid, @RequestParam("auth") String auth, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piiauth @GetMapping  /get or modify = " + userid);
        AuthVO reqpiiauth = new AuthVO();
        reqpiiauth.setUserid(userid);
        reqpiiauth.setAuth(auth);
        AuthVO piiauth = service.get(reqpiiauth);
        model.addAttribute("piiauth", piiauth);
        model.addAttribute("cri", cri);

        //logger.info(cri.toString());
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    @LogAccess(menu = "PII_AUTH", action = "UPDATE", importance = "HIGH", business = "PII_AUTH")
    public String modify(AuthToChangeVO piiauthtochange, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping modify:" + piiauthtochange);
        if (service.modify(piiauthtochange))
            rttr.addFlashAttribute("result", "success");
        else
            rttr.addFlashAttribute("result", "fail");

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piiauth/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    @LogAccess(menu = "PII_AUTH", action = "DELETE", importance = "HIGH", business = "PII_AUTH")
    public String remove(AuthVO piiauth, Criteria cri, RedirectAttributes rttr) {

        LogUtil.log("INFO", "@PostMapping remove..." + piiauth.getUserid());
        if (service.remove(piiauth)) {
            rttr.addFlashAttribute("result", "success");
        } else
            logger.warn("warn "+"/piiauth @PostMapping  /remove == fail to remove - service.remove(piiauth.getUserid()");
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piiauth/list";
    }


}
