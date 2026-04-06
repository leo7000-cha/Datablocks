package datablocks.dlm;

import datablocks.dlm.domain.PiiOrderStepTableUpdateVO;
import datablocks.dlm.util.SqlUtil;
import java.util.Arrays;
import java.util.List;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
public class Utiltest {
    public static String replaceChars(String inputString, char replacementChar, int firstChars, int lastChars) {
        if (inputString.length() < firstChars + lastChars) {
            // 문자열의 길이가 X + Y보다 짧으면 변환할 수 없음
            return inputString;
        }

        // 처음 X 글자 추출
        String firstXChars = inputString.substring(0, firstChars);

        // 마지막 Y 글자 추출
        String lastYChars = inputString.substring(inputString.length() - lastChars);

        // 대체 문자로 변환
        String replacedChars = String.valueOf(replacementChar).repeat(firstChars + lastChars);

        // 대체한 문자열을 원래 문자열의 처음 X 글자와 마지막 Y 글자와 치환
        String resultString = firstXChars + replacedChars + lastYChars;

        return resultString;
    }
        public static String replaceLastNChars(String inputString, char replacementChar, int charcnt) {
            if (inputString.length() < charcnt) {
                // 문자열의 길이가 8보다 짧으면 변환할 수 없음
                return inputString;
            }

            // 원래 문자열의 마지막 8글자 추출
            String targetChars = inputString.substring(inputString.length() - charcnt);

            // 대체 문자로 변환
            String replacedChars = String.valueOf(replacementChar).repeat(charcnt);

            // 대체한 문자열을 원래 문자열의 마지막 8글자와 치환
            String resultString = inputString.substring(0, inputString.length() - charcnt) + replacedChars;

            return resultString;
        }

    public static String FirstLastNChars(String inputString, char replacementChar, int charcnt) {
        if (inputString.length() < charcnt) {
            // 문자열의 길이가 8보다 짧으면 변환할 수 없음
            return inputString;
        }

        // 원래 문자열의 마지막 8글자 추출
        String targetChars = inputString.substring(0, charcnt);

        // 대체 문자로 변환
        String replacedChars = String.valueOf(replacementChar).repeat(charcnt);

        // 대체한 문자열을 원래 문자열의 마지막 8글자와 치환
        String resultString = replacedChars + inputString.substring(charcnt);

        return resultString;
    }

    public static String replaceSubstring(String inputString, int startIndex, int endIndex) {
        if (startIndex < 0 || startIndex >= endIndex || endIndex > inputString.length()) {
            // 인덱스가 유효하지 않으면 원래 문자열을 반환
            return inputString;
        }

        String prefix = inputString.substring(0, startIndex); // 시작 위치 이전 문자열
        String suffix = inputString.substring(endIndex); // 종료 위치 이후 문자열
        String targetChars = inputString.substring(startIndex, endIndex);
        //String replacedSubstring = INSTANCE.scrambleString(targetChars); // 대체할 문자열
        String replacedSubstring = targetChars; // 대체할 문자열

        // prefix + 대체할 문자열 + suffix를 연결하여 새 문자열 생성
        String resultString = prefix + replacedSubstring + suffix;

        return resultString;
    }

    public static String replaceSubstring(String inputString, int startIndex) {
        if (startIndex < 0 || startIndex > inputString.length()) {
            // 인덱스가 유효하지 않으면 원래 문자열을 반환
            return inputString;
        }

        String prefix = inputString.substring(0, startIndex); // 시작 위치 이전 문자열
        String targetChars = inputString.substring(startIndex);
        //String replacedSubstring = INSTANCE.scrambleString(targetChars); // 대체할 문자열
        String replacedSubstring = targetChars; // 대체할 문자열

        // prefix + 대체할 문자열 + suffix를 연결하여 새 문자열 생성
        String resultString = prefix + replacedSubstring ;

        return resultString;
    }

    public static String getCheckSum(String juminNumber ) {
        if (juminNumber.length() < 13) {
            return juminNumber;
        }

        int sum = 0;
        int processedDigits = 0;
        int i = 0;

        while (processedDigits < 12 && i < juminNumber.length()) {
            char digit = juminNumber.charAt(i);

            if (Character.isDigit(digit)) {
                int weight = (processedDigits % 8) + 2;
                sum += Character.getNumericValue(digit) * weight;
                processedDigits++;
            }

            i++;
        }

        int remainder = sum % 11;
        int checkSum = (11 - remainder) % 10;

        return juminNumber.substring(0, i) + checkSum;
    }

