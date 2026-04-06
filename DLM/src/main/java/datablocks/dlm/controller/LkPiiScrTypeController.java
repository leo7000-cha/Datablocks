package datablocks.dlm.controller;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.domain.LkPiiScrTypeVO;
import datablocks.dlm.service.ExcelService;
import datablocks.dlm.service.LkPiiScrTypeService;
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

@Controller
@RequestMapping("/lkpiiscrtype/*")
@AllArgsConstructor
public class LkPiiScrTypeController {
    private static final Logger logger = LoggerFactory.getLogger(LkPiiScrTypeController.class);
    private LkPiiScrTypeService service;
    private ExcelService excelService;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model) {

    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {

        LogUtil.log("INFO", "/lkpiiscrtype list(Criteria cri, Model model): " + cri);
        try {
            cri.setOffset((cri.getPagenum() - 1) * cri.getAmount());
        } catch (Exception ex) {
            cri.setOffset(0);
        }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/lkpiiscrtype total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/lkpiiscrtype pageMaker: " + pageMaker);
    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(LkPiiScrTypeVO lkpiiscrtype, RedirectAttributes rttr) throws Exception {

        LogUtil.log("INFO", "register: " + lkpiiscrtype);
        service.register(lkpiiscrtype);
        rttr.addFlashAttribute("result", "success");
        return "redirect:/lkpiiscrtype/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("piicode") String piicode, Criteria cri, Model model) {

        LogUtil.log("INFO", "/lkpiiscrtype @GetMapping  /get or modify = " + piicode);
        LkPiiScrTypeVO lkpiiscrtype = service.get(piicode);logger.warn("warn "+"/lkpiiscrtype @GetMapping  /get or modify lkpiiscrtype= " + lkpiiscrtype.toString());
        model.addAttribute("lkpiiscrtype", lkpiiscrtype);
        model.addAttribute("cri", cri);
        //logger.info(cri.toString());
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(LkPiiScrTypeVO lkpiiscrtype, Criteria cri, RedirectAttributes rttr) throws Exception {
        LogUtil.log("INFO", "@PostMapping modify:" + lkpiiscrtype);

        if (service.modify(lkpiiscrtype)) {
            rttr.addFlashAttribute("result", "success");
        }

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/lkpiiscrtype/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(LkPiiScrTypeVO lkpiiscrtype, Criteria cri, RedirectAttributes rttr) {

        LogUtil.log("INFO", "@PostMapping remove..." + lkpiiscrtype.getPiicode());
        if (service.remove(lkpiiscrtype.getPiicode())) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/lkpiiscrtype/list";
    }




}

