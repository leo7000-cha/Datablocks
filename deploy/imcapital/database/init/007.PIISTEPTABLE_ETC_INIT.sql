-- ============================================================
-- DLM_PIISTEPTABLE_ETC_INIT : JOB 이벤트별 후처리 SQL 등록
-- ============================================================
-- TBL_PIISTEPTABLE_ETC는 특정 JOB 이벤트 발생 시 자동 실행되는
-- 후처리(ETC) SQL을 정의하는 테이블입니다.
-- SQLTYPE='AUTO'로 설정된 항목은 해당 JOB의 STEP 완료 시 자동 실행됩니다.
--
-- [등록된 후처리 이벤트]
--   ARC_DATA_DELETE      : 영구파기 완료 후 → 원천 테이블 상태값 'DELARC'로 업데이트
--   RESTORE_CUSTID       : 고객ID 복원 완료 후 → 원천 테이블 상태값 'RESTORE'로 업데이트
--   RECOVERY_JOB         : 복구JOB 완료 후 → 원천 테이블 상태값 'RECOVERY'로 업데이트
--   RECOVERY_ORDER       : 복구ORDER 완료 후 → 원천 테이블 상태값 'RECOVERY'로 업데이트
--   ARC_DATA_DELETE_EDMS : 영구파기(EDMS) 완료 후 → KEYMAP_HIST 이관 (BROADCAST)
--   ARC_DATA_DELETE_CONTRACT : 영구파기 완료 후 → 계약정보 TBL_PIICONTRACT에 적재
--
-- ============================================================
-- 사이트별 배포 시 아래 변수를 해당 사이트 값으로 치환(Replace All)하세요.
--
--   COTDL    -> DLM 스키마명         (기본값: COTDL)
--   DAON     -> 원천 DB명            (예: DAON)
--   DW       -> EDMS DB명            (예: DW)
--   COOWNHYP  -> 원천 테이블 OWNER     (예: COOWNHYP)
--   DTBB1230  -> 상태값 업데이트 대상   (예: DTBB1230)
--   CSIF_DSTU_EXCL_RSN_CD    -> 상태값 컬럼명         (예: CSIF_DSTU_EXCL_RSN_CD)
--   COOWNSER -> 계약 테이블 OWNER    (예: COOWNSER)
--   admin    -> 등록/수정 사용자 ID    (기본값: admin)
-- ============================================================


-- 기존 데이터 삭제 (초기화 용도)
DELETE FROM COTDL.TBL_PIISTEPTABLE_ETC;


-- ────────────────────────────────────────────────────────────
-- 1. 영구파기 완료 후처리: 원천 테이블 상태값 업데이트 (DELARC)
-- ────────────────────────────────────────────────────────────
INSERT INTO COTDL.TBL_PIISTEPTABLE_ETC (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'ARC_DATA_DELETE', '1', 'EXE_FINISH', 'DAON', 'COOWNHYP', 'DTBB1230',
    NULL, NULL, 'FINISH', NULL, NULL, NULL, NULL,
    10, 400, 10, NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL,
'UPDATE COOWNHYP.DTBB1230 SET CSIF_DSTU_EXCL_RSN_CD = ''DELARC'' WHERE act_id IN
',
    NULL, NULL, NULL, NULL, 'AUTO',
    NOW(), NOW(), 'admin', 'admin'
);


-- ────────────────────────────────────────────────────────────
-- 2. 고객ID 복원 완료 후처리: 원천 테이블 상태값 업데이트 (RESTORE)
-- ────────────────────────────────────────────────────────────
INSERT INTO COTDL.TBL_PIISTEPTABLE_ETC (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'RESTORE_CUSTID', '1', 'EXE_FINISH', 'DAON', 'COOWNHYP', 'DTBB1230',
    NULL, NULL, 'FINISH', NULL, NULL, NULL, NULL,
    10, 500, 10, NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL,
'UPDATE COOWNHYP.DTBB1230 SET CSIF_DSTU_EXCL_RSN_CD = ''RESTORE'' WHERE act_id IN
',
    NULL, NULL, NULL, NULL, 'AUTO',
    NOW(), NOW(), 'admin', 'admin'
);


-- ────────────────────────────────────────────────────────────
-- 3. 복구JOB 완료 후처리: 원천 테이블 상태값 업데이트 (RECOVERY)
-- ────────────────────────────────────────────────────────────
INSERT INTO COTDL.TBL_PIISTEPTABLE_ETC (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'RECOVERY_JOB', '1', 'EXE_FINISH', 'DAON', 'COOWNHYP', 'DTBB1230',
    NULL, NULL, 'FINISH', NULL, NULL, NULL, NULL,
    10, 700, 10, NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL,
'UPDATE COOWNHYP.DTBB1230 SET CSIF_DSTU_EXCL_RSN_CD = ''RECOVERY'' WHERE act_id IN
',
    NULL, NULL, NULL, NULL, 'AUTO',
    NOW(), NOW(), 'admin', 'admin'
);


