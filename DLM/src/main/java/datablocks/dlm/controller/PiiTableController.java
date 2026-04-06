package datablocks.dlm.controller;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.LogFileVO;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.domain.PiiTableVO;
import datablocks.dlm.mapper.PiiConfigMapper;
import datablocks.dlm.service.PiiConfigService;
import datablocks.dlm.service.PiiSystemService;
import datablocks.dlm.service.PiiTableService;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/piitable/*")
@AllArgsConstructor
public class PiiTableController {
    private static final Logger logger = LoggerFactory.getLogger(PiiTableController.class);
    private PiiTableService service;
    private PiiSystemService systemSV;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model) {
        model.addAttribute("listsystem", systemSV.getList());
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("INFO", "/piitable list(Criteria cri, Model model): " + cri);
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/piitable total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piitable pageMaker: " + pageMaker);
    }

    @GetMapping("/layoutgaplist")
    @PreAuthorize("isAuthenticated()")
    public void layoutgaplist(Criteria cri, Model model) {
        LogUtil.log("INFO", "/piitable layoutgaplist(Criteria cri, Model model): " + cri);
        model.addAttribute("list", service.getLayoutGapList(cri));
        int total = service.getLayoutGapTotal(cri);
        //LogUtil.log("INFO", "/piitable total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piitable pageMaker: " + pageMaker);
    }

    /* need to custmize for each client */
    @GetMapping("/piigaplist")
    @PreAuthorize("isAuthenticated()")
    public void piigaplist(Criteria cri, Model model) {
        LogUtil.log("INFO", "/piitable piigaplist(Criteria cri, Model model): " + cri);
        model.addAttribute("list", service.getLayoutGapList(cri));
        int total = service.getLayoutGapTotal(cri);
        //LogUtil.log("INFO", "/piitable total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piitable pageMaker: " + pageMaker);
    }



    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(PiiTableVO piitable, RedirectAttributes rttr) {
        LogUtil.log("INFO", "register: " + piitable);
        service.register(piitable);

        rttr.addFlashAttribute("result", "success");

        return "redirect:/piitable/list";
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiTableVO piitable, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping modify:" + piitable);

        if (service.modify(piitable)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piitable/list";
    }

}
