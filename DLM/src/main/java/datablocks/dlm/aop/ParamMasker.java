package datablocks.dlm.aop;

import java.security.Principal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.validation.BindingResult;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * 메서드 파라미터를 JSON 으로 직렬화하면서 민감 필드를 마스킹.
 * - depth 3 제한 (순환/깊은 객체 방지)
 * - Multipart/Servlet/Model 등 직렬화 부적합 객체는 "[FILE]" / "[SKIP]" 치환
 * - 기본 마스킹 룰 + 메서드별 추가 룰 합집합
 */
@Component
public class ParamMasker {

    private static final Logger log = LoggerFactory.getLogger(ParamMasker.class);
    private static final ObjectMapper MAPPER = new ObjectMapper();

    private static final int MAX_DEPTH = 3;
    private static final String MASKED = "***";

    /**
     * 파라미터를 JSON 문자열로 변환 (마스킹 포함).
     *
     * @param paramNames 메서드 파라미터 이름 배열 (없으면 null)
     * @param args       실제 인자 값
     * @param maskFields 마스킹 대상 필드명 (대소문자 무시)
     * @param maxLen     최대 길이 (초과 시 절삭)
     */
    public String toJson(String[] paramNames, Object[] args, Set<String> maskFields, int maxLen) {
        if (args == null || args.length == 0) return "{}";
        Set<String> maskLc = toLowerSet(maskFields);

        Map<String, Object> root = new LinkedHashMap<>();
        for (int i = 0; i < args.length; i++) {
            String name = (paramNames != null && i < paramNames.length) ? paramNames[i] : ("arg" + i);
            Object safe = maskDeep(name, args[i], maskLc, 0);
            root.put(name, safe);
        }
        try {
            String json = MAPPER.writeValueAsString(root);
            if (maxLen > 0 && json.length() > maxLen) {
                return json.substring(0, maxLen) + "...[TRUNC]";
            }
            return json;
        } catch (Exception e) {
            log.debug("ParamMasker: JSON 직렬화 실패, toString fallback: {}", e.getMessage());
            return safeToString(root, maxLen);
        }
    }

    /** 직렬화 불가/중첩 객체 재귀 처리. depth 초과 시 toString. */
    private Object maskDeep(String fieldName, Object value, Set<String> maskLc, int depth) {
        if (value == null) return null;
        if (fieldName != null && maskLc.contains(fieldName.toLowerCase())) return MASKED;
        if (depth >= MAX_DEPTH) return String.valueOf(value);

        // 직렬화 스킵 대상
        if (value instanceof HttpServletRequest || value instanceof HttpServletResponse
                || value instanceof HttpSession || value instanceof Principal
                || value instanceof Model || value instanceof BindingResult) {
            return "[SKIP:" + value.getClass().getSimpleName() + "]";
        }
        if (value instanceof MultipartFile) {
            MultipartFile mf = (MultipartFile) value;
            return "[FILE:" + mf.getOriginalFilename() + ",size=" + mf.getSize() + "]";
        }

        if (value instanceof CharSequence || value instanceof Number || value instanceof Boolean
                || value instanceof Character || value instanceof Enum<?>) {
            return value;
        }

        if (value instanceof Map<?, ?>) {
            Map<String, Object> out = new LinkedHashMap<>();
            for (Map.Entry<?, ?> e : ((Map<?, ?>) value).entrySet()) {
                String k = String.valueOf(e.getKey());
                out.put(k, maskDeep(k, e.getValue(), maskLc, depth + 1));
            }
            return out;
        }

        if (value instanceof Collection<?>) {
            List<Object> out = new ArrayList<>();
            for (Object item : (Collection<?>) value) {
                out.add(maskDeep(null, item, maskLc, depth + 1));
            }
            return out;
        }

        if (value.getClass().isArray()) {
            if (value.getClass().getComponentType().isPrimitive()) {
                return value.toString();
            }
            Object[] arr = (Object[]) value;
            List<Object> out = new ArrayList<>(arr.length);
            for (Object item : arr) out.add(maskDeep(null, item, maskLc, depth + 1));
            return out;
        }

        // POJO: Jackson 에 위임하되 마스킹이 필요하면 직렬화 후 JSON 트리에서 교체하는 건 비용이 크므로
        // 여기서는 필드명 기반 마스킹만 수행하고 POJO 는 그대로 Jackson 에 맡긴다.
        // maskFields 에 해당하는 필드는 Jackson 출력 후 별도 처리 대신, 필드 이름 매칭 없이 들어오면
        // 상위 Map/파라미터 이름 단계에서 걸러진다. POJO 내부 민감필드는 Jackson @JsonIgnore 권장.
        return value;
    }

    private Set<String> toLowerSet(Set<String> in) {
        if (in == null || in.isEmpty()) return Collections.emptySet();
        Set<String> out = new HashSet<>(in.size());
        for (String s : in) {
            if (s != null && !s.isBlank()) out.add(s.trim().toLowerCase());
        }
        return out;
    }

    private String safeToString(Object v, int maxLen) {
        String s = String.valueOf(v);
        if (maxLen > 0 && s.length() > maxLen) return s.substring(0, maxLen) + "...[TRUNC]";
        return s;
    }

    /** AOP_MASK_FIELDS 쉼표 문자열 → Set 유틸 */
    public static Set<String> parseMaskFields(String csv) {
        if (csv == null || csv.isBlank()) return Collections.emptySet();
        Set<String> out = new HashSet<>();
        for (String s : csv.split(",")) {
            if (!s.isBlank()) out.add(s.trim());
        }
        return out;
    }

    /** 기본 마스킹 + 메서드 지정 필드 합집합 */
    public Set<String> union(Set<String> base, String[] extra) {
        Set<String> out = new HashSet<>(base);
        if (extra != null) out.addAll(Arrays.asList(extra));
        return out;
    }
}
