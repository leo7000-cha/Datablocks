-- ============================================================
-- DLM_BATCH_METASYSTEM : 고객사 메타시스템 정보 수집 배치 잡
-- ============================================================
-- 고객사(사이트)의 메타시스템(WAM)에서 테이블/컬럼 메타 정보를 추출하여
-- DLM 관리 DB의 TBL_METASYSTEMDATA 테이블에 적재하는 배치 잡 등록 스크립트.
--
-- 수집 대상 메타 정보:
--   - DB서버명, 인스턴스명, 스키마(OWNER)명
--   - 테이블 한글/영문명, 컬럼 한글/영문명
--   - 컬럼 요청자/승인자, 요청일/승인일
--   - 속성명(INFOTYPE), PK/FK 구분, NULL 여부
--   - 소스 복호화 여부, 타겟 암호화 여부, 암호화 여부
--   - 관리유형, 도메인 정보, 도메인 그룹, 도메인 인포타입
--   - PII 판단 정보 (PII / PII_ENC / NOTPII)
--
-- [배치 흐름]
--   Step1 EXTRACT_METASYSTEM (EXE_EXTRACT, SEQ=1)
--     1-1. 기존 TBL_METASYSTEMDATA 삭제 (DAON DB 기준)
--     1-2. 기존 TBL_METASYSTEMDATA 삭제 (DLM DB 기준)
--     1-3. 메타시스템(WAM) 테이블 조인 → TBL_METASYSTEMDATA 적재
--   Step2 EXE_HOMECAST (EXE_HOMECAST, SEQ=2)
--     2-1. 원천DB → Home DB(DLM)로 TBL_METASYSTEMDATA 전송
--
-- [메타시스템 원천 테이블 (WAM)]
--   WAM_PDM_COL        : 컬럼 메타 (PK/FK/NULL/암호화/관리유형 등)
--   WAM_DB_DDL_TBL     : 테이블 메타 (한글/영문명)
--   WAA_META_DBMS      : DB 서버 정보
--   WAA_META_DBINSTANCE : DB 인스턴스 정보
--   WAA_META_DBUSER    : DB 사용자(스키마) 정보
--   WAM_DMN_DMN        : 도메인 정보 (도메인명/그룹/인포타입)
--
-- [PII 판단 로직]
--   INFOTYPE_NM = 'PII'       AND DEST_ENC_YN = 'N' → PII
--   INFOTYPE_NM = 'Sensitive' AND DEST_ENC_YN = 'Y' → PII_ENC
--   그 외                                            → NOTPII
--
-- ============================================================
-- 사이트별 배포 시 아래 변수를 해당 사이트 값으로 치환(Replace All)하세요.
--
--   #{JOBID}          -> DLM_BATCH_METASYSTEM   잡 ID                            (기본값: DLM_BATCH_METASYSTEM)
--   #{SOURCE_DB}      -> DAON                   원천 DB명 (메타시스템 접속 DB)    (예: DAON)
--   #{HOME_DB}        -> DLM                    DLM Home DB명                    (기본값: DLM)
--   #{DLM_SCHEMA}     -> COTDL                  DLM 스키마명                     (기본값: COTDL)
--   #{BATCH_TIME}     -> 00:10                  실행 시각 (HH:MM)                (기본값: 00:10)
--   #{ADMIN_USER}     -> admin                  등록/수정 사용자 ID               (기본값: admin)
-- ============================================================


-- 1. 기존 잡 정의 삭제
DELETE FROM COTDL.TBL_PIIJOB       WHERE JOBID = 'DLM_BATCH_METASYSTEM';
DELETE FROM COTDL.TBL_PIISTEP      WHERE JOBID = 'DLM_BATCH_METASYSTEM';
DELETE FROM COTDL.TBL_PIISTEPTABLE WHERE JOBID = 'DLM_BATCH_METASYSTEM';


-- 2. JOB 등록
INSERT INTO COTDL.TBL_PIIJOB (
    JOBID, VERSION, JOBNAME, `SYSTEM`, POLICY_ID, KEYMAP_ID,
    JOBTYPE, RUNTYPE, CALENDAR, `TIME`, CRONVAL, CONFIRMFLAG, STATUS, PHASE,
    JOB_OWNER_ID1, JOB_OWNER_NAME1,
    JOB_OWNER_ID2, JOB_OWNER_NAME2,
    JOB_OWNER_ID3, JOB_OWNER_NAME3,
    ENDDATE, REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_METASYSTEM', '1', 'DLM_BATCH_METASYSTEM_DATA_수집', NULL, NULL, NULL,
    'BATCH', 'DLM_BATCH', 'ALLDAYS', '00:10', '##########', 'N', 'ACTIVE', 'CHECKIN',
    'admin', 'admin',
    NULL, NULL,
    NULL, NULL,
    NULL, NOW(), NOW(), 'admin', 'admin'
);


