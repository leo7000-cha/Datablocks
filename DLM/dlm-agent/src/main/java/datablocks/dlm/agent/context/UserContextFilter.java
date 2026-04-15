package datablocks.dlm.agent.context;

import datablocks.dlm.agent.AgentConfig;
import net.bytebuddy.agent.builder.AgentBuilder;
import net.bytebuddy.asm.Advice;
import net.bytebuddy.description.type.TypeDescription;
import net.bytebuddy.dynamic.DynamicType;
import net.bytebuddy.matcher.ElementMatchers;
import net.bytebuddy.utility.JavaModule;

import java.security.ProtectionDomain;

/**
 * ByteBuddy Advice로 FilterChain.doFilter() 시점에 사용자 정보를 ThreadLocal에 자동 주입.
 *
 * web.xml 수정 없이 동작하므로 WAS 종류(WebLogic/JEUS/Tomcat) 무관.
 * Jakarta Servlet (Spring Boot 3+) 과 javax.servlet (레거시 WAS/DevOn) 모두 지원.
 */
public class UserContextFilter {

    // 재진입 방지: FilterChain.doFilter()는 체인 내에서 여러 번 호출됨
    private static final ThreadLocal<Boolean> ACTIVE = ThreadLocal.withInitial(() -> false);

    // ─────────────────────────────────────────────────────────────────────
    // javax.servlet 용 (WebLogic 12c, JEUS, DevOn, 레거시 Tomcat)
    // ─────────────────────────────────────────────────────────────────────

    /**
     * javax.servlet.FilterChain 구현체에 Advice 적용하는 Transformer
     */
    public static class JavaxFilterChainTransformer implements AgentBuilder.Transformer {
        @Override
        public DynamicType.Builder<?> transform(DynamicType.Builder<?> builder,
                                                 TypeDescription typeDescription,
                                                 ClassLoader classLoader,
                                                 JavaModule module,
                                                 ProtectionDomain protectionDomain) {
            return builder.visit(
                    Advice.to(JavaxFilterChainAdvice.class)
                            .on(ElementMatchers.named("doFilter")
                                    .and(ElementMatchers.takesArguments(2)))
            );
        }
    }

    /**
     * javax.servlet.FilterChain.doFilter(ServletRequest, ServletResponse) Advice
     */
    public static class JavaxFilterChainAdvice {

        @Advice.OnMethodEnter
        public static boolean onEnter(
                @Advice.Argument(0) Object request) {

            // 재진입 방지: 이미 상위에서 UserContext 설정됨
            if (ACTIVE.get()) return false;

            try {
                if (request instanceof javax.servlet.http.HttpServletRequest) {
                    javax.servlet.http.HttpServletRequest httpReq =
                            (javax.servlet.http.HttpServletRequest) request;

                    UserContext ctx = new UserContext();
                    ctx.setClientIp(extractClientIp_javax(httpReq));
                    ctx.setSessionId(extractSessionId_javax(httpReq));
                    ctx.setUserId(extractUserId_javax(httpReq));
                    ctx.setUserName(extractUserName_javax(httpReq));
                    UserContext.set(ctx);
                    ACTIVE.set(true);
                    return true; // 이 진입에서 설정했음 → exit에서 정리
                }
            } catch (Throwable ignored) {
                // Agent 오류가 WAS에 영향 주지 않도록 삼킴
            }
            return false;
        }

        @Advice.OnMethodExit(onThrowable = Throwable.class)
        public static void onExit(@Advice.Enter boolean wasSet) {
            if (wasSet) {
                UserContext.clear();
                ACTIVE.set(false);
            }
        }

        // ── 사용자 추출 (javax) ──

        private static String extractUserId_javax(javax.servlet.http.HttpServletRequest req) {
            AgentConfig config = AgentConfig.getInstance();

            // 1) 설정된 HTTP 헤더 (SSO, DevOn 인증 등)
            if (config != null) {
                String headerName = config.getUserIdHeader();
                if (headerName != null) {
                    String val = req.getHeader(headerName);
                    if (val != null && !val.isEmpty()) return val;
                }
            }

            // 2) 설정된 세션 속성 (DevOn: loginVO.id, 자체: userId 등)
            if (config != null) {
                String sessionAttr = config.getUserIdSessionAttr();
                javax.servlet.http.HttpSession session = req.getSession(false);
                if (session != null && sessionAttr != null) {
                    // "loginVO.id" → getAttribute("loginVO") + getId()
                    String attrKey = sessionAttr.contains(".") ? sessionAttr.substring(0, sessionAttr.indexOf('.')) : sessionAttr;
                    Object val = session.getAttribute(attrKey);
                    if (val != null) {
                        String resolved = resolveSessionValue(val, sessionAttr);
                        if (resolved != null && !resolved.isEmpty()) return resolved;
                    }
                }
            }

            // 3) Spring Security (리플렉션 — Spring 없는 환경에서도 안전)
            String springUser = extractFromSpringSecurity();
            if (springUser != null) return springUser;

            // 4) WAS 컨테이너 인증 (Remote User)
            String remoteUser = req.getRemoteUser();
            if (remoteUser != null) return remoteUser;

            return "UNKNOWN";
        }

