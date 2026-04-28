-- ==============================================================================
-- DLM 스키마 비교 도구 (Schema Diff)
-- 고객 DB(COTDL) vs 기준 DDL(COTDL_REF) 자동 비교 → 패치 SQL 생성
-- ==============================================================================
--
-- ■ 사용법 (2단계)
--
--   [STEP 1] 기준 스키마를 임시 DB에 로드
--     실행: SCHEMA_DIFF_SETUP.sh  (또는 아래 수동 명령)
--       mysql> CREATE DATABASE IF NOT EXISTS COTDL_REF;
--       $ sed 's/`COTDL`/`COTDL_REF`/g' 10_DDL_MASTER_CORE.sql | mysql -u root -p COTDL_REF
--
--   [STEP 2] 이 파일 실행 → 결과가 패치 SQL
--       $ mysql -u root -p -N < SCHEMA_DIFF.sql
--       또는 DBeaver/HeidiSQL 등에서 실행
--
--   [STEP 3] 결과 확인 후 필요한 것만 실행
--
--   [STEP 4] 정리
--       mysql> DROP DATABASE IF EXISTS COTDL_REF;
--
-- ■ 비교 항목
--   1. 누락 테이블         → CREATE TABLE 문 생성
--   2. 누락 컬럼           → ALTER TABLE ADD COLUMN 문 생성
--   3. 컬럼 타입/길이 변경  → ALTER TABLE MODIFY COLUMN 문 생성
--   4. 불필요 테이블/컬럼   → 참고용 안내 (자동 DROP 안 함)
--
-- ==============================================================================


-- --------------------------------------------------------------
-- [1] 누락 테이블: COTDL_REF에는 있지만 COTDL에 없는 테이블
--     → 10_DDL_MASTER_CORE.sql 에서 해당 CREATE TABLE 찾아서 실행
-- --------------------------------------------------------------
SELECT CONCAT('-- ★ [신규 테이블] ', ref.TABLE_NAME, ' — COTDL에 없음. DDL에서 CREATE TABLE 실행 필요') AS patch_sql
FROM INFORMATION_SCHEMA.TABLES ref
LEFT JOIN INFORMATION_SCHEMA.TABLES cur
    ON cur.TABLE_SCHEMA = 'COTDL' AND cur.TABLE_NAME = ref.TABLE_NAME
WHERE ref.TABLE_SCHEMA = 'COTDL_REF'
  AND cur.TABLE_NAME IS NULL
ORDER BY ref.TABLE_NAME;


