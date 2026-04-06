package datablocks.dlm;
import java.util.regex.*;
public class EmailDetect {
    public static void main(String[] args) {
        //String text2 = "이메일이 leo7000@naver.com없습니다.";
        String text2 = "전화번호가 02-334-8776입니다.";

        // 이메일 주소를 패턴으로 정의
        String emailPattern = "\\d{2,3}-\\d{3,4}-\\d{4}";

        // 정규 표현식을 사용하여 문자열에서 이메일 주소 찾기
        Pattern pattern = Pattern.compile(emailPattern);
        Matcher matcher = pattern.matcher(text2);

        // 이메일 주소가 발견되면 결과를 출력
        if (matcher.find()) {
            System.out.println("이메일이 발견되었습니다: " + matcher.group(0));
        } else {
            System.out.println("이메일이 발견되지 않았습니다.");
        }
    }
}
