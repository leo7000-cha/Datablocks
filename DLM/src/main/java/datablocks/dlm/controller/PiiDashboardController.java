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

        LogUtil.log("INFO", "/PiiDashboard dashboard1(Criteria cri, Model model): " + cri);
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        PiiMemberVO piimember = memberservice.get(userDetails.getUsername());
        String needtochangepwd = "";
        LogUtil.log("INFO", "/dashboard = userDetails.getUsername() ==>" + userDetails.getUsername()+"  "+piimember);
        try {
            if (memberservice.getPwdElapsedCount(userDetails.getUsername()) > 0) {
                needtochangepwd = "EXPIRED";
            }
        } catch (Exception ex) {
            logger.warn("dashboard: pwd expiry check failed for userId=" + userDetails.getUsername());
        }

        model.addAttribute("dashboardShow", EnvConfig.getConfig("DASHBOARD_SHOW"));

        try {
            if (PasswordEncoder.matches("#"+userDetails.getUsername(), memberservice.get(piimember.getUserid()).getUserpw())) {
                needtochangepwd = "INI";
            }
        } catch (Exception ex) {
            logger.warn("dashboard: initial pwd check failed for userId=" + userDetails.getUsername());
        }
        LogUtil.log("INFO", "/dashboard = needtochangepwd ==>" + needtochangepwd);
        model.addAttribute("needtochangepwd", needtochangepwd);
        model.addAttribute("userid", userDetails.getUsername());
        try {
            model.addAttribute("jobresultlist", orderservice.getRunResultStat());
        } catch (Exception ex) {
            logger.warn("warn "+"orderservice.getRunResultStat()   " + ex.getMessage());
        }
        try {
            List<PiiCustStatVO> custstatlistdaily = extractservice.getCustStatListDaily(cri);
            /*for (PiiCustStatVO custStat : custstatlistdaily) {
                // mon 칼럼의 값을 가져와 5번째부터 끝까지의 문자열을 추출하여 다시 설정합니다.
                String originalDateStr = custStat.getMon();
                if (originalDateStr != null && originalDateStr.length() >= 5) {
                    String trimmedDate = originalDateStr.substring(5); // 5번째 문자부터 끝까지 잘라냅니다.
                    custStat.setMon(trimmedDate);
                }
            }*/
            model.addAttribute("custstatlistdaily", custstatlistdaily); // 통계 테이블(TBL_PIICUSTSTAT)로 적재후 빠른 조회 방식으로 수정 20230426
        } catch (Exception ex) {
            logger.warn("warn "+"extractservice.getCustStatListDaily(cri)   " + ex.getMessage());
        }
        try {
            model.addAttribute("custstatlistmonthly", extractservice.getCustStatListMonthly(cri)); // 통계 테이블(TBL_PIICUSTSTAT)로 적재후 빠른 조회 방식으로 수정 20230426
        } catch (Exception ex) {
            logger.warn("warn "+"extractservice.getCustStatListMonthly(cri)   " + ex.getMessage());
        }
        try {
            model.addAttribute("realdocstatlistmonthly", contractService.getStatList12Month());
        } catch (Exception ex) {
            logger.warn("warn "+"contractService.getStatList12Month()   " + ex.getMessage());
        }
        try {
            logger.info("info "+"metaPiiStatusService.getListByDb().size()   " + metaPiiStatusService.getListByDb().size());
            model.addAttribute("piiallstatus", metaPiiStatusService.getListByDb());
        } catch (Exception ex) {
            logger.warn("warn "+"metaTableService.getListPiiAllStatus()   " + ex.getMessage());
        }
        try {
            PiiExtractRunRusultYearStatVO resultYearStat = extractservice.getRunExtractResultSumStat();
//            DecimalFormat formatter = new DecimalFormat("#,###");
//
//            resultYearStat.setCnt_0(formatter.format(Double.parseDouble(resultYearStat.getCnt_0())));
//            resultYearStat.setCnt_1(formatter.format(Double.parseDouble(resultYearStat.getCnt_1())));
//            resultYearStat.setCnt_2(formatter.format(Double.parseDouble(resultYearStat.getCnt_2())));
//            resultYearStat.setCnt_3(formatter.format(Double.parseDouble(resultYearStat.getCnt_3())));
//            resultYearStat.setCnt_4(formatter.format(Double.parseDouble(resultYearStat.getCnt_4())));
//            resultYearStat.setCnt_5(formatter.format(Double.parseDouble(resultYearStat.getCnt_5())));
//            resultYearStat.setCnt_6(formatter.format(Double.parseDouble(resultYearStat.getCnt_6())));
//            resultYearStat.setCnt_7(formatter.format(Double.parseDouble(resultYearStat.getCnt_7())));
//            resultYearStat.setCnt_8(formatter.format(Double.parseDouble(resultYearStat.getCnt_8())));
//            resultYearStat.setCnt_9(formatter.format(Double.parseDouble(resultYearStat.getCnt_9())));
//            resultYearStat.setCnt_10(formatter.format(Double.parseDouble(resultYearStat.getCnt_10())));
//            resultYearStat.setCnt_11(formatter.format(Double.parseDouble(resultYearStat.getCnt_11())));

            model.addAttribute("custstatsumlist", resultYearStat);//누적파기현황 // 통계 테이블(TBL_PIICUSTSTATYEAR)로 적재후 빠른 조회 방식으로 수정 20230426
        } catch (Exception ex) {
            logger.warn("warn "+"extractservice.getRunExtractResultSumStat()   " + ex.getMessage());
        }
//        model.addAttribute("policycnt", policyservice.getTotal(cri));
//        model.addAttribute("jobcnt", jobservice.getPiiTotalCount());
//        model.addAttribute("steptablecnt", steptableservice.getTotalDistinctTabCount());
//        model.addAttribute("tableconfiglist", steptableservice.getTableConfigStatus());

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

        int total = 0;//orderservice.getTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/PiiDashboard pageMaker: " + pageMaker);

    }


}
