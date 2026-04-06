package datablocks.dlm.controller;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.schedule.TestDataDisposalScheduler;
import datablocks.dlm.service.*;
import datablocks.dlm.util.LogUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.security.Principal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Slf4j
@Controller
@RequestMapping("/testdata/")
@RequiredArgsConstructor
public class TestDataController {
    private final TestDataService service;
    private final PiiDatabaseService dbservice;
    private final PiiSystemService systemService;
    private final PiiJobService jobService;
    private final TestDataIdTypeService testDataIdTypeService;
    private final TestDataDisposalScheduler testDataDisposalScheduler; // 서비스 주입
    private final ExcelService excelService;

    @PostMapping("/disposal/{testdataid}")
    public ResponseEntity<String> orderDisposal(@PathVariable int testdataid) {
        LogUtil.log("WARN", "//disposal/{testdataid}: " + testdataid);
        // 컨트롤러는 요청을 받고 Service의 메소드를 호출하는 역할만 수행
        try {
            testDataDisposalScheduler.createDisposalOrderFor(testdataid);
            return ResponseEntity.ok("파기 오더 생성 요청이 성공적으로 처리되었습니다.");
        } catch (IllegalArgumentException e) {
            // 위에서 던진 예외를 여기서 잡아서 구체적인 오류 메시지를 반환
            LogUtil.log("WARN",(e.getMessage()));
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            LogUtil.log("WARN","Disposal order creation failed for testdataid: {}", testdataid, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("파기 오더 생성 중 서버에서 오류가 발생했습니다.");
        }
    }

    /**
     * 테스트 데이터의 파기 예정일을 업데이트하는 API
     * UpdateDisposalScheDateVO   testdataid와 disposalScheDate를 포함하는 JSON 객체
     * @return
     */
    @PostMapping("/updateDisposalScheDate")
    public ResponseEntity<String> updateDisposalScheduleDate(@RequestBody UpdateDisposalScheDateVO dto) {
        try {
            // 1. 서비스 계층의 메서드를 직접 호출합니다.
            // Spring이 JSON 데이터를 알아서 UpdateDisposalScheDateVO 객체로 변환해줍니다.
            boolean isSuccess = service.updateDisposalSchedule(dto);

            // 2. 서비스 계층의 처리 결과에 따라 다른 응답을 반환합니다.
            if (isSuccess) {
                LogUtil.log("INFO", "ID: " + dto.getTestdataid() + " 의 파기 예정일이 " + dto.getDisposalScheDate() + " 로 업데이트되었습니다.");
                return new ResponseEntity<>("Update successful", HttpStatus.OK);
            } else {
                // 서비스 로직에서 유효성 검사 실패 등으로 false를 반환한 경우
                LogUtil.log("WARN", "ID: " + dto.getTestdataid() + " 의 파기 예정일 업데이트에 실패했습니다.");
                return new ResponseEntity<>("Update failed. Please check the data.", HttpStatus.BAD_REQUEST);
            }

        } catch (Exception e) {
            // 3. 데이터베이스 오류 등 예외 발생 시 처리
            e.printStackTrace();
            return new ResponseEntity<>("Error updating date: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register() {

    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("INFO", "/testdata list(Criteria cri, Model model): " + cri);
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/testdata total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/testdata pageMaker: " + pageMaker);
        String site = EnvConfig.getConfig("SITE");
        /*사이트별 UI 구성을 다르게 하기 위해 */
        model.addAttribute("site", site);
        model.addAttribute("testdataidtypelist", testDataIdTypeService.getList());
    }

    @GetMapping("/apply")
    @PreAuthorize("isAuthenticated()")
    public void apply(Criteria cri, Model model, HttpServletRequest request) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("INFO", "/testdata apply (Criteria cri, Model model): " + cri);

        model.addAttribute("listsystem", systemService.getList());
        model.addAttribute("sourcedb", dbservice.getBySystem(cri.getSearch2()));
        model.addAttribute("piidatabaselist", dbservice.getList(cri));
        Criteria critestjob = new Criteria();
        critestjob.setSearch1("TESTDATA_AUTO_GEN");
        model.addAttribute("testdatajoblist", jobService.getTestdataAutoGenList());
        model.addAttribute("testdataidtypelist", testDataIdTypeService.getList());

        model.addAttribute("cri", cri);
    }

    @ResponseBody
    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(@RequestBody List<TestDataVO> testdatalist, Criteria cri, @RequestParam("reqreason") String reqreason,@RequestParam("aprvlineid") String aprvlineid, @RequestParam("applytype") String applytype, Model model, Principal principal) {
        LogUtil.log("INFO", "/testdata register: " + cri + " " + reqreason + " " + aprvlineid + " " + applytype + " " + applytype);
        List<String> stringList = new ArrayList<>();
        List<String> stringListNew = new ArrayList<>();
        int i = 0;
        String system = null;
        String sourceDB = null;
        String targetDB = null;
        String jobid = null;
        String idtype = null;
        for (TestDataVO testData : testdatalist) {
            stringList.add(testData.getCustid());
            stringListNew.add(testData.getCustid_new());
            if(i == 0){
                system = testData.getSystem();
                sourceDB = testData.getSourcedb();
                targetDB = testData.getTargetdb();
                jobid = testData.getJobid();
                idtype = testData.getIdtype();
            }
        }

        return service.register(principal, stringList, stringListNew, reqreason, aprvlineid, applytype, system, sourceDB, targetDB, jobid, idtype);
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("testdataid") int testdataid, Criteria cri, Model model) {
        LogUtil.log("INFO", "/testdata @GetMapping  /get or modify = " + testdataid);
        model.addAttribute("testdata", service.get(testdataid));

        model.addAttribute("cri", cri);
    }
    @GetMapping({"/getmasterkeymaplist"})
    @PreAuthorize("isAuthenticated()")
    public void getmasterkeylist(@RequestParam("testdataid") int testdataid, @RequestParam("new_orderid") int new_orderid, Model model) {
        LogUtil.log("INFO", "/testdata @GetMapping  /getmasterkeymaplist = " +new_orderid);
        model.addAttribute("masterkeylist",service.getListMasterKeymap(new_orderid));
        model.addAttribute("testdata", service.get(testdataid));

    }

    @GetMapping("/testDataUsageStatus")
    public String getTestDataStatus(
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate,
            Model model) {

        LogUtil.log("WARN", "TestDataController.getTestDataStatus() called with startDate: " + startDate + ", endDate: " + endDate);
        // 날짜 파라미터가 둘 다 null이거나 빈 값인 경우, 최근 한 달 기간으로 설정
        if ((startDate == null || startDate.isEmpty()) && (endDate == null || endDate.isEmpty())) {
            LocalDate today = LocalDate.now();
            LocalDate oneMonthAgo = today.minusMonths(1);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd");

            startDate = oneMonthAgo.format(formatter);
            endDate = today.format(formatter);
        }

        // Log.info() 대신 LogUtil.log() 사용
        LogUtil.log("WARN", "TestDataController.getTestDataStatus() called with startDate: " + startDate + ", endDate: " + endDate);

        List<TestDataCombinedStatusVO> statusList = service.getTestDataStatus(startDate, endDate);
        // 합계 계산
        long totalAutoGenRequestCount = 0;
        long totalAutoGenCustomerCount = 0;
        long totalTableLoadRequestCount = 0;
        long totalTableLoadTableCount = 0;

        for (TestDataCombinedStatusVO status : statusList) {
            totalAutoGenRequestCount += status.getAutoGenRequestCount();
            totalAutoGenCustomerCount += status.getAutoGenCustomerCount();
            totalTableLoadRequestCount += status.getTableLoadRequestCount();
            totalTableLoadTableCount += status.getTableLoadTableCount();
        }
        // 모델에 합계 값 추가
        model.addAttribute("totalAutoGenRequestCount", totalAutoGenRequestCount);
        model.addAttribute("totalAutoGenCustomerCount", totalAutoGenCustomerCount);
        model.addAttribute("totalTableLoadRequestCount", totalTableLoadRequestCount);
        model.addAttribute("totalTableLoadTableCount", totalTableLoadTableCount);

        // startDate와 endDate 값을 모델에 추가
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);

        model.addAttribute("statusList", statusList);

        // 'testDataUsageStatus.html' 이라는 이름의 Thymeleaf/JSP 뷰를 반환한다고 가정
        return "testdata/testDataUsageStatus";
    }

    @GetMapping("/testDataUsageStatus/excel")
    public String downloadTestDataStatusExcel(
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate,
            Model model,
            HttpServletRequest request) { // HttpServletRequest를 추가하여 템플릿 경로를 가져옴

        // 날짜 파라미터가 둘 다 null이거나 빈 값인 경우, 최근 한 달 기간으로 설정
        if ((startDate == null || startDate.isEmpty()) && (endDate == null || endDate.isEmpty())) {
            LocalDate today = LocalDate.now();
            LocalDate oneMonthAgo = today.minusMonths(1);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd");
            startDate = oneMonthAgo.format(formatter);
            endDate = today.format(formatter);
        }

        // 데이터 조회 (기존 로직 재사용)
        List<TestDataCombinedStatusVO> statusList = service.getTestDataStatus(startDate, endDate);
        long totalAutoGenRequestCount = 0;
        long totalAutoGenCustomerCount = 0;
        long totalTableLoadRequestCount = 0;
        long totalTableLoadTableCount = 0;

        for (TestDataCombinedStatusVO status : statusList) {
            totalAutoGenRequestCount += status.getAutoGenRequestCount();
            totalAutoGenCustomerCount += status.getAutoGenCustomerCount();
            totalTableLoadRequestCount += status.getTableLoadRequestCount();
            totalTableLoadTableCount += status.getTableLoadTableCount();
        }

        // 템플릿 파일 경로 설정
        String path = request.getSession().getServletContext().getRealPath("/WEB-INF/template");

        // ExcelService를 호출하여 워크북 생성
        XSSFWorkbook workbook = excelService.makeTestDataStatusTemplateExcel(path, "TESTDATA_STATUS", statusList, startDate, endDate
        , totalAutoGenRequestCount
        , totalAutoGenCustomerCount
        , totalTableLoadRequestCount
        , totalTableLoadTableCount
        );

        // 모델에 워크북과 파일 이름 추가
        model.addAttribute("workbook", workbook);
        model.addAttribute("workbookName", "TestDataUsageStatus"); // 원하는 파일명으로 설정

        // Excel 파일을 생성할 뷰(ExcelDownloadView)를 반환
        return "excelDownloadView";
    }
}
