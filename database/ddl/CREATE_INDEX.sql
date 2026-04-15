-- ==============================================================================
-- DLM 인덱스 DDL (성능 최적화)
-- MariaDB 10.5+ 'IF NOT EXISTS' 지원
-- 생성일: 2026-04-07
--
-- 실행: docker exec dlm-mariadb sh -c 'echo "[client]
-- password=!Dlm1234" > /tmp/.my.cnf && mysql --defaults-extra-file=/tmp/.my.cnf -u root COTDL < /tmp/CREATE_INDEX.sql && rm /tmp/.my.cnf'
-- ==============================================================================

USE COTDL;

-- ##############################################################################
-- [1] tbl_piiorder (현재 ~591건, 지속 증가)
--     PK: ORDERID
--     기존: idx_piiorder_status(STATUS), idx_piiorder_eststarttime(ESTSTARTTIME)
-- ##############################################################################

-- 스케줄러(getRunableList), 중복체크(getSameOrderCnt), 복구건수 조회에서 사용
CREATE INDEX IF NOT EXISTS idx_piiorder_jobid_basedate
    ON COTDL.tbl_piiorder (JOBID, BASEDATE);

-- deleteCompletedNonPiiOrders 정리 쿼리, readMaxOrderOkByJobid
CREATE INDEX IF NOT EXISTS idx_piiorder_jobtype_status
    ON COTDL.tbl_piiorder (JOBTYPE, STATUS);

-- getRestorableList/getRestoreStepArcList JOIN 조건
CREATE INDEX IF NOT EXISTS idx_piiorder_keymap_basedate
    ON COTDL.tbl_piiorder (KEYMAP_ID, BASEDATE);

-- deleteCompletedNonPiiOrders: WHERE realendtime < DATE_SUB(...)
CREATE INDEX IF NOT EXISTS idx_piiorder_realendtime
    ON COTDL.tbl_piiorder (REALENDTIME);

-- Basedate 단독 검색 (idx_piiorder_jobid_basedate는 JOBID 선두라 basedate만 검색 시 비효율)
CREATE INDEX IF NOT EXISTS idx_piiorder_basedate
    ON COTDL.tbl_piiorder (BASEDATE);

-- 수행타입(RUNTYPE) 필터
CREATE INDEX IF NOT EXISTS idx_piiorder_runtype
    ON COTDL.tbl_piiorder (RUNTYPE);

-- 담당자 OR 검색: orderuserid = ? OR JOB_OWNER_ID1 = ? OR JOB_OWNER_NAME1 = ? ...
-- OR 조건은 각 컬럼별 인덱스가 있어야 index_merge 가능
CREATE INDEX IF NOT EXISTS idx_piiorder_orderuserid
    ON COTDL.tbl_piiorder (ORDERUSERID);

CREATE INDEX IF NOT EXISTS idx_piiorder_job_owner_id1
    ON COTDL.tbl_piiorder (JOB_OWNER_ID1);

CREATE INDEX IF NOT EXISTS idx_piiorder_job_owner_name1
    ON COTDL.tbl_piiorder (JOB_OWNER_NAME1);

CREATE INDEX IF NOT EXISTS idx_piiorder_job_owner_id2
    ON COTDL.tbl_piiorder (JOB_OWNER_ID2);

CREATE INDEX IF NOT EXISTS idx_piiorder_job_owner_id3
    ON COTDL.tbl_piiorder (JOB_OWNER_ID3);


-- ##############################################################################
-- [2] tbl_piiorderstep (현재 ~1,808건)
--     PK: ORDERID, JOBID, VERSION, STEPID
-- ##############################################################################

-- 상태별 필터링 (Running, Wait condition, Ended OK 등)
CREATE INDEX IF NOT EXISTS idx_piiorderstep_status
    ON COTDL.tbl_piiorderstep (STATUS);

-- steptype별 필터링 (EXE_DELETE, EXE_UPDATE, EXE_ARCHIVE)
CREATE INDEX IF NOT EXISTS idx_piiorderstep_steptype
    ON COTDL.tbl_piiorderstep (STEPTYPE);

