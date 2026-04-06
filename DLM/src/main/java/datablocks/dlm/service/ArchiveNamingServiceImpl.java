package datablocks.dlm.service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import jakarta.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import datablocks.dlm.domain.PiiConfigVO;
import datablocks.dlm.mapper.PiiConfigMapper;
import lombok.AllArgsConstructor;

/**
 * Archive Naming Service Implementation
 * 아카이브 스키마 네이밍 서비스 구현체
 *
 * TBL_PIICONFIG에서 설정값 조회하여 패턴 적용
 * 코드에서 직접 패턴 처리 (별도 테이블 불필요)
 */
@Service
@AllArgsConstructor
public class ArchiveNamingServiceImpl implements ArchiveNamingService {

    private static final Logger logger = LoggerFactory.getLogger(ArchiveNamingServiceImpl.class);

    // Config 키 상수
    private static final String PII_CONFIG_KEY = "ARCHIVE_SCHEMA_NAMING_PII";
    private static final String ILM_CONFIG_KEY = "ARCHIVE_SCHEMA_NAMING_ILM";

    // 기본값
    private static final String DEFAULT_PII_CONFIG_ID = "PIIOWNER";
    private static final String DEFAULT_ILM_CONFIG_ID = "ILMOWNER";

    @Autowired
    private PiiConfigMapper piiConfigMapper;

    // 사이트 설정 캐시 (configType -> configId)
    private final Map<String, String> configCache = new ConcurrentHashMap<>();

    // ============================================================
    // 스키마명 생성 메소드 (핵심 기능)
    // ============================================================

    @Override
    public String getArchiveSchemaName(String configType, String db, String owner) {
        String configId = getSiteConfigId(configType);
        return buildSchemaName(configId, db, owner);
    }

    @Override
    public String getArchiveTablePath(String configType, String db, String owner, String tableName) {
        return getArchiveSchemaName(configType, db, owner) + "." + tableName;
    }

    @Override
    public String getArchiveSchemaNameForSql(String configType, String db, String owner, boolean withQuotes) {
        String schemaName = getArchiveSchemaName(configType, db, owner);
        return withQuotes ? "'" + schemaName + "'" : schemaName;
    }

    // ============================================================
    // 패턴 처리 로직 (코드에서 직접 처리)
    // ============================================================

    /**
     * configId에 따른 스키마명 생성
     *
     * PII 지원 패턴:
     *   PIIOWNER       -> PII + OWNER           (PIICUSTOMER)
     *   PII_OWNER      -> PII + _ + OWNER       (PII_CUSTOMER)
     *   PII_DB_OWNER   -> PII + _ + DB + _ + OWNER (PII_ARCDB_CUSTOMER)
     *   OWNER_PII      -> OWNER + _ + PII       (CUSTOMER_PII)
     *   DB_OWNER_PII   -> DB + _ + OWNER + _ + PII (ARCDB_CUSTOMER_PII)
     *
     * ILM 지원 패턴:
     *   ILMOWNER       -> ILM + OWNER           (ILMCUSTOMER)
     *   ILM_OWNER      -> ILM + _ + OWNER       (ILM_CUSTOMER)
     *   ILM_DB_OWNER   -> ILM + _ + DB + _ + OWNER (ILM_ARCDB_CUSTOMER)
     *   OWNER_ILM      -> OWNER + _ + ILM       (CUSTOMER_ILM)
     *   DB_OWNER_ILM   -> DB + _ + OWNER + _ + ILM (ARCDB_CUSTOMER_ILM)
     */
    private String buildSchemaName(String configId, String db, String owner) {
        if (configId == null) {
            configId = DEFAULT_PII_CONFIG_ID;
        }

        String upperOwner = (owner != null) ? owner.toUpperCase() : "";
        String upperDb = (db != null) ? db.toUpperCase() : "";

        switch (configId.toUpperCase()) {
            // ========== PII 패턴 (언더스코어 없음) ==========
            case "PIIOWNER":
                return "PII" + upperOwner;

            case "PIIDBOWNER":
                return "PII" + upperDb + upperOwner;

            case "OWNERPII":
                return upperOwner + "PII";

            case "DBOWNERPII":
                return upperDb + upperOwner + "PII";

            // ========== PII 패턴 (언더스코어 있음) ==========
            case "PII_OWNER":
                return "PII_" + upperOwner;

            case "PII_DB_OWNER":
                return "PII_" + upperDb + "_" + upperOwner;

            case "OWNER_PII":
                return upperOwner + "_PII";

            case "DB_OWNER_PII":
                return upperDb + "_" + upperOwner + "_PII";

            // ========== ILM 패턴 (언더스코어 없음) ==========
            case "ILMOWNER":
                return "ILM" + upperOwner;

            case "ILMDBOWNER":
                return "ILM" + upperDb + upperOwner;

            case "OWNERILM":
                return upperOwner + "ILM";

            case "DBOWNERILM":
                return upperDb + upperOwner + "ILM";

            // ========== ILM 패턴 (언더스코어 있음) ==========
            case "ILM_OWNER":
                return "ILM_" + upperOwner;

            case "ILM_DB_OWNER":
                return "ILM_" + upperDb + "_" + upperOwner;

            case "OWNER_ILM":
                return upperOwner + "_ILM";

            case "DB_OWNER_ILM":
                return upperDb + "_" + upperOwner + "_ILM";

            // 기본값 (알 수 없는 패턴)
            default:
                logger.warn("Unknown archive naming pattern: {}. Using default PIIOWNER.", configId);
                return "PII" + upperOwner;
        }
    }

