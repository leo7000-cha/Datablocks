package datablocks.dlm.controller;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.LkPiiScrTypeMapper;
import datablocks.dlm.service.*;
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

import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;
//import net.sf.jasperreports.engine.JRException;

@Controller
@RequestMapping("/piiorder/*")
@AllArgsConstructor
public class PIIOrderController {
    private static final Logger logger = LoggerFactory.getLogger(PIIOrderController.class);
    private PiiOrderService orderSV;
    private PiiOrderStepService orderstepSV;
    private PiiSystemService systemSV;
    private PiiJobService jobSV;
    private PiiOrderStepTableService ordersteptableSV;
    private PiiOrderStepTableUpdateService ordersteptableupdateSV;
    private PiiTableService tableSV;
    private PiiOrderStepTableWaitService ordersteptablewaitSV;
    private MetaTableService metaTableService;
    private LkPiiScrTypeService lkPiiScrTypeService;
    @Autowired
    private PiiOrderThreadService threadSV;

    @Autowired
    private PiiStepTableService steptableSV;

    @Autowired
    private PiiConfigService configSV;

    @Autowired
    private PiiDatabaseService databaseservice;

    @Autowired
    private InnerStepService innerStepSV;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register() {

    }

    @GetMapping("/actionpopup")
    @PreAuthorize("isAuthenticated()")
    public void actionpopup() {

    }

    @GetMapping({"/list", "/jobcontrol"})
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {
        LogUtil.log("INFO", "list(Criteria cri, Model model): " + cri);

        SimpleDateFormat dateForm = new SimpleDateFormat("yyyy/MM/dd");
        if (cri.getSearch2() != null) {
            if (cri.getSearch2().length() != 10) {
                cri.setSearch2(null);
            } else {
                String format = null;
                try {
                    format = dateForm.format(dateForm.parse(cri.getSearch2()));
                    cri.setSearch2(format);
                } catch (Exception e) {
                    cri.setSearch2(null);
                }
            }
        }
//        cri.setAmount(10);
        int total = orderSV.getTotal(cri);
        /* ASC INDEX 자체를 사용하여 추가적인 ORDERBY DESC를 제거하여 속도 계선을 위해 */
        int start = total-(cri.getPagenum()*cri.getAmount());
        int end = total-((cri.getPagenum()-1)*cri.getAmount());
        if(start < 0) start = 0;
        int limit = end - start;
//        logger.warn("warn "+total+ "  1 list(Criteria cri, Model model): " + cri);
        try {
            cri.setOffset(start);
            cri.setAmount(limit);
        } catch (Exception ex) {
            cri.setOffset(start);
            cri.setAmount(limit);
        }// Maria DB 용
//        logger.warn("warn "+total+ "  2 list(Criteria cri, Model model): " + cri);
        model.addAttribute("list", orderSV.getListDetail(cri));
        cri.setAmount(100);

        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "pageMaker: " + pageMaker);
        model.addAttribute("listjob", orderSV.getOrderJobList());
    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(PiiOrderVO piiorder, RedirectAttributes rttr) {

        LogUtil.log("INFO", "register: " + piiorder);

        orderSV.register(piiorder);

        rttr.addFlashAttribute("result", "success");

        return "redirect:/piiorder/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("orderid") int orderid, Criteria cri, Model model) {

        LogUtil.log("INFO", "/get or modify" + orderid);
        model.addAttribute("piiorder", orderSV.get(orderid));

        model.addAttribute("cri", cri);
        //logger.info(cri.toString());
    }