-- ORDER BY stepseq 정렬 (PK에 stepseq 없음)
CREATE INDEX IF NOT EXISTS idx_piiorderstep_orderid_stepseq
    ON COTDL.tbl_piiorderstep (ORDERID, STEPSEQ);


-- ##############################################################################
-- [3] tbl_piiordersteptable (현재 ~23,775건, 대형 테이블)
--     PK: ORDERID, STEPID, SEQ1, SEQ2, SEQ3
-- ##############################################################################

-- exetype별 필터링 (ARCHIVE, KEYMAP, DELETE, UPDATE)
CREATE INDEX IF NOT EXISTS idx_piiordersteptable_exetype
    ON COTDL.tbl_piiordersteptable (EXETYPE);

-- 상태별 필터링
CREATE INDEX IF NOT EXISTS idx_piiordersteptable_status
    ON COTDL.tbl_piiordersteptable (STATUS);

-- consent 쿼리: WHERE jobid = ? AND steptype = ?
CREATE INDEX IF NOT EXISTS idx_piiordersteptable_jobid_steptype
    ON COTDL.tbl_piiordersteptable (JOBID, STEPTYPE);

-- DB/TABLE 기반 조회 (PK에 DB/OWNER/TABLE_NAME 없음)
CREATE INDEX IF NOT EXISTS idx_piiordersteptable_db_owner_table
    ON COTDL.tbl_piiordersteptable (DB, OWNER, TABLE_NAME);


-- ##############################################################################
-- [4] tbl_piiordersteptableupdate (현재 ~8,202건)
--     PK: ORDERID, JOBID, VERSION, STEPID, SEQ1, SEQ2, SEQ3, COLUMN_NAME
-- ##############################################################################

-- deleteCompletedNonPiiOrders에서 orderid 기반 삭제
-- PK 시작이 ORDERID이므로 커버됨 - 추가 인덱스 불필요


-- ##############################################################################
-- [5] tbl_piijob (현재 ~52건, 소형이나 빈번 조회)
--     PK: JOBID, VERSION
-- ##############################################################################

-- MetaPiiStatus 재구축, TestData 조회 등에서 복합 필터
CREATE INDEX IF NOT EXISTS idx_piijob_status_runtype_jobtype
    ON COTDL.tbl_piijob (STATUS, RUNTYPE, JOBTYPE);

-- 정책별 Job 조회
CREATE INDEX IF NOT EXISTS idx_piijob_policy_id
    ON COTDL.tbl_piijob (POLICY_ID);

-- 시스템별 Job 조회
CREATE INDEX IF NOT EXISTS idx_piijob_system
    ON COTDL.tbl_piijob (SYSTEM);


-- ##############################################################################
-- [6] tbl_piistep (현재 ~160건)
--     PK: JOBID, VERSION, STEPID
-- ##############################################################################

-- ORDER BY stepseq (PK에 없음)
CREATE INDEX IF NOT EXISTS idx_piistep_jobid_version_stepseq
    ON COTDL.tbl_piistep (JOBID, VERSION, STEPSEQ);

-- steptype별 필터
CREATE INDEX IF NOT EXISTS idx_piistep_steptype
    ON COTDL.tbl_piistep (STEPTYPE);


-- ##############################################################################
-- [7] tbl_piisteptable (현재 ~6,567건)
--     PK: JOBID, VERSION, STEPID, SEQ1, SEQ2, SEQ3
-- ##############################################################################

-- exetype별 필터 (ARCHIVE, KEYMAP, DELETE, UPDATE)
CREATE INDEX IF NOT EXISTS idx_piisteptable_exetype
    ON COTDL.tbl_piisteptable (EXETYPE);

-- DB/OWNER/TABLE 기반 JOIN (MetaPiiStatus GAP 분석 등)
CREATE INDEX IF NOT EXISTS idx_piisteptable_db_owner_table
    ON COTDL.tbl_piisteptable (DB, OWNER, TABLE_NAME);