-- 3. STEP 등록 (2개 Step 순차 실행)

-- Step1: 메타시스템 정보 추출 (EXTRACT)
--   원천DB의 WAM 메타 테이블에서 컬럼/테이블/도메인 정보를 조인하여
--   TBL_METASYSTEMDATA에 적재
INSERT INTO COTDL.TBL_PIISTEP (
    JOBID, VERSION, STEPID, STEPNAME, STEPTYPE, STEPSEQ, DB,
    STATUS, PHASE, THREADCNT, COMMITCNT,
    ENDDATE, REGDATE, UPDDATE, REGUSERID, UPDUSERID,
    DATA_HANDLING_METHOD, PROCESSING_METHOD, FK_DISABLE_FLAG, INDEX_UNUSUAL_FLAG,
    VAL1, VAL2, VAL3, VAL4, VAL5
) VALUES (
    'DLM_BATCH_METASYSTEM', '1', 'EXTRACT_METASYSTEM', 'METASYSTEM 정보 추출', 'EXE_EXTRACT', 1, 'DAON',
    'ACTIVE', 'CHECKOUT', 1, 5000,
    NULL, NOW(), NOW(), 'admin', 'admin',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL
);

-- Step2: Home DB로 전송 (HOMECAST)
--   원천DB에서 추출한 TBL_METASYSTEMDATA를 Home DB(DLM)로 복사
INSERT INTO COTDL.TBL_PIISTEP (
    JOBID, VERSION, STEPID, STEPNAME, STEPTYPE, STEPSEQ, DB,
    STATUS, PHASE, THREADCNT, COMMITCNT,
    ENDDATE, REGDATE, UPDDATE, REGUSERID, UPDUSERID,
    DATA_HANDLING_METHOD, PROCESSING_METHOD, FK_DISABLE_FLAG, INDEX_UNUSUAL_FLAG,
    VAL1, VAL2, VAL3, VAL4, VAL5
) VALUES (
    'DLM_BATCH_METASYSTEM', '1', 'EXE_HOMECAST', 'METASYSTEM HOMECAST', 'EXE_HOMECAST', 2, 'DAON',
    'ACTIVE', 'CHECKOUT', 10, 5000,
    NULL, NOW(), NOW(), 'admin', 'admin',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL
);


-- 4. STEPTABLE 등록

-- ────────────────────────────────────────────────────────────
-- Step1: EXTRACT_METASYSTEM (메타시스템 정보 추출)
-- ────────────────────────────────────────────────────────────

-- 4-1. 기존 TBL_METASYSTEMDATA 삭제 (원천 DB 기준)
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_METASYSTEM', '1', 'EXTRACT_METASYSTEM', 'DAON', 'COTDL', 'TBL_PIITABLE',
    NULL, 'EXCLUDE', 'EXTRACT', '', '', NULL, NULL,
    10, 100, 10, NULL,
    '기존 추출 METASYSTEM 정보 제거', '', '', NULL, NULL,
    NULL, 'DELETE FROM COTDL.TBL_METASYSTEMDATA',
    NULL, NULL, NULL, '', NULL,
    NOW(), NOW(), 'admin', 'admin'
);

-- 4-2. 기존 TBL_METASYSTEMDATA 삭제 (Home DB 기준)
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_METASYSTEM', '1', 'EXTRACT_METASYSTEM', 'DLM', 'COTDL', 'TBL_PIITABLE',
    NULL, 'EXCLUDE', 'EXTRACT', '', '', NULL, NULL,
    10, 200, 10, NULL,
    '기존 추출 METASYSTEM 정보 제거', '', '', NULL, NULL,
    NULL, 'DELETE FROM COTDL.TBL_METASYSTEMDATA',
    NULL, NULL, NULL, '', NULL,
    NOW(), NOW(), 'admin', 'admin'
);

-- 4-3. 메타시스템(WAM) 전체 정보 추출 → TBL_METASYSTEMDATA 적재
--   WAM_PDM_COL (컬럼)을 기준으로
--     - WAM_DB_DDL_TBL (테이블) LEFT JOIN
--     - WAA_META_DBMS (DB서버) INNER JOIN
--     - WAA_META_DBINSTANCE (인스턴스) INNER JOIN
--     - WAA_META_DBUSER (스키마) INNER JOIN
--     - WAM_DMN_DMN (도메인) LEFT JOIN
--   하여 PII 판단 정보 포함 전체 메타 수집
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_METASYSTEM', '1', 'EXTRACT_METASYSTEM', 'DAON', 'COTDL', 'TBL_PIITABLE',
    NULL, 'ADD', 'EXTRACT', '', '', NULL, NULL,
    10, 300, 10, NULL,
    '대상 METASYSTEM 전체 정보 추출', '', '', NULL, NULL,
    NULL,
