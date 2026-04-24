-- ============================================================
-- DLM_FK_RELATION_ANALYSIS : 테이블 연관관계(FK) 분석 워크북
-- ============================================================
-- DLM 파기/복원 JOB의 테이블 순서(PRECEDING/SUCCEDDING) 설정 및
-- MasterKey 매핑을 위해 원천DB의 FK 관계를 분석하는 SQL 모음입니다.
--
-- [사용 시점]
--   1. 신규 JOB 등록 시 → 테이블 간 참조 관계 파악 (삭제/복원 순서 결정)
--   2. MasterKey 설정 시 → PK/FK/인덱스 기반 키 컬럼 자동 탐색
--   3. 분리보관 테이블 설계 시 → 부모-자식 관계 확인
--
-- [Oracle / MariaDB 공통 제공]
--   각 섹션별로 Oracle 버전과 MariaDB 버전을 함께 제공합니다.
--
-- ============================================================
-- 사용 시 아래 변수를 대상 스키마로 치환하세요.
--
--   #{TARGET_OWNER}   -> 분석 대상 스키마  (예: COOWNSER)
--   #{DLM_SCHEMA}     -> DLM 스키마        (기본값: COTDL)
--   #{TARGET_TABLE}   -> 특정 테이블 지정   (예: EMPLOYEES)
--   #{TARGET_COLUMN}  -> 특정 컬럼 지정     (예: ACTID)
-- ============================================================



-- ################################################################
-- SECTION 1. FK 제약조건 기반 연관관계 조회 (정식 FK)
-- ################################################################
-- DB에 FK 제약조건이 등록된 경우 가장 정확한 관계를 보여줍니다.


-- ────────────────────────────────────────────────────────────
-- 1-1. [Oracle] 특정 스키마의 전체 FK 관계 (부모 ← 자식)
-- ────────────────────────────────────────────────────────────
-- 결과: child_table.child_column → parent_table.parent_column
SELECT
    child.owner                AS child_owner,
    child.table_name           AS child_table,
    child_col.column_name      AS child_column,
    child_col.position         AS col_position,
    fk.constraint_name         AS fk_name,
    parent_col.owner           AS parent_owner,
    parent_col.table_name      AS parent_table,
    parent_col.column_name     AS parent_column
FROM all_constraints fk
JOIN all_cons_columns child_col
    ON  fk.owner           = child_col.owner
    AND fk.constraint_name = child_col.constraint_name
JOIN all_constraints pk
    ON  fk.r_owner           = pk.owner
    AND fk.r_constraint_name = pk.constraint_name
JOIN all_cons_columns parent_col
    ON  pk.owner           = parent_col.owner
    AND pk.constraint_name = parent_col.constraint_name
    AND child_col.position = parent_col.position
JOIN all_tables child
    ON  fk.owner      = child.owner
    AND fk.table_name = child.table_name
WHERE fk.constraint_type = 'R'
  AND fk.owner = '#{TARGET_OWNER}'
ORDER BY child.table_name, fk.constraint_name, child_col.position;


-- ────────────────────────────────────────────────────────────
-- 1-2. [MariaDB] 특정 스키마의 전체 FK 관계
-- ────────────────────────────────────────────────────────────
SELECT
    kcu.TABLE_SCHEMA           AS child_owner,
    kcu.TABLE_NAME             AS child_table,
    kcu.COLUMN_NAME            AS child_column,
    kcu.ORDINAL_POSITION       AS col_position,
    kcu.CONSTRAINT_NAME        AS fk_name,
    kcu.REFERENCED_TABLE_SCHEMA AS parent_owner,
    kcu.REFERENCED_TABLE_NAME  AS parent_table,
    kcu.REFERENCED_COLUMN_NAME AS parent_column
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
WHERE kcu.REFERENCED_TABLE_NAME IS NOT NULL
  AND kcu.TABLE_SCHEMA = '#{TARGET_OWNER}'
ORDER BY kcu.TABLE_NAME, kcu.CONSTRAINT_NAME, kcu.ORDINAL_POSITION;


-- ────────────────────────────────────────────────────────────
-- 1-3. [Oracle] 특정 테이블이 참조하는 부모 테이블 목록
-- ────────────────────────────────────────────────────────────
-- #{TARGET_TABLE}이 FK로 참조하는 부모 테이블 (삭제 시 이 테이블보다 먼저 삭제)
SELECT
    fk.table_name              AS child_table,
    child_col.column_name      AS child_column,
    fk.constraint_name         AS fk_name,
    parent_col.table_name      AS parent_table,
    parent_col.column_name     AS parent_column