-- ────────────────────────────────────────────────────────────
-- 4. 복구ORDER 완료 후처리: 원천 테이블 상태값 업데이트 (RECOVERY)
-- ────────────────────────────────────────────────────────────
INSERT INTO COTDL.TBL_PIISTEPTABLE_ETC (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'RECOVERY_ORDER', '1', 'EXE_FINISH', 'DAON', 'COOWNHYP', 'DTBB1230',
    NULL, NULL, 'FINISH', NULL, NULL, NULL, NULL,
    10, 700, 10, NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL,
'UPDATE COOWNHYP.DTBB1230 SET CSIF_DSTU_EXCL_RSN_CD = ''RECOVERY'' WHERE act_id IN
',
    NULL, NULL, NULL, NULL, 'AUTO',
    NOW(), NOW(), 'admin', 'admin'
);


-- ────────────────────────────────────────────────────────────
-- 5. 영구파기(EDMS) 완료 후처리: KEYMAP_HIST 이관 (BROADCAST)
--    영구파기 대상의 이미지 시스템 키맵을 BROADCAST로 전파
-- ────────────────────────────────────────────────────────────
INSERT INTO COTDL.TBL_PIISTEPTABLE_ETC (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'ARC_DATA_DELETE_EDMS', '1', 'EXE_BROADCAST', 'DW', 'COTDL', 'TBL_PIIKEYMAP_HIST',
    NULL, NULL, 'BROADCAST', NULL, NULL, NULL, NULL,
    10, 200, 10, NULL,
    NULL, NULL, NULL, NULL, NULL,
'EXISTS (SELECT 1 FROM COTDL.TBL_PIIEXTRACT e WHERE e.custid = A.custid AND EXCLUDE_REASON=''DELARC'' AND ARC_DEL_DATE=TO_DATE(''#BASEDATE'',''yyyy/mm/dd''))
AND A.db = ''DBPNCC'' AND A.KEY_NAME=''KEY_ECC_NBR''
',
'INSERT INTO COTDL.TBL_PIIKEYMAP_HIST
SELECT * FROM COTDL.TBL_PIIKEYMAP_HIST
WHERE
EXISTS (SELECT 1 FROM COTDL.TBL_PIIEXTRACT e WHERE e.custid = A.custid AND EXCLUDE_REASON=''DELARC'' AND ARC_DEL_DATE=TO_DATE(''#BASEDATE'',''yyyy/mm/dd''))
AND A.db = ''DBPNCC'' AND A.KEY_NAME=''KEY_ECC_NBR''
',
    NULL, NULL, NULL, NULL, 'AUTO',
    NOW(), NOW(), 'admin', 'admin'
);


-- ────────────────────────────────────────────────────────────
-- 6. 영구파기 완료 후처리: 계약정보 TBL_PIICONTRACT 적재
--    영구파기 대상 고객의 계약 정보를 원천 계약 테이블에서 조회하여 적재
-- ────────────────────────────────────────────────────────────
INSERT INTO COTDL.TBL_PIISTEPTABLE_ETC (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'ARC_DATA_DELETE_CONTRACT', '1', 'EXE_FINISH', 'DAON', 'COTDL', 'TBL_PIICONTRACT',
    NULL, NULL, 'FINISH', NULL, NULL, NULL, NULL,
    10, 500, 10, NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL,
'INSERT INTO COTDL.TBL_PIICONTRACT (
    custid, contractno, dept_cd, dept_name, contract_opn_dt, contract_close_dt,
    pd_cd, pd_nm, status, actid, rsdnt_altrntv_id, cust_nm,
    birth_dt, cb_dt, cust_pin, inst_cd, basedate, actrole_end_date,
    archive_date, delete_date, arc_del_date, real_doc_del_date, real_doc_del_userid
)
SELECT
    e.custid,
    d.dosnum AS contractno,
    d.col5 AS dept_cd,
    d.col6 AS dept_name,
    TO_DATE(d.col3, ''yyyy/mm/dd'') AS contract_opn_dt,
    TO_DATE(d.col7, ''yyyy/mm/dd'') AS contract_close_dt,
    d.col4 AS pd_cd,
    d.col4 AS pd_nm,
    ''N'' AS status,
    e.custid AS actid,
    e.rsdnt_altrntv_id,
    e.cust_nm,
    NULL AS birth_dt,
    NULL AS cb_dt,
    NULL AS cust_pin,
    NULL AS inst_cd,
    TO_DATE(''#BASEDATE'', ''yyyy/mm/dd'') AS basedate,
    NULL AS actrole_end_date,
    e.archive_date,
    e.delete_date,
    e.arc_del_date,
    NULL AS real_doc_del_date,
    NULL AS real_doc_del_userid
FROM COTDL.TBL_PIIEXTRACT e
   , COOWNSER.DOSACTEUR k
   , COOWNSER.DOSSIER d
WHERE 1=1
  AND ARC_DEL_DATE = TO_DATE(''#BASEDATE'', ''yyyy/mm/dd'')
  AND EXCLUDE_REASON = ''DELARC''
  AND e.custid = k.ACTID
  AND k.DOSID = d.DOSID
',
    NULL, NULL, NULL, NULL, 'AUTO',
    NOW(), NOW(), 'admin', 'admin'
);


COMMIT;
