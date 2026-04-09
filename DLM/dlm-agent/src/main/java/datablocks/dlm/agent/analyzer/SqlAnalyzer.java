package datablocks.dlm.agent.analyzer;

import datablocks.dlm.agent.model.AccessLogEntry;
import net.sf.jsqlparser.parser.CCJSqlParserUtil;
import net.sf.jsqlparser.statement.Statement;
import net.sf.jsqlparser.statement.delete.Delete;
import net.sf.jsqlparser.statement.insert.Insert;
import net.sf.jsqlparser.statement.select.*;
import net.sf.jsqlparser.statement.update.Update;
import net.sf.jsqlparser.statement.update.UpdateSet;
import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.schema.Column;
import net.sf.jsqlparser.schema.Table;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 경량 SQL 파서 — 기존 SqlColumnExtractor 로직 기반.
 * Agent 내에서 테이블/컬럼 추출 및 PII 정책 대조.
 */
public class SqlAnalyzer {

    // SQL 파싱 결과 LRU 캐시 (동일 SQL 반복 시 재사용)
    private static final int CACHE_SIZE = 1000;
    private static final Map<String, Map<String, Set<String>>> PARSE_CACHE =
            Collections.synchronizedMap(new LinkedHashMap<String, Map<String, Set<String>>>(CACHE_SIZE + 1, 0.75f, true) {
                @Override
                protected boolean removeEldestEntry(Map.Entry<String, Map<String, Set<String>>> eldest) {
                    return size() > CACHE_SIZE;
                }
            });

    /**
     * SQL 액션 타입 감지 (초경량 — 문자열 prefix)
     */
    public static String detectActionType(String sql) {
        if (sql == null || sql.isEmpty()) return "OTHER";
        String trimmed = sql.trim().toUpperCase();
        if (trimmed.startsWith("SELECT")) return "SELECT";
        if (trimmed.startsWith("INSERT")) return "INSERT";
        if (trimmed.startsWith("UPDATE")) return "UPDATE";
        if (trimmed.startsWith("DELETE")) return "DELETE";
        if (trimmed.startsWith("MERGE")) return "MERGE";
        if (trimmed.startsWith("CALL")) return "CALL";
        return "OTHER";
    }

    /**
     * 테이블/컬럼 추출 (JSqlParser 기반)
     * @return Map<테이블명, Set<컬럼명>>
     */
    public static Map<String, Set<String>> extractColumns(String sql) {
        if (sql == null || sql.isEmpty()) return Collections.emptyMap();

        // 캐시 확인
        Map<String, Set<String>> cached = PARSE_CACHE.get(sql);
        if (cached != null) return cached;

        Map<String, Set<String>> result = new HashMap<>();
        try {
            Statement stmt = CCJSqlParserUtil.parse(sql);

            if (stmt instanceof Select) {
                extractFromSelect((Select) stmt, result);
            } else if (stmt instanceof Insert) {
                extractFromInsert((Insert) stmt, result);
            } else if (stmt instanceof Update) {
                extractFromUpdate((Update) stmt, result);
            } else if (stmt instanceof Delete) {
                extractFromDelete((Delete) stmt, result);
            }
        } catch (Exception e) {
            // JSqlParser 실패 시 regex로 테이블명만 추출
            extractTablesRegex(sql, result);
        }

        PARSE_CACHE.put(sql, result);
        return result;
    }

    /**
     * PII 정보 보강 — PiiPolicyCache와 대조
     */
    public static void enrichPiiInfo(AccessLogEntry entry) {
        Map<String, Set<String>> tableColumns = extractColumns(entry.getSql());
        PiiPolicyCache cache = PiiPolicyCache.getInstance();

        if (cache == null || tableColumns.isEmpty()) {
            if (!tableColumns.isEmpty()) {
                entry.setTargetTable(String.join(", ", tableColumns.keySet()));
            }
            return;
        }

        List<String> piiColumns = new ArrayList<>();
        List<String> piiTypes = new ArrayList<>();
        String highestGrade = null;

        for (Map.Entry<String, Set<String>> e : tableColumns.entrySet()) {
            String table = e.getKey();
            for (String col : e.getValue()) {
                PiiPolicyCache.PiiInfo pii = cache.lookup(table, col);
                if (pii != null) {
                    piiColumns.add(table + "." + col);
                    piiTypes.add(pii.getPiiType());
                    if (highestGrade == null || pii.getPiiGrade().compareTo(highestGrade) < 0) {
                        highestGrade = pii.getPiiGrade();
                    }
                }
            }
        }

        if (!tableColumns.isEmpty()) {
            entry.setTargetTable(String.join(", ", tableColumns.keySet()));
        }
        if (!piiColumns.isEmpty()) {
            entry.setTargetColumns(String.join(", ", piiColumns));
            entry.setPiiTypeCodes(String.join(", ", piiTypes));
            entry.setPiiGrade(highestGrade);
        }
    }

    // ── SELECT ──