FROM all_constraints fk
JOIN all_cons_columns child_col
    ON  fk.owner           = child_col.owner
    AND fk.constraint_name = child_col.constraint_name
JOIN all_cons_columns parent_col
    ON  fk.r_owner           = parent_col.owner
    AND fk.r_constraint_name = parent_col.constraint_name
    AND child_col.position    = parent_col.position
WHERE fk.constraint_type = 'R'
  AND fk.owner      = '#{TARGET_OWNER}'
  AND fk.table_name = '#{TARGET_TABLE}'
ORDER BY fk.constraint_name, child_col.position;


-- ────────────────────────────────────────────────────────────
-- 1-4. [Oracle] 특정 테이블을 참조하는 자식 테이블 목록
-- ────────────────────────────────────────────────────────────
-- #{TARGET_TABLE}을 FK로 참조하는 자식 테이블 (삭제 시 이 테이블 먼저 삭제해야 함)
SELECT
    child_col.table_name       AS child_table,
    child_col.column_name      AS child_column,
    fk.constraint_name         AS fk_name,
    parent_col.table_name      AS parent_table,
    parent_col.column_name     AS parent_column
FROM all_constraints fk
JOIN all_cons_columns child_col
    ON  fk.owner           = child_col.owner
    AND fk.constraint_name = child_col.constraint_name
JOIN all_cons_columns parent_col
    ON  fk.r_owner           = parent_col.owner
    AND fk.r_constraint_name = parent_col.constraint_name
    AND child_col.position    = parent_col.position
WHERE fk.constraint_type = 'R'
  AND fk.r_owner = '#{TARGET_OWNER}'
  AND parent_col.table_name = '#{TARGET_TABLE}'
ORDER BY child_col.table_name, fk.constraint_name;



-- ################################################################
-- SECTION 2. 컬럼명 기반 잠재적 연관관계 탐색 (FK 미등록)
-- ################################################################
-- FK 제약조건이 없더라도 컬럼명 패턴으로 잠재적 관계를 추정합니다.
-- DLM 파기 JOB 설정 시 테이블 순서 결정에 활용합니다.


-- ────────────────────────────────────────────────────────────
-- 2-1. [Oracle] PK 컬럼이 다른 테이블에도 존재하는 경우 (잠재적 부모-자식)
-- ────────────────────────────────────────────────────────────
-- PK 컬럼명이 다른 테이블에도 같은 이름으로 존재하면 잠재적 FK 관계
SELECT
    pk_tbl.owner               AS pk_owner,
    pk_tbl.table_name          AS pk_table,
    pk_col.column_name         AS pk_column,
    pk_col.position            AS pk_position,
    other.table_name           AS related_table,
    other.column_name          AS related_column,
    other.data_type            AS related_data_type
FROM all_constraints pk_con
JOIN all_cons_columns pk_col
    ON  pk_con.owner           = pk_col.owner
    AND pk_con.constraint_name = pk_col.constraint_name
JOIN all_tables pk_tbl
    ON  pk_con.owner      = pk_tbl.owner
    AND pk_con.table_name = pk_tbl.table_name
JOIN all_tab_columns other
    ON  other.owner       = pk_con.owner
    AND other.column_name = pk_col.column_name
    AND other.table_name != pk_con.table_name
WHERE pk_con.constraint_type = 'P'
  AND pk_con.owner = '#{TARGET_OWNER}'
ORDER BY pk_tbl.table_name, pk_col.column_name, other.table_name;


-- ────────────────────────────────────────────────────────────
-- 2-2. [MariaDB] PK 컬럼이 다른 테이블에도 존재하는 경우
-- ────────────────────────────────────────────────────────────
SELECT
    pk_col.TABLE_NAME          AS pk_table,
    pk_col.COLUMN_NAME         AS pk_column,
    pk_col.ORDINAL_POSITION    AS pk_position,
    other.TABLE_NAME           AS related_table,
    other.COLUMN_NAME          AS related_column,
    other.DATA_TYPE            AS related_data_type
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE pk_col
JOIN INFORMATION_SCHEMA.COLUMNS other
    ON  other.TABLE_SCHEMA = pk_col.TABLE_SCHEMA
    AND other.COLUMN_NAME  = pk_col.COLUMN_NAME
    AND other.TABLE_NAME  != pk_col.TABLE_NAME
WHERE pk_col.CONSTRAINT_NAME = 'PRIMARY'
  AND pk_col.TABLE_SCHEMA = '#{TARGET_OWNER}'
ORDER BY pk_col.TABLE_NAME, pk_col.COLUMN_NAME, other.TABLE_NAME;


