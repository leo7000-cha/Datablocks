-- ============================================================
-- DLM_MASTERKEY_FINDER : MasterKey 자동 탐색 및 설정
-- ============================================================
-- DLM TBL_METATABLE의 MASTERKEY/MASTERYN 컬럼을 자동으로 설정하는
-- 분석 및 업데이트 SQL 모음입니다.
--
-- [MasterKey란?]
--   DLM 파기/복원 시 고객을 식별하는 키 컬럼입니다.
--   예: 고객번호, 계좌번호, 증권번호 등
--   TBL_METATABLE.MASTERKEY에 설정되면 해당 컬럼 값 기준으로
--   파기/복원 대상 데이터를 추출합니다.
--
-- [탐색 우선순위]
--   1순위: PK 선두 컬럼 중 알려진 키 컬럼명 매칭
--   2순위: 인덱스 선두 컬럼 중 알려진 키 컬럼명 매칭
--   3순위: 컬럼명 패턴 매칭 (빈도 분석)
--   4순위: 메타시스템 정보 활용 (TBL_METASYSTEMDATA)
--
-- ============================================================
-- 사용 시 아래 변수를 치환하세요.
--
--   #{DLM_SCHEMA}    -> DLM 스키마        (기본값: COTDL)
--   #{TARGET_OWNER}  -> 분석 대상 스키마  (예: COOWNSER, CCSADM)
--   #{KEY_COLUMNS}   -> 마스터키 후보 컬럼명 목록 (사이트별 커스터마이징)
-- ============================================================



-- ################################################################
-- STEP 0. 현황 확인
-- ################################################################


-- ────────────────────────────────────────────────────────────
-- 0-1. MasterKey 설정 현황 요약
-- ────────────────────────────────────────────────────────────
SELECT
    OWNER,
    COUNT(DISTINCT TABLE_NAME)                                           AS total_tables,
    COUNT(DISTINCT CASE WHEN MASTERKEY IS NOT NULL THEN TABLE_NAME END)  AS mapped_tables,
    COUNT(DISTINCT CASE WHEN MASTERKEY IS NULL THEN TABLE_NAME END)      AS unmapped_tables,
    ROUND(COUNT(DISTINCT CASE WHEN MASTERKEY IS NOT NULL THEN TABLE_NAME END)
        * 100.0 / NULLIF(COUNT(DISTINCT TABLE_NAME), 0), 1)             AS mapped_pct
FROM #{DLM_SCHEMA}.TBL_METATABLE
GROUP BY OWNER
ORDER BY OWNER;


-- ────────────────────────────────────────────────────────────
-- 0-2. MasterKey 미설정 테이블 목록
-- ────────────────────────────────────────────────────────────
SELECT DISTINCT DB, OWNER, TABLE_NAME
FROM #{DLM_SCHEMA}.TBL_METATABLE
WHERE MASTERKEY IS NULL
ORDER BY OWNER, TABLE_NAME;


-- ────────────────────────────────────────────────────────────
-- 0-3. 현재 MasterKey로 설정된 컬럼명 빈도
-- ────────────────────────────────────────────────────────────
SELECT MASTERKEY, COUNT(DISTINCT TABLE_NAME) AS table_count
FROM #{DLM_SCHEMA}.TBL_METATABLE
WHERE MASTERKEY IS NOT NULL
GROUP BY MASTERKEY
ORDER BY table_count DESC;



-- ################################################################
-- STEP 1. MasterKey 초기화 (필요 시)
-- ################################################################
-- 주의: 기존 수동 설정값이 있으면 백업 후 실행하세요.

-- UPDATE #{DLM_SCHEMA}.TBL_METATABLE SET MASTERKEY = NULL, MASTERYN = NULL;



-- ################################################################
-- STEP 2. PK 선두 컬럼 기반 MasterKey 자동 설정 (1순위)
-- ################################################################
-- PK의 첫 번째 컬럼이 알려진 키 컬럼명과 일치하면 MASTERKEY로 설정


