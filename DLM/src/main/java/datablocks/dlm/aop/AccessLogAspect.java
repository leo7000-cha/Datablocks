package datablocks.dlm.aop;

import java.lang.reflect.Method;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StopWatch;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.fasterxml.jackson.databind.ObjectMapper;

import datablocks.dlm.aop.annotation.LogAccess;
import datablocks.dlm.aop.util.ClientInfoExtractor;
import datablocks.dlm.domain.AccessLogVO;
import datablocks.dlm.domain.MemberVO;
import datablocks.dlm.security.domain.CustomUser;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * AOP 기반 접속기록 수집 Aspect (WAS_AOP).
 *
 * 동작 모드 (DB `AOP_COLLECT_MODE` 키):
 *   - OFF        : 일체 기록 안 함 (기본값)
 *   - ANNOTATION : {@code @LogAccess} 부착 메서드만 기록 (금융권 표준 권장)
 *   - ALL        : 전체 컨트롤러 기록 (제외 목록 제외, 감사 강화 기간 용)
 *
 * 원칙:
 *   - 비즈니스 예외/반환값 불변
 *   - Aspect 내부 예외는 모두 흡수 → 감사 실패가 서비스 장애로 번지지 않음
 *   - 비동기 디스패처로 위임하여 응답 지연 최소화
 *   - 해시체인은 기존 {@code AccessLogServiceImpl.computeHash} 재사용
 */
@Aspect
@Component
public class AccessLogAspect {

    private static final Logger log = LoggerFactory.getLogger(AccessLogAspect.class);

    private static final DateTimeFormatter TS_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
    private static final DateTimeFormatter PARTITION_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Autowired private AccessLogAopConfig aopConfig;
    @Autowired private MenuResolver menuResolver;
    @Autowired private ParamMasker paramMasker;
    @Autowired private ClientInfoExtractor clientInfoExtractor;
    @Autowired private AccessLogAsyncDispatcher dispatcher;

    /** 모드 A: @LogAccess 어노테이션 부착 메서드 */
    @Around("@annotation(datablocks.dlm.aop.annotation.LogAccess)")
    public Object logAnnotated(ProceedingJoinPoint pjp) throws Throwable {
        AccessLogAopConfig.Mode mode = aopConfig.getMode();
        if (mode == AccessLogAopConfig.Mode.OFF) return pjp.proceed();
        // ANNOTATION / ALL 모드에서 동작
        return logAround(pjp, true);
    }

    /** 모드 B: 전체 컨트롤러 (제외 목록 제외). ALL 모드에서만 실질 동작. */
    @Around("execution(* datablocks.dlm.controller..*(..)) "
          + "&& !execution(* datablocks.dlm.controller.AccessLogController..*(..)) "
          + "&& !execution(* datablocks.dlm.controller.CommonController..*(..)) "
          + "&& !execution(* datablocks.dlm.controller.LocaleController..*(..)) "
          + "&& !execution(* datablocks.dlm.controller.HomeController..*(..)) "
          + "&& !execution(* datablocks.dlm.controller.AgentApiController..*(..))")
    public Object logAll(ProceedingJoinPoint pjp) throws Throwable {
        AccessLogAopConfig.Mode mode = aopConfig.getMode();
        if (mode != AccessLogAopConfig.Mode.ALL) return pjp.proceed();

        // 중복 방지: 이 메서드에 @LogAccess 가 붙어 있으면 logAnnotated 에서 이미 처리함
        Method method = ((MethodSignature) pjp.getSignature()).getMethod();
        if (method.isAnnotationPresent(LogAccess.class)) return pjp.proceed();

        return logAround(pjp, false);
    }

    /**
     * 공통 Around 로직.
     * @param hasAnnotation @LogAccess 어노테이션 경로 여부
     */
    private Object logAround(ProceedingJoinPoint pjp, boolean hasAnnotation) throws Throwable {
        ServletRequestAttributes attrs;
        try {
            attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        } catch (Exception e) {
            attrs = null;
        }
        // 배치/스케줄러 호출은 HTTP 컨텍스트 없음 → 바로 통과
        if (attrs == null) return pjp.proceed();

        HttpServletRequest request = attrs.getRequest();
        String uri = request.getRequestURI();
        if (aopConfig.isExcludedUri(uri)) return pjp.proceed();
        if (!aopConfig.passesIncludeFilter(uri)) return pjp.proceed();

        MethodSignature sig = (MethodSignature) pjp.getSignature();
        Method method = sig.getMethod();
        LogAccess ann = hasAnnotation ? method.getAnnotation(LogAccess.class) : null;
        if (ann != null && !ann.record()) return pjp.proceed();

        MenuResolver.MenuInfo menu = menuResolver.resolve(pjp.getTarget().getClass(), method, uri, ann);
        if (menu.isExcluded()) return pjp.proceed();

        String importance = (ann != null && !ann.importance().isBlank())
                ? ann.importance().toUpperCase()
                : menu.getDefaultImportance();
        if (!aopConfig.meetsImportance(importance)) return pjp.proceed();

        String action = (ann != null && !ann.action().isBlank())
                ? ann.action().toUpperCase()
                : menuResolver.inferAction(request.getMethod(), uri);
        if (!aopConfig.isRecordReads() && "SELECT".equalsIgnoreCase(action)) return pjp.proceed();

        // ===== 사전 컨텍스트 수집 (MainThread) =====
        StopWatch sw = new StopWatch();
        sw.start();
        String resultCode = "SUCCESS";
        Throwable caught = null;
        Object result = null;

        try {
            result = pjp.proceed();
            return result;
        } catch (Throwable t) {
            resultCode = "FAIL";
            caught = t;
            throw t;
        } finally {
            if (sw.isRunning()) sw.stop();
            try {
                long durationMs = sw.getTotalTimeMillis();
                if (durationMs >= aopConfig.getDurationThresholdMs()) {
                    AccessLogVO vo = buildVo(request, method, sig, pjp.getArgs(),
                            uri, menu, action, importance, durationMs, resultCode, caught, ann);
                    if (vo != null) dispatcher.dispatch(vo);
                }
            } catch (Exception ex) {
                log.warn("[AOP] capture failed (non-critical): {}", ex.getMessage());
            }
        }
    }

