package datablocks.dlm.controller;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.domain.PiiDetectConfigVO;
import datablocks.dlm.service.PiiConfigService;
import datablocks.dlm.service.PiiDetectService;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;

@Controller
@RequestMapping("/piidetect/*")
@AllArgsConstructor
public class PiiDetectController {
    private static final Logger logger = LoggerFactory.getLogger(PiiDetectController.class);
    private PiiDetectService service;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model) {
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model, HttpServletRequest request) {

        LogUtil.log("INFO", "/piidetect list(Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/piidetect total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piidetect pageMaker: " + pageMaker);
        //String root_path = request.getSession().getServletContext().getRealPath("/");
        //LogUtil.log("INFO", "/piidetect root_path: " + root_path);

    }
    @GetMapping("/resultlist")
    @PreAuthorize("isAuthenticated()")
    public void resultlist(Criteria cri, Model model, HttpServletRequest request) {

        LogUtil.log("INFO", "/piidetect resultlist (Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getResultList(cri));
        int total = service.getResultTotal(cri);
        //LogUtil.log("INFO", "/piidetect total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piidetect pageMaker: " + pageMaker);
        //String root_path = request.getSession().getServletContext().getRealPath("/");
        //LogUtil.log("INFO", "/piidetect root_path: " + root_path);

    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(PiiDetectConfigVO piidetectconfig, RedirectAttributes rttr) {

        LogUtil.log("INFO", "register: " + piidetectconfig);
        service.register(piidetectconfig);
        rttr.addFlashAttribute("result", "success");
        return "redirect:/piidetect/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("cfgkey") String cfgkey, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piidetect @GetMapping  /get or modify = " + cfgkey);
        PiiDetectConfigVO piidetectconfig = service.get(cfgkey);
        model.addAttribute("piidetectconfig", piidetectconfig);
        model.addAttribute("cri", cri);

        //logger.info(cri.toString());

    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiDetectConfigVO piidetectconfig, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping modify:" + piidetectconfig);

        if (service.modify(piidetectconfig))
            rttr.addFlashAttribute("result", "success");
        else
            rttr.addFlashAttribute("result", "fail");

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piidetect/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiDetectConfigVO piidetectconfig, Criteria cri, RedirectAttributes rttr) {

        LogUtil.log("INFO", "@PostMapping remove..." + piidetectconfig);
        if (service.remove(piidetectconfig.getConf_id())) {
            rttr.addFlashAttribute("result", "success");
        } else
            logger.warn("warn "+"/piidetect @PostMapping  /remove == fail to remove - service.remove(piidetectconfig.getKey()");
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piidetect/list";
    }


}
