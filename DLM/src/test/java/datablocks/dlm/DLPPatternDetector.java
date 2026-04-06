import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class DLPPatternDetector {

    public static boolean containsEmailAddress(String text) {
        // 이메일 주소 형식에 맞는 정규표현식
        String regex = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}";

        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(text);
        return matcher.find();
    }

    public static void main(String[] args) {
        String text1 = "이메일 주소는 abc@example.com 입니다.";
        String text2 = "이메일이 leo7000@naver.com없습니다.";

        if (containsEmailAddress(text1)) {
            System.out.println("이메일 주소가 포함되어 있습니다.");
        } else {
            System.out.println("이메일 주소가 포함되어 있지 않습니다.");
        }

        if (containsEmailAddress(text2)) {
            System.out.println("이메일 주소가 포함되어 있습니다.");
        } else {
            System.out.println("이메일 주소가 포함되어 있지 않습니다.");
        }
    }
}
