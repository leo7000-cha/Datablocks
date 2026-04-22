package datablocks.dlm.xaudit.core;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 개인정보 정규식 탐지 + 마스킹.
 *
 * 감사 목적상 "탐지 사실"은 반드시 기록해야 하지만 "원문 값"은 저장되면 안 된다.
 * LG유플러스/카카오페이 처분 사례의 "대량 유출 기록 미보존" vs "민감정보 평문 저장"
 * 양쪽 리스크를 동시에 차단하는 것이 목적.
 */
public class XauditPiiMasker {

    public enum Pii {
        JUMIN("JUMIN",   Pattern.compile("\\b\\d{6}[-\\s]?[1-4]\\d{6}\\b")),
        CARD ("CARD",    Pattern.compile("\\b\\d{4}[-\\s]?\\d{4}[-\\s]?\\d{4}[-\\s]?\\d{4}\\b")),
        ACCOUNT("ACCOUNT", Pattern.compile("\\b\\d{2,6}-\\d{2,6}-\\d{2,8}\\b")),
        PHONE("PHONE",   Pattern.compile("\\b01[016789][-\\s]?\\d{3,4}[-\\s]?\\d{4}\\b")),
        EMAIL("EMAIL",   Pattern.compile("\\b[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}\\b"));

        public final String code;
        public final Pattern pattern;
        Pii(String code, Pattern pattern) { this.code = code; this.pattern = pattern; }
    }

    private final List<Pii> enabled;

    public XauditPiiMasker(List<String> codes) {
        this.enabled = resolve(codes);
    }

    private static List<Pii> resolve(List<String> codes) {
        if (codes == null || codes.isEmpty()) return Collections.emptyList();
        Set<String> wanted = new HashSet<>();
        for (String c : codes) if (c != null) wanted.add(c.trim().toUpperCase());
        List<Pii> out = new ArrayList<>();
        for (Pii p : Pii.values()) if (wanted.contains(p.code)) out.add(p);
        return out;
    }

    /** 텍스트 내 탐지된 PII 코드 CSV 를 반환. 없으면 null. */
    public String detect(String text) {
        if (text == null || enabled.isEmpty()) return null;
        Set<String> hits = new HashSet<>();
        for (Pii p : enabled) {
            if (p.pattern.matcher(text).find()) hits.add(p.code);
        }
        if (hits.isEmpty()) return null;
        List<String> sorted = new ArrayList<>(hits);
        Collections.sort(sorted);
        return String.join(",", sorted);
    }

    /** PII 패턴을 "***" 로 치환한 문자열 반환. */
    public String mask(String text) {
        if (text == null || enabled.isEmpty()) return text;
        String out = text;
        for (Pii p : enabled) {
            Matcher m = p.pattern.matcher(out);
            if (m.find()) out = m.replaceAll("***");
        }
        return out;
    }

    /** 단위 테스트/디버그용 */
    public static List<String> defaultCodes() {
        return new ArrayList<>(Arrays.asList("JUMIN", "CARD", "ACCOUNT"));
    }
}
