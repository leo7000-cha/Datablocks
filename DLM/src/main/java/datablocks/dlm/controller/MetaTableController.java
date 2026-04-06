package datablocks.dlm.controller;

import datablocks.dlm.domain.*;
import datablocks.dlm.service.LkPiiScrTypeService;
import datablocks.dlm.service.PiiApprovalReqService;
import datablocks.dlm.service.MetaTableService;
import datablocks.dlm.service.PiiDatabaseService;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.security.Principal;
import java.util.List;
import java.util.Locale;


@Controller
@RequestMapping("/metatable/*")
@AllArgsConstructor
public class MetaTableController {
    private static final Logger logger = LoggerFactory.getLogger(MetaTableController.class);
    private MetaTableService service;
    private PiiDatabaseService databaseservice;
    private LkPiiScrTypeService lkPiiScrTypeService;

    @Autowired
    MessageSource messageSource;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model) {
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Locale locale, HttpServletRequest request, Criteria cri, Model model) {

        LogUtil.log("INFO", "/metatable list(Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("piidatabaselist", databaseservice.getList());
        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());
        model.addAttribute("stats", service.getStats());
        model.addAttribute("dbOwnerList", service.getDistinctDbOwners());
    }

    @GetMapping("/piicolregstatlist")
    @PreAuthorize("isAuthenticated()")
    public void piicolregstatlist(Locale locale, HttpServletRequest request, Criteria cri, Model model) {

        LogUtil.log("INFO", "/metatable piicolregstatlist(Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getList_GapVO(cri));
        int total = service.getTotalCount_GapVO(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("piidatabaselist", databaseservice.getList());
        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());
    }
    @GetMapping("/listdialog")
    @PreAuthorize("isAuthenticated()")
    public void listdialog(Locale locale, HttpServletRequest request, Criteria cri, Model model) {

        LogUtil.log("INFO", "/metatable listdialog(Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());
    }
    @GetMapping("/modifylist")
    @PreAuthorize("isAuthenticated()")
    public void modifylist(Locale locale, HttpServletRequest request, Criteria cri, Model model) {

        LogUtil.log("INFO", "/metatable modifylist(Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
    }
    @ResponseBody
    @PostMapping("/verify")
    @PreAuthorize("isAuthenticated()")
    @Transactional
    public String verify(@RequestBody List<MetaTableVO> metatablelist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping verify.............................");
        for (MetaTableVO metatable : metatablelist) {
            //logger.info(piiorder.toString());
            if (service.verifymodify(metatable)) {
                LogUtil.log("INFO", "/verify = success => "+ metatable.toString());
            } else {
                LogUtil.log("INFO", "/rerun = fail => "+ metatable.toString());
            }

        }

        return "success";
    }
    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(MetaTableVO metatable, RedirectAttributes rttr) {
        LogUtil.log("INFO", "register: " + metatable);
        service.register(metatable);
        rttr.addFlashAttribute("result", "success");
        return "redirect:/metatable/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("db") String db, @RequestParam("owner") String owner, @RequestParam("table_name") String table_name, @RequestParam("column_name") String column_name, Criteria cri, Model model) {
        LogUtil.log("INFO", "/metatable @GetMapping  /get or modify = " + db + " " + owner + " " + table_name+ " " + column_name+"  "+service.get(db, owner, table_name, column_name));
        model.addAttribute("metatable", service.get(db, owner, table_name, column_name));
        model.addAttribute("cri", cri);
        //logger.info(cri.toString());
    }
    @GetMapping({"/modifydialog"})
    @PreAuthorize("isAuthenticated()")
    public void modifydialog(Criteria cri, Model model) {
        LogUtil.log("INFO", "/metatable @GetMapping  /modifydialog = " + cri+"   "+service.get(cri.getSearch1(), cri.getSearch2(), cri.getSearch3(), cri.getSearch4()));
        model.addAttribute("metatable", service.get(cri.getSearch1(), cri.getSearch2(), cri.getSearch3(), cri.getSearch4()));
        model.addAttribute("cri", cri);
        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());
        //logger.info(cri.toString());
    }

    @ResponseBody
    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(@RequestBody MetaTableVO metatable, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping modify:" + metatable);
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        if (service.modify(metatable)) {
            rttr.addFlashAttribute("result", "success");
            return "success";
        }
        return "fail";
    }
    @ResponseBody
    @PostMapping("/piimodify")
    @PreAuthorize("isAuthenticated()")
    public String piimodify(@RequestBody MetaTableVO metatable, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping piimodify:" + metatable);
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        if (service.piimodify(metatable)) {
            rttr.addFlashAttribute("result", "success");
            return "success";
        }
        return "fail";
    }
    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(MetaTableVO metatable, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping remove..." + metatable.getTable_name());
        if (service.remove(metatable)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        return "redirect:/metatable/list";
    }


}
