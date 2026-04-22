package datablocks.dlm.xaudit.servlet;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Enumeration;
import java.util.Map;
import java.util.UUID;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import datablocks.dlm.xaudit.core.XauditContext;
import datablocks.dlm.xaudit.core.XauditContextHolder;
import datablocks.dlm.xaudit.core.XauditEvent;
import datablocks.dlm.xaudit.core.XauditEventQueue;
import datablocks.dlm.xaudit.spring.XauditProperties;

/**
 * HTTP 요청 진입점에서 감사 컨텍스트를 구성 → {@link XauditContextHolder} 에 저장.
 * 응답 종료 시 ACCESS 이벤트 1건을 큐에 투입한 뒤 반드시 {@code clear()}.
 *
 * MDC 를 함께 설정 → 고객사 기존 로그(Logback {@code %X{...}}) 에도 자동 연동.
 */
public class XauditAccessFilter implements Filter {

    private static final Logger log = LoggerFactory.getLogger(XauditAccessFilter.class);
    private static final DateTimeFormatter TS = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
    private static final DateTimeFormatter PK = DateTimeFormatter.ofPattern("yyyyMMdd");

    private final XauditProperties props;
    private final XauditEventQueue queue;
    private final XauditUserResolver userResolver;

    public XauditAccessFilter(XauditProperties props, XauditEventQueue queue, XauditUserResolver r) {
        this.props = props;
        this.queue = queue;
        this.userResolver = r;
    }

    @Override public void init(FilterConfig fc) { /* no-op */ }
    @Override public void destroy()             { /* no-op */ }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (!(request instanceof HttpServletRequest) || !props.isEnabled()) {
            chain.doFilter(request, response);
            return;
        }
        HttpServletRequest req  = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        if (isExcluded(uri)) {
            chain.doFilter(request, response);
            return;
        }

        XauditContext ctx = build(req);
        XauditContextHolder.set(ctx);
        trySetMdc(ctx);

        long t0 = System.nanoTime();
        String resultCode = "SUCCESS";
        try {
            chain.doFilter(request, response);
        } catch (RuntimeException | IOException | ServletException ex) {
            resultCode = "FAIL";
            throw ex;
        } finally {
            try {
                long durMs = (System.nanoTime() - t0) / 1_000_000L;
                emitAccessEvent(ctx, res.getStatus(), durMs, resultCode);
            } catch (Throwable t) {
                log.warn("[X-Audit] access event emit failed: {}", t.toString());
            } finally {
                XauditContextHolder.clear();
                clearMdc();
            }
        }
    }

    private XauditContext build(HttpServletRequest req) {
        String reqId = UUID.randomUUID().toString().replace("-", "");
        XauditUserResolver.User u = userResolver.resolve(req);
        HttpSession ses = req.getSession(false);
        String sessionId = ses != null ? ses.getId() : null;
        String menuId = resolveMenu(req);
        return new XauditContext(
                reqId,
                u.id, u.name, u.department,
                getClientIp(req),
                sessionId,
                menuId,
                req.getRequestURI(),
                req.getMethod(),
                req.getHeader("User-Agent"),
                props.getServiceName());
    }

    private String resolveMenu(HttpServletRequest req) {
        String header = props.getMenu().getHeader();
        if (header != null && !header.isEmpty()) {
            String h = req.getHeader(header);
            if (h != null && !h.isEmpty()) return h;
        }
        String uri = req.getRequestURI();
        if (uri != null) {
            for (Map.Entry<String, String> e : props.getMenu().getUriPrefixMap().entrySet()) {
                if (uri.startsWith(e.getValue())) return e.getKey();
            }
        }
        return null;
    }

    private boolean isExcluded(String uri) {
        if (uri == null) return false;
        for (String ex : props.getExcludeUriPatterns()) {
            if (uri.startsWith(ex)) return true;
        }
        return false;
    }

    private void emitAccessEvent(XauditContext ctx, int httpStatus, long durMs, String resultCode) {
        XauditEvent ev = new XauditEvent();
        ev.type = XauditEvent.Type.ACCESS;
        ev.reqId = ctx.getReqId();
        ev.serviceName = ctx.getServiceName();
        ev.userId = ctx.getUserId();
        ev.userName = ctx.getUserName();
        ev.department = ctx.getDepartment();
        ev.clientIp = ctx.getClientIp();
        ev.sessionId = ctx.getSessionId();
        ev.menuId = ctx.getMenuId();
        ev.uri = ctx.getUri();
        ev.httpMethod = ctx.getHttpMethod();
        ev.userAgent = ctx.getUserAgent();
        LocalDateTime now = LocalDateTime.now();
        ev.accessTime = now.format(TS);
        ev.partitionKey = now.format(PK);
        ev.httpStatus = httpStatus;
        ev.totalDurationMs = durMs;
        ev.resultCode = resultCode;
        queue.offer(ev);
    }

    private void trySetMdc(XauditContext ctx) {
        try {
            org.slf4j.MDC.put("xauditReqId", ctx.getReqId());
            if (ctx.getUserId() != null) org.slf4j.MDC.put("xauditUserId", ctx.getUserId());
            if (ctx.getMenuId() != null) org.slf4j.MDC.put("xauditMenuId", ctx.getMenuId());
        } catch (Throwable ignore) {}
    }

    private void clearMdc() {
        try {
            org.slf4j.MDC.remove("xauditReqId");
            org.slf4j.MDC.remove("xauditUserId");
            org.slf4j.MDC.remove("xauditMenuId");
        } catch (Throwable ignore) {}
    }

    /** X-Forwarded-For → X-Real-IP → remoteAddr (WAF/프록시 체인 처리) */
    public static String getClientIp(HttpServletRequest r) {
        String ip = r.getHeader("X-Forwarded-For");
        if (isBlank(ip)) ip = r.getHeader("X-Real-IP");
        if (isBlank(ip)) ip = r.getRemoteAddr();
        if (ip != null && ip.contains(",")) ip = ip.split(",")[0].trim();
        return ip;
    }
    private static boolean isBlank(String s) { return s == null || s.isEmpty() || "unknown".equalsIgnoreCase(s); }

    // 헤더 덤프 등이 필요하면 확장
    @SuppressWarnings("unused")
    private static String dumpHeaders(HttpServletRequest r) {
        StringBuilder sb = new StringBuilder();
        Enumeration<String> names = r.getHeaderNames();
        while (names.hasMoreElements()) {
            String n = names.nextElement();
            sb.append(n).append('=').append(r.getHeader(n)).append(';');
        }
        return sb.toString();
    }
}
