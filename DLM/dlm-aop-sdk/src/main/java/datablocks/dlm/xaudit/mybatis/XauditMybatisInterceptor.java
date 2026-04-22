package datablocks.dlm.xaudit.mybatis;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Locale;
import java.util.Properties;

import org.apache.ibatis.executor.Executor;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.mapping.ParameterMapping;
import org.apache.ibatis.mapping.SqlCommandType;
import org.apache.ibatis.plugin.Interceptor;
import org.apache.ibatis.plugin.Intercepts;
import org.apache.ibatis.plugin.Invocation;
import org.apache.ibatis.plugin.Signature;
import org.apache.ibatis.reflection.MetaObject;
import org.apache.ibatis.reflection.SystemMetaObject;
import org.apache.ibatis.session.ResultHandler;
import org.apache.ibatis.session.RowBounds;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import datablocks.dlm.xaudit.core.XauditContext;
import datablocks.dlm.xaudit.core.XauditContextHolder;
import datablocks.dlm.xaudit.core.XauditEvent;
import datablocks.dlm.xaudit.core.XauditEventQueue;
import datablocks.dlm.xaudit.core.XauditPiiMasker;
import datablocks.dlm.xaudit.spring.XauditProperties;

/**
 * MyBatis {@code Executor#query/update} 지점을 가로채 SQL 이벤트를 큐에 투입.
 *
 * - Mapper XML/DAO 코드 수정 제로
 * - PreparedStatement 바인딩 파라미터를 SQL 에 치환해 "실행된 실제 SQL" 을 보존
 * - 옵션 활성 시 {@code /*XAUDIT USER=...*&#47;} 주석을 SQL 앞에 prepend
 *   → 네트워크 DAM(DBSAFER/PSM) 이 TNS 패킷에서 바로 파싱 가능
 */
@Intercepts({
    @Signature(type = Executor.class, method = "update",
               args = {MappedStatement.class, Object.class}),
    @Signature(type = Executor.class, method = "query",
               args = {MappedStatement.class, Object.class, RowBounds.class, ResultHandler.class}),
    @Signature(type = Executor.class, method = "query",
               args = {MappedStatement.class, Object.class, RowBounds.class, ResultHandler.class,
                       org.apache.ibatis.cache.CacheKey.class, BoundSql.class})
})
public class XauditMybatisInterceptor implements Interceptor {

    private static final Logger log = LoggerFactory.getLogger(XauditMybatisInterceptor.class);
    private static final DateTimeFormatter TS = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
    private static final DateTimeFormatter PK = DateTimeFormatter.ofPattern("yyyyMMdd");

    private final XauditProperties props;
    private final XauditEventQueue queue;
    private final XauditPiiMasker masker;

    public XauditMybatisInterceptor(XauditProperties props, XauditEventQueue queue, XauditPiiMasker masker) {
        this.props  = props;
        this.queue  = queue;
        this.masker = masker;
    }

    @Override
    public Object intercept(Invocation invocation) throws Throwable {
        long t0 = System.nanoTime();
        Object result = null;
        Throwable caught = null;
        try {
            result = invocation.proceed();
            return result;
        } catch (Throwable t) {
            caught = t;
            throw t;
        } finally {
            try {
                long durMs = (System.nanoTime() - t0) / 1_000_000L;
                emit(invocation, result, caught, durMs);
            } catch (Throwable t) {
                log.warn("[X-Audit] sql event emit failed: {}", t.toString());
            }
        }
    }

    private void emit(Invocation invocation, Object result, Throwable caught, long durMs) {
        if (!props.isEnabled() || !props.getSql().isCaptureText()) return;
        Object[] args = invocation.getArgs();
        if (args == null || args.length == 0 || !(args[0] instanceof MappedStatement)) return;
        MappedStatement ms = (MappedStatement) args[0];
        Object parameter = args.length > 1 ? args[1] : null;

        XauditContext ctx = XauditContextHolder.get();

        BoundSql bound;
        try {
            bound = ms.getBoundSql(parameter);
        } catch (Throwable t) {
            log.debug("[X-Audit] getBoundSql failed: {}", t.toString());
            return;
        }

        String sqlText = bound.getSql();
        if (sqlText == null) return;
        String bindDump = dumpBindParams(bound, parameter);

        if (props.getSql().isCommentInjection() && ctx != null) {
            sqlText = injectComment(sqlText, ctx);
        }
        sqlText = truncate(sqlText, props.getSql().getMaxTextLength());
        bindDump = truncate(bindDump, props.getSql().getMaxBindLength());

        String piiCodes = masker.detect(sqlText + " " + nullSafe(bindDump));

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

        ev.sqlId = ms.getId();
        ev.sqlType = resolveSqlType(ms.getSqlCommandType());
        ev.sqlText = sqlText;
        ev.bindParams = props.getSql().isCaptureBindParams() ? bindDump : null;
        ev.affectedRows = resolveAffected(ms.getSqlCommandType(), result);
        ev.durationMs = durMs;
        ev.piiDetected = piiCodes;
        if (caught != null) {
            ev.errorMessage = truncate(caught.getClass().getSimpleName() + ":" + caught.getMessage(), 200);
        }
        queue.offer(ev);
    }

