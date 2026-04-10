-- ============================================================
-- DLM_BATCH_BIZDAY : 영업일 달력 수집 배치 잡
-- ============================================================
-- 고객사 처리계(원천DB)의 영업일 테이블에서 데이터를 추출하여
-- DLM Home DB의 TBL_PIIBIZDAY에 반영하는 배치 잡 등록 스크립트.
--
-- [배치 흐름]
--   Step1 EXTRACT_BIZDAY : 원천DB 영업일 테이블 → TBL_PIIBIZDAY_TMP 추출
--   Step2 EXE_HOMECAST   : TMP 테이블을 Home DB(DLM)로 전송
--   Step3 EXE_FINISH     : Home DB에 최종 반영 (DELETE + INSERT) + TMP 정리
--
-- [접속기록 연계]
--   이상행위 탐지 규칙 R08(휴일 접근 탐지)에서 TBL_PIIBIZDAY를 참조하여
--   HLDY_YN = 'Y'인 날에 접속한 사용자를 탐지한다.
--
-- [원천DB 요건]
--   고객사 처리계에 영업일 테이블이 존재해야 하며,
--   Step1의 SQLSTR을 고객사 테이블 구조에 맞게 수정해야 한다.
--
-- ============================================================
-- 사이트별 배포 시 아래 변수를 해당 사이트 값으로 치환(Replace All)하세요.
--
--   DLM_BATCH_BIZDAY_DAON               -> 잡 ID                 (예: DLM_BATCH_BIZDAY_DAON)
--   DAON           -> 원천 DB명 (TBL_PIIDATABASE 등록명)  (예: COREBANK)
--   DLM             -> DLM Home DB명          (예: DLM)
--   COTDL          -> DLM 스키마명           (예: COTDL)
--   11:00          -> 실행 시각 (HH:MM)      (기본: 11:00, 매주 일요일)
--   admin          -> 등록/수정 사용자 ID     (예: admin)
--   MYCLIENT             -> 기관 코드               (예: MYBANK)
--
-- ============================================================
-- ★ 고객사별 수정 필요 항목 (Step1 SQLSTR)
-- ============================================================
--   고객사 처리계의 영업일 테이블 구조가 다르므로,
--   Step1(SEQ 100)의 SQLSTR을 고객사에 맞게 수정해야 합니다.
--
--   DLM TBL_PIIBIZDAY 레이아웃:
--     BASE_DT         VARCHAR(8)  PK  -- 기준일자 (YYYYMMDD)
--     BF_BF_BIZ_DT    VARCHAR(8)      -- 전전영업일
--     BF_BIZ_DT       VARCHAR(8)      -- 전영업일
--     BIZ_DT          VARCHAR(8)      -- 영업일 (휴일이면 익영업일)
--     NXT_BIZ_DT      VARCHAR(8)      -- 익영업일
--     NXT_NXT_BIZ_DT  VARCHAR(8)      -- 익익영업일
--     HLDY_YN         VARCHAR(1)  NN  -- 휴일여부 (Y/N)
--     INST_CD         VARCHAR(14)     -- 기관코드
--
--   원천 테이블 예시 (고객사마다 다름):
--     ┌──────────────────────────────────────────────────┐
--     │ 예시 A (은행)                                     │
--     │ TB_CM_BIZDAY: BIZ_DT, PRE_BIZ_DT, NXT_BIZ_DT,  │
--     │               HLDY_YN, HLDY_NM                   │
--     ├──────────────────────────────────────────────────┤
--     │ 예시 B (카드사)                                    │
--     │ CM_CALENDAR: CAL_DT, WORK_DAY_YN, BF_WORK_DT,   │
--     │              AF_WORK_DT                           │
--     ├──────────────────────────────────────────────────┤
--     │ 예시 C (보험사)                                    │
--     │ T_COM_HOLIDAY: BASE_DATE, HOLIDAY_FLAG,           │
--     │                PRE_WORK_DATE, NEXT_WORK_DATE      │
--     └──────────────────────────────────────────────────┘
-- ============================================================


