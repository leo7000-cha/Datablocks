package datablocks.dlm;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PersonalInfoDetector {

    public static boolean containsResidentRegistrationNumber(String text) {
        // 주민등록번호 형식에 맞는 정규표현식
        String regex = "\\d{6}-?[1-4]\\d{6}";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(text);
        return matcher.find();
    }

    public static void main(String[] args) {
        String text1 = "주민등록번호는 123456-1234567입니다.";
        String text2 = "주민등록번호가 740126189977없는 텍스트입니다.";

        if (containsResidentRegistrationNumber(text1)) {
            System.out.println(text1+"주민등록번호가 포함되어 있습니다.");
        } else {
            System.out.println("주민등록번호가 포함되어 있지 않습니다.");
        }

        if (containsResidentRegistrationNumber(text2)) {
            System.out.println(text2+"주민등록번호가 포함되어 있습니다.");
        } else {
            System.out.println("주민등록번호가 포함되어 있지 않습니다.");
        }
    }
}