    // ============================================================
    // 사이트 설정 조회 (TBL_PIICONFIG)
    // ============================================================

    @Override
    @PostConstruct
    public void refreshConfig() {
        configCache.clear();
        // 캐시 미리 로드
        getSiteConfigId(CONFIG_TYPE_PII);
        getSiteConfigId(CONFIG_TYPE_ILM);
    }

    @Override
    public String getSiteConfigId(String configType) {
        if (configType == null) {
            configType = CONFIG_TYPE_PII;
        }

        String upperType = configType.toUpperCase();

        // 캐시에 있으면 반환
        if (configCache.containsKey(upperType)) {
            return configCache.get(upperType);
        }

        // DB에서 조회
        String configKey;
        String defaultValue;

        if (CONFIG_TYPE_ILM.equals(upperType)) {
            configKey = ILM_CONFIG_KEY;
            defaultValue = DEFAULT_ILM_CONFIG_ID;
        } else {
            configKey = PII_CONFIG_KEY;
            defaultValue = DEFAULT_PII_CONFIG_ID;
        }

        String configId = defaultValue;
        try {
            PiiConfigVO configVO = piiConfigMapper.read(configKey);
            if (configVO != null && configVO.getValue() != null && !configVO.getValue().trim().isEmpty()) {
                configId = configVO.getValue().trim().toUpperCase();
                logger.info("Archive naming pattern loaded from TBL_PIICONFIG [{}]: {}", configKey, configId);
            } else {
                logger.info("Archive naming pattern not found in TBL_PIICONFIG [{}]. Using default: {}", configKey, configId);
            }
        } catch (Exception e) {
            logger.warn("Failed to load archive naming pattern [{}]. Using default: {}. Error: {}", configKey, configId, e.getMessage());
        }

        configCache.put(upperType, configId);
        return configId;
    }

    // ============================================================
    // 패턴 정보 추출 메소드 (XML 쿼리용)
    // ============================================================

    @Override
    public boolean isPrefix(String configType) {
        String configId = getSiteConfigId(configType);
        String upper = configId.toUpperCase();

        // Suffix 패턴 체크 (OWNER가 앞에 오는 패턴)
        if (upper.startsWith("OWNER") || upper.startsWith("DB")) {
            // DB_OWNER_PII, DBOWNERPII, OWNER_PII, OWNERPII, DB_OWNER_ILM, DBOWNERILM, OWNER_ILM, OWNERILM
            return false;
        }
        // 나머지는 Prefix 패턴 (PII/ILM이 앞에 오는 패턴)
        return true;
    }

    @Override
    public String getPrefix(String configType) {
        if (!isPrefix(configType)) {
            return "";
        }

        String configId = getSiteConfigId(configType);
        String upper = configId.toUpperCase();

        // 언더스코어 있는 패턴 체크
        if (upper.contains("_")) {
            // PII_OWNER, PII_DB_OWNER -> "PII_"
            // ILM_OWNER, ILM_DB_OWNER -> "ILM_"
            if (upper.startsWith("PII_")) {
                return "PII_";
            } else if (upper.startsWith("ILM_")) {
                return "ILM_";
            }
        }

        // 언더스코어 없는 패턴
        // PIIOWNER, PIIDBOWNER -> "PII"
        // ILMOWNER, ILMDBOWNER -> "ILM"
        if (upper.startsWith("PII")) {
            return "PII";
        } else if (upper.startsWith("ILM")) {
            return "ILM";
        }

        // 기본값
        return "PII";
    }

    @Override
    public String getSuffix(String configType) {
        if (isPrefix(configType)) {
            return "";
        }

        String configId = getSiteConfigId(configType);
        String upper = configId.toUpperCase();

        // 언더스코어 있는 패턴 체크
        if (upper.contains("_")) {
            // OWNER_PII, DB_OWNER_PII -> "_PII"
            // OWNER_ILM, DB_OWNER_ILM -> "_ILM"
            if (upper.endsWith("_PII")) {
                return "_PII";
            } else if (upper.endsWith("_ILM")) {
                return "_ILM";
            }
        }

        // 언더스코어 없는 패턴
        // OWNERPII, DBOWNERPII -> "PII"
        // OWNERILM, DBOWNERILM -> "ILM"
        if (upper.endsWith("PII")) {
            return "PII";
        } else if (upper.endsWith("ILM")) {
            return "ILM";
        }

        // 기본값
        return "PII";
    }

}
