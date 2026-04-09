package datablocks.dlm.engine;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.parser.CCJSqlParserUtil;
import net.sf.jsqlparser.schema.Column;
import net.sf.jsqlparser.schema.Table;
import net.sf.jsqlparser.statement.Statement;
import net.sf.jsqlparser.statement.delete.Delete;
import net.sf.jsqlparser.statement.insert.Insert;
import net.sf.jsqlparser.statement.select.*;
import net.sf.jsqlparser.statement.update.Update;
import net.sf.jsqlparser.statement.update.UpdateSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * SQL 파싱 엔진 — SQL_TEXT에서 테이블/컬럼 참조를 추출
 *
 * 수집된 Audit Log의 SQL을 파싱하여 어떤 테이블의 어떤 컬럼에 접근했는지 추출.
 * PiiMetadataCache와 연동하여 개인정보 등급을 자동 부여하는 기반.
 */
public class SqlColumnExtractor {

    private static final Logger logger = LoggerFactory.getLogger(SqlColumnExtractor.class);

    // 테이블 별칭 → 실제 테이블명 매핑 (FROM, JOIN 절 파싱)
    // regex 폴백용 패턴
    private static final Pattern TABLE_PATTERN = Pattern.compile(
            "(?:FROM|JOIN|INTO|UPDATE)\\s+(?:[\\w]+\\.)?([\\w]+)",
            Pattern.CASE_INSENSITIVE
    );

    private SqlColumnExtractor() {
        // utility class
    }

    /**
     * SQL에서 참조된 테이블/컬럼 쌍 추출
     *
     * @param sql SQL 문자열
     * @return Map(테이블명 → 컬럼명 Set). 테이블/컬럼명은 대문자.
     *   예: {"ACTEUR": ["COL6","COL7"], "ACTCONTACT": ["ACTID","PHONE"]}
     *   SELECT * 인 경우: {"ACTEUR": ["*"]}
     */
    public static Map<String, Set<String>> extractColumns(String sql) {
        if (sql == null || sql.trim().isEmpty()) {
            return Collections.emptyMap();
        }

        try {
            Statement stmt = CCJSqlParserUtil.parse(sql);

            if (stmt instanceof Select) {
                return extractFromSelect((Select) stmt);
            } else if (stmt instanceof Insert) {
                return extractFromInsert((Insert) stmt);
            } else if (stmt instanceof Update) {
                return extractFromUpdate((Update) stmt);
            } else if (stmt instanceof Delete) {
                return extractFromDelete((Delete) stmt);
            }
        } catch (Exception e) {
            logger.debug("JSqlParser failed, falling back to regex: {}", e.getMessage());
        }

        // 폴백: regex로 테이블명만 추출
        return extractTablesByRegex(sql);
    }

    /**
     * SQL에서 참조된 테이블명만 추출
     */
    public static Set<String> extractTables(String sql) {
        return extractColumns(sql).keySet();
    }

    /**
     * SQL 액션 타입 감지 (SELECT/INSERT/UPDATE/DELETE)
     */
    public static String detectActionType(String sql) {
        if (sql == null || sql.trim().isEmpty()) return "OTHER";
        String trimmed = sql.trim().toUpperCase();
        if (trimmed.startsWith("SELECT")) return "SELECT";
        if (trimmed.startsWith("INSERT")) return "INSERT";
        if (trimmed.startsWith("UPDATE")) return "UPDATE";
        if (trimmed.startsWith("DELETE")) return "DELETE";
        return "OTHER";
    }

    // ── SELECT 문 처리 ──────────────────────────────────

    private static Map<String, Set<String>> extractFromSelect(Select select) {
        Map<String, Set<String>> result = new LinkedHashMap<>();
        Map<String, String> aliasMap = new LinkedHashMap<>();

        // PlainSelect 또는 SetOperation (UNION 등)
        if (select instanceof PlainSelect) {
            extractFromPlainSelect((PlainSelect) select, result, aliasMap);
        } else if (select instanceof SetOperationList) {
            SetOperationList setOp = (SetOperationList) select;
            for (Select sel : setOp.getSelects()) {
                if (sel instanceof PlainSelect) {
                    extractFromPlainSelect((PlainSelect) sel, result, aliasMap);
                }
            }
        }

        return result;
    }