-- --------------------------------------------------------------
-- [2] 누락 컬럼: COTDL_REF에는 있지만 COTDL에 없는 컬럼
--     → ALTER TABLE ADD COLUMN 문 자동 생성
-- --------------------------------------------------------------
SELECT CONCAT(
    'ALTER TABLE `COTDL`.`', ref.TABLE_NAME, '` ADD COLUMN `', ref.COLUMN_NAME, '` ',
    ref.COLUMN_TYPE,
    CASE WHEN ref.IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE '' END,
    CASE
        WHEN ref.COLUMN_DEFAULT IS NULL AND ref.IS_NULLABLE = 'YES' THEN ' DEFAULT NULL'
        WHEN ref.COLUMN_DEFAULT IS NOT NULL THEN CONCAT(' DEFAULT ',
            CASE
                WHEN ref.COLUMN_DEFAULT = 'CURRENT_TIMESTAMP' THEN 'CURRENT_TIMESTAMP'
                WHEN ref.COLUMN_DEFAULT = 'current_timestamp()' THEN 'CURRENT_TIMESTAMP'
                WHEN ref.DATA_TYPE IN ('int','bigint','tinyint','smallint','decimal','float','double') THEN ref.COLUMN_DEFAULT
                ELSE CONCAT('''', ref.COLUMN_DEFAULT, '''')
            END)
        ELSE ''
    END,
    CASE WHEN ref.EXTRA = 'auto_increment' THEN ' AUTO_INCREMENT' ELSE '' END,
    CASE WHEN ref.COLUMN_COMMENT != '' THEN CONCAT(' COMMENT ''', REPLACE(ref.COLUMN_COMMENT, '''', ''''''), '''') ELSE '' END,
    ';',
    '  -- 추가: ', ref.TABLE_NAME, '.', ref.COLUMN_NAME
) AS patch_sql
FROM INFORMATION_SCHEMA.COLUMNS ref
JOIN INFORMATION_SCHEMA.TABLES cur_tbl
    ON cur_tbl.TABLE_SCHEMA = 'COTDL' AND cur_tbl.TABLE_NAME = ref.TABLE_NAME
LEFT JOIN INFORMATION_SCHEMA.COLUMNS cur
    ON cur.TABLE_SCHEMA = 'COTDL'
   AND cur.TABLE_NAME   = ref.TABLE_NAME
   AND cur.COLUMN_NAME  = ref.COLUMN_NAME
WHERE ref.TABLE_SCHEMA = 'COTDL_REF'
  AND cur.COLUMN_NAME IS NULL
ORDER BY ref.TABLE_NAME, ref.ORDINAL_POSITION;


-- --------------------------------------------------------------
-- [3] 컬럼 타입/길이 변경: 같은 컬럼인데 타입이 다른 것
--     → ALTER TABLE MODIFY COLUMN 문 자동 생성
-- --------------------------------------------------------------
SELECT CONCAT(
    'ALTER TABLE `COTDL`.`', ref.TABLE_NAME, '` MODIFY COLUMN `', ref.COLUMN_NAME, '` ',
    ref.COLUMN_TYPE,
    CASE WHEN ref.IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE '' END,
    CASE
        WHEN ref.COLUMN_DEFAULT IS NULL AND ref.IS_NULLABLE = 'YES' THEN ' DEFAULT NULL'
        WHEN ref.COLUMN_DEFAULT IS NOT NULL THEN CONCAT(' DEFAULT ',
            CASE
                WHEN ref.COLUMN_DEFAULT = 'CURRENT_TIMESTAMP' THEN 'CURRENT_TIMESTAMP'
                WHEN ref.COLUMN_DEFAULT = 'current_timestamp()' THEN 'CURRENT_TIMESTAMP'
                WHEN ref.DATA_TYPE IN ('int','bigint','tinyint','smallint','decimal','float','double') THEN ref.COLUMN_DEFAULT
                ELSE CONCAT('''', ref.COLUMN_DEFAULT, '''')
            END)
        ELSE ''
    END,
    ';',
    '  -- 변경: ', cur.COLUMN_TYPE, ' → ', ref.COLUMN_TYPE,
    ' (', ref.TABLE_NAME, '.', ref.COLUMN_NAME, ')'
) AS patch_sql
FROM INFORMATION_SCHEMA.COLUMNS ref
JOIN INFORMATION_SCHEMA.COLUMNS cur
    ON cur.TABLE_SCHEMA = 'COTDL'
   AND cur.TABLE_NAME   = ref.TABLE_NAME
   AND cur.COLUMN_NAME  = ref.COLUMN_NAME
WHERE ref.TABLE_SCHEMA = 'COTDL_REF'
  AND ref.COLUMN_TYPE != cur.COLUMN_TYPE
  AND NOT (ref.DATA_TYPE = cur.DATA_TYPE
           AND ref.DATA_TYPE IN ('int','bigint','tinyint','smallint','mediumint'))
ORDER BY ref.TABLE_NAME, ref.ORDINAL_POSITION;


-- --------------------------------------------------------------
-- [4] 참고: COTDL에는 있지만 COTDL_REF(기준 DDL)에 없는 테이블
--     → 고객사 커스텀이거나 폐기 대상. 자동 DROP 안 함
-- --------------------------------------------------------------
SELECT CONCAT('-- ※ [참고] ', cur.TABLE_NAME, ' — 기준 DDL에 없는 테이블 (고객 커스텀 또는 폐기 대상)') AS info
FROM INFORMATION_SCHEMA.TABLES cur
LEFT JOIN INFORMATION_SCHEMA.TABLES ref
    ON ref.TABLE_SCHEMA = 'COTDL_REF' AND ref.TABLE_NAME = cur.TABLE_NAME
WHERE cur.TABLE_SCHEMA = 'COTDL'
  AND ref.TABLE_NAME IS NULL
ORDER BY cur.TABLE_NAME;


-- --------------------------------------------------------------
-- [5] 참고: COTDL에는 있지만 COTDL_REF에 없는 컬럼
--     → 고객사 커스텀이거나 폐기 대상. 자동 DROP 안 함
-- --------------------------------------------------------------
SELECT CONCAT('-- ※ [참고] ', cur.TABLE_NAME, '.', cur.COLUMN_NAME, ' (', cur.COLUMN_TYPE, ') — 기준 DDL에 없는 컬럼') AS info
FROM INFORMATION_SCHEMA.COLUMNS cur
JOIN INFORMATION_SCHEMA.TABLES ref_tbl
    ON ref_tbl.TABLE_SCHEMA = 'COTDL_REF' AND ref_tbl.TABLE_NAME = cur.TABLE_NAME
LEFT JOIN INFORMATION_SCHEMA.COLUMNS ref
    ON ref.TABLE_SCHEMA = 'COTDL_REF'
   AND ref.TABLE_NAME   = cur.TABLE_NAME
   AND ref.COLUMN_NAME  = cur.COLUMN_NAME
WHERE cur.TABLE_SCHEMA = 'COTDL'
  AND ref.COLUMN_NAME IS NULL
ORDER BY cur.TABLE_NAME, cur.ORDINAL_POSITION;
