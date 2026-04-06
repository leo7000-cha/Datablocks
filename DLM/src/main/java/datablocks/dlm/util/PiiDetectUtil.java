package datablocks.dlm.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class PiiDetectUtil {
    private static final Logger logger = LoggerFactory.getLogger(PiiDetectUtil.class);

    public static boolean containsRRN(String text) {
        // 주민등록번호 형식에 맞는 정규표현식
        String regex = "\\d{6}-?[1-4]\\d{6}";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(text);
        return matcher.find();
    }

    public static boolean containsCardNo(String text) {
        // 신용카드 번호 형식에 맞는 정규표현식
        String regex = "\\b\\d{4}[ -]?\\d{4}[ -]?\\d{4}[ -]?\\d{4}\\b";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(text);
        return matcher.find();
    }

    public static boolean containsTelNo(String text) {
        // 전화번호 형식에 맞는 정규표현식
        String regex = "\\b(0\\d{1,2}[ -]?)?\\d{2,4}[ -]?\\d{3,4}[ -]?\\d{4}\\b";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(text);
        return matcher.find();
    }

    public static boolean containsEmail(String text) {
        // 이메일 주소 형식에 맞는 정규표현식
        String regex = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(text);
        return matcher.find();
    }
}
