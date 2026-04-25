package datablocks.dlm.jdbc;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Component;

import datablocks.dlm.domain.AccessLogVO;
import datablocks.dlm.domain.Criteria;

/**
 * 접속기록 조회 경로 — XAUDIT_DB DataSource 경유.
 *
 * <p>Master (TBL_ACCESS_LOG) + Sidecar (TBL_ACCESS_LOG_DETAIL) LEFT JOIN 기반.
 * DBMS dialect 는 {@link XauditSqlDialect} 에 위임.
 *
 * <p>이 클래스는 MyBatis Mapper 의 AccessLog 관련 SELECT 를 대체하며,
 * MyBatis XML 은 부속 테이블 (ALERT / SOURCE / CONFIG 등) 쿼리만 남긴다.
 */
@Component
public class XauditAccessLogReader {

    private static final Logger log = LoggerFactory.getLogger(XauditAccessLogReader.class);

    @Autowired
    private XauditDataSourceHolder holder;

    private JdbcTemplate jdbc;

    private JdbcTemplate jdbc() {
        if (jdbc == null) {
            jdbc = new JdbcTemplate(holder.getDataSource());
        }
        return jdbc;
    }

    // ========== Public API ==========

    public AccessLogVO selectById(Long logId) {
        if (logId == null) return null;
        String sql = XauditSqlDialect.selectByIdSql(holder.getDbType(), holder.getSchema(),
                holder.getAccessTable(), holder.getDetailTable());
        List<AccessLogVO> rs = jdbc().query(sql, ROW_MAPPER, logId);
        return rs.isEmpty() ? null : rs.get(0);
    }

    /** 동일 req_id 의 HTTP_ACCESS + SQL 행 전체 조회 (시간순). */
    public List<AccessLogVO> selectByReqId(String reqId) {
        if (reqId == null || reqId.isEmpty()) return Collections.emptyList();
        String sql = XauditSqlDialect.selectByReqIdSql(holder.getDbType(), holder.getSchema(),
                holder.getAccessTable(), holder.getDetailTable());
        try {
            return jdbc().query(sql, ROW_MAPPER, reqId);
        } catch (Exception e) {
            log.warn("[X-Audit] selectByReqId failed: {}", e.toString());
            return Collections.emptyList();
        }
    }

    public List<AccessLogVO> selectList(Criteria cri) {
        WherePart wp = buildWhere(cri);
        String sql = XauditSqlDialect.selectListSql(holder.getDbType(), holder.getSchema(),
                holder.getAccessTable(), holder.getDetailTable(),
                wp.whereClause, cri.getOffset(), cri.getAmount());
        try {
            return jdbc().query(sql, ROW_MAPPER, wp.params.toArray());
        } catch (Exception e) {
            log.warn("[X-Audit] selectList failed: {}", e.toString());
            return Collections.emptyList();
        }
    }

    public int selectTotal(Criteria cri) {
        WherePart wp = buildWhere(cri);
        String sql = XauditSqlDialect.selectTotalSql(holder.getDbType(), holder.getSchema(),
                holder.getAccessTable(), wp.whereClause);
        try {
            Integer n = jdbc().queryForObject(sql, Integer.class, wp.params.toArray());
            return n == null ? 0 : n;
        } catch (Exception e) {
            log.warn("[X-Audit] selectTotal failed: {}", e.toString());
            return 0;
        }
    }

    public String selectLastHash() {
        String fq = XauditSqlDialect.qualify(holder.getSchema(), holder.getAccessTable());
        String sql = XauditSqlDialect.lastHashSql(holder.getDbType(), fq);
        try {
            return jdbc().queryForObject(sql, String.class);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null;
        } catch (Exception e) {
            log.warn("[X-Audit] selectLastHash failed: {}", e.toString());
            return null;
        }
    }

    // ========== WHERE 동적 조건 (기존 AccessLogMapper.xml 과 동일 조건) ==========

