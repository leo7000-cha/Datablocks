package datablocks.dlm.engine;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import datablocks.dlm.domain.AccessLogCollectStatusVO;
import datablocks.dlm.domain.AccessLogSourceVO;
import datablocks.dlm.domain.AccessLogVO;
import datablocks.dlm.engine.PiiMetadataCache.PiiInfo;
import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.mapper.AccessLogMapper;
import datablocks.dlm.service.AccessLogService;
import datablocks.dlm.service.PiiDatabaseService;
import datablocks.dlm.domain.PiiDatabaseVO;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;

/**
 * Access Log Collector Implementation
 * 대상 DB Audit Log를 조회하여 접속기록을 수집하는 엔진
 */
@Component
public class AccessLogCollectorImpl implements AccessLogCollector {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogCollectorImpl.class);

    @Autowired
    private AccessLogService accessLogService;

    @Autowired
    private AccessLogMapper accessLogMapper;

    @Autowired
    private PiiDatabaseService databaseService;

    @Autowired
    private PiiMetadataCache piiMetadataCache;

    private final Map<String, Boolean> collectingMap = new ConcurrentHashMap<>();

    @Override
    public int collect(AccessLogSourceVO source) {
        LogUtil.log("INFO", "AccessLogCollector collect: " + source.getSourceName());

        int collectedCount = 0;
        String startTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        try {
            // 1. 마지막 수집 오프셋 조회
            AccessLogCollectStatusVO lastStatus = accessLogMapper.selectLatestCollectStatus(source.getSourceId());
            String lastOffset = lastStatus != null ? lastStatus.getLastOffset() : null;

            // 2. 대상 DB 접속
            PiiDatabaseVO dbInfo = databaseService.get(source.getDbName());
            if (dbInfo == null) {
                LogUtil.log("ERROR", "Database not found: " + source.getDbName());
                recordCollectStatus(source.getSourceId(), startTime, 0, "FAIL", "Database not found: " + source.getDbName());
                return 0;
            }

            AES256Util aes = new AES256Util();
            String decryptedPwd = aes.decrypt(dbInfo.getPwd());

            Connection conn = ConnectionProvider.getConnection(
                    dbInfo.getDbtype(), dbInfo.getHostname(), dbInfo.getPort(),
                    dbInfo.getId_type(), dbInfo.getId(), dbInfo.getDb(),
                    dbInfo.getDbuser(), decryptedPwd);

            try {
                // 3. DB별 Audit Log 조회
                List<AccessLogVO> logs = queryAuditLog(conn, dbInfo.getDbtype(), source, lastOffset);
                collectedCount = logs.size();

                // 4. 배치 INSERT
                if (!logs.isEmpty()) {
                    accessLogService.registerAccessLogBatch(logs);
                }

                // 5. 수집 상태 업데이트
                String newOffset = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                recordCollectStatus(source.getSourceId(), startTime, collectedCount, "SUCCESS", null);
                accessLogMapper.updateSourceCollectInfo(source.getSourceId(), newOffset, collectedCount);
                accessLogMapper.updateSourceStatus(source.getSourceId(), "RUNNING", null);

                LogUtil.log("INFO", "Collected " + collectedCount + " records from " + source.getSourceName());

            } finally {
                try { conn.close(); } catch (Exception e) { /* ignore */ }
            }

        } catch (Exception e) {
            logger.error("Collection failed for source: " + source.getSourceName(), e);
            recordCollectStatus(source.getSourceId(), startTime, 0, "FAIL", e.getMessage());
            accessLogMapper.updateSourceStatus(source.getSourceId(), "ERROR", e.getMessage());
        }

        return collectedCount;
    }

    @Override
    public void startCollection(String sourceId) {
        collectingMap.put(sourceId, true);
        accessLogMapper.updateSourceStatus(sourceId, "RUNNING", null);
        LogUtil.log("INFO", "Collection started for source: " + sourceId);
    }

    @Override
    public void stopCollection(String sourceId) {
        collectingMap.put(sourceId, false);
        accessLogMapper.updateSourceStatus(sourceId, "STOPPED", null);
        LogUtil.log("INFO", "Collection stopped for source: " + sourceId);
    }

    @Override
    public boolean isCollecting(String sourceId) {
        return Boolean.TRUE.equals(collectingMap.get(sourceId));
    }

    /**
     * DB별 Audit Log 조회 (DB 유형에 따른 분기)
     */
    private List<AccessLogVO> queryAuditLog(Connection conn, String dbType, AccessLogSourceVO source, String lastOffset) {
        List<AccessLogVO> logs = new ArrayList<>();

        try {
            String sql;
            if ("ORACLE".equalsIgnoreCase(dbType)) {
                sql = buildOracleAuditQuery(lastOffset, source);
            } else if ("MARIADB".equalsIgnoreCase(dbType) || "MYSQL".equalsIgnoreCase(dbType)) {
                sql = buildMariaDbAuditQuery(lastOffset, source);
            } else {
                LogUtil.log("WARN", "Unsupported DB type for audit log: " + dbType);
                return logs;
            }

            Statement stmt = conn.createStatement();
            stmt.setFetchSize(1000);
            ResultSet rs = stmt.executeQuery(sql);

            while (rs.next()) {
                AccessLogVO log = new AccessLogVO();
                log.setSourceSystemId(source.getSourceId());
                log.setUserAccount(rs.getString("user_account"));
                log.setAccessTime(rs.getString("access_time"));
                log.setClientIp(rs.getString("client_ip"));
                log.setActionType(rs.getString("action_type"));
                log.setTargetDb(source.getDbName());
                log.setTargetTable(rs.getString("target_table"));
                log.setSqlText(rs.getString("sql_text"));
                log.setAccessChannel("DB_DIRECT");
                log.setResultCode("SUCCESS");
                logs.add(log);
            }

            rs.close();
            stmt.close();

            // [PII 자동 분류] 수집 후 각 레코드에 PII 정보 부여
            for (AccessLogVO log : logs) {
                enrichWithPiiInfo(log, source);
            }
        } catch (Exception e) {
            logger.error("Audit log query failed", e);
        }

        return logs;
    }

    /**
     * SQL 파싱 → PII 메타데이터 매칭 → AccessLogVO에 PII 정보 자동 설정
     */
    private void enrichWithPiiInfo(AccessLogVO log, AccessLogSourceVO source) {
        if (log.getSqlText() == null || log.getSqlText().isEmpty()) return;

        try {
            // 1. SQL 파싱 → 테이블/컬럼 추출
            Map<String, Set<String>> tableColumns = SqlColumnExtractor.extractColumns(log.getSqlText());
            if (tableColumns.isEmpty()) return;

            // 2. PII 메타데이터 매칭
            String dbName = source.getDbName();
            String schema = source.getSchemaName() != null ? source.getSchemaName() : "";
            List<String> piiColumns = new ArrayList<>();
            List<String> piiTypes = new ArrayList<>();
            String highestGrade = null;

            for (Map.Entry<String, Set<String>> entry : tableColumns.entrySet()) {
                String table = entry.getKey();
                Set<String> columns = entry.getValue();

                // SELECT * → PII 컬럼으로 확장
                Set<String> effectiveColumns = columns;
                if (columns.contains("*")) {
                    effectiveColumns = piiMetadataCache.getPiiColumnsForTable(dbName, schema, table);
                    if (effectiveColumns.isEmpty()) continue;
                }

                for (String col : effectiveColumns) {
                    PiiInfo pii = piiMetadataCache.lookup(dbName, schema, table, col);
                    if (pii != null) {
                        piiColumns.add(table + "." + col);
                        piiTypes.add(pii.getPiitype());
                        if (pii.getPiigrade() != null) {
                            if (highestGrade == null || pii.getPiigrade().compareTo(highestGrade) < 0) {
                                highestGrade = pii.getPiigrade(); // "1" > "2" > "3"
                            }
                        }
                    }
                }
            }

            // 3. AccessLogVO에 PII 정보 설정
            if (!piiColumns.isEmpty()) {
                log.setTargetColumns(String.join(", ", piiColumns));
                log.setPiiTypeCodes(String.join(", ", piiTypes));
                log.setPiiGrade(highestGrade);
            }

            // 4. 테이블명 보정 (audit trail에서 못 잡은 경우)
            if ((log.getTargetTable() == null || log.getTargetTable().isEmpty())
                    && !tableColumns.isEmpty()) {
                log.setTargetTable(String.join(", ", tableColumns.keySet()));
            }

            // 5. 스키마 설정
            if (log.getTargetSchema() == null || log.getTargetSchema().isEmpty()) {
                log.setTargetSchema(schema);
            }
        } catch (Exception e) {
            // 파싱 실패 시 무시 (기존 로직 유지)
            logger.debug("SQL parsing failed for PII enrichment: {}", e.getMessage());
        }
    }

    /**
     * Oracle Unified Audit Trail 조회
     */
    private String buildOracleAuditQuery(String lastOffset, AccessLogSourceVO source) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT DBUSERNAME AS user_account, ");
        sql.append("TO_CHAR(EVENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF3') AS access_time, ");
        sql.append("USERHOST AS client_ip, ");
        sql.append("ACTION_NAME AS action_type, ");
        sql.append("OBJECT_NAME AS target_table, ");
        sql.append("SQL_TEXT AS sql_text ");
        sql.append("FROM UNIFIED_AUDIT_TRAIL ");
        sql.append("WHERE ACTION_NAME IN ('SELECT','UPDATE','DELETE','INSERT') ");
        // 시스템 계정 제외
        sql.append("AND DBUSERNAME NOT IN ('SYS','SYSTEM','DBSNMP','AUDSYS','APPQOSSYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','XDB') ");
        // 시스템 객체 제외
        sql.append("AND OBJECT_NAME IS NOT NULL ");
        sql.append("AND OBJECT_NAME NOT LIKE 'SYS_%' ");
        sql.append("AND OBJECT_NAME NOT LIKE 'X$%' ");
        sql.append("AND OBJECT_NAME NOT IN ('DUAL') ");
        // 메타데이터 조회 제외 (DBeaver, TOAD 등 도구)
        sql.append("AND (SQL_TEXT IS NULL OR ( ");
        sql.append("    SQL_TEXT NOT LIKE '%ALL_ALL_TABLES%' ");
        sql.append("    AND SQL_TEXT NOT LIKE '%ALL_OBJECTS%' ");
        sql.append("    AND SQL_TEXT NOT LIKE '%ALL_TAB_COLUMNS%' ");
        sql.append("    AND SQL_TEXT NOT LIKE '%DBA_AUDIT%' ");
        sql.append("    AND SQL_TEXT NOT LIKE '%INFORMATION_SCHEMA%' ");
        sql.append("    AND SQL_TEXT NOT LIKE '%USER_TABLES%' ");
        sql.append("    AND SQL_TEXT NOT LIKE '%USER_TAB_COLUMNS%' ");
        sql.append(")) ");
        // 제외 계정 필터
        appendExcludeAccountsCondition(sql, source, "DBUSERNAME");
        // 대상 테이블 필터
        appendTableFilterCondition(sql, source, "OBJECT_NAME");
        if (lastOffset != null) {
            sql.append("AND EVENT_TIMESTAMP > TO_TIMESTAMP('").append(lastOffset).append("', 'YYYY-MM-DD HH24:MI:SS') ");
        }
        sql.append("ORDER BY EVENT_TIMESTAMP FETCH FIRST 1000 ROWS ONLY");
        return sql.toString();
    }

    /**
     * MariaDB/MySQL General Log 조회
     */
    private String buildMariaDbAuditQuery(String lastOffset, AccessLogSourceVO source) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT user_host AS user_account, ");
        sql.append("DATE_FORMAT(event_time, '%Y-%m-%d %H:%i:%s.%f') AS access_time, ");
        sql.append("SUBSTRING_INDEX(user_host, '[', -1) AS client_ip, ");
        sql.append("CASE WHEN UPPER(argument) LIKE 'SELECT%' THEN 'SELECT' ");
        sql.append("     WHEN UPPER(argument) LIKE 'UPDATE%' THEN 'UPDATE' ");
        sql.append("     WHEN UPPER(argument) LIKE 'DELETE%' THEN 'DELETE' ");
        sql.append("     WHEN UPPER(argument) LIKE 'INSERT%' THEN 'INSERT' ");
        sql.append("     ELSE 'OTHER' END AS action_type, ");
        sql.append("'' AS target_table, ");
        sql.append("LEFT(argument, 2000) AS sql_text ");
        sql.append("FROM mysql.general_log ");
        sql.append("WHERE command_type = 'Query' ");
        sql.append("AND (UPPER(argument) LIKE 'SELECT%' OR UPPER(argument) LIKE 'UPDATE%' ");
        sql.append("     OR UPPER(argument) LIKE 'DELETE%' OR UPPER(argument) LIKE 'INSERT%') ");
        // 시스템 스키마/잡음 필터링
        sql.append("AND argument NOT LIKE '%information_schema%' ");
        sql.append("AND argument NOT LIKE '%performance_schema%' ");
        sql.append("AND user_host NOT LIKE 'root%' ");
        // 제외 계정 필터
        appendExcludeAccountsCondition(sql, source, "user_host");
        // 대상 테이블 필터 (general_log에는 argument 기반)
        appendTableFilterConditionForGeneralLog(sql, source);
        if (lastOffset != null) {
            sql.append("AND event_time > '").append(lastOffset).append("' ");
        }
        sql.append("ORDER BY event_time LIMIT 1000");
        return sql.toString();
    }

    /**
     * 제외 계정 NOT IN 조건 추가
     */
    private void appendExcludeAccountsCondition(StringBuilder sql, AccessLogSourceVO source, String columnName) {
        if (source.getExcludeAccounts() != null && !source.getExcludeAccounts().trim().isEmpty()) {
            String inClause = Arrays.stream(source.getExcludeAccounts().split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(s -> "'" + s.replace("'", "''") + "'")
                    .collect(Collectors.joining(","));
            if (!inClause.isEmpty()) {
                sql.append("AND ").append(columnName).append(" NOT IN (").append(inClause).append(") ");
            }
        }
    }

    /**
     * 대상 테이블 OBJECT_NAME 필터 조건 추가 (Oracle)
     */
    private void appendTableFilterCondition(StringBuilder sql, AccessLogSourceVO source, String columnName) {
        if (source.getTableFilter() != null && !source.getTableFilter().trim().isEmpty()) {
            List<String> tables = Arrays.stream(source.getTableFilter().split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toList());
            if (tables.size() == 1) {
                sql.append("AND ").append(columnName).append(" LIKE '%").append(tables.get(0).replace("'", "''")).append("%' ");
            } else if (tables.size() > 1) {
                String inClause = tables.stream()
                        .map(s -> "'" + s.replace("'", "''") + "'")
                        .collect(Collectors.joining(","));
                sql.append("AND ").append(columnName).append(" IN (").append(inClause).append(") ");
            }
        }
    }

    /**
     * 대상 테이블 필터 조건 추가 (MariaDB general_log — argument 기반 LIKE)
     */
    private void appendTableFilterConditionForGeneralLog(StringBuilder sql, AccessLogSourceVO source) {
        if (source.getTableFilter() != null && !source.getTableFilter().trim().isEmpty()) {
            List<String> tables = Arrays.stream(source.getTableFilter().split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toList());
            if (!tables.isEmpty()) {
                sql.append("AND (");
                for (int i = 0; i < tables.size(); i++) {
                    if (i > 0) sql.append(" OR ");
                    sql.append("argument LIKE '%").append(tables.get(i).replace("'", "''")).append("%'");
                }
                sql.append(") ");
            }
        }
    }

    /**
     * 수집 상태 기록
     */
    private void recordCollectStatus(String sourceId, String startTime, int count, String status, String errorMsg) {
        AccessLogCollectStatusVO collectStatus = new AccessLogCollectStatusVO();
        collectStatus.setSourceId(sourceId);
        collectStatus.setCollectStart(startTime);
        collectStatus.setCollectEnd(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        collectStatus.setCollectedCount(count);
        collectStatus.setStatus(status);
        collectStatus.setErrorMsg(errorMsg);
        accessLogMapper.insertCollectStatus(collectStatus);
    }
}
