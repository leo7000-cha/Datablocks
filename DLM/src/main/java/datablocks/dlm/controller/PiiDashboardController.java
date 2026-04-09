package datablocks.dlm.controller;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.service.*;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;

import java.text.DecimalFormat;
import java.util.List;

@Controller
@RequestMapping("/piidashboard/*")
@AllArgsConstructor
public class PiiDashboardController {
    private static final Logger logger = LoggerFactory.getLogger(PiiDashboardController.class);
    private PiiOrderService orderservice;
    private PiiExtractService extractservice;
    private PiiContractService contractService;
    private PiiPolicyService policyservice;
    private PiiJobService jobservice;
    private PiiStepTableService steptableservice;
    private PiiConfigService configservice;
    private PiiMemberService memberservice;
    private MetaPiiStatusService metaPiiStatusService;

    @Autowired
    private PasswordEncoder PasswordEncoder;

    @GetMapping("/dashboard")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model, Authentication authentication) {

        long totalStart = System.currentTimeMillis();
        long lap;
        logger.info("[PERF] ========== Dashboard loading START ==========");

        UserDetails userDetails = (UserDetails) authentication.getPrincipal();

        lap = System.currentTimeMillis();
        PiiMemberVO piimember = memberservice.get(userDetails.getUsername());
        logger.info("[PERF] memberservice.get('{}') → {} ms", userDetails.getUsername(), System.currentTimeMillis() - lap);

        String needtochangepwd = "";
        try {
            lap = System.currentTimeMillis();
            if (memberservice.getPwdElapsedCount(userDetails.getUsername()) > 0) {
                needtochangepwd = "EXPIRED";
            }
            logger.info("[PERF] getPwdElapsedCount → {} ms", System.currentTimeMillis() - lap);
        } catch (Exception ex) {
            logger.warn("dashboard: pwd expiry check failed for userId=" + userDetails.getUsername());
        }

        model.addAttribute("dashboardShow", EnvConfig.getConfig("DASHBOARD_SHOW"));

        try {
            lap = System.currentTimeMillis();
            if (PasswordEncoder.matches("#"+userDetails.getUsername(), memberservice.get(piimember.getUserid()).getUserpw())) {
                needtochangepwd = "INI";
            }
            logger.info("[PERF] PasswordEncoder check → {} ms", System.currentTimeMillis() - lap);
        } catch (Exception ex) {
            logger.warn("dashboard: initial pwd check failed for userId=" + userDetails.getUsername());
        }
        model.addAttribute("needtochangepwd", needtochangepwd);
        model.addAttribute("userid", userDetails.getUsername());

        try {
            lap = System.currentTimeMillis();
            model.addAttribute("jobresultlist", orderservice.getRunResultStat());
            logger.info("[PERF] orderservice.getRunResultStat() → {} ms", System.currentTimeMillis() - lap);
        } catch (Exception ex) {
            logger.warn("warn "+"orderservice.getRunResultStat()   " + ex.getMessage());
        }

        try {
            lap = System.currentTimeMillis();
            List<PiiCustStatVO> custstatlistdaily = extractservice.getCustStatListDaily(cri);
            logger.info("[PERF] extractservice.getCustStatListDaily() → {} ms", System.currentTimeMillis() - lap);
            model.addAttribute("custstatlistdaily", custstatlistdaily);
        } catch (Exception ex) {
            logger.warn("warn "+"extractservice.getCustStatListDaily(cri)   " + ex.getMessage());
        }

        try {
            lap = System.currentTimeMillis();
            model.addAttribute("custstatlistmonthly", extractservice.getCustStatListMonthly(cri));
            logger.info("[PERF] extractservice.getCustStatListMonthly() → {} ms", System.currentTimeMillis() - lap);
        } catch (Exception ex) {
            logger.warn("warn "+"extractservice.getCustStatListMonthly(cri)   " + ex.getMessage());
        }

        try {
            lap = System.currentTimeMillis();
            model.addAttribute("realdocstatlistmonthly", contractService.getStatList12Month());
            logger.info("[PERF] contractService.getStatList12Month() → {} ms", System.currentTimeMillis() - lap);
        } catch (Exception ex) {
            logger.warn("warn "+"contractService.getStatList12Month()   " + ex.getMessage());
        }

        try {
            lap = System.currentTimeMillis();
            List<?> piiallstatus = metaPiiStatusService.getListByDb();
            logger.info("[PERF] metaPiiStatusService.getListByDb() → {} ms (size={})", System.currentTimeMillis() - lap, piiallstatus.size());
            model.addAttribute("piiallstatus", piiallstatus);
        } catch (Exception ex) {
            logger.warn("warn "+"metaTableService.getListPiiAllStatus()   " + ex.getMessage());
        }

        try {
            lap = System.currentTimeMillis();
            PiiExtractRunRusultYearStatVO resultYearStat = extractservice.getRunExtractResultSumStat();
            logger.info("[PERF] extractservice.getRunExtractResultSumStat() → {} ms", System.currentTimeMillis() - lap);
            model.addAttribute("custstatsumlist", resultYearStat);
        } catch (Exception ex) {
            logger.warn("warn "+"extractservice.getRunExtractResultSumStat()   " + ex.getMessage());
        }

        try {
            model.addAttribute("notice1", configservice.get("NOTICE1").getValue());
        } catch (NullPointerException ex) {
        }
        try {
            model.addAttribute("notice2", configservice.get("NOTICE2").getValue());
        } catch (NullPointerException ex) {
        }
        try {
            model.addAttribute("notice3", configservice.get("NOTICE3").getValue());
        } catch (NullPointerException ex) {
        }
        try {
            model.addAttribute("notice4", configservice.get("NOTICE4").getValue());
        } catch (NullPointerException ex) {
        }
        try {
            model.addAttribute("notice5", configservice.get("NOTICE5").getValue());
        } catch (NullPointerException ex) {
        }

        int total = 0;
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);

        logger.info("[PERF] ========== Dashboard loading END — TOTAL {} ms ==========", System.currentTimeMillis() - totalStart);
    }


}