-- ##############################################################################
-- [8] tbl_piitable (현재 ~54,015건, 최대 테이블)
--     PK: DB, OWNER, TABLE_NAME, COLUMN_NAME
--     참고: PIITYPE 컬럼 없음 (tbl_metatable에만 존재)
--     검색필터: db(=), owner(LIKE/JOIN), table_name(LIKE/JOIN)
-- ##############################################################################

-- ORDER BY column_id (PK에 없음)
CREATE INDEX IF NOT EXISTS idx_piitable_db_owner_table_colid
    ON COTDL.tbl_piitable (DB, OWNER, TABLE_NAME, COLUMN_ID);

-- table_name 단독 LIKE 검색 + JOIN (PK 3번째라 단독 검색 불가)
CREATE INDEX IF NOT EXISTS idx_piitable_table_name
    ON COTDL.tbl_piitable (TABLE_NAME);

-- column_name 단독 검색 (PK 4번째라 단독 검색 불가)
CREATE INDEX IF NOT EXISTS idx_piitable_column_name
    ON COTDL.tbl_piitable (COLUMN_NAME);

-- owner + table_name 복합 (Layout Gap JOIN + owner 단독 LIKE 검색도 커버)
CREATE INDEX IF NOT EXISTS idx_piitable_owner_table
    ON COTDL.tbl_piitable (OWNER, TABLE_NAME);


-- ##############################################################################
-- [9] tbl_metatable (현재 ~9,053건)
--     PK: DB, OWNER, TABLE_NAME, COLUMN_NAME
--     검색필터: db(=), owner(=), table_name(LIKE), column_name(LIKE),
--              piitype, piigrade, encript_flag, scramble_type,
--              val1, val2(LIKE PII%), val3(NOT NULL), column_comment(LIKE),
--              upddate(범위)
--     정렬: regdate DESC, upddate DESC, val3 DESC
-- ##############################################################################

-- PIITYPE 필터 (IS NOT NULL, IS NULL, = 값)
CREATE INDEX IF NOT EXISTS idx_metatable_piitype
    ON COTDL.tbl_metatable (PIITYPE);

-- PIIGRADE 필터 (IS NOT NULL, IS NULL, = 값)
CREATE INDEX IF NOT EXISTS idx_metatable_piigrade
    ON COTDL.tbl_metatable (PIIGRADE);

-- 암호화 여부 필터
CREATE INDEX IF NOT EXISTS idx_metatable_encript_flag
    ON COTDL.tbl_metatable (ENCRIPT_FLAG);

-- 비식별화 유형 필터 (IS NOT NULL/IS NULL)
CREATE INDEX IF NOT EXISTS idx_metatable_scramble_type
    ON COTDL.tbl_metatable (SCRAMBLE_TYPE);

-- 수정일 기반 범위 검색 + ORDER BY
CREATE INDEX IF NOT EXISTS idx_metatable_upddate
    ON COTDL.tbl_metatable (UPDDATE);

-- 등록일 ORDER BY DESC
CREATE INDEX IF NOT EXISTS idx_metatable_regdate
    ON COTDL.tbl_metatable (REGDATE);

-- ORDER BY column_id (PK에 없음)
CREATE INDEX IF NOT EXISTS idx_metatable_db_owner_table_colid
    ON COTDL.tbl_metatable (DB, OWNER, TABLE_NAME, COLUMN_ID);

-- table_name 단독 LIKE 검색 (PK 3번째라 db+owner 없이 검색 시 비효율)
CREATE INDEX IF NOT EXISTS idx_metatable_table_name
    ON COTDL.tbl_metatable (TABLE_NAME);

-- column_name 단독 LIKE 검색 (PK 4번째)
CREATE INDEX IF NOT EXISTS idx_metatable_column_name
    ON COTDL.tbl_metatable (COLUMN_NAME);

-- val1 필터 (검증대상 Y/N)
CREATE INDEX IF NOT EXISTS idx_metatable_val1
    ON COTDL.tbl_metatable (VAL1);

-- val2 필터 (PII확인: 'PII%', 'NONPII%' prefix 검색)
CREATE INDEX IF NOT EXISTS idx_metatable_val2
    ON COTDL.tbl_metatable (VAL2);

