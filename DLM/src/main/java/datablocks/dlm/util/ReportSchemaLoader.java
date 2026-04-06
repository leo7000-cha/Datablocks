package datablocks.dlm.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Map;

public class ReportSchemaLoader {

    public static Map<String, Object> load(String formName, String path) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            String fileSeparator = System.getProperty("file.separator");
            InputStream is = ReportSchemaLoader.class.getResourceAsStream(path + fileSeparator + formName + ".json");
            return mapper.readValue(is, Map.class);
        } catch (Exception e) {
            throw new RuntimeException("An error occurred while loading the report JSON schema.", e);
        }
    }
}