-- 1. 기존 잡 정의 삭제 (재실행 가능)
DELETE FROM COTDL.TBL_PIIJOB       WHERE JOBID = 'DLM_BATCH_BIZDAY_DAON';
DELETE FROM COTDL.TBL_PIISTEP      WHERE JOBID = 'DLM_BATCH_BIZDAY_DAON';
DELETE FROM COTDL.TBL_PIISTEPTABLE WHERE JOBID = 'DLM_BATCH_BIZDAY_DAON';


-- ============================================================
-- 1-1. TMP 테이블 생성 (없으면)
-- ============================================================
CREATE TABLE IF NOT EXISTS COTDL.TBL_PIIBIZDAY_TMP LIKE COTDL.TBL_PIIBIZDAY;


-- ============================================================
-- 2. JOB 등록
-- ============================================================
INSERT INTO COTDL.TBL_PIIJOB (
    JOBID, VERSION, JOBNAME, `SYSTEM`, POLICY_ID, KEYMAP_ID,
    JOBTYPE, RUNTYPE, CALENDAR, `TIME`, CRONVAL, CONFIRMFLAG, STATUS, PHASE,
    JOB_OWNER_ID1, JOB_OWNER_NAME1,
    JOB_OWNER_ID2, JOB_OWNER_NAME2,
    JOB_OWNER_ID3, JOB_OWNER_NAME3,
    ENDDATE, REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', '영업일 달력 수집 (DAON)', NULL, NULL, NULL,
    'BATCH', 'DLM_BATCH', 'WEEK_SUN', '11:00', '##########', 'N', 'ACTIVE', 'CHECKIN',
    'admin', 'admin',
    NULL, NULL,
    NULL, NULL,
    NULL, NOW(), NOW(), 'admin', 'admin'
);


-- ============================================================
-- 3. STEP 등록 (3단계)
-- ============================================================

-- Step1: 원천DB에서 영업일 추출
INSERT INTO COTDL.TBL_PIISTEP (
    JOBID, VERSION, STEPID, STEPNAME, STEPTYPE, STEPSEQ, DB,
    STATUS, PHASE, THREADCNT, COMMITCNT,
    ENDDATE, REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', 'EXTRACT_BIZDAY', 'BIZDAY_EXTRACT', 'EXE_EXTRACT', 1, 'DAON',
    'ACTIVE', 'CHECKOUT', 1, 5000,
    NULL, NOW(), NOW(), 'admin', 'admin'
);

-- Step2: TMP 테이블을 Home DB로 전송
INSERT INTO COTDL.TBL_PIISTEP (
    JOBID, VERSION, STEPID, STEPNAME, STEPTYPE, STEPSEQ, DB,
    STATUS, PHASE, THREADCNT, COMMITCNT,
    ENDDATE, REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', 'EXE_HOMECAST', 'BIZDAY_HOMECAST', 'EXE_HOMECAST', 2, 'DAON',
    'ACTIVE', 'CHECKOUT', 1, 5000,
    NULL, NOW(), NOW(), 'admin', 'admin'
);

-- Step3: Home DB 최종 반영 + 정리
INSERT INTO COTDL.TBL_PIISTEP (
    JOBID, VERSION, STEPID, STEPNAME, STEPTYPE, STEPSEQ, DB,
    STATUS, PHASE, THREADCNT, COMMITCNT,
    ENDDATE, REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', 'EXE_FINISH', 'BIZDAY_FINISH', 'EXE_FINISH', 3, 'DAON',
    'ACTIVE', 'CHECKOUT', 1, 5000,
    NULL, NOW(), NOW(), 'admin', 'admin'
);


-- ============================================================
-- 4. STEPTABLE 등록
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- Step1: EXTRACT_BIZDAY (원천DB에서 실행)
-- ────────────────────────────────────────────────────────────