    private static void extractFromSelect(Select select, Map<String, Set<String>> result) {
        PlainSelect ps = select.getPlainSelect();
        if (ps == null) return;

        // 테이블 추출
        Map<String, String> aliasMap = new HashMap<>(); // alias → realName
        if (ps.getFromItem() != null) {
            extractFromItem(ps.getFromItem(), result, aliasMap);
        }
        if (ps.getJoins() != null) {
            for (Join join : ps.getJoins()) {
                if (join.getFromItem() != null) {
                    extractFromItem(join.getFromItem(), result, aliasMap);
                }
            }
        }

        // 컬럼 추출
        if (ps.getSelectItems() != null) {
            for (SelectItem<?> item : ps.getSelectItems()) {
                if (item.getExpression() instanceof AllColumns) {
                    // SELECT * — 모든 테이블에 "ALL_COLUMNS" 마커
                    for (String table : result.keySet()) {
                        result.get(table).add("ALL_COLUMNS");
                    }
                } else if (item.getExpression() instanceof AllTableColumns) {
                    AllTableColumns atc = (AllTableColumns) item.getExpression();
                    String tableName = resolveAlias(atc.getTable().getName(), aliasMap);
                    result.computeIfAbsent(tableName, k -> new HashSet<>()).add("ALL_COLUMNS");
                } else if (item.getExpression() instanceof Column) {
                    Column col = (Column) item.getExpression();
                    String tableName = col.getTable() != null
                            ? resolveAlias(col.getTable().getName(), aliasMap)
                            : getFirstTable(result);
                    if (tableName != null) {
                        result.computeIfAbsent(tableName, k -> new HashSet<>())
                                .add(col.getColumnName().toUpperCase());
                    }
                }
            }
        }
    }

    // ── INSERT ──

    private static void extractFromInsert(Insert insert, Map<String, Set<String>> result) {
        if (insert.getTable() != null) {
            String tableName = insert.getTable().getName().toUpperCase();
            Set<String> cols = result.computeIfAbsent(tableName, k -> new HashSet<>());
            if (insert.getColumns() != null) {
                for (Column col : insert.getColumns()) {
                    cols.add(col.getColumnName().toUpperCase());
                }
            }
        }
    }

    // ── UPDATE ──

    private static void extractFromUpdate(Update update, Map<String, Set<String>> result) {
        if (update.getTable() != null) {
            String tableName = update.getTable().getName().toUpperCase();
            Set<String> cols = result.computeIfAbsent(tableName, k -> new HashSet<>());
            if (update.getUpdateSets() != null) {
                for (UpdateSet us : update.getUpdateSets()) {
                    if (us.getColumns() != null) {
                        for (Column col : us.getColumns()) {
                            cols.add(col.getColumnName().toUpperCase());
                        }
                    }
                }
            }
        }
    }

    // ── DELETE ──

    private static void extractFromDelete(Delete delete, Map<String, Set<String>> result) {
        if (delete.getTable() != null) {
            String tableName = delete.getTable().getName().toUpperCase();
            result.computeIfAbsent(tableName, k -> new HashSet<>());
        }
    }

    // ── Helper ──

    private static void extractFromItem(FromItem fromItem, Map<String, Set<String>> result,
                                         Map<String, String> aliasMap) {
        if (fromItem instanceof Table) {
            Table table = (Table) fromItem;
            String name = table.getName().toUpperCase();
            result.computeIfAbsent(name, k -> new HashSet<>());
            if (table.getAlias() != null) {
                aliasMap.put(table.getAlias().getName().toUpperCase(), name);
            }
        }
    }

    private static String resolveAlias(String name, Map<String, String> aliasMap) {
        if (name == null) return null;
        String upper = name.toUpperCase();
        return aliasMap.getOrDefault(upper, upper);
    }

    private static String getFirstTable(Map<String, Set<String>> result) {
        return result.isEmpty() ? null : result.keySet().iterator().next();
    }

    /**
     * JSqlParser 실패 시 regex로 테이블명 추출 (폴백)
     */
    private static void extractTablesRegex(String sql, Map<String, Set<String>> result) {
        String upper = sql.toUpperCase();
        // FROM / JOIN / UPDATE / INTO 뒤의 테이블명 추출
        String[] keywords = {"FROM", "JOIN", "UPDATE", "INTO"};
        for (String kw : keywords) {
            int idx = 0;
            while ((idx = upper.indexOf(kw, idx)) >= 0) {
                idx += kw.length();
                // 공백 스킵
                while (idx < upper.length() && upper.charAt(idx) == ' ') idx++;
                // 테이블명 추출
                StringBuilder sb = new StringBuilder();
                while (idx < upper.length() && isTableNameChar(upper.charAt(idx))) {
                    sb.append(upper.charAt(idx));
                    idx++;
                }
                String tableName = sb.toString().trim();
                if (!tableName.isEmpty() && !isKeyword(tableName)) {
                    result.computeIfAbsent(tableName, k -> new HashSet<>());
                }
            }
        }
    }

    private static boolean isTableNameChar(char c) {
        return Character.isLetterOrDigit(c) || c == '_' || c == '.';
    }

    private static boolean isKeyword(String word) {
        Set<String> keywords = new HashSet<>(Arrays.asList(
                "SELECT", "WHERE", "SET", "VALUES", "AND", "OR", "ON",
                "LEFT", "RIGHT", "INNER", "OUTER", "CROSS", "NATURAL",
                "ORDER", "GROUP", "HAVING", "LIMIT", "OFFSET",
                "AS", "IN", "NOT", "NULL", "IS", "LIKE", "BETWEEN",
                "EXISTS", "ALL", "ANY", "SOME", "CASE", "WHEN", "THEN", "ELSE", "END"
        ));
        return keywords.contains(word);
    }
}
