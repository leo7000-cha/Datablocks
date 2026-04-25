-- ============================================================
-- DLM_APPROVAL_INIT : 결재 체계 초기 데이터 등록
-- ============================================================
-- DLM 시스템의 결재 유형, 결재라인, 결재단계, 결재자를 등록하는 스크립트.
-- 신규 사이트 배포 시 또는 결재 체계 초기화 시 사용합니다.
--
-- [결재 유형 (TBL_PIIAPPROVAL)]
--   JOB_APPROVAL      : JOB 실행 결재
--   POLICY_APPROVAL   : 정책 변경 결재
--   RESTORE_APPROVAL  : 복원 결재
--   BROWSE_APPROVAL   : 열람 결재
--   REALDOC_APPROVAL  : 실물파기 결재
--   REPORT_APPROVAL   : 처리내역 보고 결재
--   TESTDATA_APPROVAL : 테스트데이터 결재
--
-- [결재라인 구분]
--   일반 결재라인 : 사용자가 수동으로 결재 요청
--   자동 결재라인 : 시스템이 자동으로 결재 요청 (스케줄러/배치에서 사용)
--                  자동복원, 자동JOB, 자동테스트데이터
--
-- [결재 단계]
--   책임자 (seq=1) : 1차 승인자
--   부서장 (seq=2) : 2차 승인자 (필요 시)
--
-- [테이블 관계]
--   TBL_PIIAPPROVAL      : 결재 유형 마스터
--   TBL_PIIAPPROVALLINE  : 결재라인 정의 (유형별 1개 이상)
--   TBL_PIIAPPROVALSTEP  : 결재라인별 단계 정의
--   TBL_PIIAPPROVALUSER  : 결재단계별 결재자 지정
--   TBL_PIIAPPROVALREQ   : 결재 요청 (런타임 데이터)
--   TBL_PIIAPPROVALSTEPREQ : 결재단계별 요청 (런타임 데이터)
--
-- ============================================================
-- 사이트별 배포 시 아래 변수를 해당 사이트 값으로 치환(Replace All)하세요.
--
--   COTDL     -> DLM 스키마명         (기본값: COTDL)
--   member_it   -> 1차 결재자(책임자) ID (기본값: member_it2)
--   멤버_it   -> 1차 결재자 이름       (기본값: 멤버_it2)
--   member_biz   -> 2차 결재자(부서장) ID (기본값: member_it1)
--   맴버_비즈   -> 2차 결재자 이름       (기본값: 멤버_it1)
-- ============================================================


-- 기존 데이터 초기화 (런타임 데이터 포함)
DELETE FROM COTDL.TBL_PIIAPPROVALSTEPREQ;
DELETE FROM COTDL.TBL_PIIAPPROVALREQ;
DELETE FROM COTDL.TBL_PIIAPPROVALUSER;
DELETE FROM COTDL.TBL_PIIAPPROVALSTEP;
DELETE FROM COTDL.TBL_PIIAPPROVALLINE;
DELETE FROM COTDL.TBL_PIIAPPROVAL;


-- ════════════════════════════════════════════════════════════
-- 1. 결재 유형 마스터 (TBL_PIIAPPROVAL)
-- ════════════════════════════════════════════════════════════

INSERT INTO COTDL.TBL_PIIAPPROVAL (APPROVALID, APPROVALNAME) VALUES ('JOB_APPROVAL',      'JOB 결재');
INSERT INTO COTDL.TBL_PIIAPPROVAL (APPROVALID, APPROVALNAME) VALUES ('POLICY_APPROVAL',   'POLICY 결재');
INSERT INTO COTDL.TBL_PIIAPPROVAL (APPROVALID, APPROVALNAME) VALUES ('RESTORE_APPROVAL',  '복원 결재');
INSERT INTO COTDL.TBL_PIIAPPROVAL (APPROVALID, APPROVALNAME) VALUES ('BROWSE_APPROVAL',   '열람 결재');
INSERT INTO COTDL.TBL_PIIAPPROVAL (APPROVALID, APPROVALNAME) VALUES ('REALDOC_APPROVAL',  '실물파기 결재');
INSERT INTO COTDL.TBL_PIIAPPROVAL (APPROVALID, APPROVALNAME) VALUES ('REPORT_APPROVAL',   '보고 결재');
INSERT INTO COTDL.TBL_PIIAPPROVAL (APPROVALID, APPROVALNAME) VALUES ('TESTDATA_APPROVAL', '테스트데이터 결재');


-- ════════════════════════════════════════════════════════════
-- 2. 결재라인 정의 (TBL_PIIAPPROVALLINE)
-- ════════════════════════════════════════════════════════════

-- JOB 결재
INSERT INTO COTDL.TBL_PIIAPPROVALLINE (APRVLINEID, APPROVALID, APPROVALNAME) VALUES ('JOB결재라인',           'JOB_APPROVAL',      'JOB 결재');
INSERT INTO COTDL.TBL_PIIAPPROVALLINE (APRVLINEID, APPROVALID, APPROVALNAME) VALUES ('자동JOB결재라인',       'JOB_APPROVAL',      'JOB 결재');

-- POLICY 결재
INSERT INTO COTDL.TBL_PIIAPPROVALLINE (APRVLINEID, APPROVALID, APPROVALNAME) VALUES ('POLICY결재라인',        'POLICY_APPROVAL',   'POLICY 결재');

