package datablocks.dlm.jdbc;

import com.zaxxer.hikari.HikariDataSource;
import com.zaxxer.hikari.HikariPoolMXBean;
import datablocks.dlm.mapper.PiiDatabaseMapper;
import datablocks.dlm.domain.PiiDatabaseVO;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicReference;

/**
 * DB 식별자(key)별 HikariDataSource를 캐싱하는 스레드 안전 클래스.
 *
 * <p>Step 실행 시 모든 Worker가 공유하며, DB별로 HikariDataSource를 lazily 생성한다.
 * Step 종료 시 {@link #close()}를 호출하여 모든 DataSource를 닫아야 한다.
 *
 * <p>사용 예:
 * <pre>
 *   DataSourceCache dsCache = new DataSourceCache(databaseMapper, aes, threadcnt);
 *   try {
 *       Connection conn = dsCache.getConnection("COREDB1");
 *       // ... use connection ...
 *       conn.close(); // returns to pool
 *   } finally {
 *       dsCache.close(); // closes all pools
 *   }
 * </pre>
 */
public class DataSourceCache implements AutoCloseable {

    private static final Logger logger = LoggerFactory.getLogger(DataSourceCache.class);

    /** Graceful shutdown 시 활성 커넥션 완료 대기 최대 시간 (밀리초) */
    private static final long GRACEFUL_SHUTDOWN_TIMEOUT_MS = 60_000;
    /** 활성 커넥션 대기 시 폴링 간격 (밀리초) */
    private static final long POLL_INTERVAL_MS = 500;

    private final ConcurrentHashMap<String, HikariDataSource> cache = new ConcurrentHashMap<>();
    private final PiiDatabaseMapper databaseMapper;
    private final AES256Util aes;
    private final int poolSizePerDb;

    public DataSourceCache(PiiDatabaseMapper databaseMapper, AES256Util aes, int poolSizePerDb) {
        this.databaseMapper = databaseMapper;
        this.aes = aes;
        this.poolSizePerDb = poolSizePerDb;
    }

    /**
     * 지정된 DB key에 대한 커넥션을 풀에서 가져온다.
     * DataSource가 없으면 lazily 생성한다 (thread-safe).
     *
     * <p>반환된 커넥션은 autoCommit=false 상태이며,
     * 사용 후 반드시 close()해야 풀에 반환된다.
     *
     * @param dbKey PiiDatabaseVO의 db 식별자 (예: "DLMARC", "COREDB1")
     * @return autoCommit=false 상태의 Connection
     */
    public Connection getConnection(String dbKey) throws SQLException {
        HikariDataSource ds;
        try {
            ds = cache.computeIfAbsent(dbKey, this::createDataSource);
        } catch (RuntimeException e) {
            if (e.getCause() instanceof SQLException) {
                throw (SQLException) e.getCause();
            }
            throw e;
        }
        Connection conn = ds.getConnection();
        conn.setAutoCommit(false);
        return conn;
    }

    private HikariDataSource createDataSource(String dbKey) {
        try {
            PiiDatabaseVO dbvo = databaseMapper.read(dbKey);
            if (dbvo == null) {
                throw new RuntimeException("Database not found in TBL_PIIDATABASE: " + dbKey);
            }
            HikariDataSource ds = ConnectionProvider.getDataSource(
                    poolSizePerDb,
                    dbvo.getDbtype(), dbvo.getHostname(), dbvo.getPort(),
                    dbvo.getId_type(), dbvo.getId(), dbvo.getDb(),
                    dbvo.getDbuser(), aes.decrypt(dbvo.getPwd()));
            LogUtil.log("INFO", "DataSourceCache created pool: db=" + dbKey
                    + " poolSize=" + poolSizePerDb);
            return ds;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to create DataSource: db=" + dbKey, e);
        } catch (Exception e) {
            throw new RuntimeException("Failed to create DataSource: db=" + dbKey, e);
        }
    }

