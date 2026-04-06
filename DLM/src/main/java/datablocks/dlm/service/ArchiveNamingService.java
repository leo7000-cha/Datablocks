package datablocks.dlm.service;

/**
 * Archive Naming Service
 * 아카이브 스키마 네이밍 서비스
 *
 * TBL_PIICONFIG에서 설정값 조회:
 *   - ARCHIVE_SCHEMA_NAMING_PII: 개인정보 파기 분리보관 (기본값: PIIOWNER)
 *   - ARCHIVE_SCHEMA_NAMING_ILM: ILM 아카이빙 (기본값: ILMOWNER)
 *
 * PII 지원 패턴 (언더스코어 없음):
 *   PIIOWNER       -> PIICUSTOMER
 *   PIIDBOWNER     -> PIIARCDBCUSTOMER
 *   OWNERPII       -> CUSTOMERPII
 *   DBOWNERPII     -> ARCDBCUSTOMERPII
 *
 * PII 지원 패턴 (언더스코어 있음):
 *   PII_OWNER      -> PII_CUSTOMER
 *   PII_DB_OWNER   -> PII_ARCDB_CUSTOMER
 *   OWNER_PII      -> CUSTOMER_PII
 *   DB_OWNER_PII   -> ARCDB_CUSTOMER_PII
 *
 * ILM 지원 패턴 (언더스코어 없음):
 *   ILMOWNER       -> ILMCUSTOMER
 *   ILMDBOWNER     -> ILMARCDBCUSTOMER
 *   OWNERILM       -> CUSTOMERILM
 *   DBOWNERILM     -> ARCDBCUSTOMERILM
 *
 * ILM 지원 패턴 (언더스코어 있음):
 *   ILM_OWNER      -> ILM_CUSTOMER
 *   ILM_DB_OWNER   -> ILM_ARCDB_CUSTOMER
 *   OWNER_ILM      -> CUSTOMER_ILM
 *   DB_OWNER_ILM   -> ARCDB_CUSTOMER_ILM
 *
 * 사용법:
 *   archiveNamingService.getArchiveSchemaName("PII", db, owner);
 *   archiveNamingService.getArchiveSchemaName("ILM", db, owner);
 */
public interface ArchiveNamingService {

    /** Config Type 상수 */
    String CONFIG_TYPE_PII = "PII";
    String CONFIG_TYPE_ILM = "ILM";

    /** ILM Steptype 상수 */
    String STEPTYPE_EXE_ILM = "EXE_ILM";

    /**
     * steptype에 따라 configType 결정
     * EXE_ILM이면 ILM, 그 외는 PII
     */
    static String getConfigType(String steptype) {
        return STEPTYPE_EXE_ILM.equals(steptype) ? CONFIG_TYPE_ILM : CONFIG_TYPE_PII;
    }

    /**
     * 아카이브 스키마명 생성
     *
     * @param configType 설정 타입 (PII, ILM)
     * @param db         데이터베이스명
     * @param owner      원본 스키마/오너명
     * @return 변환된 아카이브 스키마명
     */
    String getArchiveSchemaName(String configType, String db, String owner);

    /**
     * 아카이브 테이블 전체 경로 생성
     *
     * @param configType 설정 타입 (PII, ILM)
     * @param db         데이터베이스명
     * @param owner      원본 스키마/오너명
     * @param tableName  테이블명
     * @return "스키마.테이블" 형태
     */
    String getArchiveTablePath(String configType, String db, String owner, String tableName);

    /**
     * SQL용 스키마명 생성 (따옴표 포함)
     *
     * @param configType 설정 타입 (PII, ILM)
     * @param db         데이터베이스명
     * @param owner      원본 스키마/오너명
     * @param withQuotes 따옴표 포함 여부
     * @return 스키마명
     */
    String getArchiveSchemaNameForSql(String configType, String db, String owner, boolean withQuotes);

    /**
     * 현재 사이트 설정 패턴 ID 조회
     *
     * @param configType 설정 타입 (PII, ILM)
     * @return 패턴 ID (PIIOWNER, PII_OWNER, ILMOWNER 등)
     */
    String getSiteConfigId(String configType);

    /**
     * 설정 캐시 갱신 (TBL_PIICONFIG 변경 시 호출)
     */
    void refreshConfig();

    // ============================================================
    // 패턴 정보 추출 메소드 (XML 쿼리용)
    // ============================================================

    /**
     * 패턴이 Prefix 타입인지 확인
     * Prefix: PIIOWNER, PII_OWNER, PIIDBOWNER, PII_DB_OWNER, ILMOWNER, ILM_OWNER, ILMDBOWNER, ILM_DB_OWNER
     * Suffix: OWNERPII, OWNER_PII, DBOWNERPII, DB_OWNER_PII, OWNERILM, OWNER_ILM, DBOWNERILM, DB_OWNER_ILM
     *
     * @param configType 설정 타입 (PII, ILM)
     * @return true면 Prefix 패턴, false면 Suffix 패턴
     */
    boolean isPrefix(String configType);

    /**
     * Prefix 문자열 반환 (Prefix 패턴용)
     * 예: PIIOWNER -> "PII", PII_OWNER -> "PII_", ILMOWNER -> "ILM", ILM_OWNER -> "ILM_"
     *
     * @param configType 설정 타입 (PII, ILM)
     * @return Prefix 문자열 (Suffix 패턴이면 빈 문자열)
     */
    String getPrefix(String configType);

    /**
     * Suffix 문자열 반환 (Suffix 패턴용)
     * 예: OWNERPII -> "PII", OWNER_PII -> "_PII", OWNERILM -> "ILM", OWNER_ILM -> "_ILM"
     *
     * @param configType 설정 타입 (PII, ILM)
     * @return Suffix 문자열 (Prefix 패턴이면 빈 문자열)
     */
    String getSuffix(String configType);

    /**
     * 아카이브 테이블의 추가 컬럼 수 반환
     * PII 분리보관 테이블에는 5개의 추가 컬럼이 있음
     * (PII_ORDER_ID, PII_BASE_DATE, PII_CUST_ID, PII_JOB_ID, PII_DESTRUCT_DATE)
     *
     * @return 추가 컬럼 수 (현재 5)
     */
    default int getArchiveExtraColumnCount() {
        return 5;
    }

}
