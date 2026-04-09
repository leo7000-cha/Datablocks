package datablocks.dlm.agent.context;

import datablocks.dlm.agent.AgentConfig;

import java.io.IOException;
import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.security.ProtectionDomain;

/**
 * Servlet Filter로 HTTP 요청에서 실사용자 정보를 추출하여 ThreadLocal에 저장.
 *
 * Jakarta Servlet (Spring Boot 3+) 과 javax.servlet (레거시 WAS) 모두 지원하기 위해
 * 리플렉션 기반으로 동작합니다.
 */
public class UserContextFilter {

    /**
     * ClassFileTransformer로 ServletContext 초기화 시점을 감지하여 Filter를 자동 등록.
     */
    public static class Installer implements ClassFileTransformer {

        private volatile boolean installed = false;

        @Override
        public byte[] transform(ClassLoader loader, String className,
                                Class<?> classBeingRedefined, ProtectionDomain protectionDomain,
                                byte[] classfileBuffer) throws IllegalClassFormatException {

            // ServletContainerInitializer 또는 ApplicationFilterChain 로드 시 Filter 등록 시도
            if (!installed && className != null &&
                (className.contains("ServletContext") ||
                 className.contains("ApplicationFilterChain") ||
                 className.contains("StandardContext"))) {

                // 실제 Filter 등록은 ByteBuddy Advice가 아닌,
                // premain에서 Instrumentation listener로 처리
                // 여기서는 시그널만 설정
                installed = true;
            }

            return null; // 바이트코드 변경 없음
        }
    }

    /**
     * Jakarta Servlet Filter 구현 (리플렉션 없이 직접).
     * Agent가 Jakarta Servlet API를 compileOnly로 가지고 있으므로 별도 클래스로 분리.
     */
    public static class JakartaFilter implements jakarta.servlet.Filter {

        @Override
        public void doFilter(jakarta.servlet.ServletRequest req,
                             jakarta.servlet.ServletResponse res,
                             jakarta.servlet.FilterChain chain)
                throws IOException, jakarta.servlet.ServletException {

            if (req instanceof jakarta.servlet.http.HttpServletRequest) {
                jakarta.servlet.http.HttpServletRequest httpReq =
                        (jakarta.servlet.http.HttpServletRequest) req;
                try {
                    UserContext ctx = new UserContext();
                    ctx.setClientIp(getClientIp(httpReq));
                    ctx.setSessionId(getSessionId(httpReq));
                    ctx.setUserId(extractUserId(httpReq));
                    UserContext.set(ctx);
                    chain.doFilter(req, res);
                } finally {
                    UserContext.clear();
                }
            } else {
                chain.doFilter(req, res);
            }
        }

        private String extractUserId(jakarta.servlet.http.HttpServletRequest req) {
            AgentConfig config = AgentConfig.getInstance();

            // 1) 설정된 HTTP 헤더에서 추출 (SSO 등)
            String headerName = config.getUserIdHeader();
            if (headerName != null) {
                String val = req.getHeader(headerName);
                if (val != null && !val.isEmpty()) return val;
            }

            // 2) 설정된 세션 속성에서 추출
            String sessionAttr = config.getUserIdSessionAttr();
            jakarta.servlet.http.HttpSession session = req.getSession(false);
            if (session != null && sessionAttr != null) {
                Object val = session.getAttribute(sessionAttr);
                if (val != null) {
                    String str = val.toString();
                    if (!str.isEmpty()) return str;
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

        private String getClientIp(jakarta.servlet.http.HttpServletRequest req) {
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

        private String getSessionId(jakarta.servlet.http.HttpServletRequest req) {
            jakarta.servlet.http.HttpSession session = req.getSession(false);
            return session != null ? session.getId() : null;
        }
    }

    /**
     * javax.servlet Filter 구현 (레거시 WAS 호환).
     */
    public static class JavaxFilter implements javax.servlet.Filter {

        @Override
        public void doFilter(javax.servlet.ServletRequest req,
                             javax.servlet.ServletResponse res,
                             javax.servlet.FilterChain chain)
                throws IOException, javax.servlet.ServletException {

            if (req instanceof javax.servlet.http.HttpServletRequest) {
                javax.servlet.http.HttpServletRequest httpReq =
                        (javax.servlet.http.HttpServletRequest) req;
                try {
                    UserContext ctx = new UserContext();
                    ctx.setClientIp(getClientIp(httpReq));
                    ctx.setSessionId(getSessionId(httpReq));
                    ctx.setUserId(extractUserId(httpReq));
                    UserContext.set(ctx);
                    chain.doFilter(req, res);
                } finally {
                    UserContext.clear();
                }
            } else {
                chain.doFilter(req, res);
            }
        }

        private String extractUserId(javax.servlet.http.HttpServletRequest req) {
            AgentConfig config = AgentConfig.getInstance();

            String headerName = config.getUserIdHeader();
            if (headerName != null) {
                String val = req.getHeader(headerName);
                if (val != null && !val.isEmpty()) return val;
            }

            String sessionAttr = config.getUserIdSessionAttr();
            javax.servlet.http.HttpSession session = req.getSession(false);
            if (session != null && sessionAttr != null) {
                Object val = session.getAttribute(sessionAttr);
                if (val != null) {
                    String str = val.toString();
                    if (!str.isEmpty()) return str;
                }
            }

            String springUser = extractFromSpringSecurity();
            if (springUser != null) return springUser;

            String remoteUser = req.getRemoteUser();
            if (remoteUser != null) return remoteUser;

            return "UNKNOWN";
        }

        private String getClientIp(javax.servlet.http.HttpServletRequest req) {
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

        private String getSessionId(javax.servlet.http.HttpServletRequest req) {
            javax.servlet.http.HttpSession session = req.getSession(false);
            return session != null ? session.getId() : null;
        }
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