    /** AccessLogVO 스냅샷 빌드. Request 객체는 이 단계에서만 읽는다. */
    private AccessLogVO buildVo(HttpServletRequest request, Method method, MethodSignature sig, Object[] args,
                                String uri, MenuResolver.MenuInfo menu, String action, String importance,
                                long durationMs, String resultCode, Throwable caught, LogAccess ann) {
        Map<String, String> user = currentUser();
        String userAccount = user.get("id");

        // anonymous 는 HIGH 모드일 때 노이즈 억제
        if ("anonymous".equals(userAccount) && "HIGH".equalsIgnoreCase(aopConfig.getMinImportance())) {
            return null;
        }

        AccessLogVO vo = new AccessLogVO();
        vo.setSourceSystemId("WAS_AOP");
        vo.setCollectType("WAS_AOP");
        vo.setAccessChannel("WEB");
        vo.setActionType(action);
        LocalDateTime now = LocalDateTime.now();
        vo.setAccessTime(now.format(TS_FMT));
        vo.setCollectedAt(now.format(TS_FMT));
        vo.setPartitionKey(now.format(PARTITION_FMT));
        vo.setClientIp(clientInfoExtractor.getClientIp(request));
        vo.setUserAccount(userAccount);
        vo.setUserName(user.get("name"));
        vo.setDepartment(user.get("dept"));
        HttpSession session = request.getSession(false);
        vo.setSessionId(session != null ? session.getId() : null);
        vo.setTargetDb("DLM");
        vo.setTargetSchema(uri);
        vo.setTargetTable(menu.getMenuId()); // 해시 입력에 포함되므로 안정적인 menuId 사용
        vo.setResultCode(resultCode);

        // searchCondition JSON: 파라미터 + duration + error + menuNameKey + importance
        Map<String, Object> meta = new LinkedHashMap<>();
        meta.put("_durationMs", durationMs);
        meta.put("_importance", importance);
        meta.put("_business", menu.getBusiness());
        if (menu.getMenuNameKey() != null) meta.put("_menuKey", menu.getMenuNameKey());
        meta.put("_httpMethod", request.getMethod());

        boolean shouldRecordParams = aopConfig.isRecordParams()
                && (ann == null || ann.recordParams());
        if (shouldRecordParams) {
            String[] paramNames = sig.getParameterNames();
            Set<String> maskUnion = paramMasker.union(aopConfig.getMaskFields(),
                    ann != null ? ann.maskParams() : null);
            String paramsJson = paramMasker.toJson(paramNames, args, maskUnion, aopConfig.getParamMaxLen());
            meta.put("params", paramsJson);
        }
        if (caught != null) {
            String msg = caught.getMessage();
            if (msg == null) msg = caught.getClass().getSimpleName();
            int maxLen = aopConfig.getErrorMsgLen();
            if (maxLen > 0 && msg.length() > maxLen) msg = msg.substring(0, maxLen);
            meta.put("_error", msg);
        }
        try {
            vo.setSearchCondition(MAPPER.writeValueAsString(meta));
        } catch (Exception e) {
            vo.setSearchCondition("{\"_metaErr\":\"" + e.getClass().getSimpleName() + "\"}");
        }
        return vo;
    }

    /** SecurityContext → userAccount / userName / department */
    private Map<String, String> currentUser() {
        Map<String, String> out = new HashMap<>();
        out.put("id", "anonymous");
        out.put("name", null);
        out.put("dept", null);
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth == null || !auth.isAuthenticated()) return out;
            Object principal = auth.getPrincipal();
            if (principal instanceof CustomUser) {
                CustomUser cu = (CustomUser) principal;
                MemberVO m = cu.getMember();
                if (m != null) {
                    out.put("id", m.getUserid());
                    out.put("name", m.getUserName());
                    out.put("dept", m.getPosition()); // MemberVO 에는 dept 컬럼 없음 → position 대체
                    return out;
                }
            }
            // fallback: principal.name
            out.put("id", auth.getName() != null ? auth.getName() : "anonymous");
        } catch (Exception e) {
            // ignore
        }
        return out;
    }
}
