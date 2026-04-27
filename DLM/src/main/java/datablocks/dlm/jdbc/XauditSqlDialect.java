package datablocks.dlm.jdbc;

/**
 * DBMS 별 TBL_ACCESS_LOG + TBL_ACCESS_LOG_DETAIL 접근 SQL 생성 유틸.
 *
 * <p>INSERT 는 placeholder 수가 모든 DBMS 동일. ORDER BY + LIMIT / OFFSET 형태만 DBMS 별 분기.
 */
public final class XauditSqlDialect {

    private XauditSqlDialect() {}

    /** schema 가 비어있으면 table 만, 있으면 schema.table. */
    public static String qualify(String schema, String table) {
        if (schema == null || schema.isEmpty()) return table;
        return schema + "." + table;
    }

    private static String normalize(String dbtype) {
        return dbtype == null ? "" : dbtype.trim().toUpperCase();
    }

    /** Master Lean 29 컬럼 공통 SELECT 리스트 (JOIN 별칭 a/d 사용). */
    private static final String SELECT_COLUMNS =
            "a.log_id, a.source_system_id, a.user_account, a.user_name, a.department, "
          + "a.access_time, a.client_ip, a.session_id, "
          + "a.action_type, a.target_db, a.target_schema, a.target_table, "
          + "a.affected_rows, a.result_code, "
          + "a.pii_type_codes, a.pii_grade, a.pii_detected_flag, "
          + "a.collect_type, a.access_channel, "
          + "a.hash_value, a.prev_hash, a.collected_at, a.partition_key, "
          + "a.req_id, a.service_name, a.menu_id, a.uri, a.http_method, "
          + "a.http_status, a.duration_ms, "
          + "d.sql_id, d.sql_text, d.bind_params, d.search_condition, "
          + "d.target_columns, d.full_uri, d.user_agent, d.error_message";

    // ========== 해시체인 ==========

    /** TBL_ACCESS_LOG 단일 체인의 마지막 hash_value 조회 SQL. */
    public static String lastHashSql(String dbtype, String fqMasterTable) {
        String t = normalize(dbtype);
        if ("ORACLE".equals(t) || "TIBERO".equals(t)) {
            return "SELECT hash_value FROM ("
                    + "SELECT hash_value FROM " + fqMasterTable + " ORDER BY log_id DESC"
                    + ") WHERE ROWNUM = 1";
        }
        if ("MSSQL".equals(t)) {
            return "SELECT TOP 1 hash_value FROM " + fqMasterTable + " ORDER BY log_id DESC";
        }
        if ("DB2".equals(t)) {
            return "SELECT hash_value FROM " + fqMasterTable
                    + " ORDER BY log_id DESC FETCH FIRST 1 ROWS ONLY";
        }
        // MARIADB / MYSQL / POSTGRESQL / 기타
        return "SELECT hash_value FROM " + fqMasterTable + " ORDER BY log_id DESC LIMIT 1";
    }

    // ========== SELECT ==========

    /** 단건 조회 — Master LEFT JOIN Sidecar, WHERE a.log_id = ?. */
    public static String selectByIdSql(String dbtype, String schema,
                                        String accessTable, String detailTable) {
        String fqA = qualify(schema, accessTable);
        String fqD = qualify(schema, detailTable);
        return "SELECT " + SELECT_COLUMNS
             + " FROM " + fqA + " a"
             + " LEFT JOIN " + fqD + " d"
             + "        ON a.log_id = d.log_id AND a.access_time = d.access_time"
             + " WHERE a.log_id = ?";
    }

    /**
     * 동일 요청(req_id) 내 행 전체 조회 — WAS_SDK 한 번의 HTTP 요청에 묶인
     * HTTP_ACCESS 1건 + 그 안에서 실행된 SQL N건을 시간순으로 반환.
     */
    public static String selectByReqIdSql(String dbtype, String schema,
                                           String accessTable, String detailTable) {
        String fqA = qualify(schema, accessTable);
        String fqD = qualify(schema, detailTable);
        return "SELECT " + SELECT_COLUMNS
             + " FROM " + fqA + " a"
             + " LEFT JOIN " + fqD + " d"
             + "        ON a.log_id = d.log_id AND a.access_time = d.access_time"
             + " WHERE a.req_id = ?"
             + " ORDER BY a.log_id ASC";
    }

    /**
     * 목록 조회 — 페이징 포함.
     * {@code whereClause} 는 이미 "WHERE ... " 형태이거나 빈 문자열.
     */
    public static String selectListSql(String dbtype, String schema,
                                        String accessTable, String detailTable,
                                        String whereClause, int offset, int amount) {
        String fqA = qualify(schema, accessTable);
        String fqD = qualify(schema, detailTable);
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT ").append(SELECT_COLUMNS)
          .append(" FROM ").append(fqA).append(" a")
          .append(" LEFT JOIN ").append(fqD).append(" d")
          .append("        ON a.log_id = d.log_id AND a.access_time = d.access_time")
          .append(' ').append(whereClause == null ? "" : whereClause)
          .append(" ORDER BY a.access_time DESC, a.log_id DESC")
          .append(paginationClause(dbtype, offset, amount));
        return sb.toString();
    }

    /** 총 건수 COUNT — JOIN 없이 Master 만. */
    public static String selectTotalSql(String dbtype, String schema,
                                         String accessTable, String whereClause) {
        String fqA = qualify(schema, accessTable);
        return "SELECT COUNT(*) FROM " + fqA + " a "
             + (whereClause == null ? "" : whereClause);
    }

    /** DBMS 별 페이지네이션 절. */
    private static String paginationClause(String dbtype, int offset, int amount) {
        String t = normalize(dbtype);
        if ("ORACLE".equals(t) || "TIBERO".equals(t) || "DB2".equals(t) || "MSSQL".equals(t)) {
            return " OFFSET " + offset + " ROWS FETCH NEXT " + amount + " ROWS ONLY";
        }
        if ("POSTGRESQL".equals(t)) {
            // PostgreSQL 은 콤마 문법 미지원 — 표준 LIMIT/OFFSET 분리 필요
            return " LIMIT " + amount + " OFFSET " + offset;
        }
        // MARIADB / MYSQL
        return " LIMIT " + offset + ", " + amount;
    }
}