    @GetMapping({"/getordertable"})
    @PreAuthorize("isAuthenticated()")
    public void getordertable(@RequestParam("orderid") int orderid
            , @RequestParam("stepid") String stepid
            , @RequestParam("seq1") int seq1
            , @RequestParam("seq2") int seq2
            , @RequestParam("seq3") int seq3
            , Criteria cri, Model model) {

        LogUtil.log("INFO", "/getordertable" + orderid);
        PiiOrderStepTableVO ordersteptableVO = ordersteptableSV.getWithSeq(orderid, stepid, seq1, seq2, seq3);
        PiiOrderStepVO orderstepVO = orderstepSV.get(orderid, ordersteptableVO.getJobid(), ordersteptableVO.getVersion(), ordersteptableVO.getStepid());
        model.addAttribute("piiordersteptable", ordersteptableVO);
        PiiStepTableVO steptableVO = steptableSV.getWithSeq(ordersteptableVO.getJobid(), ordersteptableVO.getVersion(), stepid, seq1, seq2, seq3);
        model.addAttribute("piisteptable", steptableVO);
        model.addAttribute("piijob", jobSV.get(ordersteptableVO.getJobid(), ordersteptableVO.getVersion()));
        model.addAttribute("liststeptablewait", ordersteptablewaitSV.getList(orderid, ordersteptableVO.getJobid(), ordersteptableVO.getVersion(), ordersteptableVO.getStepid(), ordersteptableVO.getDb(), ordersteptableVO.getOwner(), ordersteptableVO.getTable_name()));
        model.addAttribute("liststeptableupdate", ordersteptableupdateSV.getList(orderid, ordersteptableVO.getStepid(), seq1, seq2, seq3));
        model.addAttribute("cri", cri);
        Criteria cri_metatable = new Criteria();
        /** 메타 정보가 운영계 기준으로 정의되어 있어서 입력된 DB 의 시스템 기준 운영 DB로 변경해준다. 20240428*/
        PiiDatabaseVO dbVO_Prod = null;
//        if("SCRAMBLE".equalsIgnoreCase(ordersteptableVO.getExetype())){
//            /** SCRAMBLE은 step의 DB가 source 임. 20241013*/
//            String sourcedb = orderstepVO.getDb();
//            dbVO_Prod = databaseservice.get(sourcedb);
//        } else {
            dbVO_Prod = databaseservice.getBySystem(databaseservice.get(ordersteptableVO.getDb()).getSystem());
//        }
        cri_metatable.setSearch1(dbVO_Prod.getDb());
        cri_metatable.setSearch2(ordersteptableVO.getOwner());
        cri_metatable.setSearch3(ordersteptableVO.getTable_name());
        model.addAttribute("listscramblecolumn", metaTableService.getListForOneTable(cri_metatable));
        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());
        //logger.info(cri.toString());
    }

    @GetMapping({"/getinnersteplist"})
    @PreAuthorize("isAuthenticated()")
    public void getinnersteplist(@RequestParam("orderid") int orderid
            , @RequestParam("stepid") String stepid
            , @RequestParam("seq1") int seq1
            , @RequestParam("seq2") int seq2
            , @RequestParam("seq3") int seq3
            , Criteria cri, Model model) {

        LogUtil.log("INFO", "/getinnersteplist" + orderid);
        model.addAttribute("innerstepvolist", innerStepSV.getList(orderid, stepid, seq1, seq2, seq3, -1));
        model.addAttribute("cri", cri);

    }

    @GetMapping({"/modifyordertable"})
    @PreAuthorize("isAuthenticated()")
    public void modifyordertable(@RequestParam("orderid") int orderid
            , @RequestParam("stepid") String stepid
            , @RequestParam("seq1") int seq1
            , @RequestParam("seq2") int seq2
            , @RequestParam("seq3") int seq3
            , Criteria cri, Model model) {

        LogUtil.log("INFO", "/modifyordertable" + orderid);
        PiiOrderStepTableVO ordersteptableVO = ordersteptableSV.getWithSeq(orderid, stepid, seq1, seq2, seq3);
        PiiOrderStepVO orderstepVO = orderstepSV.get(orderid, ordersteptableVO.getJobid(), ordersteptableVO.getVersion(), ordersteptableVO.getStepid());
        model.addAttribute("piiordersteptable", ordersteptableVO);
        PiiStepTableVO steptableVO = steptableSV.getWithSeq(ordersteptableVO.getJobid(), ordersteptableVO.getVersion(), stepid, seq1, seq2, seq3);
        model.addAttribute("piisteptable", steptableVO);
        model.addAttribute("piijob", jobSV.get(ordersteptableVO.getJobid(), ordersteptableVO.getVersion()));
        model.addAttribute("liststeptablewait", ordersteptablewaitSV.getList(orderid, ordersteptableVO.getJobid(), ordersteptableVO.getVersion(), ordersteptableVO.getStepid(), ordersteptableVO.getDb(), ordersteptableVO.getOwner(), ordersteptableVO.getTable_name()));
        model.addAttribute("liststeptableupdate", ordersteptableupdateSV.getList(orderid, ordersteptableVO.getStepid(), seq1, seq2, seq3));
        model.addAttribute("cri", cri);
        Criteria cri_metatable = new Criteria();
        /** 메타 정보가 운영계 기준으로 정의되어 있어서 입력된 DB 의 시스템 기준 운영 DB로 변경해준다. 20240428*/
        PiiDatabaseVO dbVO_Prod = null;
//        if("SCRAMBLE".equalsIgnoreCase(ordersteptableVO.getExetype())){
//            /** SCRAMBLE은 step의 DB가 source 임. 20241013*/
//            String sourcedb = orderstepVO.getDb();
//            dbVO_Prod = databaseservice.get(sourcedb);
//        } else {
            dbVO_Prod = databaseservice.getBySystem(databaseservice.get(ordersteptableVO.getDb()).getSystem());
//        }
        cri_metatable.setSearch1(dbVO_Prod.getDb());
        cri_metatable.setSearch2(ordersteptableVO.getOwner());
        cri_metatable.setSearch3(ordersteptableVO.getTable_name());
        model.addAttribute("listscramblecolumn", metaTableService.getListForOneTable(cri_metatable));
        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());

        //logger.info(cri.toString());
    }

    @ResponseBody
    @PostMapping("/modifyordertable")
    @PreAuthorize("isAuthenticated()")
    public String modifyordertable(@RequestBody PiiOrderStepTableVO piiordersteptable, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping modifyordertable:" + piiordersteptable);

        if (!ordersteptableSV.modifyOrderTableDetail(piiordersteptable)) {
            model.addAttribute("result", "fail");
            return "fail";
        }

        model.addAttribute("result", "success");
        return "success";

    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiOrderVO piiorder, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "modify:" + piiorder);

        if (orderSV.modify(piiorder)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        return "redirect:/piiorder/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiOrderVO piiorder, Criteria cri, RedirectAttributes rttr) {

        LogUtil.log("INFO", "remove..." + piiorder);
        if (orderSV.remove(piiorder.getOrderid())) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        return "redirect:/piiorder/list";
    }

    @PostMapping("/removeOrder")
    @PreAuthorize("isAuthenticated()")
    public String removeOrder(@RequestBody List<PiiOrderVO> orderlist, Criteria cri, Model model) {

        LogUtil.log("INFO", "@PostMapping removeOrder.............................");

        for (PiiOrderVO piiorder : orderlist) {
            //logger.info(piiorder.toString());
            if (orderSV.remove(piiorder.getOrderid())) {
                model.addAttribute("result", "success");
                //LogUtil.log("INFO", "/removeOrder approval req = success  =>  "+ piiorder.toString());
            } else {
                logger.warn("warn "+"/removeOrder fail => " + piiorder.toString());
            }

        }
        return "redirect:/piiorder/jobcontrol";
    }


    @ResponseBody
    @PostMapping("/updateactionflag")
    @PreAuthorize("isAuthenticated()")
    public String updateactionflag(@RequestBody List<PiiOrderVO> orderlist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping updateactionflag.............................");
        for (PiiOrderVO piiorder : orderlist) {
            logger.warn("warn "+piiorder.toString());
            if (orderSV.updateactionflag(piiorder)) {
                model.addAttribute("result", "success");
            } else {
                logger.warn("warn "+"/updateactionflag fail => " + piiorder.toString());
            }

        }
        return "success";
    }

    @ResponseBody
    @PostMapping("/rerun")
    @PreAuthorize("isAuthenticated()")
    public String rerun(@RequestBody List<PiiOrderVO> orderlist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping rerun.............................");
        for (PiiOrderVO piiorder : orderlist) {
            //logger.info(piiorder.toString());
            if (orderSV.rerun(piiorder.getOrderid())) {
                orderstepSV.rerun(piiorder.getOrderid());
                ordersteptableSV.rerun(piiorder.getOrderid());
                threadSV.delete(piiorder.getOrderid());
                model.addAttribute("result", "success");
                //LogUtil.log("INFO", "/rerun = success => "+ piiorder.toString());
            } else {
                LogUtil.log("INFO", "/rerun = fail => "+ piiorder.toString());
            }

        }

        return "success";
    }

    @GetMapping({"/getorderdetail"})
    @PreAuthorize("isAuthenticated()")
    public void getorderdetail(@RequestParam("orderid") int orderid, @RequestParam("jobid") String jobid, @RequestParam("version") String version, @RequestParam("stepseq") int stepseq, @RequestParam("action") int action, Model model) {
        LogUtil.log("INFO", "/piiorder @GetMapping  /getorderdetail = " + orderid + " " + jobid + " " + version + " " + stepseq);
        model.addAttribute("piiorder", orderSV.get(orderid));
        model.addAttribute("liststep", orderstepSV.getOrderStepList(orderid));
        PiiOrderStepVO orderstep;
        if (stepseq == 0)
            orderstep = orderstepSV.getFirstStep(orderid);
        else
            orderstep = orderstepSV.getByStepseq(orderid, stepseq);

        model.addAttribute("piiorderstep", orderstep);

        String stepidnew = orderstep.getStepid();
        //String steptype = orderstepSV.get(orderid, jobid, version, stepidnew).getSteptype();
        String steptype = orderstep.getSteptype();
        String steptableorderby = "DESC";
        try {
            steptableorderby = EnvConfig.getConfig("DLM_TABLELIST_ORDERBY");
        } catch (NullPointerException ex) {
            LogUtil.log("INFO", " DLM_RUN_FLAG="+ex);
        }

        List<PiiOrderStepTableVO> liststeptablerst= null;
        if (steptype.equals("GEN_KEYMAP")
                || steptype.equals("EXE_RESTORE")
                || steptype.equals("EXE_RECOVERY")
                || steptype.equals("EXE_FINISH")
                || steptype.equals("EXE_EXTRACT")
                || steptype.equals("EXE_BROADCAST")
                || steptype.equals("EXE_MIGRATE")
                || steptype.equals("EXE_SYNC")
                || steptype.equals("EXE_HOMECAST")
        ) {
            liststeptablerst = ordersteptableSV.getStepTableListasc(orderid, stepidnew);
        }
        else if (steptype.equals("EXE_ARCHIVE") || steptype.equals("EXE_DELETE") || steptype.equals("EXE_UPDATE")) {
            if (steptableorderby.equalsIgnoreCase("DESC")) {
                liststeptablerst = ordersteptableSV.getStepTableList(orderid, stepidnew);
            }
            else {
                liststeptablerst =ordersteptableSV.getStepTableListasc(orderid, stepidnew);
            }
        } else {
            liststeptablerst =ordersteptableSV.getStepTableListasc(orderid, stepidnew);
        }

        NumberFormat numberFormat = NumberFormat.getNumberInstance(Locale.US);
        for (PiiOrderStepTableVO stepTableVO : liststeptablerst) {
            // 특정 칼럼의 값을 가져와서 숫자 포맷팅
            if(StrUtil.checkString(stepTableVO.getExecnt())) continue;

            int originalValue = StrUtil.parseInt(stepTableVO.getExecnt()); // 여기서 'YourSpecificColumn'은 실제 칼럼명이어야 합니다.
            String formattedValue = numberFormat.format(originalValue);

            // 포맷팅된 값을 다시 객체에 설정 (이 부분은 필요에 따라 처리)
            stepTableVO.setExecnt(formattedValue);
        }
        model.addAttribute("liststeptable", liststeptablerst);

        model.addAttribute("liststepstatus", orderstepSV.getRunStatusList(orderid));
        model.addAttribute("action", action);

        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());
        ////logger.info(orderSV.get(jobid));
    }

    @ResponseBody
    /* @PostMapping(value="getStepTableStr")*/
    @RequestMapping(value = "getStepTableStr", produces = "application/text;charset=UTF-8", method = RequestMethod.POST)
    @PreAuthorize("isAuthenticated()")
    public String getStepTableStr(@RequestBody PiiOrderStepTablePkVO ordersteptablepk, Criteria cri, Model model) {
        LogUtil.log("INFO", "getStepTableStr(: " + ordersteptablepk);

        PiiOrderStepTableVO ordersteptable = ordersteptableSV.getWithSeq(ordersteptablepk.getOrderid(), ordersteptablepk.getStepid(), ordersteptablepk.getSeq1(), ordersteptablepk.getSeq2(), ordersteptablepk.getSeq3());
        if (ordersteptable.getSqlmsg() == null) ordersteptable.setSqlmsg("");
        if (ordersteptable.getSqlstr() == null) ordersteptable.setSqlstr("");
        String str = ordersteptable.getSqlstr();
        if (ordersteptable.getExetype().equalsIgnoreCase("MIGRATE")
                || ordersteptable.getExetype().equalsIgnoreCase("SCRAMBLE")
                || ordersteptable.getExetype().equalsIgnoreCase("SYNC")
        ) str = ordersteptable.getWherestr();

        StringBuilder htmlStr = new StringBuilder();

        if(!StrUtil.checkString(ordersteptable.getSqlmsg())) {
            htmlStr.append("<div class=\"sql-error-bar\">"
                            + "<div id=\"orderdetailsqlmsg\" class=\"sql-error-msg\">"
                            + "<i class=\"fas fa-exclamation-circle\"></i>"
                            + ordersteptable.getSqlmsg()
                            + "</div>"
                            + "<button class=\"sql-magnify-btn\" onclick=\"magnify();\" title=\"상세보기\">"
                            + "<i class=\"fas fa-search-plus\"></i>"
                            + "</button>"
                    + "</div>");

            htmlStr.append("<textarea spellcheck=\"false\" id=\"sqlstr\" class=\"sql-code-area\">"
                            + str + "</textarea>");

        }else{
            htmlStr.append("<textarea spellcheck=\"false\" id=\"sqlstr\" class=\"sql-code-area\">"
                    + str + "</textarea>");
        }



        return htmlStr.toString();
    }

    @GetMapping({"/report"})
    @PreAuthorize("isAuthenticated()")
    public void report(Criteria cri, Model model) {
        LogUtil.log("INFO", "report(Criteria cri, Model model): " + cri);

        model.addAttribute("list", ordersteptableSV.getOrderReportList(cri));
        int total = ordersteptableSV.getTotalReportCount(cri);
        //LogUtil.log("INFO", "total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);

        model.addAttribute("listsystem", systemSV.getList());
        model.addAttribute("listjob", orderSV.getOrderJobList());
        //LogUtil.log("INFO", "pageMaker: " + pageMaker);
    }


    @GetMapping({"/modifyordersteptableupdatedialog"})
    @PreAuthorize("isAuthenticated()")
    public void modifyordersteptableupdatedialog(@RequestParam("orderid") String orderid, @RequestParam("jobid") String jobid, @RequestParam("version") String version,
                                                 @RequestParam("stepid") String stepid, Criteria cri,
                                                 Model model) {
        LogUtil.log("INFO", "modifyordersteptableupdatedialog  orderid:" + orderid);
        model.addAttribute("piiordersteptable", ordersteptableSV.getWithSeq(Integer.parseInt(orderid), stepid, Integer.parseInt(cri.getSearch1()), Integer.parseInt(cri.getSearch2()), Integer.parseInt(cri.getSearch3())));
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("piitablelist", tableSV.getList(cri));
        model.addAttribute("listordersteptableupdate", ordersteptableupdateSV.getList(Integer.parseInt(orderid), stepid, Integer.parseInt(cri.getSearch1()), Integer.parseInt(cri.getSearch2()), Integer.parseInt(cri.getSearch3())));
        //model.addAttribute("liststeptable", orderSV.getStepTableList(cri));
        model.addAttribute("cri", cri);
        //logger.info(steptablewait.getList(jobid, version, stepid, db, owner, table_name));

    }

    @ResponseBody
    @PostMapping("/modifyordersteptableupdate")
    @PreAuthorize("isAuthenticated()")
    public String modifysteptableupdate(@RequestBody List<PiiOrderStepTableUpdateVO> ordersteptableupdatelist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping modifysteptableupdate............................." + cri);

        return ordersteptableupdateSV.modifyordersteptableupdate(ordersteptableupdatelist);

    }

    @GetMapping({"/modifyordersteptablewaitdialog"})
    @PreAuthorize("isAuthenticated()")
    public void modifyordersteptablewaitdialog(@RequestParam("orderid") String orderid, @RequestParam("jobid") String jobid, @RequestParam("version") String version,
                                               @RequestParam("stepid") String stepid, @RequestParam("db") String db,
                                               @RequestParam("owner") String owner, @RequestParam("table_name") String table_name, Criteria cri,
                                               Model model) {

        LogUtil.log("INFO", "/piijob @GetMapping  /modifysteptablewaitdialog = " + jobid + "-" + version + "-" + stepid + "  " + table_name + "  " + cri);

        model.addAttribute("piiordersteptable", ordersteptableSV.get(Integer.parseInt(orderid), jobid, version, stepid, db, owner, table_name));
        model.addAttribute("liststeptable", ordersteptableSV.getStepTableList(Integer.parseInt(orderid), stepid));
        model.addAttribute("listordersteptablewait", ordersteptablewaitSV.getList(Integer.parseInt(orderid), jobid, version, stepid, db, owner, table_name));
        model.addAttribute("cri", cri);
        //logger.info(steptablewait.getList(jobid, version, stepid, db, owner, table_name));

    }

    @ResponseBody
    @PostMapping("/modifyordersteptablewait")
    @PreAuthorize("isAuthenticated()")
    public String modifyordersteptablewait(@RequestBody List<PiiOrderStepTableWaitVO> ordersteptablewaitlist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping modifysteptablewait............................." + cri);

        return ordersteptablewaitSV.modifysteptablewait(ordersteptablewaitlist);
    }

}
