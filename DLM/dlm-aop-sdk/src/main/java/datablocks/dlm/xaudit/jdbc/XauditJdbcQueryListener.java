package datablocks.dlm.xaudit.jdbc;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import datablocks.dlm.xaudit.core.XauditContext;
import datablocks.dlm.xaudit.core.XauditContextHolder;
import datablocks.dlm.xaudit.core.XauditEvent;
import datablocks.dlm.xaudit.core.XauditEventQueue;
import datablocks.dlm.xaudit.core.XauditPiiMasker;
import datablocks.dlm.xaudit.spring.XauditProperties;

import net.ttddyy.dsproxy.ExecutionInfo;
import net.ttddyy.dsproxy.QueryInfo;
import net.ttddyy.dsproxy.listener.QueryExecutionListener;

/**
 * DataSource-Proxy 기반 JDBC Listener.
 * MyBatis 가 아닌 경로 (JdbcTemplate, Spring Batch JobRepository, JPA 네이티브 등) 까지 덮는다.
 *
 * MyBatis Interceptor 와 중복 수집되지 않도록 {@code sqlId} 는 "JDBC:<클래스>" 로 구분.
 */
public class XauditJdbcQueryListener implements QueryExecutionListener {

    private static final Logger log = LoggerFactory.getLogger(XauditJdbcQueryListener.class);
    private static final DateTimeFormatter TS = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
    private static final DateTimeFormatter PK = DateTimeFormatter.ofPattern("yyyyMMdd");

    private final XauditProperties props;
    private final XauditEventQueue queue;
    private final XauditPiiMasker masker;

    public XauditJdbcQueryListener(XauditProperties props, XauditEventQueue queue, XauditPiiMasker masker) {
        this.props = props;
        this.queue = queue;
        this.masker = masker;
    }

    @Override
    public void beforeQuery(ExecutionInfo execInfo, List<QueryInfo> queryInfoList) { /* no-op */ }

    @Override
    public void afterQuery(ExecutionInfo execInfo, List<QueryInfo> queryInfoList) {
        if (!props.isEnabled() || !props.getSql().isCaptureText()) return;
        if (queryInfoList == null || queryInfoList.isEmpty()) return;

        // MyBatis 경로는 Interceptor 가 이미 기록했으므로 스킵 (execInfo.getConnectionId() 만 있고 MyBatis 호출은 속성 표식 없음)
        // 간단한 휴리스틱: stack trace 에 MyBatis 가 보이면 스킵. 성능 영향 크지 않음 (1~2µs).
        if (isMybatisOriginated()) return;

        XauditContext ctx = XauditContextHolder.get();
        long durMs = execInfo.getElapsedTime();
        String errorMsg = execInfo.getThrowable() != null ?
                execInfo.getThrowable().getClass().getSimpleName() + ":" + execInfo.getThrowable().getMessage() : null;

        for (QueryInfo q : queryInfoList) {
            String sql = q.getQuery();
            if (sql == null) continue;
            String bindDump = dumpBinds(q);
            sql     = truncate(sql, props.getSql().getMaxTextLength());
            bindDump = truncate(bindDump, props.getSql().getMaxBindLength());
            String piiCodes = masker.detect(sql + " " + nullSafe(bindDump));

            XauditEvent ev = new XauditEvent();
            ev.type = XauditEvent.Type.SQL;
            ev.reqId = ctx != null ? ctx.getReqId() : null;
            ev.serviceName = props.getServiceName();
            if (ctx != null) {
                ev.userId = ctx.getUserId();
                ev.userName = ctx.getUserName();
                ev.department = ctx.getDepartment();
                ev.clientIp = ctx.getClientIp();
                ev.sessionId = ctx.getSessionId();
                ev.menuId = ctx.getMenuId();
                ev.uri = ctx.getUri();
            }
            LocalDateTime now = LocalDateTime.now();
            ev.accessTime = now.format(TS);
            ev.partitionKey = now.format(PK);

            ev.sqlId = "JDBC";
            ev.sqlType = resolveType(sql);
            ev.sqlText = sql;
            ev.bindParams = props.getSql().isCaptureBindParams() ? bindDump : null;
            ev.durationMs = durMs;
            ev.piiDetected = piiCodes;
            ev.errorMessage = truncate(errorMsg, 200);
            queue.offer(ev);
        }
    }

    private static String dumpBinds(QueryInfo q) {
        List<List<net.ttddyy.dsproxy.proxy.ParameterSetOperation>> groups = q.getParametersList();
        if (groups == null || groups.isEmpty()) return null;
        StringBuilder sb = new StringBuilder();
        for (int g = 0; g < groups.size(); g++) {
            if (g > 0) sb.append(" | ");
            sb.append('[');
            List<net.ttddyy.dsproxy.proxy.ParameterSetOperation> ops = groups.get(g);
            List<String> items = new ArrayList<>();
            for (net.ttddyy.dsproxy.proxy.ParameterSetOperation op : ops) {
                Object[] args = op.getArgs();
                if (args == null || args.length < 2) continue;
                items.add(args[0] + "=" + format(args[1]));
            }
            sb.append(String.join(", ", items));
            sb.append(']');
        }
        return sb.toString();
    }

    private static String format(Object v) {
        if (v == null) return "NULL";
        if (v instanceof CharSequence) return "'" + v + "'";
        return String.valueOf(v);
    }

    private static String resolveType(String sql) {
        String trimmed = sql.trim();
        if (trimmed.isEmpty()) return "OTHER";
        char c = Character.toUpperCase(trimmed.charAt(0));
        switch (c) {
            case 'S': return "SELECT";
            case 'I': return "INSERT";
            case 'U': return "UPDATE";
            case 'D': return "DELETE";
            default:  return "OTHER";
        }
    }

    private static boolean isMybatisOriginated() {
        StackTraceElement[] trace = Thread.currentThread().getStackTrace();
        for (int i = 0; i < Math.min(trace.length, 40); i++) {
            String cls = trace[i].getClassName();
            if (cls.startsWith("org.apache.ibatis.")) return true;
        }
        return false;
    }

    private static String nullSafe(String s) { return s == null ? "" : s; }
    private static String truncate(String s, int max) {
        if (s == null || max <= 0 || s.length() <= max) return s;
        return s.substring(0, max) + "...[TRUNC]";
    }
}
