package datablocks.dlm.aop;

import java.security.Principal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import datablocks.dlm.domain.AccessLogVO;
import datablocks.dlm.service.AccessLogService;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Access Log AOP Interceptor (Legacy 뼈대).
 *
 * @deprecated 2026-04-19부터 {@link datablocks.dlm.aop.AccessLogAspect} 가 AOP 수집을 담당합니다.
 *             본 클래스는 역사적 참조용으로 남겨두며 빈 등록되지 않습니다 (@Component 주석처리).
 *             새 코드/설정은 {@code AccessLogAspect} 와 DB 설정 키 {@code AOP_COLLECT_MODE} 를 사용하세요.
 */
@Aspect
@Deprecated
// @Component  -- 비활성화: AccessLogAspect 로 대체됨
public class AccessLogInterceptor {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogInterceptor.class);

    @Autowired
    private AccessLogService accessLogService;

    /**
     * DLM 주요 컨트롤러 메서드 실행 시 접속기록 자동 생성
     * accesslog 자체 컨트롤러는 제외 (무한 루프 방지)
     */
    @Around("execution(* datablocks.dlm.controller..*(..)) " +
            "&& !execution(* datablocks.dlm.controller.AccessLogController..*(..)) " +
            "&& !execution(* datablocks.dlm.controller.CommonController..*(..)) " +
            "&& !execution(* datablocks.dlm.controller.LocaleController..*(..)) " +
            "&& !execution(* datablocks.dlm.controller.HomeController..*(..))")
    public Object logAccess(ProceedingJoinPoint joinPoint) throws Throwable {
        Object result = null;
        String resultCode = "SUCCESS";

        try {
            result = joinPoint.proceed();
        } catch (Throwable t) {
            resultCode = "FAIL";
            throw t;
        } finally {
            try {
                recordAccessLog(joinPoint, resultCode);
            } catch (Exception e) {
                logger.debug("AccessLog interceptor recording failed (non-critical)", e);
            }
        }

        return result;
    }

    private void recordAccessLog(ProceedingJoinPoint joinPoint, String resultCode) {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs == null) return;

        HttpServletRequest request = attrs.getRequest();
        String uri = request.getRequestURI();

        // 정적 리소스 제외
        if (uri.startsWith("/resources/") || uri.contains("/favicon")) {
            return;
        }

        // 액션 타입 결정
        String actionType = determineActionType(request.getMethod(), uri);

        // 사용자 정보
        Principal principal = request.getUserPrincipal();
        String userAccount = principal != null ? principal.getName() : "anonymous";

        AccessLogVO log = new AccessLogVO();
        log.setSourceSystemId("WAS_AGENT");
        log.setUserAccount(userAccount);
        log.setAccessTime(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS")));
        log.setClientIp(getClientIp(request));
        log.setActionType(actionType);
        log.setTargetDb("DLM");
        log.setTargetTable(uri);
        log.setCollectType("WAS_AGENT");
        log.setAccessChannel("WEB");
        log.setSessionId(request.getSession(false) != null ? request.getSession(false).getId() : null);
        log.setResultCode(resultCode);

        accessLogService.registerAccessLog(log);
    }

    private String determineActionType(String method, String uri) {
        if ("POST".equalsIgnoreCase(method)) {
            if (uri.contains("register") || uri.contains("insert")) return "INSERT";
            if (uri.contains("modify") || uri.contains("update")) return "UPDATE";
            if (uri.contains("remove") || uri.contains("delete")) return "DELETE";
            if (uri.contains("download") || uri.contains("excel")) return "DOWNLOAD";
            return "SELECT";
        }
        return "SELECT";
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }
}
