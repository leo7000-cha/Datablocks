package datablocks.dlm.controller;

import datablocks.dlm.domain.*;
import datablocks.dlm.exception.AES256Exception;
import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.jdbc.JdbcUtil;
import datablocks.dlm.service.ExcelService;
import datablocks.dlm.service.PiiDatabaseService;
import datablocks.dlm.service.PiiSystemService;
import datablocks.dlm.util.*;
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
import java.util.*;
import java.util.Locale;

@Controller
@RequestMapping("/piidatabase/*")
@AllArgsConstructor
public class PiiDatabaseController {
    private static final Logger logger = LoggerFactory.getLogger(PiiDatabaseController.class);
    private PiiDatabaseService service;
    private PiiSystemService systemSV;
    private ExcelService excelService;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model) {
        model.addAttribute("listsystem", systemSV.getList());
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {

        LogUtil.log("INFO", "/piidatabase list(Criteria cri, Model model): " + cri);
        try {
            cri.setOffset((cri.getPagenum() - 1) * cri.getAmount());
        } catch (Exception ex) {
            cri.setOffset(0);
        }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        model.addAttribute("listsystem", systemSV.getList());
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/piidatabase total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piidatabase pageMaker: " + pageMaker);
    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(PiiDatabaseVO piidatabase, RedirectAttributes rttr) throws Exception {

        LogUtil.log("INFO", "register: " + piidatabase);
        try {
            AES256Util aes = new AES256Util();
            piidatabase.setPwd(aes.encrypt(piidatabase.getPwd()));
        } catch (Exception ex) {
            throw new AES256Exception("AES256 encoding exception");
        }
        service.register(piidatabase);

        rttr.addFlashAttribute("result", "success");

        return "redirect:/piidatabase/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("db") String db, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piidatabase @GetMapping  /get or modify = " + db);
        PiiDatabaseVO piidatabase = service.get(db);
        piidatabase.setPwd("");
        model.addAttribute("piidatabase", piidatabase);
        model.addAttribute("listsystem", systemSV.getList());
        model.addAttribute("cri", cri);
        //logger.info(cri.toString());
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiDatabaseVO piidatabase, Criteria cri, RedirectAttributes rttr) throws Exception {
        LogUtil.log("INFO", "@PostMapping modify:" + piidatabase);
        if (piidatabase.getPwd() == "" || piidatabase.getPwd() == null) {
            //패스워드 업데이트 하면 안됨...
            if (service.modifyWithoutPw(piidatabase)) {
                rttr.addFlashAttribute("result", "success");
            }
        } else {
            try {
                AES256Util aes = new AES256Util();
                piidatabase.setPwd(aes.encrypt(piidatabase.getPwd()));
            } catch (Exception ex) {
                throw new AES256Exception("AES256 encoding exception");
            }
            if (service.modify(piidatabase)) {
                rttr.addFlashAttribute("result", "success");
            }
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piidatabase/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiDatabaseVO piidatabase, Criteria cri, RedirectAttributes rttr) {

        LogUtil.log("INFO", "@PostMapping remove..." + piidatabase.getDb());
        if (service.remove(piidatabase.getDb())) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piidatabase/list";
    }

    @ResponseBody
    @PostMapping("/connectiontest")
    @PreAuthorize("isAuthenticated()")
    public String test(@RequestBody PiiDatabaseVO piidatabase, Model model) throws Exception {
        LogUtil.log("INFO", "@PostMapping test start:" + piidatabase);
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        if (piidatabase.getPwd() == "" || piidatabase.getPwd() == null) {
            PiiDatabaseVO dbVO = service.get(piidatabase.getDb());
            try {
                AES256Util aes = new AES256Util();
                piidatabase.setPwd(aes.decrypt(dbVO.getPwd()));
            } catch (Exception ex) {
                throw new AES256Exception("AES256 encoding exception");
            }
        }

        try {

            conn = ConnectionProvider.getConnection(piidatabase.getDbtype()
                    , piidatabase.getHostname()
                    , piidatabase.getPort()
                    , piidatabase.getId_type()
                    , piidatabase.getId()
                    , piidatabase.getDb()
                    , piidatabase.getDbuser()
                    , piidatabase.getPwd()
            );

            // 3. Statement 생성
            stmt = conn.createStatement();

            // 4. 쿼리 실행
			/*String query = "SELECT 1 AS NAME FROM DUAL";
			if( piidatabase.getDbtype().equalsIgnoreCase("MARIADB") || piidatabase.getDbtype().equalsIgnoreCase("MYSQL") 
					|| piidatabase.getDbtype().equalsIgnoreCase("POSTGRESQL") || piidatabase.getDbtype().equalsIgnoreCase("MSSQL")) {
				query = "SELECT 1";
			}else if( piidatabase.getDbtype().equalsIgnoreCase("DB2") ){
				query = "SELECT 1 AS NAME FROM DUAL";
			}*/
            String query = SqlUtil.getSqlSelect1(piidatabase.getDbtype());
            rs = stmt.executeQuery(query);
            rs.next();
            //model.addAttribute("result", "success");
            //LogUtil.log("INFO", "test - Connection success");
            return "Successfully connected";
//			// 5. 쿼리 실행 결과 출력
//			while(rs.next()) {
//				LogUtil.log("INFO", "5. 쿼리 실행 결과 출력 "+rs.getString("NAME"));
//			}
        } catch (SQLRecoverableException ex) {
            logger.warn("warn "+"test - Connection fail - SQLRecoverableException " + ex.getMessage() + "  " + piidatabase.toString());
            model.addAttribute("result", "fail");
            ex.printStackTrace();
            throw ex;
        } catch (NullPointerException ex) {
            logger.warn("warn "+"test - Connection fail - " + "Connection information wrong !!  " + piidatabase.toString());
            model.addAttribute("result", "fail");
            ex.printStackTrace();
            throw ex;
        } catch (Exception ex) {
            logger.warn("warn "+"test - Connection fail - " + ex.getMessage() + "  " + piidatabase.toString());
            model.addAttribute("result", "fail");
            ex.printStackTrace();
            throw ex;
        } finally {
            //JdbcUtil.close(pstmt);
            JdbcUtil.close(conn);
        }
    }


    @GetMapping({"/exeupdate"})
    @PreAuthorize("isAuthenticated()")
    public void exeupdate(@RequestParam(value = "db", required = false) String db, Criteria cri, Model model) {
        LogUtil.log("INFO", "/piidatabase @GetMapping({exeupdate) db=" + db);

        model.addAttribute("piidatabaselist", service.getList());
        model.addAttribute("cri", cri);
        // Pass the selected DB to pre-select in dropdown
        if (db != null && !db.isEmpty()) {
            PiiExeupdateVO piiexeupdate = new PiiExeupdateVO();
            piiexeupdate.setDb(db);
            model.addAttribute("piiexeupdate", piiexeupdate);
        }
        //log.info(cri.toString());
    }

    @ResponseBody
    @RequestMapping(
            value = "exeupdate",
            method = RequestMethod.POST,
            produces = "text/html;charset=UTF-8"
    )
    @PreAuthorize("isAuthenticated()")
    public String exeupdate(@RequestBody PiiExeupdateVO exeupdate, Model model) {
        LogUtil.log("INFO", "/exeupdate - " + exeupdate);

        // 권한 토큰 체크
        if (!"DATABLOCKS".equalsIgnoreCase(exeupdate.getAmho())) {
            return htmlBox("You need the authority for running", "danger");
        }

        // DB 접속 정보 로드 & 복호화
        final PiiDatabaseVO dbVO = service.get(exeupdate.getDb());
        try {
            AES256Util aes = new AES256Util();
            dbVO.setPwd(aes.decrypt(dbVO.getPwd()));
        } catch (Exception ex) {
            throw new AES256Exception("AES256 encoding exception");
        }

        // 입력값 정리
        final String rawSql = nvl(exeupdate.getSqlstr());
        final char delimiter = getDelimiterChar(exeupdate.getSplitter()); // 기본 ';'
        final boolean clientSelectMode = "SELECT".equalsIgnoreCase(nvl(exeupdate.getRuntype()));

        // 안전한 분할 (문자열/주석 내부 ; 무시)
        final List<String> stmts = SqlSplitter.split(rawSql, delimiter);
        if (stmts.isEmpty()) {
            return htmlBox("No SQL to execute.", "warning");
        }

        // SELECT인지 자동 판별 (클라이언트가 명시한 SELECT 우선, 아니면 첫 문장 분석)
        boolean isSelectLike = clientSelectMode || (stmts.size() == 1 && SqlSafe.isSelectLike(stmts.get(0)));

        // 행 제한
        int maxRows = 1000;
        try { maxRows = Integer.parseInt(String.valueOf(exeupdate.getMaxrowcnt())); } catch (Exception ignore) {}

        StringBuilder out = new StringBuilder(4096);
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = ConnectionProvider.getConnection(
                    dbVO.getDbtype(), dbVO.getHostname(), dbVO.getPort(),
                    dbVO.getId_type(), dbVO.getId(), dbVO.getDb(),
                    dbVO.getDbuser(), dbVO.getPwd()
            );

            stmt = conn.createStatement();

            if (isSelectLike) {
                // SELECT류: 첫 문장만 결과 테이블 렌더링
                String q = stmts.get(0).trim();
                String limited = SqlUtil.getSelectWithQuery(dbVO.getDbtype(), maxRows, q);
                stmt.setMaxRows(maxRows);
                rs = stmt.executeQuery(limited);
                out.append(ResultRender.renderResultSet(rs));
            } else {
                // DDL/DML/혼합 실행: 트랜잭션
                conn.setAutoCommit(false);
                int idx = 0;

                for (String s : stmts) {
                    String cur = s.trim();
                    if (cur.isEmpty()) continue;
                    idx++;

                    boolean hasResultSet = stmt.execute(cur);

                    if (hasResultSet) {
                        try (ResultSet r = stmt.getResultSet()) {
                            out.append(title("#" + idx + " ResultSet"))
                                    .append(ResultRender.renderResultSet(r));
                        }
                    } else {
                        int upd = stmt.getUpdateCount();
                        out.append(ResultRender.renderUpdateCount(idx, upd));
                    }

                    // 추가 결과 소모(프로시저 등)
                    while (stmt.getMoreResults() || stmt.getUpdateCount() != -1) {
                        ResultSet more = stmt.getResultSet();
                        if (more != null) {
                            try (ResultSet r2 = more) {
                                out.append(title("#" + idx + " More Result"))
                                        .append(ResultRender.renderResultSet(r2));
                            }
                        } else {
                            int upd2 = stmt.getUpdateCount();
                            if (upd2 == -1) break;
                            out.append(ResultRender.renderUpdateCount(idx, upd2));
                        }
                    }
                }

                conn.commit();
            }

            return out.toString();

        } catch (SQLSyntaxErrorException ex) {
            JdbcUtil.rollback(conn);
            logger.warn("warn SQLSyntaxErrorException " + ex.getMessage());
            return htmlError(ex);
        } catch (SQLRecoverableException ex) {
            JdbcUtil.rollback(conn);
            logger.warn("warn SQLRecoverableException " + ex.getMessage());
            return htmlError(ex);
        } catch (NullPointerException ex) {
            JdbcUtil.rollback(conn);
            logger.warn("warn NullPointerException Connection information wrong !!");
            return htmlError(ex);
        } catch (Exception ex) {
            JdbcUtil.rollback(conn);
            logger.warn("warn Exception - " + ex.getMessage(), ex);
            return htmlError(ex);
        } finally {
            JdbcUtil.close(rs);
            JdbcUtil.close(stmt);
            JdbcUtil.close(conn);
        }
    }

    /* ----------------- helper ----------------- */

    private static String nvl(Object o) { return (o == null) ? "" : String.valueOf(o); }

    private static char getDelimiterChar(String splitter) {
        if (splitter != null && splitter.length() == 1) return splitter.charAt(0);
        return ';';
    }

    private static String htmlBox(String msg, String type) {
        return "<div class='alert alert-" + SqlSafe.escapeHtml(type)
                + "' role='alert' style='white-space:pre-wrap'>"
                + SqlSafe.escapeHtml(msg) + "</div>";
    }

    private static String htmlError(Exception ex) {
        String msg = SqlSafe.escapeHtml(ex.toString());
        return "<div class='alert alert-danger' role='alert' style='white-space:pre-wrap'>" + msg + "</div>";
    }

    private static String title(String t) {
        return "<h6 class='mt-2 mb-1'>" + SqlSafe.escapeHtml(t) + "</h6>";
    }


    @PostMapping("exeupdate_download_excel")
    @PreAuthorize("isAuthenticated()")
    public String exeupdate_download_excel(Criteria cri, Locale locale, Model model, HttpServletRequest request) {
        LogUtil.log("INFO", "/exeupdate - " + cri.toString());

        PiiExeupdateVO exeupdate = new PiiExeupdateVO();
        exeupdate.setDb(cri.getSearch1());
        exeupdate.setAmho(cri.getSearch2());
        exeupdate.setSplitter(cri.getSearch3());
        exeupdate.setRuntype(cri.getSearch4());
        exeupdate.setMaxrowcnt(StrUtil.parseInt(cri.getSearch5()));
        exeupdate.setSqlstr(cri.getSearch6());

        if ("EXECUTE".equalsIgnoreCase(exeupdate.getRuntype())) {
            return null;
        }
        XSSFWorkbook workbook = null;
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        String[] array;
        String cur_str = null;
        StringBuilder result_msg = new StringBuilder();

        if (!exeupdate.getAmho().equalsIgnoreCase("DATABLOCKS")) return null;

        PiiDatabaseVO dbVO = service.get(exeupdate.getDb());
        try {
            AES256Util aes = new AES256Util();
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

            array = exeupdate.getSqlstr().split(exeupdate.getSplitter());
            stmt = conn.createStatement();
            rs = stmt.executeQuery(SqlUtil.getSelectWithQuery(dbVO.getDbtype(), exeupdate.getMaxrowcnt(), array[0]));
            ResultSetMetaData rsmd = rs.getMetaData();


            String exeType = "QUERY_RESULT";
            String path = "/opt/tomcat/latest/webapps/DLM/WEB-INF/template";
            try {
                path = request.getSession().getServletContext().getRealPath("/WEB-INF/template");
            } catch (Exception e) {
                logger.warn("warn "+"request.getSession().getServletContext().getRealPath('/WEB-INF/template') is null");
            }
            workbook = excelService.makeQueryResultExcel(locale, array[0], path, exeType, rsmd, rs);


        } catch (SQLSyntaxErrorException ex) {
            logger.warn("warn "+"SQLSyntaxErrorException " + ex.getMessage() + "==>" + cur_str);
            ex.printStackTrace();
            JdbcUtil.rollback(conn);
            return null;
        } catch (SQLRecoverableException ex) {
            logger.warn("warn "+"SQLRecoverableException " + ex.getMessage() + "==>" + cur_str);
            ex.printStackTrace();
            JdbcUtil.rollback(conn);
            return null;
        } catch (NullPointerException ex) {
            logger.warn("warn "+"NullPointerException " + ex.getMessage());
            ex.printStackTrace();
            JdbcUtil.rollback(conn);
            return null;
        } catch (Exception ex) {
            logger.warn("warn "+"Exception - " + ex.getMessage() + "==>" + cur_str);
            ex.printStackTrace();
            JdbcUtil.rollback(conn);
            return null;
        } finally {
            JdbcUtil.close(rs);
            JdbcUtil.close(stmt);
            JdbcUtil.close(conn);
        }
        model.addAttribute("locale", Locale.KOREA);
        model.addAttribute("workbook", workbook);
        model.addAttribute("workbookName", "Query_results");
        return "excelDownloadView";
    }

    @ResponseBody
    @RequestMapping(value = "/bridgeQuery", produces = "application/json;charset=UTF-8", method = RequestMethod.POST)
    public String executeQueryAsJson(@RequestBody PiiExeupdateVO exeupdate) throws Exception {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        StringBuilder jsonResult = new StringBuilder();
        String cur_str = null;

        // 권한 확인
        if (!exeupdate.getAmho().equalsIgnoreCase("DATABLOCKS")) {
            return "{\"error\":\"You need the authority for running.\"}";
        }

        PiiDatabaseVO dbVO = service.get(exeupdate.getDb());
        try {
            AES256Util aes = new AES256Util();
            dbVO.setPwd(aes.decrypt(dbVO.getPwd()));
        } catch (Exception ex) {
            throw new AES256Exception("AES256 encoding exception");
        }

        try {
            conn = ConnectionProvider.getConnection(dbVO.getDbtype(), dbVO.getHostname(), dbVO.getPort(),
                    dbVO.getId_type(), dbVO.getId(), dbVO.getDb(),
                    dbVO.getDbuser(), dbVO.getPwd());

            cur_str = exeupdate.getSqlstr();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(cur_str);

            ResultSetMetaData rsmd = rs.getMetaData();
            int columnCount = rsmd.getColumnCount();

            // JSON 객체 시작
            jsonResult.append("{");

            // 1. 칼럼명 리스트 생성
            jsonResult.append("\"columns\":[");
            for (int i = 1; i <= columnCount; i++) {
                if (i > 1) {
                    jsonResult.append(",");
                }
                jsonResult.append("\"").append(rsmd.getColumnName(i)).append("\"");
            }
            jsonResult.append("],");

            // 2. 데이터 리스트(배열) 생성
            jsonResult.append("\"rows\":[");
            boolean isFirstRow = true;
            while (rs.next()) {
                if (!isFirstRow) {
                    jsonResult.append(",");
                }
                jsonResult.append("[");
                for (int i = 1; i <= columnCount; i++) {
                    if (i > 1) {
                        jsonResult.append(",");
                    }
                    // ResultSet의 데이터를 JSON 형식에 맞게 처리
                    Object value = rs.getObject(i);
                    if (value == null) {
                        jsonResult.append("null");
                    } else {
                        String stringValue = value.toString().replace("\"", "\\\""); // 쌍따옴표 이스케이프
                        jsonResult.append("\"").append(stringValue).append("\"");
                    }
                }
                jsonResult.append("]");
                isFirstRow = false;
            }
            jsonResult.append("]");

            // JSON 객체 종료
            jsonResult.append("}");

            return jsonResult.toString();

        } catch (Exception ex) {
            logger.error("Error executing query as JSON: " + ex.getMessage(), ex);
            JdbcUtil.rollback(conn);
            return "{\"error\":\"" + ex.toString() + "\", \"sql\":\"" + cur_str + "\"}";
        } finally {
            JdbcUtil.close(conn);
            JdbcUtil.close(stmt);
            JdbcUtil.close(rs);
        }
    }
}