-- ────────────────────────────────────────────────────────────
-- 2-1. [Oracle] PK 선두 컬럼 → MasterKey 설정
-- ────────────────────────────────────────────────────────────
-- 먼저 미리보기 (SELECT)
SELECT m.OWNER, m.TABLE_NAME, m.COLUMN_NAME, '← PK 선두 매칭' AS source
FROM #{DLM_SCHEMA}.TBL_METATABLE m
WHERE m.MASTERKEY IS NULL
  AND (m.OWNER, m.TABLE_NAME, m.COLUMN_NAME) IN (
      SELECT b.OWNER, a.TABLE_NAME, b.COLUMN_NAME
      FROM ALL_CONSTRAINTS a
      JOIN ALL_CONS_COLUMNS b
          ON  a.OWNER           = b.OWNER
          AND a.CONSTRAINT_NAME = b.CONSTRAINT_NAME
      WHERE a.OWNER = '#{TARGET_OWNER}'
        AND a.CONSTRAINT_TYPE = 'P'
        AND b.POSITION = 1
        AND b.COLUMN_NAME IN (
            -- ▼▼▼ 사이트별 마스터키 후보 컬럼명을 여기에 나열 ▼▼▼
            'ACTID', 'CUSTID', 'CUST_NO', 'CSTNO',
            'LGPC_CNLT_NO', 'CDED_NO'
            -- ▲▲▲ 사이트별 커스터마이징 ▲▲▲
        )
  )
ORDER BY m.OWNER, m.TABLE_NAME;

-- 확인 후 UPDATE 실행
-- UPDATE #{DLM_SCHEMA}.TBL_METATABLE SET MASTERKEY = COLUMN_NAME
-- WHERE MASTERKEY IS NULL
--   AND (OWNER, TABLE_NAME, COLUMN_NAME) IN (
--       SELECT b.OWNER, a.TABLE_NAME, b.COLUMN_NAME
--       FROM ALL_CONSTRAINTS a
--       JOIN ALL_CONS_COLUMNS b
--           ON  a.OWNER           = b.OWNER
--           AND a.CONSTRAINT_NAME = b.CONSTRAINT_NAME
--       WHERE a.OWNER = '#{TARGET_OWNER}'
--         AND a.CONSTRAINT_TYPE = 'P'
--         AND b.POSITION = 1
--         AND b.COLUMN_NAME IN (
--             'ACTID', 'CUSTID', 'CUST_NO', 'CSTNO',
--             'LGPC_CNLT_NO', 'CDED_NO'
--         )
--   );


-- ────────────────────────────────────────────────────────────
-- 2-2. [MariaDB] PK 선두 컬럼 → MasterKey 설정
-- ────────────────────────────────────────────────────────────
SELECT m.OWNER, m.TABLE_NAME, m.COLUMN_NAME, '← PK 선두 매칭' AS source
FROM #{DLM_SCHEMA}.TBL_METATABLE m
WHERE m.MASTERKEY IS NULL
  AND (m.OWNER, m.TABLE_NAME, m.COLUMN_NAME) IN (
      SELECT kcu.TABLE_SCHEMA, kcu.TABLE_NAME, kcu.COLUMN_NAME
      FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
      WHERE kcu.TABLE_SCHEMA    = '#{TARGET_OWNER}'
        AND kcu.CONSTRAINT_NAME = 'PRIMARY'
        AND kcu.ORDINAL_POSITION = 1
        AND kcu.COLUMN_NAME IN (
            'ACTID', 'CUSTID', 'CUST_NO', 'CSTNO',
            'LGPC_CNLT_NO', 'CDED_NO'
        )
  )
ORDER BY m.OWNER, m.TABLE_NAME;



-- ################################################################
-- STEP 3. 인덱스 선두 컬럼 기반 MasterKey 설정 (2순위)
-- ################################################################
-- PK 매칭이 안 된 테이블에 대해 인덱스 선두 컬럼으로 탐색


-- ────────────────────────────────────────────────────────────
-- 3-1. [Oracle] 인덱스 선두 컬럼 → MasterKey 설정
-- ────────────────────────────────────────────────────────────
SELECT m.OWNER, m.TABLE_NAME, m.COLUMN_NAME, '← 인덱스 선두 매칭' AS source
FROM #{DLM_SCHEMA}.TBL_METATABLE m
WHERE m.MASTERKEY IS NULL
  AND (m.OWNER, m.TABLE_NAME, m.COLUMN_NAME) IN (
      SELECT INDEX_OWNER, TABLE_NAME, COLUMN_NAME
      FROM ALL_IND_COLUMNS
      WHERE INDEX_OWNER = '#{TARGET_OWNER}'
        AND COLUMN_POSITION = 1
        AND COLUMN_NAME IN (
            'ACTID', 'CUSTID', 'CUST_NO', 'CSTNO',
            'LGPC_CNLT_NO', 'CDED_NO'
        )
  )
ORDER BY m.OWNER, m.TABLE_NAME;

