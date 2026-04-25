package datablocks.dlm.jdbc;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.zaxxer.hikari.HikariDataSource;
import com.zaxxer.hikari.HikariPoolMXBean;

import datablocks.dlm.domain.PiiDatabaseVO;
import datablocks.dlm.mapper.PiiDatabaseMapper;
import datablocks.dlm.util.AES256Util;

/**
 * 접속기록 전용 DataSource 홀더 — "XAUDIT_DB" 단일 논리 엔드포인트.
 *
 * <p>설계 원칙 (2026-04-25 V3):
 * <ul>
 *   <li>모든 접속기록 I/O (INSERT/SELECT/이상탐지/해시검증)가 이 Holder 경유</li>
 *   <li>물리적 저장소는 TBL_PIIDATABASE.db='XAUDIT_DB' 엔트리가 결정
 *       (default: DLM 자체 Primary DB / 선택: 고객사 별도 DB)</li>
 *   <li>부트스트랩 시 엔트리가 없으면 Primary 연결정보로 자동 등록 (편의성)</li>
 *   <li>업계 Best Practice: Spring AbstractRoutingDataSource / AWS CloudTrail / IBM Guardium</li>
 * </ul>
 */
@Component
public class XauditDataSourceHolder {

    private static final Logger log = LoggerFactory.getLogger(XauditDataSourceHolder.class);
    private static final String DB_KEY = "XAUDIT_DB";
    private static final String SYSTEM_NAME = "XAUDIT";

    @Value("${xaudit.storage.pool-size:4}")
    private int poolSize;

    @Value("${xaudit.storage.retry-init-seconds:60}")
    private long retryInitSeconds;

    @Value("${spring.datasource.url:}")
    private String primaryUrl;

    @Value("${spring.datasource.username:}")
    private String primaryUser;

    @Value("${spring.datasource.password:}")
    private String primaryPwd;

    @Autowired
    private PiiDatabaseMapper piiDatabaseMapper;

    private final AtomicReference<HikariDataSource> dataSource = new AtomicReference<>();
    private volatile String dbType;
    private volatile String schema;
    private ScheduledExecutorService retryExec;

    @PostConstruct
    public void init() {
        if (!tryInit()) {
            retryExec = Executors.newSingleThreadScheduledExecutor(r -> {
                Thread t = new Thread(r, "xaudit-ds-retry");
                t.setDaemon(true);
                return t;
            });
            retryExec.scheduleAtFixedRate(() -> {
                if (dataSource.get() != null) return;
                log.info("[X-Audit] retry XAUDIT_DB DataSource init");
                tryInit();
            }, retryInitSeconds, retryInitSeconds, TimeUnit.SECONDS);
        }
    }

    private boolean tryInit() {
        try {
            PiiDatabaseVO vo = piiDatabaseMapper.read(DB_KEY);
            if (vo == null) {
                vo = autoRegisterFromPrimary();
                if (vo == null) {
                    log.error("[X-Audit] cannot auto-register XAUDIT_DB — primary datasource info missing");
                    return false;
                }
            }
            AES256Util aes = new AES256Util();
            String plainPwd = aes.decrypt(vo.getPwd());
            HikariDataSource ds = ConnectionProvider.getDataSource(
                    poolSize,
                    vo.getDbtype(), vo.getHostname(), vo.getPort(),
                    vo.getId_type(), vo.getId(), vo.getDb(),
                    vo.getDbuser(), plainPwd);
            try (Connection c = ds.getConnection()) {
                if (!c.isValid(3)) throw new SQLException("initial validation failed");
            }
            this.dataSource.set(ds);
            this.dbType = vo.getDbtype();
            this.schema = null;   // 기본값 — 접속 유저 기본 스키마 사용
            log.info("[X-Audit] XAUDIT_DB DataSource ready: dbtype={} host={}:{} user={} poolSize={}",
                    vo.getDbtype(), vo.getHostname(), vo.getPort(), vo.getDbuser(), poolSize);
            return true;
        } catch (Exception e) {
            log.warn("[X-Audit] XAUDIT_DB init failed: {}", e.toString());
            return false;
        }
    }

    /** Primary DataSource 설정에서 XAUDIT_DB 엔트리를 자동 생성하고 TBL_PIIDATABASE 에 INSERT. */
    private PiiDatabaseVO autoRegisterFromPrimary() throws Exception {
        if (primaryUrl == null || primaryUrl.isEmpty()) return null;

        PiiDatabaseVO vo = parseJdbcUrl(primaryUrl);
        if (vo == null) return null;
        vo.setDb(DB_KEY);
        vo.setSystem(SYSTEM_NAME);
        vo.setEnv("PRODUCTION");
        vo.setDbuser(primaryUser);
        AES256Util aes = new AES256Util();
        vo.setPwd(aes.encrypt(primaryPwd == null ? "" : primaryPwd));
        vo.setComments("Auto-registered from Primary DataSource (fallback to DLM internal DB)");
        vo.setReguserid("SYSTEM");

        piiDatabaseMapper.insert(vo);
        log.info("[X-Audit] XAUDIT_DB auto-registered: dbtype={} host={}:{} user={}",
                vo.getDbtype(), vo.getHostname(), vo.getPort(), vo.getDbuser());
        return vo;
    }