-- 4-1-1. [SEQ 100] TMP 테이블 초기화
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', 'EXTRACT_BIZDAY', 'DAON', 'COTDL', 'TBL_PIIBIZDAY_TMP',
    NULL, 'ADD', 'EXTRACT', NULL, NULL, NULL, NULL,
    10, 100, 10, NULL,
    '임시테이블 초기화', NULL, NULL, NULL, NULL,
    NULL,
'DELETE FROM COTDL.TBL_PIIBIZDAY_TMP',
    NULL, NULL, NULL, NULL, NULL,
    NOW(), NOW(), 'admin', 'admin'
);

-- 4-1-2. [SEQ 200] 원천DB 영업일 테이블 → TBL_PIIBIZDAY_TMP 추출
-- ★★★ 고객사별 수정 필요 ★★★
-- 아래 SQLSTR의 원천 테이블명/컬럼명을 고객사 처리계에 맞게 변경하세요.
-- DLM 레이아웃(BASE_DT, BF_BF_BIZ_DT, BF_BIZ_DT, BIZ_DT, NXT_BIZ_DT, NXT_NXT_BIZ_DT, HLDY_YN, INST_CD)에
-- 맞추어 SELECT 하면 됩니다. 없는 컬럼은 NULL로 매핑하세요.
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', 'EXTRACT_BIZDAY', 'DAON', 'COTDL', 'TBL_PIIBIZDAY_TMP',
    NULL, 'ADD', 'EXTRACT', NULL, NULL, NULL, NULL,
    10, 200, 10, NULL,
    '원천DB 영업일 추출', NULL, NULL, NULL, NULL,
    NULL,
-- ┌──────────────────────────────────────────────────────────────────┐
-- │ ★ 고객사 원천 테이블에 맞게 아래 SQL을 수정하세요              │
-- │                                                                  │
-- │ 예시 A (은행): TB_CM_BIZDAY                                      │
-- │   SELECT BIZ_DT, PRE_PRE_BIZ_DT, PRE_BIZ_DT, BIZ_DT,          │
-- │          NXT_BIZ_DT, NXT_NXT_BIZ_DT, HLDY_YN, ''MYCLIENT''  │
-- │   FROM SCHEMA.TB_CM_BIZDAY                                       │
-- │   WHERE BIZ_DT >= DATE_FORMAT(CURDATE(), ''%Y%m%d'')            │
-- │                                                                  │
-- │ 예시 B (카드사): CM_CALENDAR                                     │
-- │   SELECT CAL_DT, NULL, BF_WORK_DT, WORK_DT,                    │
-- │          AF_WORK_DT, NULL,                                       │
-- │          CASE WHEN WORK_DAY_YN=''N'' THEN ''Y'' ELSE ''N'' END, │
-- │          ''MYCLIENT''                                          │
-- │   FROM SCHEMA.CM_CALENDAR                                        │
-- │   WHERE CAL_DT >= DATE_FORMAT(CURDATE(), ''%Y%m%d'')            │
-- │                                                                  │
-- │ 예시 C (보험사): T_COM_HOLIDAY                                   │
-- │   SELECT BASE_DATE, NULL, PRE_WORK_DATE,                        │
-- │          CASE WHEN HOLIDAY_FLAG=''Y'' THEN PRE_WORK_DATE         │
-- │               ELSE BASE_DATE END,                                │
-- │          NEXT_WORK_DATE, NULL, HOLIDAY_FLAG, ''MYCLIENT''     │
-- │   FROM SCHEMA.T_COM_HOLIDAY                                      │
-- │   WHERE BASE_DATE >= DATE_FORMAT(CURDATE(), ''%Y%m%d'')         │
-- └──────────────────────────────────────────────────────────────────┘
'INSERT INTO COTDL.TBL_PIIBIZDAY_TMP
    (BASE_DT, BF_BF_BIZ_DT, BF_BIZ_DT, BIZ_DT, NXT_BIZ_DT, NXT_NXT_BIZ_DT, HLDY_YN, INST_CD)