    private WherePart buildWhere(Criteria cri) {
        WherePart wp = new WherePart();
        if (cri == null) return wp;
        StringBuilder sb = new StringBuilder();

        if (nn(cri.getSearch1())) { sb.append(" AND a.source_system_id = ?"); wp.params.add(cri.getSearch1()); }
        if (nn(cri.getSearch2())) { sb.append(" AND a.user_account LIKE ?"); wp.params.add("%" + cri.getSearch2() + "%"); }
        if (nn(cri.getSearch3())) { sb.append(" AND a.action_type = ?"); wp.params.add(cri.getSearch3()); }
        if (nn(cri.getSearch4())) { sb.append(" AND a.target_db = ?"); wp.params.add(cri.getSearch4()); }
        if (nn(cri.getSearch5())) { sb.append(" AND a.target_table LIKE ?"); wp.params.add("%" + cri.getSearch5() + "%"); }
        if (nn(cri.getSearch6())) { sb.append(" AND a.pii_grade = ?"); wp.params.add(cri.getSearch6()); }
        if (nn(cri.getSearch7())) { sb.append(" AND a.access_time >= ?"); wp.params.add(cri.getSearch7()); }
        if (nn(cri.getSearch8())) { sb.append(" AND a.access_time <= ?"); wp.params.add(cri.getSearch8()); }
        if (nn(cri.getSearch9())) { sb.append(" AND a.client_ip LIKE ?"); wp.params.add("%" + cri.getSearch9() + "%"); }
        if (nn(cri.getSearch10())) { sb.append(" AND a.result_code = ?"); wp.params.add(cri.getSearch10()); }
        if (nn(cri.getSearch11())) { sb.append(" AND a.collect_type = ?"); wp.params.add(cri.getSearch11()); }
        if (nn(cri.getKeyword())) {
            sb.append(" AND (a.user_account LIKE ? OR a.user_name LIKE ? OR a.target_table LIKE ?)");
            String kw = "%" + cri.getKeyword() + "%";
            wp.params.add(kw); wp.params.add(kw); wp.params.add(kw);
        }
        if (sb.length() > 0) {
            wp.whereClause = "WHERE " + sb.substring(5);  // 선두 " AND " 제거
        } else {
            wp.whereClause = "";
        }
        return wp;
    }

    private static boolean nn(String s) { return s != null && !s.isEmpty(); }

    private static class WherePart {
        String whereClause = "";
        List<Object> params = new ArrayList<>();
    }

    // ========== RowMapper — Master + Sidecar 컬럼을 AccessLogVO 로 매핑 ==========

    private static final RowMapper<AccessLogVO> ROW_MAPPER = (rs, i) -> {
        AccessLogVO v = new AccessLogVO();
        v.setLogId(getLong(rs, "log_id"));
        v.setSourceSystemId(rs.getString("source_system_id"));
        v.setUserAccount(rs.getString("user_account"));
        v.setUserName(rs.getString("user_name"));
        v.setDepartment(rs.getString("department"));
        v.setAccessTime(tsStr(rs, "access_time"));
        v.setClientIp(rs.getString("client_ip"));
        v.setSessionId(rs.getString("session_id"));
        v.setActionType(rs.getString("action_type"));
        v.setTargetDb(rs.getString("target_db"));
        v.setTargetSchema(rs.getString("target_schema"));
        v.setTargetTable(rs.getString("target_table"));
        v.setAffectedRows(getInteger(rs, "affected_rows"));
        v.setResultCode(rs.getString("result_code"));
        v.setPiiTypeCodes(rs.getString("pii_type_codes"));
        v.setPiiGrade(rs.getString("pii_grade"));
        v.setPiiDetectedFlag(rs.getString("pii_detected_flag"));
        v.setCollectType(rs.getString("collect_type"));
        v.setAccessChannel(rs.getString("access_channel"));
        v.setHashValue(rs.getString("hash_value"));
        v.setPrevHash(rs.getString("prev_hash"));
        v.setCollectedAt(tsStr(rs, "collected_at"));
        v.setPartitionKey(rs.getString("partition_key"));
        v.setReqId(rs.getString("req_id"));
        v.setServiceName(rs.getString("service_name"));
        v.setMenuId(rs.getString("menu_id"));
        v.setUri(rs.getString("uri"));
        v.setHttpMethod(rs.getString("http_method"));
        v.setHttpStatus(getInteger(rs, "http_status"));
        v.setDurationMs(getLong(rs, "duration_ms"));
        // Sidecar
        v.setSqlId(rs.getString("sql_id"));
        v.setSqlText(rs.getString("sql_text"));
        v.setBindParams(rs.getString("bind_params"));
        v.setSearchCondition(rs.getString("search_condition"));
        v.setTargetColumns(rs.getString("target_columns"));
        v.setFullUri(rs.getString("full_uri"));
        v.setUserAgent(rs.getString("user_agent"));
        v.setErrorMessage(rs.getString("error_message"));
        return v;
    };

    private static String tsStr(ResultSet rs, String col) throws SQLException {
        java.sql.Timestamp ts = rs.getTimestamp(col);
        return ts == null ? null : ts.toLocalDateTime().toString().replace('T', ' ');
    }

    private static Integer getInteger(ResultSet rs, String col) throws SQLException {
        int v = rs.getInt(col);
        return rs.wasNull() ? null : v;
    }

    private static Long getLong(ResultSet rs, String col) throws SQLException {
        long v = rs.getLong(col);
        return rs.wasNull() ? null : v;
    }
}
