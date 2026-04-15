-- ============================================================
-- TBL_PIIJOB 상태 변경 SQL 모음
-- 사용법: JOBID, VERSION 값을 변경 후 실행
-- ============================================================

-- ★ 변수: 사용 전 아래 값을 변경하세요
-- @JOBID   = 'PII_POLICY3_DAON_CORE_DELETE'
-- @VERSION = '1'

-- ============================================================
-- [1] 현재 상태 확인
-- ============================================================
SELECT jobid, version, jobname, status, phase, runtype, jobtype, policy_id,
       DATE_FORMAT(regdate,'%Y/%m/%d') AS regdate,
       DATE_FORMAT(upddate,'%Y/%m/%d') AS upddate
FROM COTDL.TBL_PIIJOB
WHERE jobid = 'PII_POLICY3_DAON_CORE_DELETE';


-- ============================================================
-- [2] status 변경
-- ============================================================

-- 2-1. ACTIVE → 스케줄러 실행 대상, 대시보드 파기 등록 집계 대상
UPDATE COTDL.TBL_PIIJOB
   SET status = 'ACTIVE', upddate = NOW()
 WHERE jobid = 'PII_POLICY3_DAON_CORE_DELETE' AND version = '1';

-- 2-2. NEW → 신규 생성 상태 (스케줄러 미실행)
UPDATE COTDL.TBL_PIIJOB
   SET status = 'NEW', upddate = NOW()
 WHERE jobid = 'PII_POLICY3_DAON_CORE_DELETE' AND version = '1';

-- 2-3. OLD → 비활성 (이전 버전 처리용, 목록에서 숨김)
UPDATE COTDL.TBL_PIIJOB
   SET status = 'OLD', upddate = NOW()
 WHERE jobid = 'PII_POLICY3_DAON_CORE_DELETE' AND version = '1';

-- 2-4. INACTIVE → 비활성 (수동 중지)
UPDATE COTDL.TBL_PIIJOB
   SET status = 'INACTIVE', upddate = NOW()
 WHERE jobid = 'PII_POLICY3_DAON_CORE_DELETE' AND version = '1';


-- ============================================================
-- [3] phase 변경
-- ============================================================

-- 3-1. CHECKIN → 확정 상태 (스케줄러 실행 가능)
UPDATE COTDL.TBL_PIIJOB
   SET phase = 'CHECKIN', upddate = NOW()
 WHERE jobid = 'PII_POLICY3_DAON_CORE_DELETE' AND version = '1';

-- 3-2. CHECKOUT → 편집 중 (스케줄러 실행 불가)
UPDATE COTDL.TBL_PIIJOB
   SET phase = 'CHECKOUT', upddate = NOW()
 WHERE jobid = 'PII_POLICY3_DAON_CORE_DELETE' AND version = '1';


-- ============================================================
-- [4] 복합 변경 (자주 쓰는 시나리오)
-- ============================================================

-- 4-1. Job 활성화 (스케줄러 실행 가능 상태로 전환)
UPDATE COTDL.TBL_PIIJOB
   SET status = 'ACTIVE', phase = 'CHECKIN', upddate = NOW()
 WHERE jobid = 'PII_POLICY3_DAON_CORE_DELETE' AND version = '1';

-- 4-2. Job 비활성화 (스케줄러 실행 중지)
UPDATE COTDL.TBL_PIIJOB
   SET status = 'INACTIVE', phase = 'CHECKIN', upddate = NOW()
 WHERE jobid = 'PII_POLICY3_DAON_CORE_DELETE' AND version = '1';

-- 4-3. 특정 Job의 이전 버전을 모두 OLD 처리
UPDATE COTDL.TBL_PIIJOB
   SET status = 'OLD', phase = 'CHECKIN', upddate = NOW()
 WHERE jobid = 'PII_POLICY3_DAON_CORE_DELETE' AND version != '1';


-- ============================================================
-- [5] 대시보드 파기 등록 집계 조건 확인
--     (이 조건을 모두 만족해야 파기 등록 건수에 포함됨)
-- ============================================================
SELECT jobid, version, status, runtype, jobtype, policy_id, phase
FROM COTDL.TBL_PIIJOB
WHERE status = 'ACTIVE'
  AND runtype = 'REGULAR'
  AND jobtype = 'PII'
  AND policy_id = 'PII_POLICY3'
  AND (JOBID LIKE 'PII_POLICY3%DELETE' OR JOBID LIKE 'PII_POLICY3%UPDATE')
  AND version IN (SELECT MAX(CAST(version AS INTEGER)) FROM COTDL.TBL_PIIJOB b WHERE b.jobid = TBL_PIIJOB.jobid);


