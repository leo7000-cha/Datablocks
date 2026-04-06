package datablocks.dlm.controller;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.domain.PiiSystemVO;
import datablocks.dlm.domain.PiiExeupdateVO;
import datablocks.dlm.exception.AES256Exception;
import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.jdbc.JdbcUtil;
import datablocks.dlm.service.ExcelService;
import datablocks.dlm.service.PiiSystemService;
import datablocks.dlm.service.PiiSystemService;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.SqlUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.sql.*;
import java.util.Locale;

@Controller
@RequestMapping("/piisystem/*")
@AllArgsConstructor
public class PiiSystemController {
    private static final Logger logger = LoggerFactory.getLogger(PiiSystemController.class);
    private PiiSystemService service;
    private ExcelService excelService;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model) {

    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {

        LogUtil.log("INFO", "/piisystem list(Criteria cri, Model model): " + cri);
        try {
            cri.setOffset((cri.getPagenum() - 1) * cri.getAmount());
        } catch (Exception ex) {
            cri.setOffset(0);
        }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/piisystem total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piisystem pageMaker: " + pageMaker);
    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(PiiSystemVO piisystem, RedirectAttributes rttr) throws Exception {

        LogUtil.log("INFO", "register: " + piisystem);
        service.register(piisystem);
        rttr.addFlashAttribute("result", "success");
        return "redirect:/piisystem/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("system_id") String system_id, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piisystem @GetMapping  /get or modify = " + system_id);
        PiiSystemVO piisystem = service.get(system_id);
        model.addAttribute("piisystem", piisystem);
        model.addAttribute("cri", cri);
        //logger.info(cri.toString());
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiSystemVO piisystem, Criteria cri, RedirectAttributes rttr) throws Exception {
        LogUtil.log("INFO", "@PostMapping modify:" + piisystem);

        if (service.modify(piisystem)) {
            rttr.addFlashAttribute("result", "success");
        }

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piisystem/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiSystemVO piisystem, Criteria cri, RedirectAttributes rttr) {

        LogUtil.log("INFO", "@PostMapping remove..." + piisystem.getSystem_id());
        if (service.remove(piisystem.getSystem_id())) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piisystem/list";
    }




}

