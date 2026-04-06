package datablocks.dlm.controller;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiCustStatVO;
import datablocks.dlm.service.*;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.apache.commons.io.FilenameUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

@Controller
@RequestMapping("/piiupload/*")
@AllArgsConstructor
public class PiiUploadController {
    private static final String UPLOAD_DIR = "/opt/tomcat/latest/work/Catalina/localhost/ROOT/upload";
    private static final Logger logger = LoggerFactory.getLogger(PiiUploadController.class);
    private PiiStepTableService steptableservice;
    private PiiOrderStepTableService ordersteptableService;
    private PiiExtractService extractService;
    private ExcelService excelservice;
    private PiiJobService jobservice;
    private MetaTableService metaservice;
    private PiiContractService contractService;
    private PiiMemberService memberService;
    private MetaTableService metaTableService;
    @Autowired
    MessageSource messageSource;

    @Autowired
    private ServletContext servletContext;

    @GetMapping("/uploadForm")
    public void uploadForm() {

        LogUtil.log("INFO", "upload form");
    }

    // @PostMapping("/uploadFormAction")
    // public void uploadFormPost(MultipartFile[] uploadFile, Model model) {
    //
    // for (MultipartFile multipartFile : uploadFile) {
    //
    // LogUtil.log("INFO", "-------------------------------------");
    // LogUtil.log("INFO", "Upload File Name: " +multipartFile.getOriginalFilename());
    // LogUtil.log("INFO", "Upload File Size: " +multipartFile.getSize());
    //
    // }
    // }

    @PostMapping("/uploadFormAction")
    public void uploadFormPost(MultipartFile[] uploadFile, Model model) {

        String uploadFolder = "C:\\upload";

        for (MultipartFile multipartFile : uploadFile) {

            LogUtil.log("INFO", "-------------------------------------");
            LogUtil.log("INFO", "Upload File Name: " + multipartFile.getOriginalFilename());
            LogUtil.log("INFO", "Upload File Size: " + multipartFile.getSize());

            File saveFile = new File(uploadFolder, multipartFile.getOriginalFilename());

            try {
                multipartFile.transferTo(saveFile);
            } catch (Exception e) {
                logger.error(e.getMessage());
            } // end catch
        } // end for

    }

    @GetMapping("/uploadAjax")
    public void uploadAjax() {

        LogUtil.log("INFO", "upload ajax");
    }


    private String getFolder() {

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        Date date = new Date();

        String str = sdf.format(date);

        return str.replace("-", File.separator);
    }


