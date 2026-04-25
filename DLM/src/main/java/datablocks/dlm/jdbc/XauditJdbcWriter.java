package datablocks.dlm.jdbc;

import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.locks.ReentrantLock;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import datablocks.dlm.domain.AccessLogVO;

/**
 * EXTERNAL 모드 — {@link XauditDataSourceHolder} 의 별도 DB 로 AccessLog 를 수동 JDBC 배치 INSERT.
 *
 * <p>저장 대상 (Phase V2):
 *   · TBL_ACCESS_LOG        (Master, 29 컬럼, 고정 길이)
 *   · TBL_ACCESS_LOG_DETAIL (Sidecar, 11 컬럼, TEXT/가변)
 *
 * <p>해시체인: AccessLogService.computeHash() 와 동일 규약
 *   {@code SHA256(userAccount + accessTime + actionType + targetTable + prevHash)}
 *
 * <p>무결성: {@link #chainLock} 로 "이전 hash 조회 → 새 hash 계산 → INSERT" 직렬화.
 * 트랜잭션: 배치마다 setAutoCommit(false) → commit / rollback.
 */
@Component
public class XauditJdbcWriter {

    private static final Logger log = LoggerFactory.getLogger(XauditJdbcWriter.class);
    private static final int BATCH_SIZE = 500;
    private static final DateTimeFormatter TS_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

    @Autowired
    private XauditDataSourceHolder holder;

    private final ReentrantLock chainLock = new ReentrantLock();

    public ReentrantLock getChainLock() { return chainLock; }

    /** 단건 INSERT — {@link #insertUnified(List)} 를 싱글턴 리스트로 래핑. */
    public int insertOne(AccessLogVO vo) throws SQLException {
        if (vo == null) return 0;
        return insertUnified(java.util.Collections.singletonList(vo));
    }

    /** 통합 INSERT — AccessLogVO 를 Master + Sidecar(hasDetail()) 로 라우팅. */
    public int insertUnified(List<AccessLogVO> logs) throws SQLException {
        if (logs == null || logs.isEmpty()) return 0;
        int total = 0;
        chainLock.lock();
        try {
            for (int i = 0; i < logs.size(); i += BATCH_SIZE) {
                int end = Math.min(logs.size(), i + BATCH_SIZE);
                total += insertChunk(logs.subList(i, end));
            }
            return total;
        } finally {
            chainLock.unlock();
        }
    }

