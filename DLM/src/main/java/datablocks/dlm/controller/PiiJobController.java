package datablocks.dlm.controller;

import datablocks.dlm.domain.*;
import datablocks.dlm.jdbc.DmlExecutor;
import datablocks.dlm.service.*;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.security.Principal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Optional;

@Slf4j
@Controller
@RequestMapping("/piijob")
@RequiredArgsConstructor
public class PiiJobController {
    private final PiiJobService jobService;
    private final PiiStepService stepSV;
    private final PiiStepTableService steptableSV;
    private final PiiJobWaitService jobwaitSV;
    private final PiiSystemService systemSV;
    private final PiiPolicyService policySV;
    private final PiiMemberService memberService;
    private final PiiDatabaseService databaseService;
    private final PiiOrderService orderSV;
    private final DmlExecutor dmlExecutor;
    private final ProgOrderHistService progOrderHistService;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model, Principal principal) {
        LogUtil.log("INFO", "/piijob /register  @GetMapping " + principal);
        PiiJobVO jobvo = new PiiJobVO();
        PiiMemberVO memebervo = memberService.get(principal.getName());
        //LogUtil.log("INFO", "/piijob /register  memebervo ="+memebervo);
        jobvo.setJob_owner_id1(memebervo.getUserid());
        jobvo.setJob_owner_name1(memebervo.getUsername());
        model.addAttribute("piijob", jobvo);
        model.addAttribute("listsystem", systemSV.getList());
        model.addAttribute("listpolicy", policySV.getList());
        model.addAttribute("piidatabaselist", databaseService.getList());
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {

        LogUtil.log("INFO", "/piijob list(Criteria cri, Model model): " + cri);
        if (StrUtil.checkString(cri.getSearch7())) {
            cri.setSearch7("ACTIVE");
            LogUtil.log("INFO", "/piijob list(status): null to ACTIVE  " + cri);
        }
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", jobService.getList(cri));
        int total = jobService.getTotal(cri);
        //LogUtil.log("INFO", "/piijob total: " + total);

        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piijob pageMaker: " + pageMaker);
        model.addAttribute("listsystem", systemSV.getList());
        model.addAttribute("listpolicy", policySV.getList());
        model.addAttribute("listkeymap", jobService.getKeymapList());
    }

    @GetMapping("/checkJobId")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<Boolean> checkJobId(@RequestParam("jobid") String jobid) {
        PiiJobVO existing = jobService.get(jobid, "1");
        return ResponseEntity.ok(existing != null);
    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(PiiJobDbidVO piijobVO, RedirectAttributes rttr) {

        LogUtil.log("INFO", "register: " + piijobVO);
        PiiJobVO piijob = new PiiJobVO();
        piijob.setJobid(piijobVO.getJobid());
        piijob.setVersion(piijobVO.getVersion());
        piijob.setJobname(piijobVO.getJobname());
        piijob.setSystem(piijobVO.getSystem());
        piijob.setPolicy_id(piijobVO.getPolicy_id());
        piijob.setKeymap_id(piijobVO.getKeymap_id());
        piijob.setJobtype(piijobVO.getJobtype());
        piijob.setRuntype(piijobVO.getRuntype());
        piijob.setCalendar(piijobVO.getCalendar());
        piijob.setTime(piijobVO.getTime());
        piijob.setCronval(piijobVO.getCronval());
        piijob.setConfirmflag(piijobVO.getConfirmflag());
        piijob.setStatus(piijobVO.getStatus());
        piijob.setPhase(piijobVO.getPhase());
        piijob.setJob_owner_id1(piijobVO.getJob_owner_id1());
        piijob.setJob_owner_name1(piijobVO.getJob_owner_name1());
        piijob.setJob_owner_id2(piijobVO.getJob_owner_id2());
        piijob.setJob_owner_name2(piijobVO.getJob_owner_name2());
        piijob.setJob_owner_id3(piijobVO.getJob_owner_id3());
        piijob.setJob_owner_name3(piijobVO.getJob_owner_name3());
        piijob.setEnddate(piijobVO.getEnddate());
        piijob.setRegdate(piijobVO.getRegdate());
        piijob.setUpddate(piijobVO.getUpddate());
        piijob.setReguserid(piijobVO.getReguserid());
        piijob.setUpduserid(piijobVO.getUpduserid());

        //checkbox
        if (piijob.getConfirmflag() == null) {
            piijob.setConfirmflag("N");
        }
        jobService.register(piijob, piijobVO.getDb());

        rttr.addFlashAttribute("result", "success");
        rttr.addAttribute("search1", piijobVO.getJobid());
        //rttr.addAttribute("search8", "REGULAR");
        return "redirect:/piijob/list";
    }

    @GetMapping({"/get", "/modifyjoballinfo"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("jobid") String jobid, @RequestParam("version") String version, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piijob @GetMapping  /get or modify = " + jobid);
        // 1. Job 정보 조회
        PiiJobVO piijob = jobService.get(jobid, version);

//        // 2. 현재 로그인한 사용자 정보 가져오기
//        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
//        String currentUsername = authentication.getName(); // 사용자 ID (principal)
//
//        // 3. 권한 확인 로직 (ADMIN 역할 또는 Job Owner 여부)
//        boolean isAdmin = authentication.getAuthorities().stream()
//                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
//
//        boolean isOwner = (piijob.getJob_owner_id1() != null && piijob.getJob_owner_id1().equals(currentUsername)) ||
//                (piijob.getJob_owner_id2() != null && piijob.getJob_owner_id2().equals(currentUsername)) ||
//                (piijob.getJob_owner_id3() != null && piijob.getJob_owner_id3().equals(currentUsername));

        model.addAttribute("piijob", piijob);
        model.addAttribute("listallversion", jobService.getAllVersionList(jobid));
        model.addAttribute("liststep", stepSV.getJobList(jobid, version));
        model.addAttribute("liststeptable", steptableSV.getJobTableList(jobid, version));
        model.addAttribute("listjobwait", jobwaitSV.getList(jobid, version));
        model.addAttribute("listsystem", systemSV.getList());
        model.addAttribute("listpolicy", policySV.getList());
        model.addAttribute("maxversion", jobService.getMaxVersionByJob(jobid));
        model.addAttribute("cri", cri);

        for (PiiStepVO piistep : stepSV.getJobList(jobid, version)) {
            model.addAttribute("firststepid", piistep.getStepid());
            LogUtil.log("INFO", piistep.getStepid());
            break;
        }
//        // 4. 조건에 따라 다른 뷰 반환
//        if (isAdmin || isOwner) {
//            // ADMIN 이거나 소유자라면 수정 페이지(modify)로 이동
//            return "piijob/modifyjoballinfo";
//        } else {
//            return "piijob/get";
//        }
    }

    @GetMapping({"/getsteptable", "/modifysteptable"})
    @PreAuthorize("isAuthenticated()")
    public void getStepTable(@RequestParam("jobid") String jobid, @RequestParam("version") String version, @RequestParam("stepid") String stepid, @RequestParam("db") String db, @RequestParam("owner") String owner, @RequestParam("table_name") String table_name, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piijob @GetMapping  /getsteptable or modifysteptable = " + jobid + " " + stepid + " " + db + " " + owner + " " + table_name);
        model.addAttribute("piisteptable", steptableSV.get(jobid, version, stepid, db, owner, table_name));
        model.addAttribute("cri", cri);
        //logger.info(cri.toString());
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiJobVO piijob, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping modify:" + piijob);
        //checkbox
        if (piijob.getConfirmflag() == null) {
            piijob.setConfirmflag("N");
        }
        if (jobService.modify(piijob)) {
            rttr.addFlashAttribute("result", "success");
        }
        rttr.addAttribute("jobid", piijob.getJobid());
        rttr.addAttribute("version", piijob.getVersion());

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        rttr.addAttribute("search4", cri.getSearch4());
        rttr.addAttribute("search5", cri.getSearch5());
        rttr.addAttribute("search6", cri.getSearch6());
        rttr.addAttribute("search7", cri.getSearch7());
        rttr.addAttribute("search8", cri.getSearch8());
        return "redirect:/piijob/modifyjoballinfo";
    }

    @GetMapping("/copy")
    @PreAuthorize("isAuthenticated()")
    public String copy(@RequestParam("jobid") String jobid, @RequestParam("version") String version
            , @RequestParam("jobid_copy") String jobid_copy, @RequestParam("jobname_copy") String jobname_copy
            , @RequestParam("copytype") String copytype
            , Criteria cri, RedirectAttributes rttr, Principal principal) {

        LogUtil.log("INFO", "@GetMapping copy..." + jobid + " " + version + " " + jobid_copy + " " + jobname_copy + " " + cri.toString());
        // 1. 현재 인증된 사용자 정보 가져오기
        PiiMemberVO memebervo = memberService.get(principal.getName());

        PiiJobVO piijob_copy = jobService.get(jobid, version);
        piijob_copy.setJobid(jobid_copy);// set new jobid
        piijob_copy.setJobname(jobname_copy);//set new jobname
        piijob_copy.setVersion("1");
        piijob_copy.setStatus("ACTIVE");
        piijob_copy.setPhase("CHECKOUT");
        piijob_copy.setJob_owner_id1(memebervo.getUserid());
        piijob_copy.setJob_owner_name1(memebervo.getUsername());
        piijob_copy.setJob_owner_id2(null);
        piijob_copy.setJob_owner_name2(null);
        piijob_copy.setJob_owner_id3(null);
        piijob_copy.setJob_owner_name3(null);
        if ("BACKDATED".equalsIgnoreCase(copytype)) {        //backdated job
            jobService.copyBackdated(piijob_copy, jobid, version);
        } else if ("RECOVERY".equalsIgnoreCase(copytype)) {    //Recovery job
            jobService.copyRecovery(piijob_copy, jobid, version);
        } else                                                    // copy job
            jobService.copy(piijob_copy, jobid, version);

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", jobid_copy);
//        rttr.addAttribute("search2", cri.getSearch2());
//        rttr.addAttribute("search3", cri.getSearch3());
//        rttr.addAttribute("search4", cri.getSearch4());
//        rttr.addAttribute("search5", cri.getSearch5());
//        rttr.addAttribute("search6", cri.getSearch6());
//        rttr.addAttribute("search7", cri.getSearch7());
//        rttr.addAttribute("search8", cri.getSearch8());
        rttr.addFlashAttribute("result", "success");
        return "redirect:/piijob/list";
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiJobVO piijob, Criteria cri, RedirectAttributes rttr) {

        LogUtil.log("INFO", "@PostMapping remove..." + piijob.getJobid() + "  " + cri);
        if (jobService.remove(piijob.getJobid(), piijob.getVersion())) {
            rttr.addFlashAttribute("result", "success");
        }

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        rttr.addAttribute("search4", cri.getSearch4());
        rttr.addAttribute("search5", cri.getSearch5());
        rttr.addAttribute("search6", cri.getSearch6());
        rttr.addAttribute("search7", cri.getSearch7());
        rttr.addAttribute("search8", cri.getSearch8());

        return "redirect:/piijob/list";
    }

    @GetMapping({"/modifyjobwaitdialog"})
    @PreAuthorize("isAuthenticated()")
    public void modifyjobwaitdialog(@RequestParam("jobid") String jobid, @RequestParam("version") String version, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piijob @GetMapping  /modifyjobwaitdialog = " + jobid + "-" + version + "  " + cri);
        PiiJobVO currentJob = jobService.get(jobid, version);
        model.addAttribute("piijob", currentJob);

        // 같은 JOBTYPE만 조회 + 자기 자신 제외
        if (cri.getSearch2() == null && currentJob != null) {
            cri.setSearch2(currentJob.getJobtype());
        }
        List<PiiJobVO> activeList = jobService.getActiveList(cri);
        activeList.removeIf(j -> jobid.equals(j.getJobid()));
        model.addAttribute("list", activeList);

        model.addAttribute("listjobwait", jobwaitSV.getList(jobid, version));
        model.addAttribute("cri", cri);

    }

    @ResponseBody
    @PostMapping("/modifyjobwait")
    @PreAuthorize("isAuthenticated()")
    public String modifyjobwait(@RequestBody List<PiiJobWaitVO> jobwaitlist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@PostMapping modifyjobwait............................." + cri);
        for (PiiJobWaitVO piijobwait : jobwaitlist) {
            jobwaitSV.removeJob(piijobwait.getJobid(), piijobwait.getVersion());
            break;
        }
        for (PiiJobWaitVO piijobwait : jobwaitlist) {
            if (piijobwait.getType().equalsIgnoreCase("PRE")) {
                jobwaitSV.register(piijobwait);
                model.addAttribute("result", "success");
            }
        }
        return "Successfully saved";
    }


    @GetMapping("/checkout")
    @PreAuthorize("isAuthenticated()")
    public String checkout(@RequestParam("jobid") String jobid, @RequestParam("version") String version, Criteria cri, RedirectAttributes rttr) {

        LogUtil.log("INFO", "@GetMapping(\"/checkout\")..." + jobid + "-" + version);
        jobService.checkout(jobid, version);

        rttr.addFlashAttribute("result", "success");

        rttr.addAttribute("jobid", jobid);
        rttr.addAttribute("version", Integer.toString(Integer.parseInt(version) + 1));

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        rttr.addAttribute("search4", cri.getSearch4());
        rttr.addAttribute("search5", cri.getSearch5());
        rttr.addAttribute("search6", cri.getSearch6());
        rttr.addAttribute("search7", cri.getSearch7());
        rttr.addAttribute("search8", cri.getSearch8());
        return "redirect:/piijob/get";
    }

    @PostMapping("/checkin")
    @PreAuthorize("isAuthenticated()")
    public String checkin(@RequestBody PiiApprovalReqVO approvalreq
            , Criteria cri, RedirectAttributes rttr, Principal principal) {

        LogUtil.log("INFO", "@GetMapping(checkin)..." + approvalreq + "-" + cri);
        String rst = jobService.checkin(approvalreq, principal);

        rttr.addAttribute("jobid", approvalreq.getJobid());
        rttr.addAttribute("version", approvalreq.getVersion());

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        rttr.addAttribute("search3", cri.getSearch3());
        rttr.addAttribute("search4", cri.getSearch4());
        rttr.addAttribute("search5", cri.getSearch5());
        rttr.addAttribute("search6", cri.getSearch6());
        rttr.addAttribute("search7", cri.getSearch7());
        rttr.addAttribute("search8", cri.getSearch8());

        return "redirect:/piijob/list";
    }

    @ResponseBody
    @PostMapping("/order")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<String> order(@RequestBody PiiJobOrderVO joborder, Criteria cri, Model model) {

        SimpleDateFormat yyyymmdd = new SimpleDateFormat("yyyy/MM/dd");
        //Calendar basetime = Calendar.getInstance();
        Calendar runtime = Calendar.getInstance();
        Date date = null;
        try {
            date = yyyymmdd.parse(joborder.getBasedate());
        } catch (ParseException e) {
            e.printStackTrace();
        }
        runtime.setTime(date);
        runtime.add(Calendar.DATE, 1);
        String rundate = yyyymmdd.format(runtime.getTime());
        logger.warn("warn "+"/order joborder=> "+joborder.toString());
        try {
            if("ARC_DATA_DELETE".equalsIgnoreCase(joborder.getJobid())){LogUtil.log("INFO", "22   "+joborder.toString());
                orderSV.orderArcdelJob(joborder.getJobid(), joborder.getVersion(), joborder.getBasedate(), rundate);
            }else {
                orderSV.orderOneJob(joborder.getJobid(), joborder.getVersion(), joborder.getBasedate(), rundate);
            }
            return ResponseEntity.ok("success"); // 클라이언트로 결과를 반환
        } catch (Exception e) {
            logger.warn("warn "+"/order Exception=> "+e.getMessage());
            //e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }

    }

    @ResponseBody
    @PostMapping("/order/by-prog")
    @PreAuthorize("permitAll()")
    public ResponseEntity<String> orderByProg(@RequestBody ProgOrderVO req) {

        // db와 sql 파라미터가 비어있는지 함께 검증합니다.
        if (req == null || req.getProgJobNm() == null || req.getProgJobNm().isBlank()
                || req.getDb() == null || req.getDb().isBlank()
                || req.getSelectQuery() == null || req.getSelectQuery().isBlank()
                || req.getUpdateQuery() == null || req.getUpdateQuery().isBlank()
                || req.getInsertQuery() == null || req.getInsertQuery().isBlank()
        ) {
            return ResponseEntity.badRequest().body("progJobNm, db, selectQuery, updateQuery are required");
        }
        logger.warn("ProgOrderVO=: {}", req.toString());
        // 1) MCMM 조회
        final Optional<ProgJobInfoVO> rowOpt;
        PiiDatabaseVO dbVO = databaseService.get(req.getDb());
        try {
            rowOpt = dmlExecutor.selectMcmmByProgJobNm(dbVO, req.getProgJobNm(), req.getSelectQuery());
        } catch (Exception e) {
            logger.warn("select failed for{}:{}:{}: {}", dbVO, req.getSelectQuery(), req.getProgJobNm(), e.toString());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("select failed: " + e.getMessage());
        }
        logger.warn("rowOpt=: {}", rowOpt.toString());
        if (rowOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Select result is empty=> " + req.getProgJobNm()+" : "+req.getSelectQuery());
        }

        // Optional 해제
        ProgJobInfoVO row = rowOpt.get();
        logger.warn("ProgJobInfoVO=: {}", row.toString());

        // 2) JOBID 구성 (원하시는 규칙대로 조정)
        String jobid = row.getProgJobNm() + "_" + row.getBgnnChngDvcd();
        logger.info("jobid=: {}", jobid);
        // 3) VERSION 자동 결정
        int versionInt = jobService.getMaxVersionCheckinByJob(jobid);
        String version = String.valueOf(versionInt);
        logger.info("version=: {}", version);
        // 4) BASEDATE = PARAM_BASE_DT
        String basedateRaw = row.getParamBaseDt();
        // 👇 이 라인을 추가하여 숫자 외 모든 문자를 제거합니다.
        String digitsOnly = basedateRaw.replaceAll("[^0-9]", ""); // 결과: "20250801"
        String year = digitsOnly.substring(0, 4);  // "2025"
        String month = digitsOnly.substring(4, 6); // "08"
        String day = digitsOnly.substring(6, 8);   // "01"

        String basedate = year + "/" + month + "/" + day; // 결과: "2025/08/01"

        // 5) rundate 계산
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
        String rundate = LocalDateTime.now().format(formatter);

        logger.warn("basedate=: {}", basedate);
        logger.warn("rundate=: {}", rundate);

        // 6) 주문 실행
        try {
            int orderid = orderSV.orderOneJob(jobid, version, basedate, rundate);

            ProgOrderHistVO progorderhist = new ProgOrderHistVO();
            progorderhist.setOrderid(orderid);
            progorderhist.setProg_job_nm(row.getProgJobNm());
            progorderhist.setBgnn_chng_dvcd(row.getBgnnChngDvcd());
            progorderhist.setParam_base_dt(row.getParamBaseDt());
            progorderhist.setDb(req.getDb());
            progorderhist.setUpdate_query(req.getUpdateQuery());
            progorderhist.setInsert_query(req.getInsertQuery());
            //progorderhist.setCreated_at("");  //default setting
            //progorderhist.setError_message("");

            progOrderHistService.register(progorderhist);
            /**
             * 나중에   작업이  종료 되었는지 확인 해야해서  orderid 의 상태가 'Ended OK' 를 확인하면   DW 배치 스케줄 마스터에 상태를 업데이트 하고  해당 ORDERID 정보도 지우자
             *  어떻게 구현 할지   지금 생각은 스케줄을 하나 돌리면 될거 같아......1분에 한번씩 돌게 해서 확인해서 처리하는거.....TBL_PIIorder에 안쓰는 필드 있는지 확인하고
             *  사용하면 테이블 안만들어도 되고..
             *  POLICY_ID  사용하면 된다.  EXE_MIGRATE은 NULL 이기 때문에.....POLICY_ID IS NULL AND STATUS = Ended OK 이면.....
             *  MCMM_ETT_JOB_MST_M가  칼럼 상태 업데이트 치고
             *  이 칼럼을 "SEND_RST" 로 업데이트 치고
             *  업데이트 치는 SQL도 만들어야 되네... 그냥 테이블 하나 만들자.
             * */

            return ResponseEntity.ok("success");
        } catch (Exception e) {
            logger.warn("warn /order/by-prog Exception => {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }




}
