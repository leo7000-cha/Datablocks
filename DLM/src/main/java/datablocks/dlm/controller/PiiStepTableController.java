package datablocks.dlm.controller;

import datablocks.dlm.domain.*;
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
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.*;

@Controller
@RequestMapping("/piisteptable/*")
@AllArgsConstructor
public class PiiStepTableController {
    private static final Logger logger = LoggerFactory.getLogger(PiiStepTableController.class);
    private PiiStepTableService service;
    private PiiStepService stepservice;
    private PiiTableService tableservice;
    private PiiJobService jobservice;
    private PiiStepTableWaitService steptablewait;
    private PiiStepTableUpdateService steptableupdate;
    private PiiDatabaseService databaseservice;
    private MetaTableService metaTableService;
    private LkPiiScrTypeService lkPiiScrTypeService;
    private PiiSystemService systemService;

    // private String jobid;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(@RequestParam("jobid") String jobid, @RequestParam("version") String version,
                         @RequestParam("stepid") String stepid, Criteria cri, Model model) {
        LogUtil.log("INFO", "@GetMapping(register)" + stepid);

        PiiStepTableVO piisteptableVo = new PiiStepTableVO();
        PiiJobVO piijobVo = jobservice.get(jobid, version);
        PiiStepVO piistepVo = stepservice.get(jobid, version, stepid);
        PiiSystemVO piisystem = systemService.get(piijobVo.getSystem());
        String steptype = piistepVo.getSteptype();
        piisteptableVo.setJobid(jobid);
        piisteptableVo.setVersion(version);
        piisteptableVo.setStepid(stepid);
        if (!steptype.equals("EXE_BROADCAST") && !steptype.equals("EXE_HOMECAST") && !steptype.equals("EXE_SCRAMBLE") && !steptype.equals("EXE_ILM") && !steptype.equals("EXE_MIGRATE") && !steptype.equals("EXE_SYNC")) {
            piisteptableVo.setDb(piistepVo.getDb());
        }

        piisteptableVo.setExetype(steptype.replace("EXE_", "").replace("GEN_", ""));

        PiiStepMaxSeqVO stepmaxseqVO = service.getStepMaxseq(jobid, version, stepid);
        if (steptype.equals("GEN_KEYMAP")) {
            piisteptableVo.setSeq1(10);
            if (stepmaxseqVO == null) {
                piisteptableVo.setSeq2(10);
            } else {
                piisteptableVo.setSeq2(stepmaxseqVO.getSeq2() + 10);
            }
            piisteptableVo.setSeq3(1);
            piisteptableVo.setKeymap_id(piijobVo.getKeymap_id());
        } else {
            piisteptableVo.setSeq1(10);
            if (stepmaxseqVO == null) {
                piisteptableVo.setSeq1(1);
                piisteptableVo.setSeq2(10);

            } else {
                piisteptableVo.setSeq1(stepmaxseqVO.getSeq1());
                piisteptableVo.setSeq2(stepmaxseqVO.getSeq2() + 10);
            }
            piisteptableVo.setSeq3(10);

        }

        if (steptype.equals("EXE_EXTRACT")) {
            piisteptableVo.setOwner("COTDL");
            piisteptableVo.setTable_name("TBL_PIIEXTRACT");
        }

        model.addAttribute("piijob", piijobVo);
        model.addAttribute("piistep", piistepVo);
        model.addAttribute("piisteptable", piisteptableVo);
        model.addAttribute("piidatabaselist", databaseservice.getList());
        model.addAttribute("cri", cri);
        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());
        //logger.info(cri.toString());
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("INFO", "/getExeStepTableList list(Criteria cri, Model model): " + cri);
        model.addAttribute("list", service.getExeStepTableList(cri));
        int total = service.getTotalCountExeStepTable(cri);