SELECT
    A.BASE_DT                   AS BASE_DT,
    A.BF_BF_BIZ_DT              AS BF_BF_BIZ_DT,
    A.BF_BIZ_DT                 AS BF_BIZ_DT,
    A.BIZ_DT                    AS BIZ_DT,
    A.NXT_BIZ_DT                AS NXT_BIZ_DT,
    A.NXT_NXT_BIZ_DT            AS NXT_NXT_BIZ_DT,
    A.HLDY_YN                   AS HLDY_YN,
    ''MYCLIENT''              AS INST_CD
FROM #{SOURCE_SCHEMA}.#{SOURCE_TABLE} A
WHERE A.BASE_DT >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 YEAR), ''%Y%m%d'')',
    NULL, NULL, NULL, NULL, NULL,
    NOW(), NOW(), 'admin', 'admin'
);

-- 4-1-3. [SEQ 100] HOME TMP 테이블 초기화
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', 'EXTRACT_BIZDAY', 'DLM', 'COTDL', 'TBL_PIIBIZDAY_TMP',
    NULL, 'ADD', 'EXTRACT', NULL, NULL, NULL, NULL,
    10, 300, 10, NULL,
    'HOME 임시테이블 초기화', NULL, NULL, NULL, NULL,
    NULL,
'DELETE FROM COTDL.TBL_PIIBIZDAY_TMP',
    NULL, NULL, NULL, NULL, NULL,
    NOW(), NOW(), 'admin', 'admin'
);
-- ────────────────────────────────────────────────────────────
-- Step2: EXE_HOMECAST (원천DB → Home DB 전송)
-- ────────────────────────────────────────────────────────────

-- 4-2-1. [SEQ 100] TBL_PIIBIZDAY_TMP를 Home DB로 전송
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', 'EXE_HOMECAST', 'DAON', 'COTDL', 'TBL_PIIBIZDAY_TMP',
    NULL, NULL, 'HOMECAST', NULL, NULL, NULL, NULL,
    10, 100, 10, NULL,
    NULL, NULL, NULL, NULL, NULL,
    ' ',
'INSERT INTO COTDL.TBL_PIIBIZDAY_TMP
SELECT * FROM COTDL.TBL_PIIBIZDAY_TMP',
    NULL, NULL, NULL, NULL, 'AUTO',
    NOW(), NOW(), 'admin', 'admin'
);


-- ────────────────────────────────────────────────────────────
-- Step3: EXE_FINISH (정리 + Home DB 최종 반영)
-- ────────────────────────────────────────────────────────────

-- 4-3-1. [SEQ 100] 원천DB TBL_PIIBIZDAY_TMP 정리
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', 'EXE_FINISH', 'DAON', 'COTDL', 'TBL_PIIBIZDAY_TMP',
    NULL, NULL, 'FINISH', NULL, NULL, NULL, NULL,
    10, 100, 10, NULL,
    NULL, NULL, NULL, NULL, NULL,
    ' ',
'DELETE FROM COTDL.TBL_PIIBIZDAY_TMP',
    NULL, NULL, NULL, NULL, 'AUTO',
    NOW(), NOW(), 'admin', 'admin'
);

-- 4-3-2. [SEQ 200] Home DB: 기존 영업일 삭제 (TMP에 있는 기간만)
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', 'EXE_FINISH', 'DLM', 'COTDL', 'TBL_PIIBIZDAY',
    NULL, NULL, 'FINISH', NULL, NULL, NULL, NULL,
    10, 200, 10, NULL,
    NULL, NULL, NULL, NULL, NULL,
    ' ',
'DELETE FROM COTDL.TBL_PIIBIZDAY
WHERE 1=1',
    NULL, NULL, NULL, NULL, 'AUTO',
    NOW(), NOW(), 'admin', 'admin'
);

