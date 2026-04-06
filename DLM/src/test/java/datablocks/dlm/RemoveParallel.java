package datablocks.dlm;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class RemoveParallel {


    public static void main(String[] args) {
        String inputString = "CREATE INDEX \"COTDL\".\"RATID_INDEX\" ON \"COOWNORG\".\"ARAGRID\" (\"RATID\") \n" +
                "  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS \n" +
                "  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645\n" +
                "  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1\n" +
                "  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)\n" +
                "  TABLESPACE \"USERS\"\n" +
                "  PARALLEL  PARALLEL";

        // "PARALLEL" 문자열을 제거
        String resultString = inputString.replaceAll("\\bPARALLEL\\b", "") + "PARALLEL";

        System.out.println(resultString);
    }
}
