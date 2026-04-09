package datablocks.dlm.engine;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import datablocks.dlm.domain.MetaTableVO;
import datablocks.dlm.mapper.MetaTableMapper;
import jakarta.annotation.PostConstruct;

/**
 * PII 메타데이터 인메모리 캐시
 *
 * TBL_METATABLE에서 PII가 지정된 컬럼 정보를 메모리에 캐싱.
 * 수집된 Audit Log의 SQL 파싱 결과와 대조하여 PII 등급을 자동 부여.
 *
 * 캐시 키: "DB.OWNER.TABLE.COLUMN" (대문자)
 * 캐시 값: PiiInfo(piitype, piigrade)
 */
@Component
public class PiiMetadataCache {

    private static final Logger logger = LoggerFactory.getLogger(PiiMetadataCache.class);

    @Autowired
    private MetaTableMapper metaTableMapper;

    // key: "DB.OWNER.TABLE.COLUMN" (대문자) → value: PiiInfo
    private final ConcurrentHashMap<String, PiiInfo> cache = new ConcurrentHashMap<>();

    // 테이블별 전체 컬럼 목록 (SELECT * 확장용)
    // key: "DB.OWNER.TABLE" → value: 해당 테이블의 모든 컬럼명 Set
    private final ConcurrentHashMap<String, Set<String>> tableColumnsCache = new ConcurrentHashMap<>();

    /**
     * PII 정보 VO (불변 객체)
     */
    public static class PiiInfo {
        private final String piitype;
        private final String piigrade;

        public PiiInfo(String piitype, String piigrade) {
            this.piitype = piitype;
            this.piigrade = piigrade;
        }

        public String getPiitype() { return piitype; }
        public String getPiigrade() { return piigrade; }

        @Override
        public String toString() {
            return "PiiInfo{type=" + piitype + ", grade=" + piigrade + "}";
        }
    }

    /**
     * 서버 시작 시 캐시 로드
     */
    @PostConstruct
    public void init() {
        refresh();
    }

    /**
     * 캐시 리프레시 — 5분마다 자동 갱신
     */
    @Scheduled(fixedDelay = 300000, initialDelay = 300000) // 5분
    public void refresh() {
        try {
            List<MetaTableVO> piiColumns = metaTableMapper.selectPiiColumnsForCache();
            if (piiColumns == null || piiColumns.isEmpty()) {
                logger.info("PiiMetadataCache: No PII columns found in TBL_METATABLE");
                return;
            }

            ConcurrentHashMap<String, PiiInfo> newCache = new ConcurrentHashMap<>();
            ConcurrentHashMap<String, Set<String>> newTableColumns = new ConcurrentHashMap<>();

            for (MetaTableVO vo : piiColumns) {
                String key = buildKey(vo.getDb(), vo.getOwner(), vo.getTable_name(), vo.getColumn_name());
                newCache.put(key, new PiiInfo(vo.getPiitype(), vo.getPiigrade()));

                // 테이블별 컬럼 목록
                String tableKey = buildTableKey(vo.getDb(), vo.getOwner(), vo.getTable_name());
                newTableColumns.computeIfAbsent(tableKey, k -> ConcurrentHashMap.newKeySet())
                        .add(vo.getColumn_name().toUpperCase());
            }

            // 원자적 교체
            cache.clear();
            cache.putAll(newCache);
            tableColumnsCache.clear();
            tableColumnsCache.putAll(newTableColumns);

            logger.info("PiiMetadataCache refreshed: {} PII columns cached", newCache.size());
        } catch (Exception e) {
            logger.error("PiiMetadataCache refresh failed", e);
        }
    }

    /**
     * 컬럼의 PII 정보 조회
     *
     * @return PiiInfo 또는 null (PII 아닌 경우)
     */
    public PiiInfo lookup(String db, String owner, String table, String column) {
        if (db == null || table == null || column == null) return null;
        String key = buildKey(db, owner != null ? owner : "", table, column);
        return cache.get(key);
    }

    /**
     * 테이블에 PII 컬럼이 있는지 확인
     */
    public boolean hasPiiColumns(String db, String owner, String table) {
        String tableKey = buildTableKey(db, owner != null ? owner : "", table);
        return tableColumnsCache.containsKey(tableKey);
    }

    /**
     * SELECT * 확장 — 테이블의 PII 컬럼 목록 반환
     *
     * @return 해당 테이블의 PII 컬럼명 Set (없으면 빈 Set)
     */
    public Set<String> getPiiColumnsForTable(String db, String owner, String table) {
        String tableKey = buildTableKey(db, owner != null ? owner : "", table);
        Set<String> cols = tableColumnsCache.get(tableKey);
        return cols != null ? cols : Set.of();
    }

    /**
     * 접근한 컬럼 목록에서 최고 PII 등급 반환
     *
     * PII 등급: "1" > "2" > "3" (숫자가 작을수록 높은 등급)
     *
     * @param db DB명
     * @param owner 스키마명
     * @param tableColumns 테이블→컬럼 매핑 (SqlColumnExtractor 결과)
     * @return 최고 등급 문자열 (예: "1") 또는 null
     */
    public String getHighestGrade(String db, String owner, Map<String, Set<String>> tableColumns) {
        String highestGrade = null;

        for (Map.Entry<String, Set<String>> entry : tableColumns.entrySet()) {
            String table = entry.getKey();
            Set<String> columns = entry.getValue();

            // SELECT * 처리 — PII 컬럼으로 확장
            Set<String> effectiveColumns = columns;
            if (columns.contains("*")) {
                effectiveColumns = getPiiColumnsForTable(db, owner, table);
            }

            for (String col : effectiveColumns) {
                PiiInfo pii = lookup(db, owner, table, col);
                if (pii != null && pii.getPiigrade() != null) {
                    if (highestGrade == null || pii.getPiigrade().compareTo(highestGrade) < 0) {
                        highestGrade = pii.getPiigrade();
                    }
                }
            }
        }

        return highestGrade;
    }

    /**
     * 현재 캐시 크기
     */
    public int size() {
        return cache.size();
    }

    // ── 내부 유틸 ──────────────────────────────────────

    private static String buildKey(String db, String owner, String table, String column) {
        return (db + "." + owner + "." + table + "." + column).toUpperCase();
    }

    private static String buildTableKey(String db, String owner, String table) {
        return (db + "." + owner + "." + table).toUpperCase();
    }
}