-- val3 필터 (검증완료 여부 IS NOT NULL) + ORDER BY val3 DESC
CREATE INDEX IF NOT EXISTS idx_metatable_val3
    ON COTDL.tbl_metatable (VAL3);


-- ##############################################################################
-- [10] tbl_piiextract (현재 ~4,047건, 고객 데이터 증가)
--      PK: ORDERID, JOBID, ACTID, CUSTID, BASEDATE
--      검색필터: custid(=), cust_nm(=), birth_dt(=),
--               delete_date(범위), arc_del_date(범위), orderid(=), jobid(prefix)
-- ##############################################################################

-- custid 단독 검색 (PK 선두 컬럼이 ORDERID이므로 custid 검색 시 풀스캔)
CREATE INDEX IF NOT EXISTS idx_piiextract_custid
    ON COTDL.tbl_piiextract (CUSTID);

-- 고객명 검색
CREATE INDEX IF NOT EXISTS idx_piiextract_cust_nm
    ON COTDL.tbl_piiextract (CUST_NM);

-- 생년월일 검색
CREATE INDEX IF NOT EXISTS idx_piiextract_birth_dt
    ON COTDL.tbl_piiextract (BIRTH_DT);

-- 파기기준일(delete_date) 범위 검색
CREATE INDEX IF NOT EXISTS idx_piiextract_delete_date
    ON COTDL.tbl_piiextract (DELETE_DATE);

-- JOBID prefix 검색 (substr(jobid,1,11) = ?)
CREATE INDEX IF NOT EXISTS idx_piiextract_jobid
    ON COTDL.tbl_piiextract (JOBID);

-- 파기 대상 조회: EXCLUDE_REASON 필터
CREATE INDEX IF NOT EXISTS idx_piiextract_exclude_reason
    ON COTDL.tbl_piiextract (EXCLUDE_REASON);

-- 아카이브/복원 관련 날짜 필터
CREATE INDEX IF NOT EXISTS idx_piiextract_archive_date
    ON COTDL.tbl_piiextract (ARCHIVE_DATE);

CREATE INDEX IF NOT EXISTS idx_piiextract_restore_date
    ON COTDL.tbl_piiextract (RESTORE_DATE);

-- ARC_DEL_DATE 범위 검색
CREATE INDEX IF NOT EXISTS idx_piiextract_arc_del_date
    ON COTDL.tbl_piiextract (ARC_DEL_DATE);


-- ##############################################################################
-- [11] tbl_piicontract (현재 ~766건)
--      PK: CUSTID, CONTRACTNO
--      기존: idx_piicontract_arc_del_date, idx_piicontract_delete_date
-- ##############################################################################

-- 관리부서 + 상태 복합 필터 (getListWithPaging, getStatListWithPaging)
CREATE INDEX IF NOT EXISTS idx_piicontract_mgmt_dept_status
    ON COTDL.tbl_piicontract (MGMT_DEPT_CD, STATUS);

-- ORDER BY dept_cd
CREATE INDEX IF NOT EXISTS idx_piicontract_dept_cd
    ON COTDL.tbl_piicontract (DEPT_CD);


-- ##############################################################################
-- [12] tbl_innerstep (현재 ~4,663건)
--      PK: ORDERID, STEPID, SEQ1, SEQ2, SEQ3, INNER_STEP_SEQ
-- ##############################################################################

-- getOrphanedTmpSteps: WHERE status 필터
CREATE INDEX IF NOT EXISTS idx_innerstep_status
    ON COTDL.tbl_innerstep (STATUS);


-- ##############################################################################
-- [13] tbl_piidetect_result (현재 ~926건)
--      PK: DB, OWNER, TABLE_NAME, COLUMN_NAME, ORDERID
-- ##############################################################################

-- ORDER BY orderid DESC (PK 선두가 DB이므로 orderid 정렬 시 비효율)
CREATE INDEX IF NOT EXISTS idx_piidetect_result_orderid
    ON COTDL.tbl_piidetect_result (ORDERID);


