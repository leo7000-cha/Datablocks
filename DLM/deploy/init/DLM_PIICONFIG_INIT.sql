-- ============================================================
-- DLM_PIICONFIG_INIT : TBL_PIICONFIG 초기 설정값 등록
-- ============================================================
-- DLM 시스템 운영에 필요한 전체 설정값을 등록하는 스크립트.
-- 신규 사이트 배포 시 또는 설정 테이블 초기화 시 사용합니다.
--
-- ============================================================
-- 사이트별 배포 시 아래 항목을 해당 사이트 값으로 수정하세요.
--
--   #{DLM_SCHEMA}       -> DLM 스키마명        (기본값: COTDL)
--   #{SITE}             -> 고객사 코드          (예: JBCAP)
--   DLM_ENV             -> 환경 구분            (PROD / DEV)
--   DLM_CURRENT_ORDERID -> 현재 ORDER 시퀀스    (신규: 1, 이관: 기존값)
--   DLM_ENC_PWD_SQL     -> 사이트별 암호화 SQL
--   DLM_LOG_PATH        -> 서버 로그 디렉토리
-- ============================================================


-- 기존 설정 전체 삭제 (초기화 용도)
-- DELETE FROM #{DLM_SCHEMA}.TBL_PIICONFIG;


-- ────────────────────────────────────────────────────────────
-- [시스템 기본 설정]
-- ────────────────────────────────────────────────────────────
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('SITE',            '#{SITE}',   '고객사명으로 고객사별 커스트마이징 요건이 이 값을 기준으로 적용됩니다.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_ENV',         'PROD',     '반드시 PROD 상태를 유지 해야합니다 - PROD, DEV');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_LOG_PATH',    '/datablocks', '로그파일 조회시 root 디렉토리입니다.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DEFAULT_LOCALE',  'ko',       '다국어 기본 로케일 설정 (ko, en, ja 등)');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('LOG_LEVEL',       'WARN',     '로그 출력 레벨 (DEBUG, INFO, WARN, ERROR)');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DASHBOARD_SHOW',  '월별 파기 현황:Y, 실물 파기 현황:Y, 시스템별 현황:Y', '대시보드 섹션 표시 설정');


-- ────────────────────────────────────────────────────────────
-- [JOB 실행 제어]
-- ────────────────────────────────────────────────────────────
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_RUN_FLAG',               'Y',   'ORDER 된 JOB의 실행 FLAG입니다. ''N'' 이면 ORDER 된 JOB이 실행 되지 않습니다.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_ORDER_FLAG',             'N',   'JOB 자동 ORDER FLAG입니다. ''N'' 이면 파기JOB이 자동 ORDER되지 않습니다.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_CURRENT_ORDERID',       '100000', 'ORDER 시퀀스를 관리합니다. 절대 수정하지 마세요.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_TABLELIST_ORDERBY',     'ASC', 'ARCHIVE, DELETE, UPDATE 스텝의 수행 순서로 ASC는 순서대로, DESC는 역순으로 수행됩니다.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('BATCH_EXECUTOR_TIMEOUT_HOURS', '24', '배치 실행기 타임아웃 시간(시간 단위). 이 시간을 초과하면 배치가 강제 종료됩니다.');


-- ────────────────────────────────────────────────────────────
-- [영구파기 JOB 설정]
-- ────────────────────────────────────────────────────────────
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_ORDER_ARCDELJOB_FLAG',   'N',     '영구파기JOB의 자동 ORDER FLAG입니다. ''N'' 이면 영구파기가 ORDER 되지 않습니다.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_ARCDELJOB_TIME',         '07:00', '자동 영구파기JOB의 수행 시간을 설정한다.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_ARCDELJOB_THREADCNT',    '8',     '자동 영구파기JOB의 동시 작업수를 설정한다.');


-- ────────────────────────────────────────────────────────────
-- [분리보관 테이블 관리]
-- ────────────────────────────────────────────────────────────
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_ARC_TAB_AUTO_MGMT_FLAG', 'N',   '분리보관테이블 자동생성 및 동기화 FLAG입니다. ''N'' 이면 자동 생성 및 동기화 되지 않습니다.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('ARCHIVE_SCHEMA_NAMING_PII',  'PIIOWNER', '개인정보 파기 분리보관 스키마 네이밍 패턴');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('ARCHIVE_SCHEMA_NAMING_ILM',  'ILMOWNER', 'ILM 아카이빙 스키마 네이밍 패턴');