-- ============================================================
-- [6] 대시보드 즉시 갱신 (refreshDashboard 수동 실행)
-- ============================================================
DELETE FROM COTDL.TBL_METAPIISTATUS WHERE 1=1;

INSERT INTO COTDL.TBL_METAPIISTATUS
SELECT
    (SELECT s.SYSTEM_NAME FROM cotdl.tbl_piidatabase d, cotdl.tbl_piisystem s WHERE subquery_alias.db = d.db AND d.SYSTEM = s.SYSTEM_ID) AS system_name,
    db, owner, total_tables, total_columns, pii_notconfirmed, pii_tables, pii_columns,
    pii3_del_columns, pii3_upd_columns,
    (pii_columns - pii3_del_columns - pii3_upd_columns) AS pii3_notregistered,
    CASE
        WHEN pii_columns > 0 THEN ROUND(((pii_columns - pii3_del_columns - pii3_upd_columns) * 100.0) / pii_columns, 2)
        ELSE 0.00
    END AS pii3_notregistered_percentage
FROM (
    SELECT
        t.db, t.owner,
        COUNT(DISTINCT t.table_name) AS total_tables,
        COUNT(t.column_name) AS total_columns,
        COUNT(DISTINCT CASE WHEN t.PIITYPE IS NOT NULL AND t.PIITYPE NOT IN ('3_3_corpno') THEN t.table_name ELSE NULL END) AS pii_tables,
        SUM(CASE WHEN t.PIITYPE IS NOT NULL AND t.PIITYPE NOT IN ('3_3_corpno') THEN 1 ELSE 0 END) AS pii_columns,
        SUM(CASE WHEN val3 IS NULL THEN 1 ELSE 0 END) AS pii_notconfirmed,
        SUM(CASE
            WHEN t.PIITYPE IS NOT NULL AND t.PIITYPE NOT IN ('3_3_corpno')
                AND (t.db, t.owner, t.table_name) IN (
                    SELECT b.db, b.owner, b.table_name
                    FROM cotdl.tbl_piijob a
                    JOIN cotdl.tbl_piisteptable b ON a.jobid = b.jobid AND a.version = b.version
                    WHERE a.status = 'ACTIVE' AND a.runtype = 'REGULAR' AND a.jobtype = 'PII'
                      AND a.POLICY_ID = 'PII_POLICY3' AND a.JOBID LIKE 'PII_POLICY3%DELETE'
                      AND a.version IN (SELECT MAX(CAST(version AS INTEGER)) FROM cotdl.tbl_piijob WHERE jobid = a.jobid)
                ) THEN 1 ELSE 0
        END) AS pii3_del_columns,
        SUM(CASE
            WHEN t.PIITYPE IS NOT NULL AND t.PIITYPE NOT IN ('3_3_corpno')
                AND (t.db, t.owner, t.table_name, t.column_name) IN (
                    SELECT b.db, b.owner, b.table_name, c.column_name
                    FROM cotdl.tbl_piijob a
                    JOIN cotdl.tbl_piisteptable b ON a.jobid = b.jobid AND a.version = b.version
                    JOIN cotdl.tbl_piisteptableupdate c ON b.jobid = c.jobid AND b.version = c.version AND b.exetype = 'UPDATE'
                        AND b.seq1 = c.seq1 AND b.seq2 = c.seq2 AND b.seq3 = c.seq3
                    WHERE a.status = 'ACTIVE' AND a.runtype = 'REGULAR' AND a.jobtype = 'PII'
                      AND a.JOBID LIKE 'PII_POLICY3%UPDATE'
                      AND a.version IN (SELECT MAX(CAST(version AS INTEGER)) FROM cotdl.tbl_piijob WHERE jobid = a.jobid)
                ) THEN 1 ELSE 0
        END) AS pii3_upd_columns
    FROM cotdl.tbl_metatable t
    WHERE DB IN (SELECT DB FROM cotdl.tbl_piidatabase WHERE ENV = 'PRODUCTION')
    GROUP BY t.db, t.owner
) AS subquery_alias
ORDER BY db, owner;

COMMIT;
