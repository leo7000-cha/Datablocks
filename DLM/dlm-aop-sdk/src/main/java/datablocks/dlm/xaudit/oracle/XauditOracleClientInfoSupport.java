package datablocks.dlm.xaudit.oracle;

import java.sql.Connection;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import datablocks.dlm.xaudit.core.XauditContext;
import datablocks.dlm.xaudit.core.XauditContextHolder;

/**
 * Oracle {@code V$SESSION.CLIENT_IDENTIFIER} 를 요청별 사용자 ID 로 세팅.
 *
 * - setClientInfo 호출은 추가 roundtrip 없음 (다음 SQL 실행 시 piggyback)
 * - HikariCP 는 커넥션 반환 시 자동 clear 하지 않음 → Dirty Session 버그 방어
 * - 반드시 {@link #clear(Connection)} 으로 명시적 null 세팅 필요
 *
 * 호출 시점 권장:
 *   - MyBatis Interceptor 의 진입 직전 set
 *   - 종료 후 clear
 *   - HikariCP {@code connectionInitSql="BEGIN DBMS_SESSION.CLEAR_IDENTIFIER; END;"} 병행
 */
public final class XauditOracleClientInfoSupport {

    private static final Logger log = LoggerFactory.getLogger(XauditOracleClientInfoSupport.class);

    /** Oracle JDBC 4.0+ namespaced key */
    private static final String KEY_CLIENT_ID = "OCSID.CLIENTID";
    private static final String KEY_MODULE    = "OCSID.MODULE";
    private static final String KEY_ACTION    = "OCSID.ACTION";

    private XauditOracleClientInfoSupport() {}

    public static void apply(Connection conn) {
        XauditContext ctx = XauditContextHolder.get();
        if (conn == null || ctx == null) return;
        try {
            if (ctx.getUserId() != null) conn.setClientInfo(KEY_CLIENT_ID, ctx.getUserId());
            if (ctx.getServiceName() != null) conn.setClientInfo(KEY_MODULE, ctx.getServiceName());
            if (ctx.getMenuId() != null) conn.setClientInfo(KEY_ACTION, ctx.getMenuId());
        } catch (Throwable t) {
            // 지원하지 않는 드라이버(Tibero/MariaDB 등)는 SQLFeatureNotSupportedException 발생 가능 → 무시
            log.debug("[X-Audit] setClientInfo skipped: {}", t.toString());
        }
    }

    public static void clear(Connection conn) {
        if (conn == null) return;
        try {
            conn.setClientInfo(KEY_CLIENT_ID, null);
            conn.setClientInfo(KEY_MODULE,    null);
            conn.setClientInfo(KEY_ACTION,    null);
        } catch (Throwable ignore) {}
    }
}
