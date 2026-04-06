package datablocks.dlm.controller;

import datablocks.dlm.domain.CommandVO;
import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.domain.PiiConfigVO;
import datablocks.dlm.service.PiiConfigService;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.List;

@Controller
@RequestMapping("/piiconfig/*")
@AllArgsConstructor
public class PiiConfigController {
    private static final Logger logger = LoggerFactory.getLogger(PiiConfigController.class);
    private PiiConfigService service;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model) {
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model, HttpServletRequest request) {

        LogUtil.log("INFO", "/piiconfig list - fetching all configs without paging");
        // 환경설정은 항목이 적으므로 페이징 없이 전체 조회
        List<PiiConfigVO> list = service.getList();
        model.addAttribute("list", list);
        LogUtil.log("INFO", "/piiconfig list size: " + list.size());

        int total = list.size();
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);

    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(PiiConfigVO piiconfig, RedirectAttributes rttr) {

        LogUtil.log("INFO", "register: " + piiconfig);
        service.register(piiconfig);
        rttr.addFlashAttribute("result", "success");
        return "redirect:/piiconfig/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("cfgkey") String cfgkey, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piiconfig @GetMapping  /get or modify = " + cfgkey);
        PiiConfigVO piiconfig = service.get(cfgkey);
        model.addAttribute("piiconfig", piiconfig);
        model.addAttribute("cri", cri);

        //logger.info(cri.toString());

    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiConfigVO piiconfig, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping modify:" + piiconfig);

        if (service.modify(piiconfig))
            rttr.addFlashAttribute("result", "success");
        else
            rttr.addFlashAttribute("result", "fail");

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piiconfig/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(@RequestParam("cfgkey") String cfgkey, Criteria cri, RedirectAttributes rttr) {

        logger.warn("@PostMapping /piiconfig/remove - cfgkey: [" + cfgkey + "]");

        if (cfgkey == null || cfgkey.trim().isEmpty()) {
            logger.warn("warn /piiconfig remove - cfgkey is null or empty!");
            rttr.addFlashAttribute("result", "fail");
            return "redirect:/piiconfig/list";
        }

        if (service.remove(cfgkey)) {
            LogUtil.log("INFO", "/piiconfig remove success - cfgkey: " + cfgkey);
            rttr.addFlashAttribute("result", "success");
        } else {
            logger.warn("warn /piiconfig remove failed - cfgkey: " + cfgkey);
            rttr.addFlashAttribute("result", "fail");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piiconfig/list";
    }

    @ResponseBody
    @RequestMapping(value = "refreshConfig", produces = "text/plain;charset=UTF-8", method = RequestMethod.GET)
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<String> refreshConfig() {
        service.refreshConfig();
        return ResponseEntity.ok("Successfully refreshed all configs");
    }



}