-- ##############################################################################
-- [14] tbl_piirestore (현재 ~130건, 복원건수 증가 가능)
--      PK: RESTOREID
-- ##############################################################################

-- custid 검색 (복원 대상 고객 조회)
CREATE INDEX IF NOT EXISTS idx_piirestore_custid
    ON COTDL.tbl_piirestore (CUSTID);

-- old_orderid 기반 JOIN (원본 주문 조회)
CREATE INDEX IF NOT EXISTS idx_piirestore_old_orderid
    ON COTDL.tbl_piirestore (OLD_ORDERID);

-- getRestorableList JOIN: keymap_id + basedate
CREATE INDEX IF NOT EXISTS idx_piirestore_keymap_basedate
    ON COTDL.tbl_piirestore (KEYMAP_ID, BASEDATE);


-- ##############################################################################
-- [15] tbl_piirecovery (현재 ~4건, 증가 가능)
--      PK: RECOVERYID
-- ##############################################################################

-- old_jobid 검색 (복구 대상 조회)
CREATE INDEX IF NOT EXISTS idx_piirecovery_old_jobid
    ON COTDL.tbl_piirecovery (OLD_JOBID);

-- basedate 날짜 필터
CREATE INDEX IF NOT EXISTS idx_piirecovery_basedate
    ON COTDL.tbl_piirecovery (BASEDATE);


-- ##############################################################################
-- [16] tbl_piiapprovalreq (현재 ~76건, 승인 요청 증가)
--      PK: REQID, APRVLINEID
-- ##############################################################################

-- approvalid별 조회 (TESTDATA_APPROVAL, RESTORE_APPROVAL 등)
CREATE INDEX IF NOT EXISTS idx_piiapprovalreq_approvalid
    ON COTDL.tbl_piiapprovalreq (APPROVALID);

-- 요청자별 조회
CREATE INDEX IF NOT EXISTS idx_piiapprovalreq_requesterid
    ON COTDL.tbl_piiapprovalreq (REQUESTERID);

-- jobid 기반 JOIN (testdata, restore 등과 연결)
CREATE INDEX IF NOT EXISTS idx_piiapprovalreq_jobid
    ON COTDL.tbl_piiapprovalreq (JOBID);

-- 신청자명 LIKE 검색 (테스트데이터 결과 조회 화면)
CREATE INDEX IF NOT EXISTS idx_piiapprovalreq_requestername
    ON COTDL.tbl_piiapprovalreq (REQUESTERNAME);


-- ##############################################################################
-- [17] tbl_testdata (현재 ~29건)
--      PK: TESTDATAID
-- ##############################################################################

-- 상태별 필터 (disposal 대상 조회)
CREATE INDEX IF NOT EXISTS idx_testdata_status
    ON COTDL.tbl_testdata (STATUS);

-- custid 검색
CREATE INDEX IF NOT EXISTS idx_testdata_custid
    ON COTDL.tbl_testdata (CUSTID);

-- 폐기 예정일 범위 검색
CREATE INDEX IF NOT EXISTS idx_testdata_disposal_sche_date
    ON COTDL.tbl_testdata (DISPOSAL_SCHE_DATE);


-- ##############################################################################
-- [18] tbl_piidatabase (현재 ~8건, 소형)
--      PK: DB
-- ##############################################################################

-- system + env 복합 필터 (readBySystem)
CREATE INDEX IF NOT EXISTS idx_piidatabase_system_env
    ON COTDL.tbl_piidatabase (SYSTEM, ENV);


-- ##############################################################################
-- [19] tbl_member (현재 ~160건)
--      PK: USERID
-- ##############################################################################

-- ORDER BY regdate DESC (회원목록 정렬)
CREATE INDEX IF NOT EXISTS idx_member_regdate
    ON COTDL.tbl_member (REGDATE);


-- ##############################################################################
-- [20] tbl_errorhist (현재 0건, 운영 시 증가)
--      PK: ID
-- ##############################################################################

