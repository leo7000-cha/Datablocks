package datablocks.dlm;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class LogFileParser {
    public static void main(String[] args) {
        try {
            //FileReader fileReader = new FileReader("D:/tmp/COOWNORG_ARAGRID_1.log");
            String filePath = "D:/tmp/COOWNORG_ARAGRID_1.log"; // 파일 경로를 수정하세요.
            int loadedRowCount = 0;
            try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
                String line;
                while ((line = reader.readLine()) != null) { System.out.println(line);
                    // 정규식 패턴을 사용하여 로드된 행 수 추출
                    Pattern pattern = Pattern.compile("  (\\d+) Rows successfully loaded.");
                    Matcher matcher = pattern.matcher(line);

                    if (matcher.find()) {
                        loadedRowCount = Integer.parseInt(matcher.group(1));
                        break; // 첫 번째로 발견된 패턴만 사용
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
            System.out.println(loadedRowCount);
        }catch (Exception e){
            e.printStackTrace();
        }
    }

}

