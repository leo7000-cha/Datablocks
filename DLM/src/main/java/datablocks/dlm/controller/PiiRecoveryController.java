package datablocks.dlm.controller;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.domain.PiiRecoveryVO;
import datablocks.dlm.service.PiiJobService;
import datablocks.dlm.service.PiiOrderService;
import datablocks.dlm.service.PiiRecoveryService;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.text.SimpleDateFormat;
import java.util.List;

@Controller
@RequestMapping("/piirecovery/*")
@AllArgsConstructor
public class PiiRecoveryController {
    private static final Logger logger = LoggerFactory.getLogger(PiiRecoveryController.class);
    private PiiRecoveryService service;
    private PiiJobService jobSV;
    private PiiOrderService orderSV;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register() {

    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("INFO", "/piirecovery list(Criteria cri, Model model): " + cri);
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/piirecovery total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("listjob", service.getRecoveryJobList());
        //LogUtil.log("INFO", "/piirecovery pageMaker: " + pageMaker);
    }

    @GetMapping("/orderlist")
    @PreAuthorize("isAuthenticated()")
    public void orderlist(Criteria cri, Model model) {

        LogUtil.log("INFO", "/piirecovery orderlist(Criteria cri, Model model): " + cri);
        SimpleDateFormat dateForm = new SimpleDateFormat("yyyy/MM/dd");
        if (cri.getSearch2() != null) {
            if (cri.getSearch2().length() != 10) {
                cri.setSearch2(null);
            } else {
                String format = null;
                try {
                    format = dateForm.format(dateForm.parse(cri.getSearch2()));
                } catch (Exception e) {
                    cri.setSearch2(null);
                }
            }
        }

        int total = 0;
        //if("".equalsIgnoreCase(cri.getSearch1()) || cri.getSearch1() == null) {
        //	total = 0;
        //}else {
        model.addAttribute("list", service.getOrderList(cri));
        total = service.getTotal(cri);
        //}
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("listjob", service.getOrderJobList());
    }

    @GetMapping("/joblist")
    @PreAuthorize("isAuthenticated()")
    public void joblist(Criteria cri, Model model) {
        LogUtil.log("INFO", "/piirecovery orderlist(Criteria cri, Model model): " + cri);
        SimpleDateFormat dateForm = new SimpleDateFormat("yyyyMMdd");
        if (cri.getSearch2() != null) {
            if (cri.getSearch2().length() != 8) {
                cri.setSearch2(null);
            } else {
                String format = null;
                try {
                    format = dateForm.format(dateForm.parse(cri.getSearch2()));
                } catch (Exception e) {
                    cri.setSearch2(null);
                }
            }
        }

        int total = 0;
        //if("".equalsIgnoreCase(cri.getSearch1()) || cri.getSearch1() == null) {
        //	total = 0;
        //}else {
        model.addAttribute("list", service.getOrderJobListWithPaging(cri));
        total = service.getTotal(cri);
        //}
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("listjob", service.getOrderJobList());
    }

    @ResponseBody
    @PostMapping("/orderregister")
    @PreAuthorize("isAuthenticated()")
    public String orderregister(@RequestBody List<PiiRecoveryVO> recoverylist, Criteria cri, Model model) {
        LogUtil.log("INFO", "/orderregister: " + cri);
        String rst = null;
        for (PiiRecoveryVO piirecovery : recoverylist) {
            //LogUtil.log("INFO", "service.register(piirecovery);" + piirecovery);
            if (service.orderregister(piirecovery))
                rst = "success";
            else
                rst = "fail to processing recovery";
        }
        return rst;
    }

    @ResponseBody
    @PostMapping("/jobregister")
    @PreAuthorize("isAuthenticated()")
    public String jobregister(@RequestBody List<PiiRecoveryVO> recoverylist, Criteria cri, Model model) {
        LogUtil.log("INFO", "/jobregister: " + cri);
        String rst = null;
        for (PiiRecoveryVO piirecovery : recoverylist) {
            //LogUtil.log("INFO", "service.register(piirecovery);" + piirecovery);

            if (orderSV.getMaxOrderOkByJobid(piirecovery.getOld_jobid()) == null) {LogUtil.log("INFO", "orderSV.getMaxOrderOkByJobid(piirecovery.getOld_jobid()) == null;" );
                rst = "There's no data to recover";
                break;
            }
            //set orderid of job's orderlist for helping create a RECOVERY ORDER
            piirecovery.setOld_orderid(orderSV.getMaxOrderOkByJobid(piirecovery.getOld_jobid()).getOrderid());

            if (service.jobregister(piirecovery))
                rst = "success";
            else
                rst = "fail to processing recovery";
        }
        LogUtil.log("INFO", rst );
        return rst;
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("recoveryid") int recoveryid, Criteria cri, Model model) {
        LogUtil.log("INFO", "/get: " + cri);
        //LogUtil.log("INFO", "/piirecovery @GetMapping  /get or modify = "+recoveryid);
        model.addAttribute("piirecovery", service.get(recoveryid));

        model.addAttribute("cri", cri);
    }

    @GetMapping({"/requestapproval"})
    @PreAuthorize("isAuthenticated()")
    public String requestapproval(@RequestParam("recoveryid") int recoveryid, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "/piirecovery @GetMapping  /requestapproval = " + recoveryid);
        if (service.requestapproval(recoveryid)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("recoveryid", recoveryid);

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piirecovery/list";
    }

    @GetMapping({"/approve"})
    @PreAuthorize("isAuthenticated()")
    public String approve(@RequestParam("recoveryid") int recoveryid, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "/piirecovery @GetMapping  /approve = " + recoveryid);
        if (service.approve(recoveryid)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("recoveryid", recoveryid);

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piirecovery/list";
    }

    @GetMapping({"/reject"})
    @PreAuthorize("isAuthenticated()")
    public String reject(@RequestParam("recoveryid") int recoveryid, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "/piirecovery @GetMapping  /reject = " + recoveryid);
        if (service.reject(recoveryid)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("recoveryid", recoveryid);

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piirecovery/list";
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiRecoveryVO piirecovery, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping modify:" + piirecovery);

        if (service.modify(piirecovery)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("recoveryid", piirecovery.getRecoveryid());

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piirecovery/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiRecoveryVO piirecovery, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping remove..." + piirecovery.getRecoveryid());
        if (service.remove(piirecovery.getRecoveryid())) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piirecovery/list";
    }
}