-- 복원 결재
INSERT INTO COTDL.TBL_PIIAPPROVALLINE (APRVLINEID, APPROVALID, APPROVALNAME) VALUES ('복원결재라인',          'RESTORE_APPROVAL',  '복원 결재');
INSERT INTO COTDL.TBL_PIIAPPROVALLINE (APRVLINEID, APPROVALID, APPROVALNAME) VALUES ('자동복원결재라인',      'RESTORE_APPROVAL',  '복원 결재');

-- 열람 결재
INSERT INTO COTDL.TBL_PIIAPPROVALLINE (APRVLINEID, APPROVALID, APPROVALNAME) VALUES ('열람결재라인',          'BROWSE_APPROVAL',   '열람 결재');

-- 실물파기 결재
INSERT INTO COTDL.TBL_PIIAPPROVALLINE (APRVLINEID, APPROVALID, APPROVALNAME) VALUES ('실물파기결재라인',      'REALDOC_APPROVAL',  '실물파기 결재');

-- 보고 결재
INSERT INTO COTDL.TBL_PIIAPPROVALLINE (APRVLINEID, APPROVALID, APPROVALNAME) VALUES ('처리내역보고결재라인',  'REPORT_APPROVAL',   '보고 결재');

-- 테스트데이터 결재
INSERT INTO COTDL.TBL_PIIAPPROVALLINE (APRVLINEID, APPROVALID, APPROVALNAME) VALUES ('테스트데이터결재라인',      'TESTDATA_APPROVAL', '테스트데이터 결재');
INSERT INTO COTDL.TBL_PIIAPPROVALLINE (APRVLINEID, APPROVALID, APPROVALNAME) VALUES ('자동테스트데이터결재라인',  'TESTDATA_APPROVAL', '테스트데이터 결재');


-- ════════════════════════════════════════════════════════════
-- 3. 결재 단계 정의 (TBL_PIIAPPROVALSTEP)
-- ════════════════════════════════════════════════════════════

-- JOB 결재: 1단계 (책임자)
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('JOB결재라인',      1, '책임자', 'JOB_APPROVAL', 'JOB 결재');
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('자동JOB결재라인',  1, '책임자', 'JOB_APPROVAL', 'JOB 결재');

-- POLICY 결재: 1단계 (책임자)
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('POLICY결재라인',   1, '책임자', 'POLICY_APPROVAL', 'POLICY 결재');

-- 복원 결재: 2단계 (책임자 → 부서장)
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('복원결재라인',     1, '책임자', 'RESTORE_APPROVAL', '복원 결재');
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('복원결재라인',     2, '부서장', 'RESTORE_APPROVAL', '복원 결재');
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('자동복원결재라인', 1, '책임자', 'RESTORE_APPROVAL', '복원 결재');
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('자동복원결재라인', 2, '부서장', 'RESTORE_APPROVAL', '복원 결재');

-- 열람 결재: 2단계 (책임자 → 부서장)
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('열람결재라인',     1, '책임자', 'BROWSE_APPROVAL', '열람 결재');
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('열람결재라인',     2, '부서장', 'BROWSE_APPROVAL', '열람 결재');

-- 실물파기 결재: 1단계 (부서장)
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('실물파기결재라인', 1, '부서장', 'REALDOC_APPROVAL', '실물파기 결재');

-- 보고 결재: 1단계 (부서장)
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('처리내역보고결재라인', 1, '부서장', 'REPORT_APPROVAL', '보고 결재');

-- 테스트데이터 결재: 1단계 (부서장)
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('테스트데이터결재라인',     1, '부서장', 'TESTDATA_APPROVAL', '테스트데이터 결재');
INSERT INTO COTDL.TBL_PIIAPPROVALSTEP (APRVLINEID, SEQ, STEPNAME, APPROVALID, APPROVALNAME) VALUES ('자동테스트데이터결재라인', 1, '부서장', 'TESTDATA_APPROVAL', '테스트데이터 결재');


-- ════════════════════════════════════════════════════════════
-- 4. 결재자 지정 (TBL_PIIAPPROVALUSER)
-- ════════════════════════════════════════════════════════════

-- JOB 결재: 책임자
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('JOB결재라인',      1, '책임자', 'member_it', '멤버_it');
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('자동JOB결재라인',  1, '책임자', 'member_it', '멤버_it');

-- POLICY 결재: 책임자
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('POLICY결재라인',   1, '책임자', 'member_it', '멤버_it');

-- 복원 결재: 책임자 → 부서장
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('복원결재라인',     1, '책임자', 'member_it', '멤버_it');
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('복원결재라인',     2, '부서장', 'member_biz', '맴버_비즈');
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('자동복원결재라인', 1, '책임자', 'member_it', '멤버_it');
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('자동복원결재라인', 2, '부서장', 'member_biz', '맴버_비즈');

-- 열람 결재: 책임자 → 부서장
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('열람결재라인',     1, '책임자', 'member_it', '멤버_it');
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('열람결재라인',     2, '부서장', 'member_biz', '맴버_비즈');

-- 실물파기 결재: 부서장
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('실물파기결재라인', 1, '부서장', 'member_biz', '맴버_비즈');

-- 보고 결재: 부서장
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('처리내역보고결재라인', 1, '부서장', 'member_biz', '맴버_비즈');

-- 테스트데이터 결재: 부서장
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('테스트데이터결재라인',     1, '부서장', 'member_biz', '맴버_비즈');
INSERT INTO COTDL.TBL_PIIAPPROVALUSER (APRVLINEID, SEQ, STEPNAME, APPROVERID, APPROVERNAME) VALUES ('자동테스트데이터결재라인', 1, '부서장', 'member_biz', '맴버_비즈');


COMMIT;