    private int insertChunk(List<AccessLogVO> chunk) throws SQLException {
        String schema = holder.getSchema();
        String master = XauditSqlDialect.qualify(schema, holder.getAccessTable());
        String detail = XauditSqlDialect.qualify(schema, holder.getDetailTable());

        String masterSql = "INSERT INTO " + master + " ("
                + "source_system_id, user_account, user_name, department, access_time, client_ip, session_id,"
                + "action_type, target_db, target_schema, target_table, affected_rows, result_code,"
                + "pii_type_codes, pii_grade, pii_detected_flag,"
                + "collect_type, access_channel,"
                + "hash_value, prev_hash, collected_at, partition_key,"
                + "req_id, service_name, menu_id, uri, http_method, http_status, duration_ms"
                + ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

        String detailSql = "INSERT INTO " + detail + " ("
                + "log_id, access_time, req_id, sql_id, sql_text, bind_params,"
                + "search_condition, target_columns, full_uri, user_agent, error_message, collected_at"
                + ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";

        Connection c = holder.getConnection();
        boolean prevAuto = c.getAutoCommit();
        c.setAutoCommit(false);
        try {
            // 1) 이전 hash 획득
            String prevHash = queryLastHash(c, master);
            if (prevHash == null) prevHash = "GENESIS";

            // 2) 해시 계산 + master INSERT (generated keys 수집)
            long[] generatedIds = new long[chunk.size()];
            try (PreparedStatement ps = c.prepareStatement(masterSql, Statement.RETURN_GENERATED_KEYS)) {
                for (AccessLogVO a : chunk) {
                    a.setPrevHash(prevHash);
                    String h = computeHash(a);
                    a.setHashValue(h);
                    prevHash = h;
                    bindMaster(ps, a);
                    ps.addBatch();
                }
                ps.executeBatch();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    int idx = 0;
                    while (rs.next() && idx < generatedIds.length) {
                        generatedIds[idx++] = rs.getLong(1);
                    }
                }
            }
            for (int k = 0; k < chunk.size(); k++) {
                if (generatedIds[k] > 0) chunk.get(k).setLogId(generatedIds[k]);
            }

            // 3) Sidecar INSERT — hasDetail() 이고 logId 확보된 경우만
            try (PreparedStatement psd = c.prepareStatement(detailSql)) {
                int detailCount = 0;
                for (AccessLogVO a : chunk) {
                    if (!a.hasDetail()) continue;
                    if (a.getLogId() == null || a.getLogId() <= 0) continue;
                    bindDetail(psd, a);
                    psd.addBatch();
                    detailCount++;
                }
                if (detailCount > 0) psd.executeBatch();
            }

            c.commit();
            return chunk.size();
        } catch (SQLException e) {
            try { c.rollback(); } catch (SQLException ignore) {}
            log.warn("[X-Audit] external unified insert failed (chunk={}): {}", chunk.size(), e.toString());
            throw e;
        } finally {
            try { c.setAutoCommit(prevAuto); } catch (SQLException ignore) {}
            try { c.close(); } catch (SQLException ignore) {}
        }
    }

    private String queryLastHash(Connection c, String fqMaster) throws SQLException {
        String sql = XauditSqlDialect.lastHashSql(holder.getDbType(), fqMaster);
        try (PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getString(1) : null;
        }
    }

    /** AccessLogService.computeHash() 와 동일 — 단일 체인 유지. */
    private String computeHash(AccessLogVO a) {
        try {
            String input = nz(a.getUserAccount()) + nz(a.getAccessTime())
                    + nz(a.getActionType()) + nz(a.getTargetTable()) + nz(a.getPrevHash());
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bs = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(64);
            for (byte b : bs) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            log.warn("[X-Audit] hash calc failed: {}", e.toString());
            return "ERROR";
        }
    }

    private void bindMaster(PreparedStatement ps, AccessLogVO a) throws SQLException {
        int i = 1;
        ps.setString(i++, a.getSourceSystemId());
        ps.setString(i++, a.getUserAccount());
        ps.setString(i++, a.getUserName());
        ps.setString(i++, a.getDepartment());
        setTimestamp(ps, i++, a.getAccessTime());
        ps.setString(i++, a.getClientIp());
        ps.setString(i++, a.getSessionId());
        ps.setString(i++, a.getActionType());
        ps.setString(i++, a.getTargetDb());
        ps.setString(i++, a.getTargetSchema());
        ps.setString(i++, a.getTargetTable());
        setInteger(ps, i++, a.getAffectedRows());
        ps.setString(i++, a.getResultCode());
        ps.setString(i++, a.getPiiTypeCodes());
        ps.setString(i++, a.getPiiGrade());
        ps.setString(i++, resolvePiiFlag(a));
        ps.setString(i++, a.getCollectType());
        ps.setString(i++, a.getAccessChannel());
        ps.setString(i++, a.getHashValue());
        ps.setString(i++, a.getPrevHash());
        ps.setTimestamp(i++, new Timestamp(System.currentTimeMillis()));
        ps.setString(i++, a.getPartitionKey());
        ps.setString(i++, a.getReqId());
        ps.setString(i++, a.getServiceName());
        ps.setString(i++, a.getMenuId());
        ps.setString(i++, a.getUri());
        ps.setString(i++, a.getHttpMethod());
        setInteger(ps, i++, a.getHttpStatus());
        setLong(ps, i++, a.getDurationMs());
    }

    private void bindDetail(PreparedStatement ps, AccessLogVO a) throws SQLException {
        int i = 1;
        ps.setLong(i++, a.getLogId());
        setTimestamp(ps, i++, a.getAccessTime());
        ps.setString(i++, a.getReqId());
        ps.setString(i++, a.getSqlId());
        setText(ps, i++, a.getSqlText());
        setText(ps, i++, a.getBindParams());
        setText(ps, i++, a.getSearchCondition());
        setText(ps, i++, a.getTargetColumns());
        ps.setString(i++, a.getFullUri());
        ps.setString(i++, a.getUserAgent());
        ps.setString(i++, a.getErrorMessage());
        ps.setTimestamp(i++, new Timestamp(System.currentTimeMillis()));
    }

    private static String resolvePiiFlag(AccessLogVO a) {
        if (a.getPiiDetectedFlag() != null && !a.getPiiDetectedFlag().isEmpty()) return a.getPiiDetectedFlag();
        return (a.getPiiTypeCodes() == null || a.getPiiTypeCodes().isEmpty()) ? "N" : "Y";
    }

    private void setText(PreparedStatement ps, int idx, String value) throws SQLException {
        if (value == null) { ps.setNull(idx, Types.VARCHAR); return; }
        if (value.length() > 2000) ps.setCharacterStream(idx, new StringReader(value), value.length());
        else                       ps.setString(idx, value);
    }

    private void setInteger(PreparedStatement ps, int idx, Integer value) throws SQLException {
        if (value == null) ps.setNull(idx, Types.INTEGER);
        else               ps.setInt(idx, value);
    }

    private void setLong(PreparedStatement ps, int idx, Long value) throws SQLException {
        if (value == null) ps.setNull(idx, Types.BIGINT);
        else               ps.setLong(idx, value);
    }

    private void setTimestamp(PreparedStatement ps, int idx, String value) throws SQLException {
        if (value == null || value.isEmpty()) { ps.setNull(idx, Types.TIMESTAMP); return; }
        try {
            LocalDateTime ldt = LocalDateTime.parse(value, TS_FMT);
            ps.setTimestamp(idx, Timestamp.valueOf(ldt));
        } catch (Exception e) {
            ps.setString(idx, value);
        }
    }

    private static String nz(String s) { return s == null ? "" : s; }
}
