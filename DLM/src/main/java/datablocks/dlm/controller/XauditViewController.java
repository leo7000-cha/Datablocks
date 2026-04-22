package datablocks.dlm.controller;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.domain.XauditEventVO;
import datablocks.dlm.service.XauditEventService;

/**
 * X-Audit 조회 UI (DLM 운영자용).
 * /xaudit/** URL 은 인증 필요. 수신은 {@link XauditEventController} 가 /api/xaudit/** 로 별도 처리.
 */
@Controller
@RequestMapping("/xaudit")
public class XauditViewController {

    @Autowired
    private XauditEventService service;

    @GetMapping("/dashboard")
    @PreAuthorize("isAuthenticated()")
    public String dashboard(Model model, @RequestParam(required = false) String date) {
        if (date == null || date.isEmpty()) {
            date = new SimpleDateFormat("yyyyMMdd").format(new Date());
        }
        model.addAttribute("date", date);
        model.addAttribute("counts",   service.getDashboardCounts(date));
        model.addAttribute("hourly",   service.getHourlyTrend(date));
        model.addAttribute("services", service.getServiceDistribution(date));
        model.addAttribute("piiDist",  service.getPiiDistribution(date));
        return "xaudit/dashboard";
    }

    @GetMapping("/access")
    @PreAuthorize("isAuthenticated()")
    public String accessList(Criteria cri, Model model) {
        cri.setOffset(Math.max(0, (cri.getPagenum() - 1) * cri.getAmount()));
        int total = service.getAccessTotal(cri);
        model.addAttribute("list",      service.getAccessList(cri));
        model.addAttribute("pageMaker", new PageDTO(cri, total));
        model.addAttribute("total",     total);
        return "xaudit/access";
    }

    @GetMapping("/sql")
    @PreAuthorize("isAuthenticated()")
    public String sqlList(Criteria cri, Model model) {
        cri.setOffset(Math.max(0, (cri.getPagenum() - 1) * cri.getAmount()));
        int total = service.getSqlTotal(cri);
        model.addAttribute("list",      service.getSqlList(cri));
        model.addAttribute("pageMaker", new PageDTO(cri, total));
        model.addAttribute("total",     total);
        return "xaudit/sql";
    }

    @GetMapping("/detail/{reqId}")
    @PreAuthorize("isAuthenticated()")
    public String detail(@PathVariable String reqId, Model model) {
        List<XauditEventVO> sqls = service.getSqlByReqId(reqId);
        model.addAttribute("reqId", reqId);
        model.addAttribute("sqls",  sqls);
        return "xaudit/detail";
    }
}