final class SqlSplitter {
    private SqlSplitter() {}

    /** 문자열/식별자/주석/이스케이프를 고려하여 안전하게 문장 분리 */
    static List<String> split(String sql, char delimiter) {
        List<String> res = new ArrayList<>();
        if (sql == null) return res;

        boolean inS = false;       // '...'
        boolean inD = false;       // "..."
        boolean inLine = false;    // -- ...
        boolean inBlock = false;   // /* ... */
        boolean backslash = false; // \ 이스케이프(주로 MySQL)

        StringBuilder buf = new StringBuilder(sql.length());
        int n = sql.length();

        for (int i = 0; i < n; i++) {
            char c = sql.charAt(i);
            char next = (i + 1 < n) ? sql.charAt(i + 1) : '\0';

            // 라인 주석
            if (inLine) {
                buf.append(c);
                if (c == '\n' || c == '\r') inLine = false;
                continue;
            }

            // 블록 주석
            if (inBlock) {
                buf.append(c);
                if (c == '*' && next == '/') {
                    buf.append(next);
                    i++;
                    inBlock = false;
                }
                continue;
            }

            // 문자열(')
            if (inS) {
                buf.append(c);
                if (backslash) {
                    backslash = false;
                } else if (c == '\\') {
                    backslash = true;
                } else if (c == '\'' && next == '\'') { // '' → '
                    buf.append(next);
                    i++;
                } else if (c == '\'') {
                    inS = false;
                }
                continue;
            }

            // 식별자(")
            if (inD) {
                buf.append(c);
                if (c == '"' && next == '"') { // "" → "
                    buf.append(next);
                    i++;
                } else if (c == '"') {
                    inD = false;
                }
                continue;
            }

            // 주석 시작 / 문자열 시작
            if (c == '-' && next == '-') { buf.append(c).append(next); i++; inLine = true; continue; }
            if (c == '/' && next == '*') { buf.append(c).append(next); i++; inBlock = true; continue; }
            if (c == '\'') { buf.append(c); inS = true; backslash = false; continue; }
            if (c == '"')  { buf.append(c); inD = true; continue; }

            // 안전한 구분자
            if (c == delimiter) {
                String stmt = buf.toString().trim();
                if (!stmt.isEmpty()) res.add(stmt);
                buf.setLength(0);
                continue;
            }

            buf.append(c);
        }

        String tail = buf.toString().trim();
        if (!tail.isEmpty()) res.add(tail);
        return res;
    }
}

