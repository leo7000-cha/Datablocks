package datablocks.dlm;

import java.util.HashMap;
import java.util.Map;

public class Maptest {
    public static void main(String[] args) {
        Map<String, String> colNameMap = new HashMap<>();
        colNameMap.put("column1", "1"); // 컬럼 이름 "column1"에 컬럼 ID "1" 매핑
        colNameMap.put("column2", "2"); // 컬럼 이름 "column2"에 컬럼 ID "2" 매핑

        String columnName = colNameMap.get("column1"); // columnName = "column1"
        System.out.println(columnName); // "column1" 출력
        String columnName2 = colNameMap.get("column2"); // columnName2 = "column2"
        System.out.println(columnName2); // "column2" 출력

    }
}