        private static String extractClientIp_javax(javax.servlet.http.HttpServletRequest req) {
            String ip = req.getHeader("X-Forwarded-For");
            if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
                return ip.split(",")[0].trim();
            }
            ip = req.getHeader("X-Real-IP");
            if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
                return ip;
            }
            return req.getRemoteAddr();
        }

        private static String extractSessionId_javax(javax.servlet.http.HttpServletRequest req) {
            javax.servlet.http.HttpSession session = req.getSession(false);
            return session != null ? session.getId() : null;
        }

        private static String extractUserName_javax(javax.servlet.http.HttpServletRequest req) {
            AgentConfig config = AgentConfig.getInstance();

            // 1) 설정된 HTTP 헤더
            if (config != null) {
                String headerName = config.getUserNameHeader();
                if (headerName != null) {
                    String val = req.getHeader(headerName);
                    if (val != null && !val.isEmpty()) return val;
                }
            }

            // 2) 설정된 세션 속성
            if (config != null) {
                String sessionAttr = config.getUserNameSessionAttr();
                javax.servlet.http.HttpSession session = req.getSession(false);
                if (session != null && sessionAttr != null) {
                    String attrKey = sessionAttr.contains(".") ? sessionAttr.substring(0, sessionAttr.indexOf('.')) : sessionAttr;
                    Object val = session.getAttribute(attrKey);
                    if (val != null) {
                        String resolved = resolveSessionValue(val, sessionAttr);
                        if (resolved != null && !resolved.isEmpty()) return resolved;
                    }
                }
            }

            return null;
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // Jakarta Servlet 용 (Spring Boot 3+, Tomcat 10+, WebLogic 14c+)
    // ─────────────────────────────────────────────────────────────────────

    /**
     * jakarta.servlet.FilterChain 구현체에 Advice 적용하는 Transformer
     */
    public static class JakartaFilterChainTransformer implements AgentBuilder.Transformer {
        @Override
        public DynamicType.Builder<?> transform(DynamicType.Builder<?> builder,
                                                 TypeDescription typeDescription,
                                                 ClassLoader classLoader,
                                                 JavaModule module,
                                                 ProtectionDomain protectionDomain) {
            return builder.visit(
                    Advice.to(JakartaFilterChainAdvice.class)
                            .on(ElementMatchers.named("doFilter")
                                    .and(ElementMatchers.takesArguments(2)))
            );
        }
    }

    /**
     * jakarta.servlet.FilterChain.doFilter(ServletRequest, ServletResponse) Advice
     */
    public static class JakartaFilterChainAdvice {

        @Advice.OnMethodEnter
        public static boolean onEnter(
                @Advice.Argument(0) Object request) {

            if (ACTIVE.get()) return false;

            try {
                if (request instanceof jakarta.servlet.http.HttpServletRequest) {
                    jakarta.servlet.http.HttpServletRequest httpReq =
                            (jakarta.servlet.http.HttpServletRequest) request;

                    UserContext ctx = new UserContext();
                    ctx.setClientIp(extractClientIp_jakarta(httpReq));
                    ctx.setSessionId(extractSessionId_jakarta(httpReq));
                    ctx.setUserId(extractUserId_jakarta(httpReq));
                    ctx.setUserName(extractUserName_jakarta(httpReq));
                    UserContext.set(ctx);
                    ACTIVE.set(true);
                    return true;
                }
            } catch (Throwable ignored) {
            }
            return false;
        }

        @Advice.OnMethodExit(onThrowable = Throwable.class)
        public static void onExit(@Advice.Enter boolean wasSet) {
            if (wasSet) {
                UserContext.clear();
                ACTIVE.set(false);
            }
        }

        // ── 사용자 추출 (jakarta) ──

        private static String extractUserId_jakarta(jakarta.servlet.http.HttpServletRequest req) {
            AgentConfig config = AgentConfig.getInstance();

            // 1) 설정된 HTTP 헤더
            if (config != null) {
                String headerName = config.getUserIdHeader();
                if (headerName != null) {
                    String val = req.getHeader(headerName);
                    if (val != null && !val.isEmpty()) return val;
                }
            }

            // 2) 설정된 세션 속성 (DevOn: loginVO.id 등)
            if (config != null) {
                String sessionAttr = config.getUserIdSessionAttr();
                jakarta.servlet.http.HttpSession session = req.getSession(false);
                if (session != null && sessionAttr != null) {
                    String attrKey = sessionAttr.contains(".") ? sessionAttr.substring(0, sessionAttr.indexOf('.')) : sessionAttr;
                    Object val = session.getAttribute(attrKey);
                    if (val != null) {
                        String resolved = resolveSessionValue(val, sessionAttr);
                        if (resolved != null && !resolved.isEmpty()) return resolved;
                    }
                }
            }

            // 3) Spring Security (리플렉션)
            String springUser = extractFromSpringSecurity();
            if (springUser != null) return springUser;

            // 4) Remote User
            String remoteUser = req.getRemoteUser();
            if (remoteUser != null) return remoteUser;

            return "UNKNOWN";
        }

        private static String extractClientIp_jakarta(jakarta.servlet.http.HttpServletRequest req) {
            String ip = req.getHeader("X-Forwarded-For");
            if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
                return ip.split(",")[0].trim();
            }
            ip = req.getHeader("X-Real-IP");
            if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
                return ip;
            }
            return req.getRemoteAddr();
        }

        private static String extractSessionId_jakarta(jakarta.servlet.http.HttpServletRequest req) {
            jakarta.servlet.http.HttpSession session = req.getSession(false);
            return session != null ? session.getId() : null;
        }

        private static String extractUserName_jakarta(jakarta.servlet.http.HttpServletRequest req) {
            AgentConfig config = AgentConfig.getInstance();

            // 1) 설정된 HTTP 헤더
            if (config != null) {
                String headerName = config.getUserNameHeader();
                if (headerName != null) {
                    String val = req.getHeader(headerName);
                    if (val != null && !val.isEmpty()) return val;
                }
            }

            // 2) 설정된 세션 속성
            if (config != null) {
                String sessionAttr = config.getUserNameSessionAttr();
                jakarta.servlet.http.HttpSession session = req.getSession(false);
                if (session != null && sessionAttr != null) {
                    String attrKey = sessionAttr.contains(".") ? sessionAttr.substring(0, sessionAttr.indexOf('.')) : sessionAttr;
                    Object val = session.getAttribute(attrKey);
                    if (val != null) {
                        String resolved = resolveSessionValue(val, sessionAttr);
                        if (resolved != null && !resolved.isEmpty()) return resolved;
                    }
                }
            }

            return null;
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // 공통 유틸
    // ─────────────────────────────────────────────────────────────────────

    /**
     * 세션 속성 값 추출.
     * "loginVO.id" 형식이면 session.getAttribute("loginVO") 후 리플렉션으로 getId() 호출.
     * "userId" 형식이면 session.getAttribute("userId").toString() 반환.
     *
     * DevOn 등에서 LoginVO 객체를 세션에 저장하는 경우:
     *   dlm.user.session-attr=loginVO.id → session.getAttribute("loginVO").getId()
     *   dlm.user.session-attr=loginVO.userId → session.getAttribute("loginVO").getUserId()
     */
    static String resolveSessionValue(Object sessionObj, String attrExpr) {
        if (sessionObj == null || attrExpr == null) return null;

        int dotIdx = attrExpr.indexOf('.');
        if (dotIdx < 0) {
            // 단순 키: toString()
            String str = sessionObj.toString();
            // 객체 기본 toString (패키지명@해시) 감지 → 무시
            if (str.contains("@") && str.indexOf('.') >= 0) return null;
            return str.isEmpty() ? null : str;
        }

        // "loginVO.id" → 점 이후 부분으로 getter 호출
        String fieldPath = attrExpr.substring(dotIdx + 1);
        Object current = sessionObj;
        for (String field : fieldPath.split("\\.")) {
            if (current == null) return null;
            current = invokeGetter(current, field);
        }
        return current != null ? current.toString() : null;
    }

    /**
     * 리플렉션으로 getter 호출. getXxx() → isXxx() → 필드직접 순서로 시도.
     */
    private static Object invokeGetter(Object obj, String fieldName) {
        if (obj == null || fieldName == null || fieldName.isEmpty()) return null;
        String capitalized = fieldName.substring(0, 1).toUpperCase() + fieldName.substring(1);
        // 1) getXxx()
        try {
            return obj.getClass().getMethod("get" + capitalized).invoke(obj);
        } catch (Exception ignored) {}
        // 2) isXxx()
        try {
            return obj.getClass().getMethod("is" + capitalized).invoke(obj);
        } catch (Exception ignored) {}
        // 3) 필드명 그대로 메서드
        try {
            return obj.getClass().getMethod(fieldName).invoke(obj);
        } catch (Exception ignored) {}
        // 4) 필드 직접 접근
        try {
            java.lang.reflect.Field f = obj.getClass().getDeclaredField(fieldName);
            f.setAccessible(true);
            return f.get(obj);
        } catch (Exception ignored) {}
        return null;
    }

    /**
     * Spring Security에서 사용자 정보 추출 (리플렉션 — Agent는 Spring에 의존하지 않음)
     */
    static String extractFromSpringSecurity() {
        try {
            Class<?> ctxClass = Class.forName(
                    "org.springframework.security.core.context.SecurityContextHolder");
            Object secCtx = ctxClass.getMethod("getContext").invoke(null);
            if (secCtx == null) return null;
            Object auth = secCtx.getClass().getMethod("getAuthentication").invoke(secCtx);
            if (auth == null) return null;
            Object name = auth.getClass().getMethod("getName").invoke(auth);
            if (name != null && !"anonymousUser".equals(name.toString())) {
                return name.toString();
            }
        } catch (Exception ignored) {
            // Spring Security 미사용 환경
        }
        return null;
    }
}
