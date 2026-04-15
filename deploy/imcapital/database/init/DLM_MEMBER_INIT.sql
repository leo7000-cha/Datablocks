-- ============================================================
-- DLM_MEMBER_INIT : 초기 사용자 계정 및 권한 등록
-- ============================================================
-- DLM 시스템의 초기 사용자 계정과 역할(권한)을 등록하는 스크립트.
-- 신규 사이트 배포 시 또는 계정 초기화 시 사용합니다.
--
-- [역할(권한) 체계]
--   ROLE_ADMIN : 시스템 관리자 (전체 기능 접근)
--   ROLE_IT    : IT 운영 담당자 (JOB 관리, 모니터링)
--   ROLE_BIZ   : 업무 담당자 (파기/복원 요청, 현황 조회)
--   ROLE_SEC   : 보안 담당자 (감사, 보안 설정)
--   ROLE_USER  : 일반 사용자 (조회 위주)
--
-- [기본 비밀번호]
--   초기 비밀번호: 1111 (BCrypt 해시)
--   배포 후 반드시 변경하세요.
--
-- ============================================================
-- 사이트별 배포 시 아래 변수를 해당 사이트 값으로 치환(Replace All)하세요.
--
--   #{DLM_SCHEMA}    -> DLM 스키마명  (기본값: COTDL)
--   #{DEFAULT_PW}    -> 초기 비밀번호 BCrypt 해시
--                       1111      : $2a$10$Xr.Jd3Py1wR4beAigAhqCOIzKUaFPILJlss0TA4xY.xgiFe6LbTc6
--                       datablocks: $2a$10$bEVCXtJOrO0pjIHcplMs2uLkV7oJYAFUP/VAscVOPua2xhWOosLLe
-- ============================================================


-- 기존 데이터 초기화
TRUNCATE TABLE #{DLM_SCHEMA}.TBL_MEMBER_AUTH;
TRUNCATE TABLE #{DLM_SCHEMA}.TBL_MEMBER;


-- ────────────────────────────────────────────────────────────
-- [사용자 계정 등록]
-- ────────────────────────────────────────────────────────────

-- 관리자
INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER (USERID, USERPW, USERNAME, REGDATE, UPDATEDATE, ENABLED, DEPT_CD, DEPT_NAME)
VALUES ('admin', '#{DEFAULT_PW}', '어드민', NOW(), NOW(), '1', 'ITO', 'IT운영팀');

-- IT 운영 담당자
INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER (USERID, USERPW, USERNAME, REGDATE, UPDATEDATE, ENABLED, DEPT_CD, DEPT_NAME)
VALUES ('member_it', '#{DEFAULT_PW}', '맴버_아이티', NOW(), NOW(), '1', 'ITO', 'IT운영팀');

INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER (USERID, USERPW, USERNAME, REGDATE, UPDATEDATE, ENABLED, DEPT_CD, DEPT_NAME)
VALUES ('member_it1', '#{DEFAULT_PW}', '맴버_아이티1', NOW(), NOW(), '1', 'ITO', 'IT운영팀');

INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER (USERID, USERPW, USERNAME, REGDATE, UPDATEDATE, ENABLED, DEPT_CD, DEPT_NAME)
VALUES ('member_it2', '#{DEFAULT_PW}', '맴버_아이티2', NOW(), NOW(), '1', 'ITO', 'IT운영팀');

-- 업무 담당자
INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER (USERID, USERPW, USERNAME, REGDATE, UPDATEDATE, ENABLED, DEPT_CD, DEPT_NAME)
VALUES ('member_biz', '#{DEFAULT_PW}', '맴버_비즈', NOW(), NOW(), '1', 'CPT', '소비자보호팀');

-- 보안 담당자
INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER (USERID, USERPW, USERNAME, REGDATE, UPDATEDATE, ENABLED, DEPT_CD, DEPT_NAME)
VALUES ('member_sec', '#{DEFAULT_PW}', '맴버_보안', NOW(), NOW(), '1', 'CPT', '소비자보호팀');

-- 일반 사용자
INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER (USERID, USERPW, USERNAME, REGDATE, UPDATEDATE, ENABLED, DEPT_CD, DEPT_NAME)
VALUES ('user', '#{DEFAULT_PW}', '유저', NOW(), NOW(), '1', 'USR', '일반유저팀');


-- ────────────────────────────────────────────────────────────
-- [권한(역할) 매핑]
-- ────────────────────────────────────────────────────────────

INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER_AUTH (USERID, AUTH) VALUES ('admin',      'ROLE_ADMIN');
INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER_AUTH (USERID, AUTH) VALUES ('member_it',  'ROLE_IT');
INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER_AUTH (USERID, AUTH) VALUES ('member_it1', 'ROLE_IT');
INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER_AUTH (USERID, AUTH) VALUES ('member_it2', 'ROLE_IT');
INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER_AUTH (USERID, AUTH) VALUES ('member_biz', 'ROLE_BIZ');
INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER_AUTH (USERID, AUTH) VALUES ('member_sec', 'ROLE_SEC');
INSERT INTO #{DLM_SCHEMA}.TBL_MEMBER_AUTH (USERID, AUTH) VALUES ('user',       'ROLE_USER');


COMMIT;
