-- ============================================================
-- 대시보드 즉시 현행화 (refreshDashboard 수동 실행)
-- 용도: TBL_METAPIISTATUS를 재계산하여 대시보드 수치 즉시 반영
-- 참조: JobScheduler.refreshDashboard() → 매시 정각 자동 실행
--       MetaPiiStatusMapper.xml (delete + insert)
-- ============================================================

-- [1] 기존 데이터 삭제
DELETE FROM COTDL.TBL_METAPIISTATUS WHERE 1=1;

-- [2] 재계산하여 INSERT
INSERT INTO COTDL.TBL_METAPIISTATUS
SELECT
    (SELECT s.SYSTEM_NAME
       FROM cotdl.tbl_piidatabase d, cotdl.tbl_piisystem s
      WHERE subquery_alias.db = d.db AND d.SYSTEM = s.SYSTEM_ID) AS system_name,
    db, owner, total_tables, total_columns, pii_notconfirmed, pii_tables, pii_columns,
    pii3_del_columns, pii3_upd_columns,
    (pii_columns - pii3_del_columns - pii3_upd_columns) AS pii3_notregistered,
    CASE
        WHEN pii_columns > 0 THEN ROUND(((pii_columns - pii3_del_columns - pii3_upd_columns) * 100.0) / pii_columns, 2)
        ELSE 0.00
    END AS pii3_notregistered_percentage
FROM (
    SELECT
        t.db,
        t.owner,
        COUNT(DISTINCT t.table_name) AS total_tables,
        COUNT(t.column_name) AS total_columns,
        COUNT(DISTINCT CASE
            WHEN t.PIITYPE IS NOT NULL AND t.PIITYPE NOT IN ('3_3_corpno') THEN t.table_name
            ELSE NULL
        END) AS pii_tables,
        SUM(CASE
            WHEN t.PIITYPE IS NOT NULL AND t.PIITYPE NOT IN ('3_3_corpno') THEN 1 ELSE 0
        END) AS pii_columns,
        SUM(CASE
            WHEN val3 IS NULL THEN 1 ELSE 0
        END) AS pii_notconfirmed,
        SUM(CASE
            WHEN t.PIITYPE IS NOT NULL AND t.PIITYPE NOT IN ('3_3_corpno')
                AND (t.db, t.owner, t.table_name) IN (
                    SELECT b.db, b.owner, b.table_name
                    FROM cotdl.tbl_piijob a
                    JOIN cotdl.tbl_piisteptable b ON a.jobid = b.jobid AND a.version = b.version
                    WHERE a.status = 'ACTIVE'
                      AND a.runtype = 'REGULAR'
                      AND a.jobtype = 'PII'
                      AND a.POLICY_ID = 'PII_POLICY3'
                      AND a.JOBID LIKE 'PII_POLICY3%DELETE'
                      AND a.version IN (SELECT MAX(CAST(version AS INTEGER)) FROM cotdl.tbl_piijob WHERE jobid = a.jobid)
                )
            THEN 1 ELSE 0
        END) AS pii3_del_columns,
        SUM(CASE
            WHEN t.PIITYPE IS NOT NULL AND t.PIITYPE NOT IN ('3_3_corpno')
                AND (t.db, t.owner, t.table_name, t.column_name) IN (
                    SELECT b.db, b.owner, b.table_name, c.column_name
                    FROM cotdl.tbl_piijob a
                    JOIN cotdl.tbl_piisteptable b ON a.jobid = b.jobid AND a.version = b.version
                    JOIN cotdl.tbl_piisteptableupdate c ON b.jobid = c.jobid AND b.version = c.version AND b.exetype = 'UPDATE'
                        AND b.seq1 = c.seq1 AND b.seq2 = c.seq2 AND b.seq3 = c.seq3
                    WHERE a.status = 'ACTIVE'
                      AND a.runtype = 'REGULAR'
                      AND a.jobtype = 'PII'
                      AND a.JOBID LIKE 'PII_POLICY3%UPDATE'
                      AND a.version IN (SELECT MAX(CAST(version AS INTEGER)) FROM cotdl.tbl_piijob WHERE jobid = a.jobid)
                )
            THEN 1 ELSE 0
        END) AS pii3_upd_columns
    FROM cotdl.tbl_metatable t
    WHERE DB IN (SELECT DB FROM cotdl.tbl_piidatabase WHERE ENV = 'PRODUCTION')
    GROUP BY t.db, t.owner
) AS subquery_alias
ORDER BY db, owner;

COMMIT;

-- [3] 결과 확인
SELECT system_name, db, owner, total_columns, pii_columns,
       pii3_del_columns, pii3_upd_columns,
       (pii3_del_columns + pii3_upd_columns) AS "파기등록수",
       pii3_notregistered, pii3_notregistered_percentage
FROM COTDL.TBL_METAPIISTATUS
ORDER BY system_name, db;