-- ────────────────────────────────────────────────────────────
-- 2-3. [Oracle] 특정 컬럼이 PK의 선두 컬럼인 테이블 목록
-- ────────────────────────────────────────────────────────────
-- #{TARGET_COLUMN}이 PK 첫 번째 컬럼인 테이블 = 이 컬럼이 마스터키일 가능성 높음
SELECT
    a.owner, a.table_name, a.constraint_name,
    b.column_name, b.position
FROM all_constraints a
JOIN all_cons_columns b
    ON  a.owner           = b.owner
    AND a.constraint_name = b.constraint_name
WHERE a.owner NOT LIKE '%SYS%'
  AND a.constraint_type = 'P'
  AND b.column_name = '#{TARGET_COLUMN}'
  AND b.position = 1
ORDER BY a.table_name;


-- ────────────────────────────────────────────────────────────
-- 2-4. [Oracle] 동일 컬럼명-데이터타입으로 연결 가능한 테이블 쌍
-- ────────────────────────────────────────────────────────────
-- 컬럼명과 데이터타입이 동일한 경우만 (원본의 LIKE 매칭보다 정확)
SELECT
    a.table_name               AS table_a,
    b.table_name               AS table_b,
    a.column_name              AS shared_column,
    a.data_type                AS data_type,
    a.data_length              AS data_length
FROM all_tab_columns a
JOIN all_tab_columns b
    ON  a.column_name  = b.column_name
    AND a.data_type    = b.data_type
    AND a.table_name  != b.table_name
    AND a.table_name   < b.table_name  -- 중복 제거 (A-B만, B-A 제외)
WHERE a.owner = '#{TARGET_OWNER}'
  AND b.owner = '#{TARGET_OWNER}'
ORDER BY a.column_name, a.table_name, b.table_name;



-- ################################################################
-- SECTION 3. 제약조건 / 인덱스 현황 요약
-- ################################################################


-- ────────────────────────────────────────────────────────────
-- 3-1. [Oracle] 테이블별 제약조건 현황 요약
-- ────────────────────────────────────────────────────────────
SELECT
    table_name,
    COUNT(CASE WHEN constraint_type = 'P' THEN 1 END) AS pk_count,
    COUNT(CASE WHEN constraint_type = 'R' THEN 1 END) AS fk_count,
    COUNT(CASE WHEN constraint_type = 'U' THEN 1 END) AS unique_count,
    COUNT(CASE WHEN constraint_type = 'C' THEN 1 END) AS check_count
FROM all_constraints
WHERE owner = '#{TARGET_OWNER}'
GROUP BY table_name
ORDER BY table_name;


-- ────────────────────────────────────────────────────────────
-- 3-2. [MariaDB] 테이블별 제약조건 현황 요약
-- ────────────────────────────────────────────────────────────
SELECT
    tc.TABLE_NAME,
    SUM(CASE WHEN tc.CONSTRAINT_TYPE = 'PRIMARY KEY' THEN 1 ELSE 0 END) AS pk_count,
    SUM(CASE WHEN tc.CONSTRAINT_TYPE = 'FOREIGN KEY' THEN 1 ELSE 0 END) AS fk_count,
    SUM(CASE WHEN tc.CONSTRAINT_TYPE = 'UNIQUE'      THEN 1 ELSE 0 END) AS unique_count
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
WHERE tc.TABLE_SCHEMA = '#{TARGET_OWNER}'
GROUP BY tc.TABLE_NAME
ORDER BY tc.TABLE_NAME;


-- ────────────────────────────────────────────────────────────
-- 3-3. [Oracle] 인덱스 현황
-- ────────────────────────────────────────────────────────────
SELECT
    table_name, index_name, index_type,
    uniqueness, visibility, status
FROM all_indexes
WHERE owner = '#{TARGET_OWNER}'
ORDER BY table_name, index_name;


-- ────────────────────────────────────────────────────────────
-- 3-4. [Oracle] FK가 없지만 PK가 있는 테이블 (FK 누락 후보)
-- ────────────────────────────────────────────────────────────
-- PK는 있는데 FK를 참조하는 자식이 하나도 없는 테이블 → FK 설정 누락 가능성
SELECT t.table_name, t.num_rows
FROM all_tables t
WHERE t.owner = '#{TARGET_OWNER}'
  AND EXISTS (
      SELECT 1 FROM all_constraints c
      WHERE c.owner = t.owner AND c.table_name = t.table_name AND c.constraint_type = 'P'
  )
  AND NOT EXISTS (
      SELECT 1 FROM all_constraints c
      WHERE c.r_owner = t.owner
        AND c.r_constraint_name IN (
            SELECT constraint_name FROM all_constraints
            WHERE owner = t.owner AND table_name = t.table_name AND constraint_type = 'P'
        )
  )
ORDER BY t.table_name;



