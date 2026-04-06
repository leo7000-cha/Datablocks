package datablocks.dlm.util;

import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.view.AbstractView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Map;

@Component
public class ExcelDownloadView extends AbstractView{

    @Override
    protected void renderMergedOutputModel(Map<String, Object> model, HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        Locale locale = (Locale) model.get("locale");
        // Locale이 null일 경우, 시스템 기본 Locale을 사용하도록 수정
        if (locale == null) {
            locale = Locale.getDefault();
        }

        String workbookName = (String) model.get("workbookName");

        // workbookName이 null일 경우 오류 방지를 위해 기본값 설정
        if (workbookName == null || workbookName.isEmpty()) {
            workbookName = "excel_download";
        }

        // 겹치는 파일 이름 중복을 피하기 위해 시간을 이용해서 파일 이름에 추
        Date date = new Date();
        SimpleDateFormat dayformat = new SimpleDateFormat("yyyyMMdd", locale);
        SimpleDateFormat hourformat = new SimpleDateFormat("hhmmss", locale);
        String day = dayformat.format(date);
        String hour = hourformat.format(date);
        //String fileName = workbookName + "_" + day + "_" + hour + ".xlsx";
        String fileName = workbookName + "_" + day + ".xlsx";

        // 여기서부터는 각 브라우저에 따른 파일이름 인코딩작업
        String browser = request.getHeader("User-Agent");
        if (browser.indexOf("MSIE") > -1) {
            fileName = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");
        } else if (browser.indexOf("Trident") > -1) {       // IE11
            fileName = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");
        } else if (browser.indexOf("Firefox") > -1) {
            fileName = "\"" + new String(fileName.getBytes("UTF-8"), "8859_1") + "\"";
        } else if (browser.indexOf("Opera") > -1) {
            fileName = "\"" + new String(fileName.getBytes("UTF-8"), "8859_1") + "\"";
        } else if (browser.indexOf("Chrome") > -1) {
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < fileName.length(); i++) {
               char c = fileName.charAt(i);
               if (c > '~') {
                     sb.append(URLEncoder.encode("" + c, "UTF-8"));
                       } else {
                             sb.append(c);
                       }
                }
                fileName = sb.toString();
        } else if (browser.indexOf("Safari") > -1){
            fileName = "\"" + new String(fileName.getBytes("UTF-8"), "8859_1")+ "\"";
        } else {
             fileName = "\"" + new String(fileName.getBytes("UTF-8"), "8859_1")+ "\"";
        }

        response.setContentType("application/download;charset=utf-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\";");
        response.setHeader("Content-Transfer-Encoding", "binary");

       OutputStream os = null;
       SXSSFWorkbook sxssfworkbook = null;
       XSSFWorkbook xssfworkbook = null;

       try {
    	   sxssfworkbook = (SXSSFWorkbook) model.get("workbook");
           os = response.getOutputStream();

           // 파일생성
           sxssfworkbook.write(os);
       }catch (Exception e) {
           //e.printStackTrace();
    	   xssfworkbook = (XSSFWorkbook) model.get("workbook");
           os = response.getOutputStream();

           // 파일생성
           xssfworkbook.write(os);
       } finally {
           if(sxssfworkbook != null) {
               try {
            	   sxssfworkbook.close();
               } catch (Exception e) {
                   e.printStackTrace();
               }
           }

           if(xssfworkbook != null) {
        	   try {
        		   xssfworkbook.close();
        	   } catch (Exception e) {
        		   e.printStackTrace();
        	   }
           }

           if(os != null) {
               try {
                   os.close();
               } catch (Exception e) {
                   e.printStackTrace();
               }
           }
       }
    }
}