    /**
     * JDBC URL 을 파싱해 PiiDatabaseVO 의 dbtype/hostname/port/id/id_type 을 세팅.
     * 지원: MariaDB / MySQL / Oracle / PostgreSQL / MSSQL / Tibero / DB2.
     * 예:
     *   jdbc:mariadb://host:3306/cotdl?...      → dbtype=MARIADB, host=host, port=3306, id=cotdl
     *   jdbc:oracle:thin:@host:1521/ORCL        → dbtype=ORACLE,  host=host, port=1521, id=ORCL, id_type=SERVICE
     *   jdbc:oracle:thin:@host:1521:SID         → dbtype=ORACLE,  host=host, port=1521, id=SID,  id_type=SID
     */
    private static PiiDatabaseVO parseJdbcUrl(String url) {
        PiiDatabaseVO vo = new PiiDatabaseVO();

        // Oracle thin 형식 먼저 매칭
        Matcher ora = Pattern.compile(
                "jdbc:(oracle|tibero):thin:@([^:/]+):(\\d+)([/:])(\\S+?)(\\?.*)?$",
                Pattern.CASE_INSENSITIVE).matcher(url);
        if (ora.matches()) {
            vo.setDbtype(ora.group(1).toUpperCase());
            vo.setHostname(ora.group(2));
            vo.setPort(ora.group(3));
            vo.setId(ora.group(5));
            vo.setId_type("/".equals(ora.group(4)) ? "SERVICE" : "SID");
            return vo;
        }

        // 일반 JDBC URL (MariaDB/MySQL/PostgreSQL/MSSQL 등)
        Matcher m = Pattern.compile(
                "jdbc:(\\w+)://([^:/]+)(?::(\\d+))?/([^?;]+)",
                Pattern.CASE_INSENSITIVE).matcher(url);
        if (m.find()) {
            String driver = m.group(1).toUpperCase();
            vo.setDbtype(driver);    // MARIADB/MYSQL/POSTGRESQL
            vo.setHostname(m.group(2));
            vo.setPort(m.group(3) != null ? m.group(3) : defaultPort(driver));
            vo.setId(m.group(4));
            vo.setId_type("");
            return vo;
        }

        // MSSQL 고유 포맷: jdbc:sqlserver://host:port;DatabaseName=xxx
        Matcher msql = Pattern.compile(
                "jdbc:sqlserver://([^:;]+):(\\d+);DatabaseName=([^;]+)",
                Pattern.CASE_INSENSITIVE).matcher(url);
        if (msql.find()) {
            vo.setDbtype("MSSQL");
            vo.setHostname(msql.group(1));
            vo.setPort(msql.group(2));
            vo.setDb(msql.group(3));
            vo.setId(msql.group(3));
            return vo;
        }
        return null;
    }

    private static String defaultPort(String driver) {
        switch (driver) {
            case "MARIADB": case "MYSQL":     return "3306";
            case "POSTGRESQL":                return "5432";
            case "SQLSERVER": case "MSSQL":   return "1433";
            case "DB2":                       return "50000";
            default:                          return "3306";
        }
    }

    public boolean isReady() { return dataSource.get() != null; }

    public Connection getConnection() throws SQLException {
        HikariDataSource ds = dataSource.get();
        if (ds == null) throw new SQLException("XAUDIT_DB DataSource not initialized");
        return ds.getConnection();
    }

    public HikariDataSource getDataSource() {
        HikariDataSource ds = dataSource.get();
        if (ds == null) throw new IllegalStateException("XAUDIT_DB DataSource not initialized");
        return ds;
    }

    public String getDbType() { return dbType; }
    public String getSchema() { return schema; }
    public String getAccessTable()  { return "TBL_ACCESS_LOG"; }
    public String getDetailTable()  { return "TBL_ACCESS_LOG_DETAIL"; }

    @PreDestroy
    public void shutdown() {
        if (retryExec != null) retryExec.shutdownNow();
        HikariDataSource ds = dataSource.getAndSet(null);
        if (ds == null) return;
        try {
            HikariPoolMXBean mx = ds.getHikariPoolMXBean();
            if (mx != null) {
                mx.softEvictConnections();
                long deadline = System.currentTimeMillis() + 30_000;
                while (mx.getActiveConnections() > 0 && System.currentTimeMillis() < deadline) {
                    try { Thread.sleep(500); } catch (InterruptedException e) {
                        Thread.currentThread().interrupt(); break;
                    }
                }
            }
        } finally {
            ds.close();
            log.info("[X-Audit] XAUDIT_DB DataSource closed");
        }
    }
}
