-- ============================================================
-- Archive Naming Config
-- 아카이브 스키마 네이밍 설정
-- ============================================================
-- TBL_PIICONFIG에 패턴 ID만 설정하면 됨 (별도 테이블 불필요)
--
-- PII 지원 패턴 (언더스코어 없음):
--   PIIOWNER       -> PIICUSTOMER
--   PIIDBOWNER     -> PIIARCDBCUSTOMER
--   OWNERPII       -> CUSTOMERPII
--   DBOWNERPII     -> ARCDBCUSTOMERPII
--
-- PII 지원 패턴 (언더스코어 있음):
--   PII_OWNER      -> PII_CUSTOMER
--   PII_DB_OWNER   -> PII_ARCDB_CUSTOMER
--   OWNER_PII      -> CUSTOMER_PII
--   DB_OWNER_PII   -> ARCDB_CUSTOMER_PII
--
-- ILM 지원 패턴 (언더스코어 없음):
--   ILMOWNER       -> ILMCUSTOMER
--   ILMDBOWNER     -> ILMARCDBCUSTOMER
--   OWNERILM       -> CUSTOMERILM
--   DBOWNERILM     -> ARCDBCUSTOMERILM
--
-- ILM 지원 패턴 (언더스코어 있음):
--   ILM_OWNER      -> ILM_CUSTOMER
--   ILM_DB_OWNER   -> ILM_ARCDB_CUSTOMER
--   OWNER_ILM      -> CUSTOMER_ILM
--   DB_OWNER_ILM   -> ARCDB_CUSTOMER_ILM
-- ============================================================

-- ============================================================
-- 1. 개인정보 파기 분리보관 설정 (PII)
-- ============================================================
INSERT INTO COTDL.TBL_PIICONFIG (cfgkey, value, comments)
VALUES ('ARCHIVE_SCHEMA_NAMING_PII', 'PIIOWNER', '개인정보 파기 분리보관 스키마 네이밍 패턴')
ON DUPLICATE KEY UPDATE comments = '개인정보 파기 분리보관 스키마 네이밍 패턴';

-- ============================================================
-- 2. ILM 아카이빙 설정
-- ============================================================
INSERT INTO COTDL.TBL_PIICONFIG (cfgkey, value, comments)
VALUES ('ARCHIVE_SCHEMA_NAMING_ILM', 'ILMOWNER', 'ILM 아카이빙 스키마 네이밍 패턴')
ON DUPLICATE KEY UPDATE comments = 'ILM 아카이빙 스키마 네이밍 패턴';


-- ============================================================
-- PII 패턴 변경 예시 (언더스코어 없음)
-- ============================================================

-- PIIOWNER → PIICUSTOMER (기본값)
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'PIIOWNER' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_PII';

-- PIIDBOWNER → PIIARCDBCUSTOMER
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'PIIDBOWNER' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_PII';

-- OWNERPII → CUSTOMERPII
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'OWNERPII' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_PII';

-- DBOWNERPII → ARCDBCUSTOMERPII
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'DBOWNERPII' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_PII';


-- ============================================================
-- PII 패턴 변경 예시 (언더스코어 있음)
-- ============================================================

-- PII_OWNER → PII_CUSTOMER
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'PII_OWNER' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_PII';

-- PII_DB_OWNER → PII_ARCDB_CUSTOMER
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'PII_DB_OWNER' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_PII';

-- OWNER_PII → CUSTOMER_PII
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'OWNER_PII' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_PII';

-- DB_OWNER_PII → ARCDB_CUSTOMER_PII
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'DB_OWNER_PII' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_PII';


-- ============================================================
-- ILM 패턴 변경 예시 (언더스코어 없음)
-- ============================================================

-- ILMOWNER → ILMCUSTOMER (기본값)
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'ILMOWNER' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_ILM';

-- ILMDBOWNER → ILMARCDBCUSTOMER
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'ILMDBOWNER' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_ILM';

-- OWNERILM → CUSTOMERILM
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'OWNERILM' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_ILM';

-- DBOWNERILM → ARCDBCUSTOMERILM
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'DBOWNERILM' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_ILM';


-- ============================================================
-- ILM 패턴 변경 예시 (언더스코어 있음)
-- ============================================================

-- ILM_OWNER → ILM_CUSTOMER
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'ILM_OWNER' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_ILM';

-- ILM_DB_OWNER → ILM_ARCDB_CUSTOMER
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'ILM_DB_OWNER' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_ILM';

-- OWNER_ILM → CUSTOMER_ILM
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'OWNER_ILM' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_ILM';

-- DB_OWNER_ILM → ARCDB_CUSTOMER_ILM
-- UPDATE COTDL.TBL_PIICONFIG SET value = 'DB_OWNER_ILM' WHERE cfgkey = 'ARCHIVE_SCHEMA_NAMING_ILM';


-- ============================================================
-- 현재 설정 확인
-- ============================================================
-- SELECT * FROM COTDL.TBL_PIICONFIG WHERE cfgkey LIKE 'ARCHIVE_SCHEMA_NAMING_%';