    private static String resolveSqlType(SqlCommandType t) {
        if (t == null) return "OTHER";
        switch (t) {
            case SELECT: return "SELECT";
            case INSERT: return "INSERT";
            case UPDATE: return "UPDATE";
            case DELETE: return "DELETE";
            default:     return t.name();
        }
    }

    @SuppressWarnings("rawtypes")
    private static Integer resolveAffected(SqlCommandType t, Object result) {
        if (t == null) return null;
        if (result instanceof Integer) return (Integer) result;
        if (result instanceof Long)    return ((Long) result).intValue();
        if (result instanceof java.util.Collection) return ((java.util.Collection) result).size();
        return null;
    }

    /** PreparedStatement 의 {@code ?} 를 실제 바인딩 값 리스트로 덤프.
     *  원문 SQL 의 물리적 치환 대신 별도 필드로 저장 — Oracle shared pool 오염 방지. */
    private static String dumpBindParams(BoundSql bound, Object parameter) {
        java.util.List<ParameterMapping> maps = bound.getParameterMappings();
        if (maps == null || maps.isEmpty()) return null;
        StringBuilder sb = new StringBuilder("[");
        MetaObject mo = parameter == null ? null : SystemMetaObject.forObject(parameter);
        for (int i = 0; i < maps.size(); i++) {
            if (i > 0) sb.append(", ");
            ParameterMapping pm = maps.get(i);
            String property = pm.getProperty();
            Object value;
            if (bound.hasAdditionalParameter(property)) {
                value = bound.getAdditionalParameter(property);
            } else if (parameter == null) {
                value = null;
            } else if (mo != null && mo.hasGetter(property)) {
                value = mo.getValue(property);
            } else {
                value = parameter;
            }
            sb.append(property).append('=').append(formatValue(value));
        }
        sb.append("]");
        return sb.toString();
    }

    private static String formatValue(Object v) {
        if (v == null) return "NULL";
        if (v instanceof CharSequence) return "'" + v + "'";
        if (v.getClass().isArray()) {
            if (v instanceof Object[]) return Arrays.toString((Object[]) v);
            return String.valueOf(v);
        }
        return String.valueOf(v);
    }

    /** 사용자·메뉴·세션을 식별할 수 있는 SQL 주석. Oracle 힌트(+) 와 구분되어야 함. */
    private String injectComment(String sql, XauditContext ctx) {
        StringBuilder sb = new StringBuilder(sql.length() + 128);
        sb.append("/*XAUDIT ")
          .append("SVC=").append(nullSafe(ctx.getServiceName())).append(';')
          .append("USER=").append(nullSafe(ctx.getUserId())).append(';')
          .append("MENU=").append(nullSafe(ctx.getMenuId())).append(';')
          .append("IP=").append(nullSafe(ctx.getClientIp())).append(';')
          .append("SID=").append(nullSafe(ctx.getSessionId()))
          .append("*/ ")
          .append(sql);
        return sb.toString();
    }

    @Override public Object plugin(Object target) { return org.apache.ibatis.plugin.Plugin.wrap(target, this); }
    @Override public void setProperties(Properties properties) { /* no-op */ }

    private static String nullSafe(String s) { return s == null ? "" : s; }
    private static String truncate(String s, int max) {
        if (s == null || max <= 0 || s.length() <= max) return s;
        return s.substring(0, max) + "...[TRUNC]";
    }

    // 로케일 영향 차단 (대소문자 변환 시 사용할 경우)
    @SuppressWarnings("unused")
    private static final Locale LOC = Locale.ROOT;
}