-- ────────────────────────────────────────────────────────────
-- [복원 설정]
-- ────────────────────────────────────────────────────────────
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_RESTORE_THREADCNT',       '10',   '필수 선행 복원 테이블을 고려하여 10 이상 되어야 함.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_RESTORE_COMMITCNT',       '1000', '업무 중 복원 신청이 되므로 기존 처리계 Transaction과 경합을 피하기 위해 커밋 단위를 최소화함');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('RESTOREGAP_UPDROW_EXCEPTION', 'N',    '고객복원 시 원천 테이블이 분리보관 시 데이터와의 건수 변화를 확인 함');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('RESTORE_JOB_MAX_CNT',         '10',   '복원 JOB 최대 동시 실행 개수');


-- ────────────────────────────────────────────────────────────
-- [SQL / 힌트 설정]
-- ────────────────────────────────────────────────────────────
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_ENC_PWD_SQL',            'SELECT FN_GENDER2(?) FROM DUAL ', '통합로그인을 위해 암호화 저장된 pw를 읽는 sql입니다.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_KEYMAP_JOIN_HINT',       '/*+ LEADING(B A) USE_HASH(B A) INDEX(B IX_TBL_PIIKEYMAP_PII01) */', 'Hint for the join with TBL_PIIKEYMAP');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_KEYMAP_HIST_JOIN_HINT',  '/*+ LEADING(B A) USE_HASH(B A) INDEX(B IX_TBL_PIIKEYMAP_HIST_PII01) */', 'Hint for the join with TBL_PIIKEYMAP_HIST');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DLM_EXTRACT_MAX_CNT',        '10',   '고객추출 시 하루 MAX 건수를 제한하는 값으로 JOB 설정의 EXTRACT 스텝의 SQL에 적용됩니다.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('SQLLDR_PATH',                 '',     'Oracle SQL*Loader 실행 파일 경로 (예: /opt/oracle/bin/sqlldr)');


-- ────────────────────────────────────────────────────────────
-- [COMMIT 루프 / 작업 중지 시간대]
-- ────────────────────────────────────────────────────────────
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('SCRAMBLE_COMMIT_LOOP_CNT',   '15',   'SCRAMBLE 처리 시 Looping 건수 for COMMIT');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('ILM_COMMIT_LOOP_CNT',        '15',   'ILM 처리 시 Looping 건수 for COMMIT');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('ILM_STOPHOUR_FROM_TO',       '',     'ILM 작업 중지 시간대 (예: 09-18)');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('MIGRATE_COMMIT_LOOP_CNT',    '15',   'Migration 처리 시 Looping 건수 for COMMIT');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('MIGRATE_STOPHOUR_FROM_TO',   '',     'Migration 작업 중지 시간대 (예: 09-18)');


-- ────────────────────────────────────────────────────────────
-- [인증 / SSO 설정]
-- ────────────────────────────────────────────────────────────
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('PWD_TYPE',                    '',     '비밀번호 암호화 타입. 통합로그인(SSO) 시 암호화 방식을 지정합니다.');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('DOMAIN_URL',                  '',     '통합로그인(SSO) 도메인 URL');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('INST_CD',                     '',     '통합로그인(SSO) 기관 코드');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('LOGIN_SRVC_CD',               '',     '통합로그인(SSO) 서비스 코드');


-- ────────────────────────────────────────────────────────────
-- [테스트데이터]
-- ────────────────────────────────────────────────────────────
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('TESTDATA_AUTO_GEN_JOB_MAX_CNT', '5', '테스트데이터 자동 생성 JOB 최대 동시 실행 개수');


-- ────────────────────────────────────────────────────────────
-- [공지사항]
-- ────────────────────────────────────────────────────────────
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('NOTICE1', '', '대시보드 공지사항 1');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('NOTICE2', '', '대시보드 공지사항 2');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('NOTICE3', '', '대시보드 공지사항 3');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('NOTICE4', '', '대시보드 공지사항 4');
INSERT INTO #{DLM_SCHEMA}.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('NOTICE5', '', '대시보드 공지사항 5');


COMMIT;