-- 확인 후 UPDATE 실행
-- UPDATE #{DLM_SCHEMA}.TBL_METATABLE SET MASTERKEY = COLUMN_NAME
-- WHERE MASTERKEY IS NULL
--   AND (OWNER, TABLE_NAME, COLUMN_NAME) IN (
--       SELECT INDEX_OWNER, TABLE_NAME, COLUMN_NAME
--       FROM ALL_IND_COLUMNS
--       WHERE INDEX_OWNER = '#{TARGET_OWNER}'
--         AND COLUMN_POSITION = 1
--         AND COLUMN_NAME IN (
--             'ACTID', 'CUSTID', 'CUST_NO', 'CSTNO',
--             'LGPC_CNLT_NO', 'CDED_NO'
--         )
--   );



-- ################################################################
-- STEP 4. 컬럼명 빈도 분석 (3순위 - 수동 판단 지원)
-- ################################################################
-- 아직 MasterKey가 설정되지 않은 컬럼 중 출현 빈도가 높은 컬럼을 찾아
-- 추가 마스터키 후보로 검토합니다.


-- ────────────────────────────────────────────────────────────
-- 4-1. MasterKey 미설정 컬럼의 출현 빈도 (노이즈 제외)
-- ────────────────────────────────────────────────────────────
-- 날짜(DT/DTTM), 버전(VR), 코드(CD), 번호(NO) 등 키가 아닌 컬럼 제외
SELECT
    COLUMN_NAME,
    COUNT(DISTINCT TABLE_NAME) AS table_count
FROM #{DLM_SCHEMA}.TBL_METATABLE
WHERE MASTERKEY IS NULL
  AND OWNER = '#{TARGET_OWNER}'
  -- 노이즈 컬럼 제외
  AND COLUMN_NAME NOT LIKE '%\_DT' ESCAPE '\'
  AND COLUMN_NAME NOT LIKE '%\_DTTM' ESCAPE '\'
  AND COLUMN_NAME NOT LIKE '%\_VR' ESCAPE '\'
  AND COLUMN_NAME NOT LIKE '%\_CD' ESCAPE '\'
  AND COLUMN_NAME NOT LIKE '%\_YN' ESCAPE '\'
  AND COLUMN_NAME NOT LIKE '%\_NM' ESCAPE '\'
  AND COLUMN_NAME NOT LIKE '%\_AMT' ESCAPE '\'
  AND COLUMN_NAME NOT IN ('REGDATE', 'UPDDATE', 'REGUSERID', 'UPDUSERID')
GROUP BY COLUMN_NAME
HAVING COUNT(DISTINCT TABLE_NAME) >= 3  -- 3개 이상 테이블에 존재
ORDER BY table_count DESC;


-- ────────────────────────────────────────────────────────────
-- 4-2. 특정 컬럼명으로 MasterKey 일괄 설정 (빈도 분석 후)
-- ────────────────────────────────────────────────────────────
-- 위 빈도 분석 결과를 보고 마스터키로 확정된 컬럼을 일괄 설정

-- UPDATE #{DLM_SCHEMA}.TBL_METATABLE SET MASTERKEY = COLUMN_NAME
-- WHERE MASTERKEY IS NULL
--   AND OWNER = '#{TARGET_OWNER}'
--   AND COLUMN_NAME = '여기에_확정된_컬럼명';



-- ################################################################
-- STEP 5. MASTERYN 플래그 설정
-- ################################################################
-- MASTERKEY가 설정된 행에 MASTERYN = 'Y' 표시


-- ────────────────────────────────────────────────────────────
-- 5-1. MASTERYN 일괄 업데이트
-- ────────────────────────────────────────────────────────────
-- UPDATE #{DLM_SCHEMA}.TBL_METATABLE
-- SET MASTERYN = CASE WHEN MASTERKEY IS NOT NULL THEN 'Y' ELSE NULL END
-- WHERE OWNER = '#{TARGET_OWNER}';


-- ────────────────────────────────────────────────────────────
-- 5-2. 최종 결과 확인
-- ────────────────────────────────────────────────────────────
SELECT OWNER, TABLE_NAME, COLUMN_NAME, MASTERKEY, MASTERYN
FROM #{DLM_SCHEMA}.TBL_METATABLE
WHERE MASTERKEY IS NOT NULL
  AND OWNER = '#{TARGET_OWNER}'
ORDER BY OWNER, TABLE_NAME, COLUMN_NAME;