    /**
     * 지정된 DB key에 대한 커넥션 풀을 미리 생성하고 물리 커넥션을 워밍업한다.
     * Worker 스레드 시작 전에 호출하여 첫 커넥션 획득 지연을 제거한다.
     *
     * <p>각 DB별로 병렬 스레드에서 maximumPoolSize만큼 물리 커넥션을 생성 후 풀에 반환한다.
     *
     * @param dbKeys 워밍업할 DB 식별자 목록 (예: "DLMARC", "COREDB1")
     * @throws SQLException 풀 생성 또는 커넥션 획득 실패 시
     */
    public void warmUp(String... dbKeys) throws SQLException {
        if (dbKeys == null || dbKeys.length == 0) {
            return;
        }

        // 중복 키 제거 (같은 풀에 2개 스레드가 동시 getConnection하면 데드락 가능)
        Set<String> uniqueKeys = new LinkedHashSet<>();
        for (String k : dbKeys) {
            if (k != null) uniqueKeys.add(k);
        }
        if (uniqueKeys.isEmpty()) {
            return;
        }

        AtomicReference<Exception> error = new AtomicReference<>();
        List<Thread> threads = new ArrayList<>();

        for (String dbKey : uniqueKeys) {
            // 풀 생성 (computeIfAbsent)
            HikariDataSource ds;
            try {
                ds = cache.computeIfAbsent(dbKey, this::createDataSource);
            } catch (RuntimeException e) {
                if (e.getCause() instanceof SQLException) {
                    throw (SQLException) e.getCause();
                }
                throw new SQLException("Failed to create pool for warm-up: db=" + dbKey, e);
            }

            // DB별 병렬 스레드로 물리 커넥션 워밍업
            Thread t = new Thread(() -> {
                List<Connection> conns = new ArrayList<>();
                try {
                    for (int i = 0; i < poolSizePerDb; i++) {
                        conns.add(ds.getConnection());
                    }
                } catch (Exception e) {
                    error.compareAndSet(null, e);
                } finally {
                    for (Connection conn : conns) {
                        try {
                            conn.close();
                        } catch (SQLException ignored) {
                        }
                    }
                }
                LogUtil.log("INFO", "DataSourceCache warmed up: db=" + dbKey
                        + " connections=" + conns.size());
            }, "pool-warmup-" + dbKey);

            threads.add(t);
            t.start();
        }

        // 모든 워밍업 스레드 완료 대기 (30초 타임아웃)
        for (Thread t : threads) {
            try {
                t.join(30_000);
                if (t.isAlive()) {
                    LogUtil.log("WARN", "DataSourceCache warm-up thread timed out: " + t.getName());
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                LogUtil.log("WARN", "DataSourceCache warm-up interrupted");
                break;
            }
        }

        // 워밍업 중 에러 발생 시 전파
        Exception ex = error.get();
        if (ex != null) {
            if (ex instanceof SQLException) {
                throw (SQLException) ex;
            }
            throw new SQLException("Pool warm-up failed", ex);
        }
    }

    /**
     * 모든 DataSource를 graceful하게 닫는다. Step 종료 시 반드시 호출해야 한다.
     * 활성 커넥션이 있으면 완료 대기 후 닫는다 (timeout 포함).
     * 이 메서드 호출 후에는 getConnection()을 호출할 수 없다.
     */
    @Override
    public void close() {
        for (Map.Entry<String, HikariDataSource> entry : cache.entrySet()) {
            String dbKey = entry.getKey();
            HikariDataSource ds = entry.getValue();
            try {
                gracefulClose(dbKey, ds);
            } catch (Exception e) {
                LogUtil.log("WARN", "DataSourceCache close failed: db=" + dbKey
                        + " error=" + e.getMessage());
            }
        }
        cache.clear();
    }

    /**
     * Graceful shutdown: 새 커넥션 차단 → 활성 커넥션 완료 대기 → 풀 종료
     */
    private void gracefulClose(String dbKey, HikariDataSource ds) {
        HikariPoolMXBean poolMXBean = ds.getHikariPoolMXBean();
        if (poolMXBean == null) {
            // MXBean을 못 가져오면 즉시 close
            ds.close();
            LogUtil.log("INFO", "DataSourceCache closed pool (immediate): db=" + dbKey);
            return;
        }

        // 1. 새 커넥션 할당 차단 (softEvict으로 반환 시 제거)
        poolMXBean.softEvictConnections();

        // 2. 활성 커넥션 완료 대기
        int activeCount = poolMXBean.getActiveConnections();
        if (activeCount > 0) {
            LogUtil.log("INFO", "DataSourceCache waiting for " + activeCount
                    + " active connections to complete: db=" + dbKey);
            long deadline = System.currentTimeMillis() + GRACEFUL_SHUTDOWN_TIMEOUT_MS;
            while (poolMXBean.getActiveConnections() > 0
                    && System.currentTimeMillis() < deadline) {
                try {
                    Thread.sleep(POLL_INTERVAL_MS);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    LogUtil.log("WARN", "DataSourceCache graceful wait interrupted: db=" + dbKey);
                    break;
                }
            }
            int remaining = poolMXBean.getActiveConnections();
            if (remaining > 0) {
                LogUtil.log("WARN", "DataSourceCache closing with " + remaining
                        + " active connections still running (timeout): db=" + dbKey);
            }
        }

        // 3. 풀 종료
        ds.close();
        LogUtil.log("INFO", "DataSourceCache closed pool: db=" + dbKey);
    }
}