-- 모듈별 에러 조회
CREATE INDEX IF NOT EXISTS idx_errorhist_module_name
    ON COTDL.tbl_errorhist (MODULE_NAME);

-- 날짜 범위 검색
CREATE INDEX IF NOT EXISTS idx_errorhist_created_at
    ON COTDL.tbl_errorhist (CREATED_AT);


-- ==============================================================================
-- 완료: 총 20개 테이블, 54개 인덱스 (기존 인덱스 중복 시 IF NOT EXISTS로 SKIP)
-- 중복 제거: idx_piitable_owner → idx_piitable_owner_table이 커버
-- ==============================================================================


-- ##############################################################################
-- [부록] 중복 인덱스 진단 & DROP 스크립트 생성
-- ##############################################################################
--
-- ■ 사용법:
--   1) 위 CREATE INDEX 문을 전부 실행 (IF NOT EXISTS이므로 안전)
--   2) 아래 SELECT 쿼리를 실행하면 DROP INDEX 문이 자동 생성됨
--   3) 결과를 확인하고 필요한 것만 실행
--
-- ■ 판단 기준:
--   인덱스 A의 컬럼이 인덱스 B의 왼쪽 접두사(left-prefix)이면
--   B가 A를 완전히 커버하므로 A는 제거 가능
--   예) PK(JOBID, VERSION) 가 있으면 idx(JOBID) 단독은 불필요
--       idx(A, B, C) 가 있으면 idx(A, B)는 불필요
--
-- ■ 주의: PK/UNIQUE는 제거 대상에서 제외됨 (일반 인덱스만 대상)
-- ##############################################################################

-- [진단1] 중복 인덱스 조회 + DROP 문 생성
SELECT
    CONCAT('-- ', shorter.TABLE_NAME, ': ',
           shorter.INDEX_NAME, '(', shorter.idx_cols, ') 는 ',
           longer.INDEX_NAME, '(', longer.idx_cols, ') 에 포함됨') AS reason,
    CONCAT('DROP INDEX ', shorter.INDEX_NAME, ' ON ', shorter.TABLE_SCHEMA, '.', shorter.TABLE_NAME, ';') AS drop_sql
FROM (
    SELECT TABLE_SCHEMA, TABLE_NAME, INDEX_NAME, NON_UNIQUE,
           GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS idx_cols,
           COUNT(*) AS col_cnt
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = 'COTDL'
      AND INDEX_NAME != 'PRIMARY'
    GROUP BY TABLE_SCHEMA, TABLE_NAME, INDEX_NAME, NON_UNIQUE
) shorter
JOIN (
    SELECT TABLE_SCHEMA, TABLE_NAME, INDEX_NAME,
           GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS idx_cols,
           COUNT(*) AS col_cnt
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = 'COTDL'
    GROUP BY TABLE_SCHEMA, TABLE_NAME, INDEX_NAME
) longer
ON  shorter.TABLE_SCHEMA = longer.TABLE_SCHEMA
AND shorter.TABLE_NAME   = longer.TABLE_NAME
AND shorter.INDEX_NAME  != longer.INDEX_NAME
AND shorter.col_cnt      < longer.col_cnt
AND longer.idx_cols LIKE CONCAT(shorter.idx_cols, ',%')
AND shorter.NON_UNIQUE   = 1
ORDER BY shorter.TABLE_NAME, shorter.col_cnt;

-- [진단2] 테이블별 전체 인덱스 현황 조회 (참고용)
-- SELECT TABLE_NAME, INDEX_NAME,
--        GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS idx_cols,
--        CASE WHEN INDEX_NAME = 'PRIMARY' THEN 'PK'
--             WHEN NON_UNIQUE = 0 THEN 'UNIQUE'
--             ELSE 'INDEX' END AS idx_type
-- FROM INFORMATION_SCHEMA.STATISTICS
-- WHERE TABLE_SCHEMA = 'COTDL'
-- GROUP BY TABLE_NAME, INDEX_NAME, NON_UNIQUE
-- ORDER BY TABLE_NAME, INDEX_NAME = 'PRIMARY' DESC, INDEX_NAME;