    private boolean checkImageType(File file) {

        try {
            String contentType = Files.probeContentType(file.toPath());

            return contentType.startsWith("image");

        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return false;
    }

    /* 운영환경에 일반파일 업로드 console 화면엔서 사용함 20230614 */
    @PreAuthorize("isAuthenticated()")
    @PostMapping(value = "/uploadFile", produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
    @ResponseBody
    public String uploadFile(MultipartFile[] uploadFile, @RequestParam("path") String path) {
        if (uploadFile.length < 1) {
            // 파일이 없을 경우 예외 처리 또는 오류 메시지를 반환할 수 있습니다.
            return "upload-error: file.isEmpty";
        }
        logger.warn("warn "+path);
        for (MultipartFile multipartFile : uploadFile) {
            try {
                String fileName = multipartFile.getOriginalFilename();
                String extension = FilenameUtils.getExtension(fileName);
//            File destinationFile = new File(UPLOAD_DIR + File.separator + fileName);
                File destinationFile = new File(path + File.separator + fileName);

                // 파일 저장
                FileCopyUtils.copy(multipartFile.getBytes(), destinationFile);

                // 파일 업로드 성공 시 처리할 로직을 추가할 수 있습니다.

                return "successfully processed";
            } catch (IOException e) {
                // 파일 업로드 중 예외가 발생한 경우 예외 처리 또는 오류 메시지를 반환할 수 있습니다.
                e.printStackTrace();
                return "upload-error: " + e.getMessage();
            }
        }
        return "successfully processed";
    }

    /* 운영환경에서 일반파일 다운로드 console 화면엔서 사용함 20230614 */
    @GetMapping("/downloadFile")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Resource> downloadFile(@RequestHeader("User-Agent") String userAgent, @RequestParam("path") String path, @RequestParam("filename") String filename) {

        // 파일 경로 및 이름을 합칩니다.
        String filePath = path + File.separator + filename;
        Resource resource = new FileSystemResource(filePath);
        if (resource.exists() == false) {
            logger.warn("warn "+filePath + " resource.exists() == false");
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        String resourceName = resource.getFilename();
        HttpHeaders headers = new HttpHeaders();
        try {
            String downloadName = null;
            if (userAgent.contains("Trident")) {
                downloadName = URLEncoder.encode(resourceName, "UTF8");
            } else if (userAgent.contains("Edge")) {
                downloadName = URLEncoder.encode(resourceName, "UTF8");
            } else {
                downloadName = new String(resourceName.getBytes("UTF-8"), "ISO-8859-1");
            }
            headers.add("Content-Disposition", "attachment; filename=" + downloadName);
        } catch (UnsupportedEncodingException e) {
            logger.warn("warn "+"UnsupportedEncodingException;");
            e.printStackTrace();
        }
        return new ResponseEntity<Resource>(resource, headers, HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping(value = "/uploadAjaxAction", produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
    @ResponseBody
    //public ResponseEntity<List<PiiAttachFileDTO>> uploadAjaxPost(MultipartFile[] uploadFile, @RequestParam("jobid") String jobid, @RequestParam("version") String version,
    public String uploadAjaxPost(MultipartFile[] uploadFile, @RequestParam("jobid") String jobid, @RequestParam("version") String version,
                                 @RequestParam("stepid") String stepid, @RequestParam("userid") String userid) {

        return steptableservice.uploadExcelSteptable(uploadFile, jobid, version, stepid, userid);
    }
    @PreAuthorize("isAuthenticated()")
    @PostMapping(value = "/uploadfromDBAjaxAction", produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
    @ResponseBody
    public String uploadfromDBAjaxPost(@RequestParam("jobid") String jobid, @RequestParam("version") String version,
                                 @RequestParam("stepid") String stepid, @RequestParam("userid") String userid) {
        LogUtil.log("INFO", jobid +"  "+ version +"  "+ stepid +"  "+ userid);
        return steptableservice.uploadExcelSteptableFromDB(jobid, version, stepid, userid);
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping(value = "/uploadMetadata", produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
    @ResponseBody
    //public ResponseEntity<List<PiiAttachFileDTO>> uploadAjaxPost(MultipartFile[] uploadFile, @RequestParam("jobid") String jobid, @RequestParam("version") String version,
    public String uploadMetadata(MultipartFile[] uploadFile) {

        return metaTableService.uploadMetadata(uploadFile);
    }

    @GetMapping("/display")
    @ResponseBody
    public ResponseEntity<byte[]> getFile(String fileName) {
        LogUtil.log("INFO", "fileName: " + fileName);
        File file = new File("c:\\upload\\" + fileName);
        LogUtil.log("INFO", "file: " + file);
        ResponseEntity<byte[]> result = null;
        try {
            HttpHeaders header = new HttpHeaders();

            header.add("Content-Type", Files.probeContentType(file.toPath()));
            result = new ResponseEntity<>(FileCopyUtils.copyToByteArray(file), header, HttpStatus.OK);
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return result;
    }

    @GetMapping(value = "/download", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    @ResponseBody
    public ResponseEntity<Resource> downloadFile(@RequestHeader("User-Agent") String userAgent, String fileName, HttpServletRequest request) {
        String path = "/opt/tomcat/latest/webapps/DLM/WEB-INF/template";
        try {
            path = request.getSession().getServletContext().getRealPath("/WEB-INF/template");
        }catch(Exception e){
            logger.warn("warn "+"request.getSession().getServletContext().getRealPath('/WEB-INF/template') is null");
        }
        Resource resource = new FileSystemResource(path + "\\" + fileName);
        if (resource.exists() == false) {
            logger.warn("warn "+path + "\\" + fileName + " resource.exists() == false");
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        String resourceName = resource.getFilename();
        HttpHeaders headers = new HttpHeaders();
        try {
            String downloadName = null;
            if (userAgent.contains("Trident")) {
                downloadName = URLEncoder.encode(resourceName, "UTF8");
            } else if (userAgent.contains("Edge")) {
                downloadName = URLEncoder.encode(resourceName, "UTF8");
            } else {
                downloadName = new String(resourceName.getBytes("UTF-8"), "ISO-8859-1");
            }
            headers.add("Content-Disposition", "attachment; filename=" + downloadName);
        } catch (UnsupportedEncodingException e) {
            logger.warn("warn "+"UnsupportedEncodingException;");
            e.printStackTrace();
        }
        return new ResponseEntity<Resource>(resource, headers, HttpStatus.OK);
    }

    @PostMapping("/download_steptable")
    @PreAuthorize("isAuthenticated()")
    public String download_steptable(Model model, @RequestParam("jobid") String jobid, @RequestParam("version") String version, @RequestParam("stepid") String stepid, @RequestParam("exeType") String exeType, HttpServletRequest request) {
        LogUtil.log("INFO", "download_steptable 0 => "+jobid+"  "+stepid+"  "+version+"  "+exeType+" getRealPath >>>");
        String path = "/opt/tomcat/latest/webapps/DLM/WEB-INF/template";
        LogUtil.log("INFO", "download_steptable 1 => "+jobid+"  "+stepid+"  "+version+"  "+exeType+" getRealPath >>>"+path);
        try {
            path = request.getSession().getServletContext().getRealPath("/WEB-INF/template");
        }catch(Exception e){
            logger.warn("warn "+"request.getSession().getServletContext().getRealPath('/WEB-INF/template') is null");
        }
        LogUtil.log("INFO", "download_steptable 2 => "+jobid+"  "+stepid+"  "+version+"  "+exeType+" getRealPath >>>"+path);

        Criteria cri = new Criteria();
        cri.setPagenum(1);
        cri.setAmount(100000);
        cri.setSearch1(jobid);
        cri.setSearch2(version);
        cri.setSearch3(stepid);
        XSSFWorkbook workbook = excelservice.makeStepTableExcelTemplate(path, exeType, jobid
                , steptableservice.getListWithWait(cri)
                , steptableservice.getList_Keymap(jobid, version)
        );
        model.addAttribute("locale", Locale.KOREA);
        model.addAttribute("workbook", workbook);
        model.addAttribute("workbookName", jobid + "(" + stepid + ")");
        return "excelDownloadView";
    }
    @PostMapping("/download_metadata")
    @PreAuthorize("isAuthenticated()")
    public String download_metadata(Model model, Criteria cri, HttpServletRequest request) {
        cri.setOffset(0);
        String path = "/opt/tomcat/latest/webapps/DLM/WEB-INF/template";
        try {
            path = request.getSession().getServletContext().getRealPath("/WEB-INF/template");
        }catch(Exception e){
            logger.warn("warn "+"request.getSession().getServletContext().getRealPath('/WEB-INF/template') is null");
        }
        cri.setPagenum(1);
        cri.setAmount(200000);
        logger.warn("warn "+"download_metadata => "+cri);
        XSSFWorkbook workbook = excelservice.makeMetadataExcelTemplate(path, "METADATA"
                , metaservice.getList(cri));
        model.addAttribute("locale", Locale.KOREA);
        model.addAttribute("workbook", workbook);
        model.addAttribute("workbookName", "Table Meta Data");
        return "excelDownloadView";
    }
    @PostMapping("/download_metadata_gap")
    @PreAuthorize("isAuthenticated()")
    public String download_metadata_gap(Model model, Criteria cri, HttpServletRequest request) {
        cri.setOffset(0);
        String path = "/opt/tomcat/latest/webapps/DLM/WEB-INF/template";
        try {
            path = request.getSession().getServletContext().getRealPath("/WEB-INF/template");
        }catch(Exception e){
            logger.warn("warn "+"request.getSession().getServletContext().getRealPath('/WEB-INF/template') is null");
        }
        cri.setPagenum(1);
        cri.setAmount(200000);
        LogUtil.log("INFO", "download_metadata_gap => "+cri);
        XSSFWorkbook workbook = excelservice.makeMetadataGapExcelTemplate(path, "METADATA_GAP"
                , metaservice.getList_GapVO(cri));
        model.addAttribute("locale", Locale.KOREA);
        model.addAttribute("workbook", workbook);
        model.addAttribute("workbookName", "PII Registered Status");
        return "excelDownloadView";
    }
    @PostMapping("/download_cust_history")
    @PreAuthorize("isAuthenticated()")
    public String download_cust_history(Locale locale, Model model, Criteria cri, HttpServletRequest request, Authentication authentication) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        String path = "/opt/tomcat/latest/webapps/DLM/WEB-INF/template";
        try {
            path = request.getSession().getServletContext().getRealPath("/WEB-INF/template");
        }catch(Exception e){
            logger.warn("warn "+"request.getSession().getServletContext().getRealPath('/WEB-INF/template') is null");
        }
        cri.setPagenum(1);
        cri.setAmount(100000);
        logger.warn("warn "+"download_cust_history cri=> "+cri);
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        String username = userDetails.getUsername();
        username = memberService.get(username).getUsername();
        XSSFWorkbook workbook = excelservice.makeCustHistoryExcel(locale, path, "CUST_HISTORY", extractService.getList(cri),cri,username);

        model.addAttribute("locale", Locale.KOREA);
        model.addAttribute("workbook", workbook);
        model.addAttribute("workbookName", messageSource.getMessage("memu.report_cust_list", null, "PII_destruction_history", locale));
        return "excelDownloadView";
    }

    @PostMapping("/deleteFile")
    @ResponseBody
    public ResponseEntity<String> deleteFile(String fileName, String type) {
        LogUtil.log("INFO", "deleteFile: " + fileName);
        File file;
        try {
            file = new File("c:\\upload\\" + URLDecoder.decode(fileName, "UTF-8"));
            file.delete();
            if (type.equals("image")) {
                String largeFileName = file.getAbsolutePath().replace("s_", "");
                LogUtil.log("INFO", "largeFileName: " + largeFileName);
                file = new File(largeFileName);
                file.delete();
            }
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<String>("deleted", HttpStatus.OK);
    }

    @PostMapping("/download_cust_stat")
    @PreAuthorize("isAuthenticated()")
    public String download_cust_stat(Locale locale, Model model, Criteria cri, HttpServletRequest request, Authentication authentication) {
        String path = "/opt/tomcat/latest/webapps/DLM/WEB-INF/template";
        try {
            path = request.getSession().getServletContext().getRealPath("/WEB-INF/template");
        }catch(Exception e){
            logger.warn("warn "+"request.getSession().getServletContext().getRealPath('/WEB-INF/template') is null");
        }
        cri.setPagenum(1);
        cri.setAmount(100000);
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        String username = userDetails.getUsername();
        username = memberService.get(username).getUsername();
//        logger.warn("warn "+"download_cust_stat cri=> "+cri+ locale);
        if("MONTHLY_CONSENT".equalsIgnoreCase(cri.getSearch6())) {
            XSSFWorkbook workbook1 = excelservice.makeCustStatConsentExcel(locale, path, "CUST_STAT_CONSENT", extractService.getCustStatList_consent(cri), cri, username);
            model.addAttribute("workbook", workbook1);
        }else{
            List<PiiCustStatVO> list =  extractService.getCustStatList(cri);
            XSSFWorkbook workbook2 = excelservice.makeCustStatExcel(locale, path, "CUST_STAT", list, cri, username);
            model.addAttribute("workbook", workbook2);
        }
        model.addAttribute("locale", Locale.KOREA);

        model.addAttribute("workbookName", messageSource.getMessage("menu.month_pagi_stat", null, "Monthly destruction report", locale.KOREA));
        return "excelDownloadView";
    }

    @PostMapping("/download_real_doc_list")
    @PreAuthorize("isAuthenticated()")
    public String download_real_doc_list(Locale locale, Model model, Criteria cri, HttpServletRequest request) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        String path = "/opt/tomcat/latest/webapps/DLM/WEB-INF/template";
        try {
            path = request.getSession().getServletContext().getRealPath("/WEB-INF/template");
        }catch(Exception e){
            logger.warn("warn "+"request.getSession().getServletContext().getRealPath('/WEB-INF/template') is null");
        }
        LogUtil.log("INFO", "download_metadata => "+cri);
        cri.setPagenum(1);
        cri.setAmount(500000);
        XSSFWorkbook workbook = excelservice.makeRealDocMgmtExcel(locale, path, "REAL_DOC_LIST"
                , contractService.getList(cri), cri);
        model.addAttribute("locale", Locale.KOREA);
        model.addAttribute("workbook", workbook);
        model.addAttribute("workbookName", messageSource.getMessage("memu.real_doc_del_mgmt", null, "Document destruction management", locale));
        return "excelDownloadView";
    }

    @PostMapping("/download_real_doc_stat")
    @PreAuthorize("isAuthenticated()")
    public String download_real_doc_stat(Locale locale, Model model, Criteria cri, HttpServletRequest request) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        String path = "/opt/tomcat/latest/webapps/DLM/WEB-INF/template";
        try {
            path = request.getSession().getServletContext().getRealPath("/WEB-INF/template");
        }catch(Exception e){
            logger.warn("warn "+"request.getSession().getServletContext().getRealPath('/WEB-INF/template') is null");
        }

        LogUtil.log("INFO", "download_metadata => "+cri);
        cri.setPagenum(1);
        cri.setAmount(100000);
        XSSFWorkbook workbook = excelservice.makeRealDocStatExcel(locale, path, "REAL_DOC_STAT"
                , contractService.getStatList(cri), cri);
        model.addAttribute("locale", Locale.KOREA);
        model.addAttribute("workbook", workbook);
        model.addAttribute("workbookName", messageSource.getMessage("menu.month_real_doc_pagi_stat", null, "Document destruction status", locale));
        return "excelDownloadView";
    }

    @PostMapping("/download_table_del_stat")
    @PreAuthorize("isAuthenticated()")
    public String download_table_del_stat(Locale locale, Model model, Criteria cri, HttpServletRequest request) {
        String path = "/opt/tomcat/latest/webapps/DLM/WEB-INF/template";
        try {
            path = request.getSession().getServletContext().getRealPath("/WEB-INF/template");
        }catch(Exception e){
            logger.warn("warn "+"request.getSession().getServletContext().getRealPath('/WEB-INF/template') is null");
        }
        LogUtil.log("INFO", "download_table_del_stat cri=> "+cri);
        cri.setPagenum(1);
        cri.setAmount(100000);
        XSSFWorkbook workbook = excelservice.makeTableDelStatExcel(locale, path, "TABLE_DEL_STAT", ordersteptableService.getOrderReportList(cri), cri);
        model.addAttribute("locale", Locale.KOREA);
        model.addAttribute("workbook", workbook);
        model.addAttribute("workbookName", messageSource.getMessage("memu.table_del_stat", null, "Table destruction report", locale));
        return "excelDownloadView";
    }


}
