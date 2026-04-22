package datablocks.dlm.xaudit.servlet;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import datablocks.dlm.xaudit.spring.XauditProperties;

/**
 * HttpServletRequest → (사용자 ID, 이름, 부서) 추출.
 *
 * 우선순위:
 *  1. {@code xaudit.user.header} 헤더 (예: 게이트웨이가 실제 사용자 ID 를 헤더로 전달)
 *  2. {@code xaudit.user.session-attribute} 세션 속성
 *  3. Spring Security SecurityContext (reflection — 의존성 없이 접근)
 *  4. HttpServletRequest.getRemoteUser() / UserPrincipal.getName()
 *  5. "anonymous"
 *
 * 고객사 처리계마다 로그인 세션 구조가 다르므로, 고객사는 {@link #custom(CustomResolver)}
 * 으로 커스텀 Resolver 를 등록할 수 있다.
 */
public class XauditUserResolver {

    public static class User {
        public final String id;
        public final String name;
        public final String department;
        public User(String id, String name, String department) {
            this.id = id; this.name = name; this.department = department;
        }
        public static User anonymous() { return new User("anonymous", null, null); }
    }

    public interface CustomResolver {
        User resolve(HttpServletRequest req);
    }

    private final XauditProperties props;
    private volatile CustomResolver custom;

    public XauditUserResolver(XauditProperties props) {
        this.props = props;
    }

    public void custom(CustomResolver r) { this.custom = r; }

    public User resolve(HttpServletRequest req) {
        if (req == null) return User.anonymous();
        try {
            if (custom != null) {
                User u = custom.resolve(req);
                if (u != null && u.id != null && !u.id.isEmpty()) return u;
            }
            XauditProperties.User cfg = props.getUser();

            String header = cfg.getHeader();
            if (header != null && !header.isEmpty()) {
                String v = req.getHeader(header);
                if (notBlank(v)) return new User(v, null, null);
            }

            String sesAttr = cfg.getSessionAttribute();
            if (sesAttr != null && !sesAttr.isEmpty()) {
                HttpSession ses = req.getSession(false);
                if (ses != null) {
                    Object v = ses.getAttribute(sesAttr);
                    if (v != null) return new User(String.valueOf(v), null, null);
                }
            }

            if (cfg.isUseSecurityContext()) {
                User u = fromSecurityContext();
                if (u != null) return u;
            }

            if (notBlank(req.getRemoteUser())) {
                return new User(req.getRemoteUser(), null, null);
            }
            if (req.getUserPrincipal() != null && notBlank(req.getUserPrincipal().getName())) {
                return new User(req.getUserPrincipal().getName(), null, null);
            }
        } catch (Throwable ignore) { /* fallthrough */ }
        return User.anonymous();
    }

    /** Spring Security 가 존재할 때만 ReflectionUtils 로 접근. 없으면 null. */
    private User fromSecurityContext() {
        try {
            Class<?> holderCls = Class.forName("org.springframework.security.core.context.SecurityContextHolder");
            Object ctx = holderCls.getMethod("getContext").invoke(null);
            if (ctx == null) return null;
            Object auth = ctx.getClass().getMethod("getAuthentication").invoke(ctx);
            if (auth == null) return null;
            Boolean authenticated = (Boolean) auth.getClass().getMethod("isAuthenticated").invoke(auth);
            if (authenticated == null || !authenticated) return null;
            String name = (String) auth.getClass().getMethod("getName").invoke(auth);
            if (!notBlank(name) || "anonymousUser".equals(name)) return null;
            return new User(name, null, null);
        } catch (Throwable ignore) {
            return null;
        }
    }

    private static boolean notBlank(String s) { return s != null && !s.isEmpty(); }
}