final class SqlSafe {
    private SqlSafe() {}

    static boolean isSelectLike(String sql) {
        if (sql == null) return false;
        String t = sql.trim().toUpperCase(Locale.ROOT);
        return t.startsWith("SELECT") || t.startsWith("WITH")
                || t.startsWith("SHOW") || t.startsWith("DESC") || t.startsWith("DESCRIBE")
                || t.startsWith("EXPLAIN");
    }

    static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}

final class ResultRender {
    private ResultRender() {}

    static String renderResultSet(ResultSet rs) throws SQLException {
        StringBuilder sb = new StringBuilder(2048);
        ResultSetMetaData md = rs.getMetaData();
        int cols = md.getColumnCount();

        sb.append("<div class='table-responsive'>")
                .append("<table class='table table-sm table-striped table-hover'>")
                .append("<thead><tr>");

        for (int i = 1; i <= cols; i++) {
            sb.append("<th>").append(SqlSafe.escapeHtml(md.getColumnLabel(i))).append("</th>");
        }
        sb.append("</tr></thead><tbody>");

        int rows = 0;
        while (rs.next()) {
            sb.append("<tr>");
            for (int i = 1; i <= cols; i++) {
                String v = rs.getString(i);
                sb.append("<td>").append(SqlSafe.escapeHtml(v)).append("</td>");
            }
            sb.append("</tr>");
            rows++;
        }

        sb.append("</tbody></table>")
                .append("<div class='text-muted' style='font-size:12px'>Rows: ").append(rows).append("</div>")
                .append("</div>");

        return sb.toString();
    }

    static String renderUpdateCount(int index, int count) {
        return "<div class='mb-1'><span class='badge bg-secondary'>#" + index
                + "</span> UpdateCount: <strong>" + count + "</strong></div>";
    }
}