-- ################################################################
-- SECTION 4. DLM 파기 순서 분석 (FK 기반 삭제 순서 결정)
-- ################################################################
-- FK 관계를 기반으로 DLM JOB의 테이블 삭제/복원 순서를 결정합니다.
-- 삭제: 자식 → 부모 순 (FK 참조 방향 역순)
-- 복원: 부모 → 자식 순 (FK 참조 방향 순)


-- ────────────────────────────────────────────────────────────
-- 4-1. [Oracle] FK 참조 깊이(depth) 계산 (삭제 순서 = depth DESC)
-- ────────────────────────────────────────────────────────────
-- depth 0 = 최상위 부모 (마지막에 삭제), depth가 클수록 먼저 삭제
WITH fk_tree (table_name, depth, path) AS (
    -- 루트: FK로 참조되지만, 자신은 FK를 가지지 않는 테이블 (최상위 부모)
    SELECT DISTINCT pk_tbl.table_name, 0 AS depth,
           pk_tbl.table_name AS path
    FROM all_constraints pk_con
    JOIN all_cons_columns pk_col
        ON pk_con.owner = pk_col.owner AND pk_con.constraint_name = pk_col.constraint_name
    JOIN all_tables pk_tbl
        ON pk_con.owner = pk_tbl.owner AND pk_con.table_name = pk_tbl.table_name
    WHERE pk_con.owner = '#{TARGET_OWNER}'
      AND pk_con.constraint_type = 'P'
      AND NOT EXISTS (
          SELECT 1 FROM all_constraints fk
          WHERE fk.owner = pk_con.owner AND fk.table_name = pk_con.table_name
            AND fk.constraint_type = 'R'
      )
      AND EXISTS (
          SELECT 1 FROM all_constraints child_fk
          WHERE child_fk.r_owner = pk_con.owner
            AND child_fk.r_constraint_name = pk_con.constraint_name
      )
    UNION ALL
    -- 재귀: 부모를 FK로 참조하는 자식 테이블
    SELECT fk.table_name, ft.depth + 1,
           ft.path || ' > ' || fk.table_name
    FROM fk_tree ft
    JOIN all_constraints pk_con
        ON pk_con.owner = '#{TARGET_OWNER}' AND pk_con.table_name = ft.table_name AND pk_con.constraint_type = 'P'
    JOIN all_constraints fk
        ON fk.r_owner = pk_con.owner AND fk.r_constraint_name = pk_con.constraint_name
        AND fk.constraint_type = 'R' AND fk.owner = '#{TARGET_OWNER}'
    WHERE ft.depth < 10  -- 무한루프 방지
      AND INSTR(ft.path, fk.table_name) = 0  -- 순환참조 방지
)
SELECT table_name,
       MAX(depth) AS max_depth,
       MIN(path)  AS reference_path
FROM fk_tree
GROUP BY table_name
ORDER BY MAX(depth) DESC, table_name;


-- ────────────────────────────────────────────────────────────
-- 4-2. [Oracle] DLM StepTable 순서 자동 생성 도우미
-- ────────────────────────────────────────────────────────────
-- FK depth 기반으로 DLM TBL_PIISTEPTABLE의 SEQ2 값을 자동 산출
-- 삭제(DELETE/ARCHIVE): depth 큰 것부터 (SEQ2 작은값)
-- 복원(RESTORE): depth 작은 것부터 (SEQ2 작은값)
WITH fk_depth AS (
    SELECT
        child.table_name AS child_table,
        parent_col.table_name AS parent_table
    FROM all_constraints fk
    JOIN all_cons_columns child_col
        ON fk.owner = child_col.owner AND fk.constraint_name = child_col.constraint_name
    JOIN all_cons_columns parent_col
        ON fk.r_owner = parent_col.owner AND fk.r_constraint_name = parent_col.constraint_name
        AND child_col.position = parent_col.position
    WHERE fk.constraint_type = 'R'
      AND fk.owner = '#{TARGET_OWNER}'
),
all_tables_list AS (
    SELECT DISTINCT table_name FROM (
        SELECT child_table AS table_name FROM fk_depth
        UNION
        SELECT parent_table AS table_name FROM fk_depth
    )
)
SELECT
    t.table_name,
    COUNT(d.parent_table)                              AS parent_count,
    (COUNT(d.parent_table) + 1) * 100                  AS "SEQ2_삭제순서(ASC)",
    (1000 - COUNT(d.parent_table) * 100)               AS "SEQ2_복원순서(ASC)"
FROM all_tables_list t
LEFT JOIN fk_depth d ON t.table_name = d.child_table
GROUP BY t.table_name
ORDER BY parent_count DESC, t.table_name;
