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
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

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

    // 대시보드용 병렬 실행 풀 (DB 6개 stat 쿼리 동시 수행). Hikari 커넥션 풀 여유 범위 내에서 제한.
    private static final ExecutorService DASHBOARD_POOL = Executors.newFixedThreadPool(6, r -> {
        Thread t = new Thread(r, "dashboard-stat");
        t.setDaemon(true);
        return t;
    });

    @GetMapping("/dashboard")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model, Authentication authentication) {

        long totalStart = System.currentTimeMillis();
        long lap;
        logger.info("[PERF] ========== Dashboard loading START ==========");

        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        final String username = userDetails.getUsername();

        // 1) 사용자 조회 (이전: 동일 사용자 2회 조회 — dedupe)
        lap = System.currentTimeMillis();
        PiiMemberVO piimember = memberservice.get(username);
        logger.info("[PERF] memberservice.get('{}') → {} ms", username, System.currentTimeMillis() - lap);

        // 2) 비밀번호 만료/초기 여부를 병렬로 계산 (둘 다 username 기반이고 서로 독립)
        final PiiMemberVO memberForPwd = piimember;
        CompletableFuture<String> pwdFlagFuture = CompletableFuture.supplyAsync(() -> {
            String flag = "";
            try {
                if (memberservice.getPwdElapsedCount(username) > 0) {
                    flag = "EXPIRED";
                }
            } catch (Exception ex) {
                logger.warn("dashboard: pwd expiry check failed for userId=" + username);
            }
            try {
                if (memberForPwd != null
                        && PasswordEncoder.matches("#" + username, memberForPwd.getUserpw())) {
                    flag = "INI";
                }
            } catch (Exception ex) {
                logger.warn("dashboard: initial pwd check failed for userId=" + username);
            }
            return flag;
        }, DASHBOARD_POOL);

        // 3) 독립적 통계 쿼리 6개를 병렬 실행
        CompletableFuture<Object> f1 = CompletableFuture.supplyAsync(() -> {
            try { return orderservice.getRunResultStat(); }
            catch (Exception ex) { logger.warn("orderservice.getRunResultStat: " + ex.getMessage()); return null; }
        }, DASHBOARD_POOL);

        CompletableFuture<List<PiiCustStatVO>> f2 = CompletableFuture.supplyAsync(() -> {
            try { return extractservice.getCustStatListDaily(cri); }
            catch (Exception ex) { logger.warn("extractservice.getCustStatListDaily: " + ex.getMessage()); return null; }
        }, DASHBOARD_POOL);

        CompletableFuture<Object> f3 = CompletableFuture.supplyAsync(() -> {
            try { return extractservice.getCustStatListMonthly(cri); }
            catch (Exception ex) { logger.warn("extractservice.getCustStatListMonthly: " + ex.getMessage()); return null; }
        }, DASHBOARD_POOL);

        CompletableFuture<Object> f4 = CompletableFuture.supplyAsync(() -> {
            try { return contractService.getStatList12Month(); }
            catch (Exception ex) { logger.warn("contractService.getStatList12Month: " + ex.getMessage()); return null; }
        }, DASHBOARD_POOL);

        CompletableFuture<List<?>> f5 = CompletableFuture.supplyAsync(() -> {
            try { return metaPiiStatusService.getListByDb(); }
            catch (Exception ex) { logger.warn("metaPiiStatusService.getListByDb: " + ex.getMessage()); return null; }
        }, DASHBOARD_POOL);

        CompletableFuture<PiiExtractRunRusultYearStatVO> f6 = CompletableFuture.supplyAsync(() -> {
            try { return extractservice.getRunExtractResultSumStat(); }
            catch (Exception ex) { logger.warn("extractservice.getRunExtractResultSumStat: " + ex.getMessage()); return null; }
        }, DASHBOARD_POOL);

        // 4) 캐시된 설정은 EnvConfig 에서 꺼냄 (DB 왕복 없음). 컨트롤러가 6회→0회 DB 콜 감소.
        model.addAttribute("dashboardShow", EnvConfig.getConfig("DASHBOARD_SHOW"));
        model.addAttribute("notice1", EnvConfig.getConfig("NOTICE1"));
        model.addAttribute("notice2", EnvConfig.getConfig("NOTICE2"));
        model.addAttribute("notice3", EnvConfig.getConfig("NOTICE3"));
        model.addAttribute("notice4", EnvConfig.getConfig("NOTICE4"));
        model.addAttribute("notice5", EnvConfig.getConfig("NOTICE5"));
        model.addAttribute("userid", username);

        // 5) 병렬 결과 취합
        lap = System.currentTimeMillis();
        try { model.addAttribute("needtochangepwd", pwdFlagFuture.get()); }
        catch (InterruptedException | ExecutionException e) { Thread.currentThread().interrupt(); model.addAttribute("needtochangepwd", ""); }

        try { model.addAttribute("jobresultlist", f1.get()); } catch (Exception e) { /* logged above */ }
        try { model.addAttribute("custstatlistdaily", f2.get()); } catch (Exception e) { /* logged above */ }
        try { model.addAttribute("custstatlistmonthly", f3.get()); } catch (Exception e) { /* logged above */ }
        try { model.addAttribute("realdocstatlistmonthly", f4.get()); } catch (Exception e) { /* logged above */ }
        try { model.addAttribute("piiallstatus", f5.get()); } catch (Exception e) { /* logged above */ }
        try { model.addAttribute("custstatsumlist", f6.get()); } catch (Exception e) { /* logged above */ }
        logger.info("[PERF] parallel stats join → {} ms", System.currentTimeMillis() - lap);

        int total = 0;
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);

        logger.info("[PERF] ========== Dashboard loading END — TOTAL {} ms ==========", System.currentTimeMillis() - totalStart);
    }


}
