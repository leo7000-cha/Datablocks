package datablocks.dlm.controller;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.domain.PiiRestoreVO;
import datablocks.dlm.schedule.JobScheduler;
import datablocks.dlm.service.*;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.text.SimpleDateFormat;
import java.util.Date;

@Controller
@RequestMapping("/piiextract")
@AllArgsConstructor
public class PiiExtractController {
    private static final Logger logger = LoggerFactory.getLogger(PiiExtractController.class);
    private PiiExtractService service;
    private PiiReportService reportService;
    private JobScheduler jobScheduler;
//    private PiiSystemService systemSV;
//    private PiiPolicyService policySV;
//    private PiiJobService jobSV;
    private DepartmentService departmentService;
    private PiiPolicyService policySV;

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {

        LogUtil.log("INFO", "/piiextract list(Criteria cri, Model model): " + cri);
        int total = 0;
        String search1 = cri.getSearch1();
        String search2 = cri.getSearch2();
        String search3 = cri.getSearch3();
        String search4 = cri.getSearch4();
        String search5 = cri.getSearch5();
        String search6 = cri.getSearch6();
        String search7 = cri.getSearch7();
        String search8 = cri.getSearch8();
        if (search1 != null || search2 != null || search3 != null || search4 != null || search5 != null
                || search6 != null || search7 != null || search8 != null) {
            total = service.getTotal(cri);
            /* ASC INDEX 자체를 사용하여 추가적인 ORDERBY DESC를 제거하여 속도 계선을 위해 */
            int start = total - (cri.getPagenum() * cri.getAmount());
            int end = total - ((cri.getPagenum() - 1) * cri.getAmount());
            if (start < 0) start = 0;
            int limit = end - start;
//            logger.warn("warn "+total + "  1 list(Criteria cri, Model model): " + cri);
            try {
                cri.setOffset(start);
                cri.setAmount(limit);
            } catch (Exception ex) {
                cri.setOffset(start);
                cri.setAmount(limit);
            }// Maria DB 용
//            logger.warn("warn "+total + "  2list(Criteria cri, Model model): " + cri);
            model.addAttribute("list", service.getList(cri));
            cri.setAmount(100);
        }
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("listpolicy", policySV.getList());
    }

    @GetMapping("/custstatlist")
    @PreAuthorize("isAuthenticated()")
    public void custstatlist(Criteria cri, Model model) {

        LogUtil.log("INFO", "/piiextract custstatlist(Criteria cri, Model model): " + cri);
        int total = 0;
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        Date today = new Date();
        SimpleDateFormat yyyymm = new SimpleDateFormat("yyyy/MM");
        SimpleDateFormat yyyy = new SimpleDateFormat("yyyy");
        String curmonth = yyyymm.format(today);
        String curyear = yyyy.format(today);

        if(StrUtil.checkString(cri.getSearch6())) {
            cri.setSearch6("MONTHLY");
        }

        if("MONTHLY".equalsIgnoreCase(cri.getSearch6())){
            if(StrUtil.checkString(cri.getSearch4())) {
                cri.setSearch4(curmonth);
            }
            cri.setSearch5(cri.getSearch4());
            model.addAttribute("list", service.getCustStatList(cri));
            total = service.getCustStatTotal(cri);
        }else if("QUARTERLY".equalsIgnoreCase(cri.getSearch6())){
            if(StrUtil.checkString(cri.getSearch4())) {
                cri.setSearch4(curyear+"/01");
            }
//            if(StrUtil.checkString(cri.getSearch5())) {
//                cri.setSearch5(curmonth);
//            }
            model.addAttribute("list", service.getCustStatList(cri));
            total = service.getCustStatTotal(cri);
        }else if("MONTHLY_CONSENT".equalsIgnoreCase(cri.getSearch6())){
            if(StrUtil.checkString(cri.getSearch4())) {
                cri.setSearch4(curmonth);
            }
            cri.setSearch5(cri.getSearch4());
            model.addAttribute("list", service.getCustStatList_consent(cri));
            total = service.getCustStatTotal_consent(cri);
        }

        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);

        model.addAttribute("listdepartment", departmentService.getList());
    }


    @ResponseBody
    @PostMapping("/reportregister")
    @PreAuthorize("isAuthenticated()")
    public String reportregister(Criteria cri, @RequestParam("reqreason") String reqreason,@RequestParam("aprvlineid") String aprvlineid, @RequestParam("applytype") String applytype, Model model, Principal
    principal) {
        logger.warn("warn "+"/reportregister register: " + cri + " " + reqreason + " " + aprvlineid + " " + applytype + " " + applytype);
        return reportService.register(cri, principal, reqreason, aprvlineid, applytype);
    }

    @ResponseBody
    @PostMapping("/purge")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public String purge() {
        try {
            logger.info("info " + "/piiextract/purge 수동 실행 시작");
            jobScheduler.purgeCompletedExtractRecords();
            return "{\"status\":\"OK\",\"message\":\"퍼지 완료\"}";
        } catch (Exception ex) {
            logger.error("error " + "/piiextract/purge 실패: " + ex.toString(), ex);
            String safeMsg = (ex.getMessage() != null)
                    ? ex.getMessage().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "")
                    : "Unknown error";
            return "{\"status\":\"FAIL\",\"message\":\"" + safeMsg + "\"}";
        }
    }
}
