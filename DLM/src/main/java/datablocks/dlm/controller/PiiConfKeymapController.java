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
import datablocks.dlm.domain.PiiConfKeymapVO;
import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.service.PiiConfKeymapService;

import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Controller
@RequestMapping("/piiconfkeymap/*")
@AllArgsConstructor
public class PiiConfKeymapController {
    private static final Logger logger = LoggerFactory.getLogger(PiiConfKeymapController.class);
    private PiiConfKeymapService service;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register() {

    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {

        LogUtil.log("INFO", "list(Criteria cri, Model model): " + cri);
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
    public String register(PiiConfKeymapVO piiconfkeymap, RedirectAttributes rttr) {

        LogUtil.log("INFO", "register: " + piiconfkeymap);

        service.register(piiconfkeymap);

        rttr.addFlashAttribute("result", "success");

        return "redirect:/piiconfkeymap/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("keymap_id") String keymap_id, @RequestParam("key_name") String key_name, @RequestParam("db") String db, @RequestParam("seq1") int seq1, @RequestParam("seq2") int seq2, @RequestParam("seq3") int seq3, Criteria cri, Model model) {

        LogUtil.log("INFO", "/get or modify");
        model.addAttribute("piiconfkeymap", service.get(keymap_id, key_name, db, seq1, seq2, seq3));

        model.addAttribute("cri", cri);
        //logger.info(cri.toString());
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiConfKeymapVO piiconfkeymap, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "modify:" + piiconfkeymap);

        if (service.modify(piiconfkeymap)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piiconfkeymap/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiConfKeymapVO piiconfkeymap, Criteria cri, RedirectAttributes rttr) {

        LogUtil.log("INFO", "remove..." + piiconfkeymap.toString());
        if (service.remove(piiconfkeymap.getKeymap_id(), piiconfkeymap.getKey_name(), piiconfkeymap.getDb(), piiconfkeymap.getSeq1(), piiconfkeymap.getSeq2(), piiconfkeymap.getSeq3())) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piiconfkeymap/list";
    }

}