    private static void extractFromPlainSelect(PlainSelect ps,
                                                Map<String, Set<String>> result,
                                                Map<String, String> aliasMap) {
        // 1. FROM 절에서 테이블/별칭 수집
        collectTablesFromFrom(ps.getFromItem(), aliasMap, result);

        // 2. JOIN 절에서 테이블/별칭 수집
        if (ps.getJoins() != null) {
            for (Join join : ps.getJoins()) {
                collectTablesFromFrom(join.getFromItem(), aliasMap, result);
                // JOIN ON 조건의 컬럼도 수집
                if (join.getOnExpressions() != null) {
                    for (Expression onExpr : join.getOnExpressions()) {
                        collectColumnsFromExpression(onExpr, aliasMap, result);
                    }
                }
            }
        }

        // 3. SELECT 항목에서 컬럼 수집
        if (ps.getSelectItems() != null) {
            for (SelectItem<?> item : ps.getSelectItems()) {
                if (item.getExpression() instanceof AllColumns) {
                    // SELECT * → 모든 테이블에 "*" 마커
                    for (String table : aliasMap.values()) {
                        result.computeIfAbsent(table.toUpperCase(), k -> new LinkedHashSet<>()).add("*");
                    }
                    // 별칭 없는 테이블도 포함
                    if (aliasMap.isEmpty()) {
                        for (String table : result.keySet()) {
                            result.get(table).add("*");
                        }
                    }
                } else if (item.getExpression() instanceof AllTableColumns) {
                    AllTableColumns atc = (AllTableColumns) item.getExpression();
                    String tableName = resolveAlias(atc.getTable().getName(), aliasMap);
                    result.computeIfAbsent(tableName.toUpperCase(), k -> new LinkedHashSet<>()).add("*");
                } else if (item.getExpression() instanceof Column) {
                    Column col = (Column) item.getExpression();
                    addColumn(col, aliasMap, result);
                } else {
                    // 함수 호출, 서브쿼리 등 — 내부 컬럼 참조 수집
                    collectColumnsFromExpression(item.getExpression(), aliasMap, result);
                }
            }
        }

        // 4. WHERE 절에서 컬럼 수집
        if (ps.getWhere() != null) {
            collectColumnsFromExpression(ps.getWhere(), aliasMap, result);
        }

        // 5. GROUP BY / HAVING / ORDER BY
        if (ps.getGroupBy() != null && ps.getGroupBy().getGroupByExpressionList() != null) {
            for (Object expr : ps.getGroupBy().getGroupByExpressionList()) {
                if (expr instanceof Expression) {
                    collectColumnsFromExpression((Expression) expr, aliasMap, result);
                }
            }
        }
        if (ps.getHaving() != null) {
            collectColumnsFromExpression(ps.getHaving(), aliasMap, result);
        }
    }

    // ── INSERT 문 처리 ──────────────────────────────────

    private static Map<String, Set<String>> extractFromInsert(Insert insert) {
        Map<String, Set<String>> result = new LinkedHashMap<>();
        String tableName = insert.getTable().getName().toUpperCase();

        Set<String> columns = new LinkedHashSet<>();
        if (insert.getColumns() != null) {
            for (Column col : insert.getColumns()) {
                columns.add(col.getColumnName().toUpperCase());
            }
        }
        if (columns.isEmpty()) {
            columns.add("*");
        }
        result.put(tableName, columns);

        // INSERT ... SELECT 의 SELECT 부분도 파싱
        if (insert.getSelect() != null) {
            Map<String, Set<String>> selectResult = extractFromSelect(insert.getSelect());
            mergeResults(result, selectResult);
        }

        return result;
    }

    // ── UPDATE 문 처리 ──────────────────────────────────

    private static Map<String, Set<String>> extractFromUpdate(Update update) {
        Map<String, Set<String>> result = new LinkedHashMap<>();
        Map<String, String> aliasMap = new LinkedHashMap<>();

        String tableName = update.getTable().getName().toUpperCase();
        result.computeIfAbsent(tableName, k -> new LinkedHashSet<>());

        if (update.getTable().getAlias() != null) {
            aliasMap.put(update.getTable().getAlias().getName().toUpperCase(), tableName);
        }

        // SET 절의 컬럼
        if (update.getUpdateSets() != null) {
            for (UpdateSet us : update.getUpdateSets()) {
                if (us.getColumns() != null) {
                    for (Column col : us.getColumns()) {
                        addColumn(col, aliasMap, result);
                    }
                }
            }
        }

        // JOIN
        if (update.getJoins() != null) {
            for (Join join : update.getJoins()) {
                collectTablesFromFrom(join.getFromItem(), aliasMap, result);
            }
        }

        // WHERE
        if (update.getWhere() != null) {
            collectColumnsFromExpression(update.getWhere(), aliasMap, result);
        }

        return result;
    }

    // ── DELETE 문 처리 ──────────────────────────────────

    private static Map<String, Set<String>> extractFromDelete(Delete delete) {
        Map<String, Set<String>> result = new LinkedHashMap<>();
        Map<String, String> aliasMap = new LinkedHashMap<>();

        String tableName = delete.getTable().getName().toUpperCase();
        result.computeIfAbsent(tableName, k -> new LinkedHashSet<>());

        if (delete.getTable().getAlias() != null) {
            aliasMap.put(delete.getTable().getAlias().getName().toUpperCase(), tableName);
        }

        // WHERE
        if (delete.getWhere() != null) {
            collectColumnsFromExpression(delete.getWhere(), aliasMap, result);
        }

        return result;
    }