    public static String convertDate(String inputDate) {
        // 입력된 날짜에서 연도, 월, 일을 추출
        int year = Integer.parseInt(inputDate.substring(0, 2));
        int month = Integer.parseInt(inputDate.substring(2, 4));
        int day = Integer.parseInt(inputDate.substring(4, 6));

        String yearS = null;
        String monthS =  null;
        String dayS =  null;
        // 월을 한 자리로 바꾸기
        if (month == 0) {
            monthS = "01"; // "00"인 경우 0으로 유지
        } else if (month <= 9) {
            monthS = "0"+month; // "01"에서 "09" 사이인 경우 그대로 유지
        }else{
            monthS = ""+month;
        }
        if (day == 0) {
            dayS = "01"; // "00"인 경우 0으로 유지
        } else if (day <= 9) {
            dayS = "0"+day; // "01"에서 "09" 사이인 경우 그대로 유지
        }else{
            dayS = ""+day;
        }

        // 변환된 날짜를 "yymmdd" 형식으로 조합
        //String outputDate = String.format("%02d%02d%02d", year, monthS, day);
        String outputDate = year + monthS + dayS;

        return outputDate;
    }
    public static void main(String[] args) {



        //System.out.println(convertDate("740000"));


        System.out.println(getCheckSum("7405041766383"));//7405041766380
        System.out.println(getCheckSum("1609013798921"));//1609013798926
        System.out.println(getCheckSum("7401261899510"));
        System.out.println(getCheckSum("740126-1899510"));
        System.out.println(getCheckSum("8108132000720"));
        System.out.println(getCheckSum("1611153047419"));
        System.out.println(getCheckSum("161115-3047419"));
        System.out.println(getCheckSum("1611153047428"));
/*
        System.out.println("FIXED_*".substring(6));


        String inputString = "HelloWorld12345678"; // 대상 문자열을 여기에 넣으세요
        char replacementChar = 'X'; // 대체할 문자

        String replacedString = replaceLastNChars(inputString, replacementChar, 8);

        System.out.println("Last변환 전: " + inputString);
        System.out.println("Last변환 후: " + replacedString);

        replacedString = FirstLastNChars(inputString, replacementChar, 8);

        System.out.println("First변환 전: " + inputString);
        System.out.println("First변환 후: " + replacedString);

        int startIndex = 7; // 대체를 시작할 인덱스
        int endIndex = 12; // 대체를 종료할 인덱스 (이전까지)
        String replacement = "$$$$$";
        replacedString = replaceSubstring(inputString,  startIndex, endIndex);

        System.out.println("replaceSubstring변환 전: " + inputString);
        System.out.println("replaceSubstring변환 후: " + replacedString);
        replacedString = replaceSubstring(inputString,  startIndex);

        System.out.println("replaceSubstring2변환 전: " + inputString);
        System.out.println("replaceSubstring2변환 후: " + replacedString);

        String[] calval ="@#^$%^=^^%$&dfg^=^#$%TGWG".split("\\^\\=\\^");
        System.out.println(calval[0]);
        System.out.println(calval[1]);
        System.out.println(calval[2]);
        String data = "'*'";
        System.out.println(data.replace("'",""));
        data = "*NOARC1234";
        System.out.println(data.replaceAll("(?i)NOARC", ""));
        HashMap<String, String> upcols = new HashMap<String, String>();
        if(upcols.containsKey("5555")) {
            System.out.println(1);
        }else{
            System.out.println(2);
        }
        System.out.println("'NOARC'".replace("'",""));
        if("NOARC".equalsIgnoreCase("'NOARC'".replace("'",""))){
            System.out.println(11);
        }
        System.out.println(
        SqlUtil.getArcTabCreateSql("ORACLE"," (PII_ORDER_ID DECIMAL(15) ,PII_BASE_DATE DATETIME ,PII_CUST_ID VARCHAR(50) ,PII_JOB_ID VARCHAR(200) ,PII_DESTRUCT_DATE DATETIME ")
        );
        System.out.println(
                SqlUtil.getArcTabCreateSql("ORACLE",") ENGINE=INNODB DEFAULT CHARACTER SET = UTF8MB4")
        );

        System.out.println(
        SqlUtil.convertDateformat("MARIADB", "delete from " + "cotdl" + "." + "tbl_piikeymap_hist" + " \r\n"
            + " TO_DATE"
            + "                           ARC_DEL_DATE > ( select COALESCE(MAX(basedate),TO_DATE('1900/01/01','yyyy/mm/dd')) from cotdl.tbl_piiorder where jobid='ARC_DATA_DELETE' and status='Ended OK' )    \r\n"
            + "                           or \r\n"
            + "                           DELETE_DATE > ( SELECT COALESCE(MAX(REALENDTIME),TO_DATE('1900/01/01','yyyy/mm/dd')) from cotdl.tbl_piiorder where jobid='ARC_DATA_DELETE' and status='Ended OK' ) \r\n"
            + "                          )\r\n"
            + "                ) "
            )
        );
        String t1 = "EXE_RESTORE_U2";
        if (t1.substring(0,13).equalsIgnoreCase("EXE_RESTORE_U") )
            System.out.println("kkk");

        System.out.println("/opt/tomcat/latest/webapps/DLM/WEB-INF/template".substring(0,12));
        System.out.println(SqlUtil.convertDateformat("MARIADB", " pii_destruct_date <= TO_DATE('20220101 23:59:59','yyyy/mm/dd HH24:MI:SS')"));

        String s  = "Abc_abC_ABC_abc"; // 원본 문자열
        String s2;

        System.out.println("원본:    " + s);
        System.out.println(); // 줄바꿈


        s2 = s.replaceFirst("(?i)abc", "ZZZ");
        System.out.println("치환(1): " + s2);


        s2 = s.replaceAll("(?i)abc", "ZZZ");
        System.out.println("치환(2): " + s2);



        HashMap<String, String> ourHashmap = new HashMap<>();

        ourHashmap.put("one", "Alex");
        ourHashmap.put("two", "Nik");
        ourHashmap.put("three", "Morse");
        ourHashmap.put("four", "Luke");

        System.out.println("Old Hashmap: "+ourHashmap);
        ourHashmap.replace("three", "Jake");

        System.out.println("New Hashmap: "+ourHashmap);

        Hashtable<String, Integer> ourHashtable = new Hashtable<String, Integer>();

        ourHashtable.put("one", 1);
        ourHashtable.put("two", 2);
        ourHashtable.put("three", 3);
        ourHashtable.put("four", 4);

        System.out.println("Old Hashmap: "+ourHashtable);
        ourHashtable.put("three", ourHashtable.get("three")+1);

        System.out.println("New Hashmap: "+ourHashtable);


        Map<String, Integer> hashMap = new HashMap<String, Integer>();

        hashMap.put("Key1", 1);
        hashMap.put("Key2", 2);
        hashMap.put("Key3", 3);
        hashMap.put("Key4", 4);
        hashMap.put("Key5", 5);

        // 방법1

        // Iterator 사용 1 - keySet()
        Iterator<String> keys = hashMap.keySet().iterator();
        while (keys.hasNext()){
            String key = keys.next();
            System.out.println("1KEY : " + key); // Key2 , Key1, Key4, Key3, Key5
        }

        // Iterator 사용 2 - keySet()
        Set set = hashMap.keySet();
        Iterator iterator = set.iterator();
        while(iterator.hasNext()){
            String key = (String) iterator.next();
            System.out.println("2KEY : " + key); // Key2 , Key1, Key5, Key4, Key3
        }

        // Iterator 사용 3 - entrySet() : key / value
        Set set2 = hashMap.entrySet();
        Iterator iterator2 = set2.iterator();
        while(iterator2.hasNext()){
            Entry<String,Integer> entry = (Entry)iterator2.next();
            String key = (String)entry.getKey();
            int value = (Integer)entry.getValue();
            System.out.println("3hashMap Key : " + key);
            System.out.println("3hashMap Value : " + value);
        }

        //방법 2 - entrySet() : key / value
        for(Entry<String, Integer> elem : hashMap.entrySet()){
            System.out.println("4키 : " + elem.getKey() + "값 : " + elem.getValue());
        }

        //방법 3 - keySet() : key
        for(String key : hashMap.keySet()){
            System.out.println("5키 : " + key);
        }*/
    }
}