//        LogUtil.log("INFO", "/getExeStepTableList total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
    }

    @GetMapping("/steptablelist")
    @PreAuthorize("isAuthenticated()")
    public void steptablelist(Criteria cri, Model model) {
        LogUtil.log("INFO", "/piisteptable list(Criteria cri, Model model): " + cri);
        model.addAttribute("list", service.getStepTableList(cri));
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/piisteptable total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
    }

    @ResponseBody
    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(@RequestBody PiiStepTableVO piisteptable, Criteria cri, Model model) {

        LogUtil.log("INFO", "@PostMapping register: " + piisteptable);
        model.addAttribute("result", "success");

        return service.register(piisteptable);

    }
    @ResponseBody
    @GetMapping("/registerEntireToScramble")
    @PreAuthorize("isAuthenticated()")
    public String registerEntireToScramble(@RequestParam("jobid") String jobid,
                                           @RequestParam("version") String version,
                                           @RequestParam("stepid") String stepid,  Model model) {

        LogUtil.log("INFO", "@GetMapping registerEntireToScramble: " + "Received jobid: " + jobid + ", version: " + version + ", stepid: " + stepid);
        model.addAttribute("result", "success");

        return service.registerEntireToScramble(jobid, version, stepid);

    }

//    @ResponseBody
//    @GetMapping("/getListEntireToScramble")
//    @PreAuthorize("isAuthenticated()")
//    public String getListEntireToScramble(@RequestParam("jobid") String jobid,
//                                           @RequestParam("version") String version,
//                                           @RequestParam("stepid") String stepid,  Model model) {
//
//        LogUtil.log("INFO", "@GetMapping getListEntireToScramble: " + "Received jobid: " + jobid + ", version: " + version + ", stepid: " + stepid);
//        List<PiiStepTableTargetVO> toAddScrambleList  = service.getListEntireToScramble(jobid, version, stepid)
//        model.addAttribute("toAddScrambleList", toAddScrambleList);
//        model.addAttribute("result", "success");
//
//        return toAddScrambleList.size()+"";
//
//    }

    /**
     * 아카이브 DDL 확인: 아카이브 테이블 존재 여부 + 생성 DDL 스크립트 반환
     */
    @ResponseBody
    @PostMapping("/checkArcDdl")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> checkArcDdl(@RequestBody PiiStepTableVO piisteptable) {
        LogUtil.log("INFO", "@PostMapping checkArcDdl: " + piisteptable);
        Map<String, Object> result = service.checkArcDdlStatus(piisteptable);
        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    /**
     * 아카이브 DDL 재실행: createArcTable 재호출
     */
    @ResponseBody
    @PostMapping("/retryArcDdl")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> retryArcDdl(@RequestBody PiiStepTableVO piisteptable) {
        LogUtil.log("INFO", "@PostMapping retryArcDdl: " + piisteptable);
        Map<String, Object> result = service.retryArcDdl(piisteptable);
        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("jobid") String jobid, @RequestParam("version") String version,
                    @RequestParam("stepid") String stepid, @RequestParam("seq1") int seq1, @RequestParam("seq2") int seq2, @RequestParam("seq3") int seq3,
                    Criteria cri, Model model) {
        LogUtil.log("INFO", "@GetMapping get: " + stepid);
        PiiStepTableVO piisteptable = service.getWithSeq(jobid, version, stepid, seq1, seq2, seq3);
        PiiStepVO piistep = stepservice.get(jobid, version, stepid);
        model.addAttribute("piijob", jobservice.get(jobid, version));
        model.addAttribute("piistep", piistep);
        model.addAttribute("piisteptable", piisteptable);
        model.addAttribute("liststeptablewait", steptablewait.getList(piisteptable.getJobid(), piisteptable.getVersion(), piisteptable.getStepid(), piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name()));
        model.addAttribute("liststeptableupdate", steptableupdate.getList(jobid, version, stepid, seq1, seq2, seq3));
        model.addAttribute("cri", cri);
        model.addAttribute("stepid", stepid);
        model.addAttribute("piidatabaselist", databaseservice.getList());
        Criteria cri_metatable = new Criteria();

        PiiDatabaseVO dbVO_Prod = null;
        /** 메타 정보가 운영계 기준으로 정의되어 있어서 입력된 DB 의 시스템 기준 운영 DB로 변경해준다. 20240428*/
//        if("SCRAMBLE".equalsIgnoreCase(piisteptable.getExetype())){
//            /** SCRAMBLE은 step의 DB가 source 임. 20241013*/
//            String sourcedb = piistep.getDb();
//            dbVO_Prod = databaseservice.get(sourcedb);
//        } else {
            dbVO_Prod = databaseservice.getBySystem(databaseservice.get(piisteptable.getDb()).getSystem());
//        }
        cri_metatable.setSearch1(dbVO_Prod.getDb());
        cri_metatable.setSearch2(piisteptable.getOwner());
        cri_metatable.setSearch3(piisteptable.getTable_name());
        model.addAttribute("listscramblecolumn", metaTableService.getListForOneTable(cri_metatable));
        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());

    }

    @GetMapping({"/wizarddialog"})
    @PreAuthorize("isAuthenticated()")
    public void wizarddialog(@RequestParam("jobid") String jobid, @RequestParam("version") String version,
                             @RequestParam("stepid") String stepid, Criteria cri, Model model) {
        LogUtil.log("INFO", "@GetMapping /wizarddialog = " + jobid + " " + stepid + cri.toString());
        model.addAttribute("jobid", jobid);
        model.addAttribute("version", version);
        model.addAttribute("stepid", stepid);
        model.addAttribute("piistep", stepservice.get(jobid, version, stepid));

        if (cri.getSearch1() == null || cri.getSearch2() == null || cri.getSearch3() == null) {
            PiiStepTableVO piisteptable = new PiiStepTableVO();
            piisteptable.setJobid(jobid);
            piisteptable.setVersion(version);
            piisteptable.setStepid(stepid);
            model.addAttribute("piisteptable", piisteptable);

        } else {
            PiiStepTableVO piisteptable = service.getWithSeq(jobid, version, stepid, Integer.parseInt(cri.getSearch1()), Integer.parseInt(cri.getSearch2()), Integer.parseInt(cri.getSearch3()));
            model.addAttribute("piisteptable", piisteptable);
        }

        model.addAttribute("piitablelist", tableservice.getListWithMeta(cri));
        model.addAttribute("piikeymaplist", service.getList_Keymap(jobid, version));

        // 소스 DB에서 인덱스 컬럼 정보 조회
        // indexInfoMap: column_name -> [{name:"IDX1", pos:1}, {name:"IDX2", pos:3}]
        // indexNameSet: 인덱스명 목록 (색상 매핑용)
        Map<String, List<Map<String, Object>>> indexInfoMap = new LinkedHashMap<>();
        Set<String> indexNameSet = new LinkedHashSet<>();
        String db = cri.getSearch4();
        String owner = cri.getSearch5();
        String tableName = cri.getSearch6();
        if (db != null && owner != null && tableName != null) {
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;
            try {
                PiiDatabaseVO dbVO = databaseservice.get(db);
                if (dbVO != null) {
                    AES256Util aes = new AES256Util();
                    String decryptedPwd = aes.decrypt(dbVO.getPwd());
                    conn = ConnectionProvider.getConnection(
                            dbVO.getDbtype(), dbVO.getHostname(), dbVO.getPort(),
                            dbVO.getId_type(), dbVO.getId(), dbVO.getDb(),
                            dbVO.getDbuser(), decryptedPwd);
                    String indexSql = SqlUtil.getSqlColumnIndexInfo(dbVO.getDbtype(), owner, tableName);
                    if (!indexSql.isEmpty()) {
                        stmt = conn.createStatement();
                        rs = stmt.executeQuery(indexSql);
                        while (rs.next()) {
                            String colName = rs.getString("COLUMN_NAME");
                            String idxName = rs.getString("INDEX_NAME");
                            int pos = rs.getInt("COLUMN_POSITION");
                            indexNameSet.add(idxName);
                            Map<String, Object> entry = new LinkedHashMap<>();
                            entry.put("name", idxName);
                            entry.put("pos", pos);
                            indexInfoMap.computeIfAbsent(colName, k -> new ArrayList<>()).add(entry);
                        }
                    }
                }
            } catch (Exception e) {
                logger.warn("Index info query failed: " + e.getMessage());
            } finally {
                JdbcUtil.close(rs);
                JdbcUtil.close(stmt);
                JdbcUtil.close(conn);
            }
        }
        // 인덱스명 -> 색상번호 매핑 (8색 순환)
        Map<String, Integer> indexColorMap = new LinkedHashMap<>();
        int colorIdx = 0;
        for (String idxName : indexNameSet) {
            indexColorMap.put(idxName, colorIdx % 8);
            colorIdx++;
        }
        model.addAttribute("indexInfoMap", indexInfoMap);
        model.addAttribute("indexColorMap", indexColorMap);

        cri.setSearch1(jobid);
        cri.setSearch2(version);
        cri.setSearch3(stepid);
        int total = service.getTotal(cri);

        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());

    }

    @GetMapping({"/searchtabledialog"})
    @PreAuthorize("isAuthenticated()")
    public void searchTabledialog(@RequestParam("jobid") String jobid, @RequestParam("version") String version,
                                  @RequestParam("stepid") String stepid, Criteria cri, Model model) {
        LogUtil.log("INFO", "@GetMapping /searchtabledialog = " + cri.toString());
        cri.setSearch1(jobid);
        cri.setSearch2(version);
        cri.setSearch3(stepid);

        PiiStepVO piiStepVO = stepservice.get(jobid, version, stepid);
        String stepType = piiStepVO.getSteptype();
        if(StrUtil.checkString(cri.getSearch4()) && StrUtil.checkString(cri.getSearch5()) && StrUtil.checkString(cri.getSearch6())){

            if (!piiStepVO.getSteptype().equals("EXE_SCRAMBLE") && !piiStepVO.getSteptype().equals("EXE_ILM") && !piiStepVO.getSteptype().equals("EXE_MIGRATE") && !piiStepVO.getSteptype().equals("EXE_SYNC")) {
                cri.setSearch4(piiStepVO.getDb());
                model.addAttribute("piitablelist", tableservice.getTableList(cri));
                int total = tableservice.getTableTotal(cri);
                //LogUtil.log("INFO", "/piijob total: " + total);
                PageDTO pageMaker = new PageDTO(cri, total);
                model.addAttribute("pageMaker", pageMaker);
            }
        } else {
            model.addAttribute("piitablelist", tableservice.getTableList(cri));
            int total = tableservice.getTableTotal(cri);
            //LogUtil.log("INFO", "/piijob total: " + total);
            PageDTO pageMaker = new PageDTO(cri, total);
            model.addAttribute("pageMaker", pageMaker);
        }

        PiiJobVO jobVO = jobservice.get(jobid, version);
        cri.setSearch1(null);
        if ("EXE_DELETE".equals(stepType) || "EXE_UPDATE".equals(stepType) || "EXE_ILM".equals(stepType) || "EXE_SCRAMBLE".equals(stepType) ) {
            cri.setSearch2(jobVO.getSystem());
        } else{
            cri.setSearch2(null);
        }
        cri.setSearch3(null);
        model.addAttribute("piidatabaselist", databaseservice.getList(cri));
        cri.setSearch1(jobid);
        cri.setSearch2(version);
        cri.setSearch3(stepid);
        model.addAttribute("cri", cri);



        //LogUtil.log("INFO", "/piijob pageMaker: " + pageMaker);

    }

    @GetMapping("/getstepallinfo")
    @PreAuthorize("isAuthenticated()")
    public void getsteallinfo(@RequestParam("jobid") String jobid, @RequestParam("version") String version,
                              @RequestParam("stepid") String stepid, Criteria cri, Model model) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("INFO", "@GetMapping /getstepallinfo or modifystepallinfo = " + jobid + "-" + version + "-" + stepid);
        // model.addAttribute("list", service.getJobTableList(jobid));
        model.addAttribute("jobid", jobid);
        model.addAttribute("version", version);
        model.addAttribute("stepid", stepid);
        model.addAttribute("maxversion", jobservice.getMaxVersionByJob(jobid));
        model.addAttribute("liststep", stepservice.getList(cri));
        model.addAttribute("liststeptable", service.getJobStepTableList(jobid, version, stepid));
        List<PiiStepTableTargetVO> toAddScrambleList  = service.getListEntireToScramble(jobid, version, stepid);
        model.addAttribute("toAddScrambleList", toAddScrambleList);
        model.addAttribute("toAddScrambleListSize", toAddScrambleList.size());
    }

    @GetMapping("/modifystepallinfo")
    @PreAuthorize("isAuthenticated()")
    public void modifystepallinfo(@RequestParam("jobid") String jobid, @RequestParam("version") String version,
                                  @RequestParam("stepid") String stepid, Criteria cri, Model model) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("INFO", "@GetMapping /getstepallinfo or modifystepallinfo = " + jobid + "-" + version + "-" + stepid);
        // model.addAttribute("list", service.getJobTableList(jobid));
        model.addAttribute("jobid", jobid);
        model.addAttribute("version", version);
        model.addAttribute("stepid", stepid);
        model.addAttribute("maxversion", jobservice.getMaxVersionByJob(jobid));
        model.addAttribute("liststep", stepservice.getList(cri));
        model.addAttribute("liststeptable", service.getJobStepTableList(jobid, version, stepid));
        List<PiiStepTableTargetVO> toAddScrambleList  = service.getListEntireToScramble(jobid, version, stepid);
        model.addAttribute("toAddScrambleList", toAddScrambleList);
        model.addAttribute("toAddScrambleListSize", toAddScrambleList.size());
    }

    @ResponseBody
    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<String> modify(@RequestBody PiiStepTablePkNewVO piisteptable, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping modify:" + piisteptable);
        try {
            // 서버에서 작업을 수행하고 결과를 받아옴
            String result = service.modify(piisteptable);

            // 성공적인 처리인 경우
            return ResponseEntity.ok(result); // 클라이언트로 결과를 반환
        } catch (Exception e) {
            // 예외 발생 시
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
            // 예외 메시지를 클라이언트로 반환
        }
    }

    @ResponseBody
    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(@RequestBody PiiStepTableVO piisteptable, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping remove..." + piisteptable.getStepid());
        return service.remove(piisteptable);
    }

    @ResponseBody
    @PostMapping("/removeList")
    @PreAuthorize("isAuthenticated()")
    public String removeList(@RequestBody List<PiiStepTableVO> piisteptablelist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping updateactionflag............................." + cri);
        for (PiiStepTableVO piisteptable : piisteptablelist) {
            LogUtil.log("INFO", piisteptable.toString());
            if (!service.remove(piisteptable).equalsIgnoreCase("success")) {
                logger.warn("warn "+"Fail to remove " + piisteptable.getTable_name() + " (" + piisteptable.getSeq1() + "," + piisteptable.getSeq2() + "," + piisteptable.getSeq3());
                return "Fail to remove " + piisteptable.getTable_name() + " (" + piisteptable.getSeq1() + "," + piisteptable.getSeq2() + "," + piisteptable.getSeq3();
            }
        }

        return "success";
    }

    @GetMapping({"/modifysteptablewaitdialog"})
    @PreAuthorize("isAuthenticated()")
    public void modifysteptablewaitdialog(@RequestParam("jobid") String jobid, @RequestParam("version") String version,
                                          @RequestParam("stepid") String stepid, @RequestParam("db") String db,
                                          @RequestParam("owner") String owner, @RequestParam("table_name") String table_name, Criteria cri,
                                          Model model) {
        LogUtil.log("INFO", "/@GetMapping  /modifysteptablewaitdialog = " + jobid + "-" + version + "-" + stepid + "  " + table_name + "  " + cri);
        model.addAttribute("piisteptable", service.get(jobid, version, stepid, db, owner, table_name));
        model.addAttribute("liststeptable", service.getStepTableList(cri));
        model.addAttribute("liststeptablewait", steptablewait.getList(jobid, version, stepid, db, owner, table_name));
        model.addAttribute("cri", cri);
        //logger.info(steptablewait.getList(jobid, version, stepid, db, owner, table_name));

    }

    @GetMapping({"/modifysteptableupdatedialog"})
    @PreAuthorize("isAuthenticated()")
    public void modifysteptableupdatedialog(@RequestParam("jobid") String jobid, @RequestParam("version") String version,
                                            @RequestParam("stepid") String stepid, Criteria cri,
                                            Model model) {
        LogUtil.log("INFO", "/@GetMapping  /modifysteptableupdatedialog = " + jobid + "-" + version + "-" + stepid + "  " + cri);
        model.addAttribute("piisteptable", service.getWithSeq(jobid, version, stepid, Integer.parseInt(cri.getSearch1()), Integer.parseInt(cri.getSearch2()), Integer.parseInt(cri.getSearch3())));
        model.addAttribute("piitablelist", tableservice.getListWithMeta(cri));
        model.addAttribute("liststeptableupdate", steptableupdate.getList(jobid, version, stepid, Integer.parseInt(cri.getSearch1()), Integer.parseInt(cri.getSearch2()), Integer.parseInt(cri.getSearch3())));
        //model.addAttribute("liststeptable", service.getStepTableList(cri));
        model.addAttribute("cri", cri);
        model.addAttribute("listlkPiiScrType", lkPiiScrTypeService.getList());
        //logger.info(steptablewait.getList(jobid, version, stepid, db, owner, table_name));

    }

    @ResponseBody
    @PostMapping("/getPkcols")
    @PreAuthorize("isAuthenticated()")
    public String getPkcols(@RequestBody PiiTableVO piitablereq, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping getPkcols....piitablereq : " + piitablereq.toString());
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        List<PiiTableVO> piitablelist = tableservice.getList(cri);
        StringBuilder sqlpkcols = new StringBuilder();
        int colcnt = 0;
        for (PiiTableVO piitable : piitablelist) {
            if (("Y").equalsIgnoreCase(piitable.getPk_yn())
                    && cri.getSearch5().equalsIgnoreCase(piitable.getOwner())
                    && cri.getSearch6().equalsIgnoreCase(piitable.getTable_name())
            ) {
                if (colcnt == 0) {
                    sqlpkcols.append("" + piitable.getColumn_name() + "");
                } else {
                    sqlpkcols.append("," + piitable.getColumn_name() + "");
                }
                colcnt++;
            }
        }

        return sqlpkcols.toString();
    }

    @ResponseBody
    @PostMapping("/modifysteptableupdate")
    @PreAuthorize("isAuthenticated()")
    public String modifysteptableupdate(@RequestBody List<PiiStepTableUpdateVO> steptableupdatelist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping modifysteptableupdate...." + cri);
        return steptableupdate.modifysteptableupdate(steptableupdatelist);
    }

    @ResponseBody
    @PostMapping("/modifysteptablewait")
    @PreAuthorize("isAuthenticated()")
    public String modifysteptablewait(@RequestBody List<PiiStepTableWaitVO> steptablewaitlist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping modifysteptablewait....." + cri);
        return steptablewait.modifysteptablewait(steptablewaitlist);
    }

    @GetMapping("/getTDUpdateWhereClauseData")
    @ResponseBody
    public Map<String, String> getTDUpdateWhereClauseData(
            @RequestParam("jobid") String jobid,
            @RequestParam("version") String version,
            @RequestParam("stepid") String stepid,
            @RequestParam("owner") String owner,
            @RequestParam("table_name") String table_name) {
        // 서비스 계층의 메서드를 호출하여 WHERE 절 관련 데이터를 가져옴
        return service.getTDUpdateWhereClauseData(jobid, version, stepid, owner, table_name);
    }

}