'INSERT INTO COTDL.TBL_METASYSTEMDATA
SELECT A.OBJ_KNM AS DBSERVER_NM
     , C.OBJ_KNM AS OWNER
     , B.OBJ_KNM AS DBINSTANCE_NM
     , t.OBJ_KNM AS 테이블한글명
     , t.OBJ_ENM AS 테이블명
     , c.OBJ_KNM AS 컬럼한글명
     , c.OBJ_ENM AS 컬럼명
     , get_user_knm(c.ORGL_USER) AS 컬럼요청자
     , c.ORGL_DTTM AS 컬럼요청일자
     , get_user_knm(c.APRV_USER) AS 컬럼승인자
     , c.APRV_DTTM AS 컬럼승인일자
     , c.INFOTYPE_NM AS 속성명
     , c.IS_PK_YN AS pk구분
     , c.IS_FK_YN AS fk구분
     , c.IS_NULL_YN AS NULL여부
     , c.SRC_DEC_YN AS 소스복호화여부
     , c.DEST_ENC_YN AS 타겟암호화여부
     , c.CRYPT_YN  AS 암호화여부
     , c.OF_ADM_DIT AS 관리유형
     , d.OBJ_ENM AS 도메인
     , d.OBJ_KNM AS 도메인한글명
     , d.DMNGRP_NM AS 도메인그룹명
     , d.INFOTYPE_NM AS 도메인인포타입
     , CASE
            WHEN d.INFOTYPE_NM = ''PII''       AND c.DEST_ENC_YN = ''N'' THEN ''PII''
            WHEN d.INFOTYPE_NM = ''Sensitive'' AND c.DEST_ENC_YN = ''Y'' THEN ''PII_ENC''
            ELSE ''NOTPII''
       END AS 메타판단정보
  FROM WAM_PDM_COL c
  LEFT OUTER JOIN WAM_DB_DDL_TBL t
    ON t.OF_TABLE = c.OF_TABLE
   AND t.XPR_DTTM = TO_DATE(''9999-12-31'',''YYYY-MM-DD'')
   AND t.ORGL_TYPE IN (''C'', ''U'')
 INNER JOIN WAA_META_DBMS A
    ON A.OBJ_ID = T.OF_DBSERVER
   AND A.XPR_DTTM = TO_DATE(''9999-12-31'',''YYYY-MM-DD'')
   AND A.ORGL_TYPE IN (''C'', ''U'')
 INNER JOIN WAA_META_DBINSTANCE B
    ON B.OBJ_ID = T.OF_DBINSTANCE
   AND B.XPR_DTTM = TO_DATE(''9999-12-31'',''YYYY-MM-DD'')
   AND B.ORGL_TYPE IN (''C'', ''U'')
 INNER JOIN WAA_META_DBUSER C
    ON C.OBJ_ID = T.OF_DBUSER
   AND C.XPR_DTTM = TO_DATE(''9999-12-31'',''YYYY-MM-DD'')
   AND C.ORGL_TYPE IN (''C'', ''U'')
  LEFT OUTER JOIN WAM_DMN_DMN d
    ON d.OBJ_ID = c.OF_DOMAIN
   AND d.XPR_DTTM = TO_DATE(''9999-12-31'',''YYYY-MM-DD'')
   AND d.ORGL_TYPE IN (''C'', ''U'')
 WHERE 1=1
   AND c.XPR_DTTM = TO_DATE(''9999-12-31'',''YYYY-MM-DD'')
   AND c.ORGL_TYPE IN (''C'', ''U'')',
    NULL, NULL, NULL, '', NULL,
    NOW(), NOW(), 'admin', 'admin'
);

-- ────────────────────────────────────────────────────────────
-- Step2: EXE_HOMECAST (Home DB 전송)
-- ────────────────────────────────────────────────────────────

-- 4-4. 원천DB의 TBL_METASYSTEMDATA → Home DB(DLM)로 전송
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_METASYSTEM', '1', 'EXE_HOMECAST', 'DLM', 'COTDL', 'TBL_METASYSTEMDATA',
    NULL, NULL, 'HOMECAST', '', '', NULL, NULL,
    10, 100, 10, NULL,
    '', '', '', NULL, NULL,
    ' ',
'INSERT INTO COTDL.TBL_METASYSTEMDATA -- DB in Step
SELECT * FROM COTDL.TBL_METASYSTEMDATA -- Source DB : DAON',
    NULL, NULL, NULL, '', NULL,
    NOW(), NOW(), 'admin', 'admin'
);


COMMIT;
