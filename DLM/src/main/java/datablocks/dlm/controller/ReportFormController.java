package datablocks.dlm.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import datablocks.dlm.domain.ReportJsonVO;
import datablocks.dlm.schedule.JobScheduler;
import datablocks.dlm.util.LogUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/reportform")
public class ReportFormController {
    private static final Logger logger = LoggerFactory.getLogger(ReportFormController.class);
    private final ObjectMapper mapper = new ObjectMapper();

    @GetMapping("/editor")
    public String openEditor(@RequestParam(required = false) String name, Model model, HttpServletRequest request) throws IOException {
        String fileSeparator = System.getProperty("file.separator");
        String realPath = request.getSession().getServletContext().getRealPath("/WEB-INF/ReportJson");
        Path filePath = name != null ? Paths.get(realPath + fileSeparator + name + ".json") : null;

        if (filePath != null && Files.exists(filePath)) {
            String json = Files.readString(filePath);
            //logger.warn(json);
            model.addAttribute("json", json);
            model.addAttribute("name", name);
        } else {
            logger.warn("filePath == null");
            model.addAttribute("json", "{ \"form_name\": \"\", \"sections\": [] }");
            model.addAttribute("name", name != null ? name : "");
        }
        return "reportform/reportNewForm";
    }
    @GetMapping("/view")
    public String viewReport(
            @RequestParam("name") String name,
            Model model, HttpServletRequest request
    ) throws Exception {
        String fileSeparator = System.getProperty("file.separator");
        String realPath = request.getSession().getServletContext().getRealPath("/WEB-INF/ReportJson");
        Path filePath = name != null ? Paths.get(realPath + fileSeparator + name + ".json") : null;
        String json;
        if (filePath != null && Files.exists(filePath)) {
            json = Files.readString(filePath);
            logger.warn(json);
        } else {
            throw new IllegalArgumentException("해당 보고서가 존재하지 않습니다.");
        }

        Map<String, Object> formMap = mapper.readValue(json, new TypeReference<>() {});

        model.addAttribute("form", formMap);
        model.addAttribute("data", null);

        return "report/reportPDF";
    }
    @PostMapping("/save")
    public ResponseEntity<String> save(
            @RequestParam("jsonData") String jsonData,
            @RequestParam("formName") String formName,
            HttpServletRequest request
    ) {
        try {
            // 파일명 보안 처리
            String safeFormName = formName.replaceAll("[^a-zA-Z0-9가-힣_\\-]", "_");

            // 저장 경로 설정
            String realPath = request.getServletContext().getRealPath("/WEB-INF/ReportJson");
            Path filePath = Paths.get(realPath, safeFormName + ".json");

            // 디렉토리 생성 (없을 경우)
            Files.createDirectories(filePath.getParent());

            // 파일 저장
            Files.writeString(filePath, jsonData, StandardCharsets.UTF_8);

            return ResponseEntity.ok("파일이 성공적으로 저장되었습니다.");
        } catch (IOException e) {
            return ResponseEntity.internalServerError()
                    .body("파일 저장 실패: " + e.getMessage());
        }
    }

}
