package datablocks.dlm.controller;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.exception.AES256Exception;
import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.jdbc.JdbcUtil;
import datablocks.dlm.service.*;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.SqlUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.security.Principal;
import java.sql.*;
import java.text.ParseException;
import java.util.List;

@Controller
@RequestMapping("/piirestore/*")
@AllArgsConstructor
public class PiiRestoreController {
    private static final Logger logger = LoggerFactory.getLogger(PiiRestoreController.class);
    private PiiRestoreService service;
    private PiiApprovalLineService approvalLineService;
//    private PiiApprovalUserService approvalUserService;
//    private PiiApprovalReqService approvalReqService;
//    private PiiMemberService memberservice;
    private PiiDatabaseService dbservice;
    private PiiOrderStepTableService orderStepTableservice;
    private ArchiveNamingService archiveNamingService;


    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register() {

    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("INFO", "/piirestore list(Criteria cri, Model model): " + cri);
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        LogUtil.log("INFO", "/piirestore total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piirestore pageMaker: " + pageMaker);
        String site = EnvConfig.getConfig("SITE");
        /*사이트별 UI 구성을 다르게 하기 위해 */
        model.addAttribute("site", site);
    }

    @GetMapping("/actorderlist")
    @PreAuthorize("isAuthenticated()")
    public void actorderlist(Criteria cri, Model model, HttpServletRequest request) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("WARN", "/piirestore actorderlist(Criteria cri, Model model): " + cri);
        logger.warn("INFO   "+"/piirestore actorderlist(Criteria cri, Model model): " + cri);
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
                || search6 != null || search7 != null || search8 != null ) {
            total = service.getActOrderListTotal(cri);
            /* ASC INDEX 자체를 사용하여 추가적인 ORDERBY DESC를 제거하여 속도 계선을 위해 */
            int start = total - (cri.getPagenum() * cri.getAmount());
            int end = total - ((cri.getPagenum() - 1) * cri.getAmount());
            if (start < 0) start = 0;
            int limit = end - start;
            try {
                cri.setOffset(start);
                cri.setAmount(limit);
            } catch (Exception ex) {
                cri.setOffset(start);
                cri.setAmount(limit);
            }// Maria DB 용

            model.addAttribute("list", service.getActOrderList(cri));
            cri.setAmount(100);
		}

        String site = EnvConfig.getConfig("SITE");
        /*사이트별 UI 구성을 다르게 하기 위해 */
        model.addAttribute("site", site);

        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
    }

    @ResponseBody
    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(@RequestBody List<PiiRestoreVO> restorelist, Criteria cri, @RequestParam("reqreason") String reqreason,@RequestParam("aprvlineid") String aprvlineid, @RequestParam("applytype") String applytype, Model model, Principal principal) {
        LogUtil.log("INFO", "/piirestore register: " + cri + " " + reqreason + " " + aprvlineid + " " + applytype + " " + applytype);
        return service.register(restorelist, principal, reqreason, aprvlineid, applytype);
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("restoreid") int restoreid, Criteria cri, Model model) {
        LogUtil.log("INFO", "/piirestore @GetMapping  /get or modify = " + restoreid);
        model.addAttribute("piirestore", service.get(restoreid));

        model.addAttribute("cri", cri);
    }

    @GetMapping({"/requestapproval"})
    @PreAuthorize("isAuthenticated()")
    public String requestapproval(@RequestParam("restoreid") int restoreid, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "/piirestore @GetMapping  /requestapproval = " + restoreid);
        if (service.requestapproval(restoreid)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("restoreid", restoreid);

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piirestore/list";
    }


    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiRestoreVO piirestore, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping modify:" + piirestore);
        if (service.modify(piirestore)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("restoreid", piirestore.getRestoreid());

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piirestore/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiRestoreVO piirestore, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping remove..." + piirestore.getRestoreid());
        if (service.remove(piirestore.getRestoreid())) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piirestore/list";
    }

    @GetMapping({ "/arccustlist" })
    @PreAuthorize("isAuthenticated()")
    public void arccustlist(Criteria cri, Model model, Authentication authentication) {
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        LogUtil.log("INFO", "/piidatabase @GetMapping({arccustlist)  userDetails.getUsername(): "+userDetails.getUsername());

        model.addAttribute("arccustlist", service.getArcCustBrowseList(userDetails.getUsername()));
        model.addAttribute("arctablelist", orderStepTableservice.getArcTableList());
        model.addAttribute("cri", cri);
        //log.info(cri.toString());
    }
    @ResponseBody
    @RequestMapping(value="arccustbrowse", produces="application/text;charset=UTF-8", method=RequestMethod.POST)
    @PreAuthorize("isAuthenticated()")
    public String arccustbrowse(@RequestBody PiiArcCustBrowseVO arccustVO, Model model)  {
        logger.warn("warn "+"/arccustbrowse - "+ arccustVO.toString());

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        String sel_str = null;;
        StringBuilder result_msg = new StringBuilder();

        PiiDatabaseVO dbVO = dbservice.get("DLMARC");
        try{
            AES256Util aes=new AES256Util();
            dbVO.setPwd(aes.decrypt(dbVO.getPwd()));
        } catch (Exception ex) {
            throw new AES256Exception("AES256 encoding exception");
        }

        try {
            conn = ConnectionProvider.getConnection(dbVO.getDbtype()
                    , dbVO.getHostname()
                    , dbVO.getPort()
                    , dbVO.getId_type()
                    , dbVO.getId()
                    , dbVO.getDb()
                    , dbVO.getDbuser()
                    , dbVO.getPwd()
            );

            String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, arccustVO.getDb(), arccustVO.getOwner(), arccustVO.getTable_name());
            sel_str = "select * from "+archiveTablePath+" where pii_cust_id='"+arccustVO.getCustid()+"'";
            stmt = conn.createStatement();
            rs = stmt.executeQuery(SqlUtil.getSelectWithQuery(dbVO.getDbtype(), 1001, sel_str));
            ResultSetMetaData rsmd = rs.getMetaData();
            int columnCount = rsmd.getColumnCount();
            result_msg.append("<table  id=\"listTable\" class=\" table-hover\" >");
            result_msg.append("<tr>");
            // The column count starts from 1
            for (int i = 1; i <= columnCount; i++ ) {
                String name = rsmd.getColumnName(i);
                if(i != 2 && i != 3 && i != 4 && i != 5 && i != 6)
                    result_msg.append("<th scope=\"row\" class=\"th-get\">" + rsmd.getColumnName(i) + "</th>");

            }
            result_msg.append("</tr>");
            while( rs.next() ) {
                result_msg.append("<tr>");
                // The column count starts from 1
                for (int i = 1; i <= columnCount; i++ ) {
                    if(i != 2 && i != 3 && i != 4 && i != 5 && i != 6)
                        result_msg.append("<td>"+rs.getString(i)+"</td>");
                }
                result_msg.append("</tr>");
            }
            result_msg.append("</table>");
            return result_msg.toString();

        } catch(SQLSyntaxErrorException ex) {
            logger.warn("warn "+"SQLSyntaxErrorException "+ex.getMessage() +"==>"+sel_str);
            ex.printStackTrace();
            JdbcUtil.rollback(conn);
            return ex.toString()+"==>"+sel_str;
        } catch(SQLRecoverableException ex) {
            logger.warn("warn "+"SQLRecoverableException "+ex.getMessage() +"==>"+sel_str);
            ex.printStackTrace();
            JdbcUtil.rollback(conn);
            return ex.toString()+"==>"+sel_str;
        } catch(NullPointerException ex) {
            logger.warn("warn "+"NullPointerException "+"Connection information wrong !!  ");
            ex.printStackTrace();
            JdbcUtil.rollback(conn);
            return ex.toString()+"==>"+sel_str;
        } catch(Exception ex) {
            logger.warn("warn "+"Exception - "+ex.getMessage() +"==>"+sel_str);
            ex.printStackTrace();
            JdbcUtil.rollback(conn);
            return ex.toString()+"==>"+sel_str;
        } finally {
            JdbcUtil.close(conn);
            JdbcUtil.close(stmt);
        }
    }
}
