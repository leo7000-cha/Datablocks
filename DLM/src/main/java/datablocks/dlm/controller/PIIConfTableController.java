package datablocks.dlm.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
//import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.domain.PiiConfTableVO;
import datablocks.dlm.service.PiiConfTableService;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Controller
@RequestMapping("/piiconftable/*")
@AllArgsConstructor
public class PIIConfTableController {
    private static final Logger logger = LoggerFactory.getLogger(PIIConfTableController.class);
    private PiiConfTableService service;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register() {

    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {

        //LogUtil.log("INFO", "list(Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "pageMaker: " + pageMaker);
    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(PiiConfTableVO piiconftable, RedirectAttributes rttr) {

        //LogUtil.log("INFO", "register: " + piiconftable);

        service.register(piiconftable);

        rttr.addFlashAttribute("result", "success");

        return "redirect:/piiconftable/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("db") String db, @RequestParam("owner") String owner, @RequestParam("table_name") String table_name, Criteria cri, Model model) {

        //LogUtil.log("INFO", "/get or modify"+db+owner+table_name);
        model.addAttribute("piiconftable", service.get(db, owner, table_name));

        model.addAttribute("cri", cri);
        //logger.info(cri.toString());
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiConfTableVO piiconftable, Criteria cri, RedirectAttributes rttr) {
        //LogUtil.log("INFO", "modify:" + piiconftable);

        if (service.modify(piiconftable)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        return "redirect:/piiconftable/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiConfTableVO piiconftable, Criteria cri, RedirectAttributes rttr) {

        //LogUtil.log("INFO", "remove..." + piiconftable);
        if (service.remove(piiconftable.getDb(), piiconftable.getOwner(), piiconftable.getTable_name())) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        return "redirect:/piiconftable/list";
    }

}