    // ── 공통 유틸리티 ───────────────────────────────────

    /**
     * FROM 절 아이템에서 테이블명/별칭 수집
     */
    private static void collectTablesFromFrom(FromItem fromItem,
                                               Map<String, String> aliasMap,
                                               Map<String, Set<String>> result) {
        if (fromItem == null) return;

        if (fromItem instanceof Table) {
            Table table = (Table) fromItem;
            String tableName = table.getName().toUpperCase();
            result.computeIfAbsent(tableName, k -> new LinkedHashSet<>());

            if (table.getAlias() != null) {
                aliasMap.put(table.getAlias().getName().toUpperCase(), tableName);
            }
        } else if (fromItem instanceof ParenthesedSelect) {
            // 서브쿼리 — 내부 파싱
            ParenthesedSelect subSelect = (ParenthesedSelect) fromItem;
            Map<String, Set<String>> subResult = extractFromSelect(subSelect);
            mergeResults(result, subResult);

            // 서브쿼리 별칭은 실제 테이블이 아니므로 aliasMap에 추가하지 않음
        }
    }

    /**
     * Expression에서 컬럼 참조를 재귀적으로 수집
     */
    private static void collectColumnsFromExpression(Expression expr,
                                                      Map<String, String> aliasMap,
                                                      Map<String, Set<String>> result) {
        if (expr == null) return;

        if (expr instanceof Column) {
            addColumn((Column) expr, aliasMap, result);
        } else if (expr instanceof ParenthesedSelect) {
            // 서브쿼리
            ParenthesedSelect subSelect = (ParenthesedSelect) expr;
            Map<String, Set<String>> subResult = extractFromSelect(subSelect);
            mergeResults(result, subResult);
        } else {
            // BinaryExpression, Function 등 — toString()으로 내부 Column 참조 찾기
            // JSqlParser의 visitor 패턴 대신 간단한 접근
            try {
                expr.accept(new net.sf.jsqlparser.expression.ExpressionVisitorAdapter<Void>() {
                    @Override
                    public <S> Void visit(Column column, S context) {
                        addColumn(column, aliasMap, result);
                        return null;
                    }

                    @Override
                    public <S> Void visit(ParenthesedSelect subSelect, S context) {
                        Map<String, Set<String>> subResult = extractFromSelect(subSelect);
                        mergeResults(result, subResult);
                        return null;
                    }
                });
            } catch (Exception e) {
                // visitor 실패 시 무시
                logger.trace("Expression visitor failed: {}", e.getMessage());
            }
        }
    }

    /**
     * 컬럼을 result에 추가 (별칭 해소 포함)
     */
    private static void addColumn(Column col, Map<String, String> aliasMap,
                                   Map<String, Set<String>> result) {
        String colName = col.getColumnName().toUpperCase();
        String tableName = null;

        if (col.getTable() != null && col.getTable().getName() != null) {
            tableName = resolveAlias(col.getTable().getName(), aliasMap);
        }

        if (tableName != null) {
            result.computeIfAbsent(tableName.toUpperCase(), k -> new LinkedHashSet<>()).add(colName);
        } else {
            // 테이블 미지정 컬럼 → 첫 번째 테이블에 추가 (단일 테이블 쿼리 대부분)
            if (!result.isEmpty()) {
                result.values().iterator().next().add(colName);
            }
        }
    }

    /**
     * 별칭 → 실제 테이블명 해소
     */
    private static String resolveAlias(String nameOrAlias, Map<String, String> aliasMap) {
        String upper = nameOrAlias.toUpperCase();
        return aliasMap.getOrDefault(upper, upper);
    }

    /**
     * 두 결과 맵 병합
     */
    private static void mergeResults(Map<String, Set<String>> target,
                                      Map<String, Set<String>> source) {
        for (Map.Entry<String, Set<String>> entry : source.entrySet()) {
            target.computeIfAbsent(entry.getKey(), k -> new LinkedHashSet<>()).addAll(entry.getValue());
        }
    }

    /**
     * Regex 폴백 — JSqlParser 실패 시 테이블명만 추출
     */
    private static Map<String, Set<String>> extractTablesByRegex(String sql) {
        Map<String, Set<String>> result = new LinkedHashMap<>();
        Matcher matcher = TABLE_PATTERN.matcher(sql);
        while (matcher.find()) {
            String tableName = matcher.group(1).toUpperCase();
            // 시스템 키워드 제외
            if (!isReservedKeyword(tableName)) {
                result.computeIfAbsent(tableName, k -> new LinkedHashSet<>()).add("*");
            }
        }
        return result;
    }

    private static boolean isReservedKeyword(String name) {
        Set<String> keywords = Set.of("SELECT", "FROM", "WHERE", "SET", "VALUES",
                "INTO", "TABLE", "INDEX", "VIEW", "DUAL", "NULL");
        return keywords.contains(name.toUpperCase());
    }
}