-- 4-3-3. [SEQ 300] Home DB: TMP → TBL_PIIBIZDAY 반영
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', 'EXE_FINISH', 'DLM', 'COTDL', 'TBL_PIIBIZDAY',
    NULL, NULL, 'FINISH', NULL, NULL, NULL, NULL,
    10, 300, 10, NULL,
    NULL, NULL, NULL, NULL, NULL,
    ' ',
'INSERT INTO COTDL.TBL_PIIBIZDAY
SELECT * FROM COTDL.TBL_PIIBIZDAY_TMP',
    NULL, NULL, NULL, NULL, 'AUTO',
    NOW(), NOW(), 'admin', 'admin'
);

-- 4-3-4. [SEQ 400] Home DB: TBL_PIIBIZDAY_TMP 정리
INSERT INTO COTDL.TBL_PIISTEPTABLE (
    JOBID, VERSION, STEPID, DB, OWNER, TABLE_NAME,
    PAGITYPE, PAGITYPEDETAIL, EXETYPE, ARCHIVEFLAG, STATUS, `PRECEDING`, SUCCEDDING,
    SEQ1, SEQ2, SEQ3, PIPELINE,
    PK_COL, WHERE_COL, WHERE_KEY_NAME, PARALLELCNT, COMMITCNT,
    WHERESTR, SQLSTR,
    KEYMAP_ID, KEY_NAME, KEY_COLS, KEY_REFSTR, SQLTYPE,
    REGDATE, UPDDATE, REGUSERID, UPDUSERID
) VALUES (
    'DLM_BATCH_BIZDAY_DAON', '1', 'EXE_FINISH', 'DLM', 'COTDL', 'TBL_PIIBIZDAY_TMP',
    NULL, NULL, 'FINISH', NULL, NULL, NULL, NULL,
    10, 400, 10, NULL,
    NULL, NULL, NULL, NULL, NULL,
    ' ',
'DELETE FROM COTDL.TBL_PIIBIZDAY_TMP',
    NULL, NULL, NULL, NULL, 'AUTO',
    NOW(), NOW(), 'admin', 'admin'
);


COMMIT;


-- ============================================================
-- 배포 가이드
-- ============================================================
--
-- [치환 변수 예시]
--   DLM_BATCH_BIZDAY_DAON          → DLM_BATCH_BIZDAY_DAONBANK
--   DAON      → COREBANK
--   DLM        → DLM
--   COTDL     → COTDL
--   11:00     → 00:30
--   admin     → admin
--   MYCLIENT        → MYBANK
--   #{SOURCE_SCHEMA}  → CORE_SCHEMA    (고객사 스키마)
--   #{SOURCE_TABLE}   → TB_CM_BIZDAY   (고객사 영업일 테이블)
--
-- [고객사별 수정 포인트]
--   Step1 SEQ200의 SQLSTR만 수정하면 됩니다.
--   고객사 영업일 테이블의 컬럼을 DLM 레이아웃에 맞춰 매핑:
--
--   DLM 컬럼         ← 고객사 컬럼 (예시)
--   ──────────────────────────────────────
--   BASE_DT          ← BIZ_DT / CAL_DT / BASE_DATE
--   BF_BF_BIZ_DT     ← PRE_PRE_BIZ_DT (없으면 NULL)
--   BF_BIZ_DT        ← PRE_BIZ_DT / BF_WORK_DT
--   BIZ_DT           ← BIZ_DT / WORK_DT
--   NXT_BIZ_DT       ← NXT_BIZ_DT / AF_WORK_DT
--   NXT_NXT_BIZ_DT   ← NXT_NXT_BIZ_DT (없으면 NULL)
--   HLDY_YN          ← HLDY_YN / HOLIDAY_FLAG
--                       (주의: WORK_DAY_YN이면 반전 필요)
--   INST_CD          ← 'MYCLIENT' (고정값)
--
-- ============================================================
