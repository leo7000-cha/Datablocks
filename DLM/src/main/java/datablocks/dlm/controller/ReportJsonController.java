package datablocks.dlm.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import datablocks.dlm.domain.ReportJsonVO;
import datablocks.dlm.service.ReportJsonService;
import datablocks.dlm.util.HtmlToPdfUtil;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.ReportSchemaLoader;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.FileInputStream;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/report")
@AllArgsConstructor
public class ReportJsonController {
    private static final Logger logger = LoggerFactory.getLogger(ReportJsonController.class);
    private ReportJsonService reportJsonService;

    @GetMapping("/form")
    public String showForm(@RequestParam("srvyId") String srvyId,
                           @RequestParam("formName") String formName,
                           Model model, HttpServletRequest request)  throws Exception {
        // 1. 저장된 JSON 조회
        ReportJsonVO report = reportJsonService.get(srvyId, formName);
        LogUtil.log("WARN", "showForm   srvyId:%s formName:%s ", srvyId, formName );
        Map<String, Object> schema;
        Map<String, Object> input;
        ObjectMapper mapper = new ObjectMapper();
        if (report != null) {
            // ✅ 저장된 JSON이 있으면 해당 내용 사용
            LogUtil.log("WARN", "showForm report != null  srvyId:%s formName:%s ", srvyId, formName );
            schema = mapper.readValue(report.getForm_json(), new TypeReference<>() {});
            input = mapper.readValue(report.getInput_json(), new TypeReference<>() {});
        } else {
            // ❌ 저장된 내용이 없으면 formName 기준 스키마 로드
            LogUtil.log("WARN", "showForm report == null  srvyId:%s formName:%s ", srvyId, formName );

            try {
                String path = request.getSession().getServletContext().getRealPath("/WEB-INF/ReportJson");
                schema = ReportSchemaLoader.load(formName, path);
            } catch (Exception e) {
                logger.warn("warn "+"request.getSession().getServletContext().getRealPath('/WEB-INF/ReportJson') is null");
                throw new RuntimeException("Couldn't find /WEB-INF/ReportJson path.", e);
            }

            input = new HashMap<>(); // 입력값은 비워둠
        }

        model.addAttribute("form", schema);
        model.addAttribute("data", input);
        model.addAttribute("srvyId", srvyId);       // 나중에 저장 시 필요
        model.addAttribute("formName", formName);   // 나중에 저장 시 필요

        return "report/reportForm"; // reportForm.jsp
    }


    // 저장 처리 (예: /report/save)
    @PostMapping("/save")
    public String saveReport(HttpServletRequest request, Model model) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        Map<String, String> inputMap = new HashMap<>();

        // 사용자가 입력한 name-value 파싱
        Enumeration<String> names = request.getParameterNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            String value = request.getParameter(name);
            inputMap.put(name, value);
        }

        String srvyId = request.getParameter("srvyId");
        String formName = request.getParameter("formName");
        LogUtil.log("WARN", "srvyId:%s formName:%s ", srvyId, formName );


        String fileSeparator = System.getProperty("file.separator");
        String path = request.getSession().getServletContext().getRealPath("/WEB-INF/ReportJson");

        // JSON 폼 정의 불러오기
        InputStream formStream = new FileInputStream(path + fileSeparator + formName + ".json");
        JsonNode formJson = mapper.readTree(formStream);
        //String formName = formJson.get("form_name").asText();

        String formJsonStr = mapper.writeValueAsString(formJson);
        String inputJsonStr = mapper.writeValueAsString(inputMap);
        //LogUtil.log("WARN", "formJsonStr:%s "+ formJsonStr );
        //LogUtil.log("WARN", "inputJsonStr: "+ inputJsonStr );
        String result = reportJsonService.saveReportJson(srvyId, formName, formJsonStr, inputJsonStr);

        // 저장 후 다시 보여줄 값 전달
        model.addAttribute("form", mapper.convertValue(formJson, Map.class));
        model.addAttribute("data", inputMap);
        model.addAttribute("result", result);
        return "report/reportSaved"; // 저장 결과 페이지
    }

    @GetMapping("/view")
    public String viewReport(
            @RequestParam("srvyId") String srvyId,
            @RequestParam("formName") String formName,
            Model model
    ) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        LogUtil.log("WARN", "/report/view ==>  srvyId:%s , formName:%s ", srvyId, formName );
        ReportJsonVO report = reportJsonService.get(srvyId, formName);

        if (report == null) {
            throw new IllegalArgumentException("해당 보고서가 존재하지 않습니다.");
        }

        Map<String, Object> formMap = mapper.readValue(report.getForm_json(), new TypeReference<>() {});
        Map<String, String> inputMap = mapper.readValue(report.getInput_json(), new TypeReference<>() {});

        model.addAttribute("form", formMap);
        model.addAttribute("data", inputMap);

        return "report/reportPDF";
    }


    @GetMapping("/print")
    public void printAsPdf(@RequestParam String srvyId,
                           @RequestParam String formName,
                           HttpServletResponse response) throws Exception {

        String url = "http://localhost:8080/report/view?srvyId=" + URLEncoder.encode(srvyId, "UTF-8")
                + "&formName=" + URLEncoder.encode(formName, "UTF-8");

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=\"report.pdf\"");

        HtmlToPdfUtil.convertUrlToPdf(url, response.getOutputStream());
    }

}

