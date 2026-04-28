-- ============================================================
-- PIIDATABASE_INIT : TBL_PIIDATABASE 초기 DB 등록
-- ============================================================
-- DLM 에서 관리할 대상 DB(원천/분리보관/접속기록 등)를 등록하는 스크립트.
-- 신규 사이트 배포 시 또는 DB 마스터 초기화 시 사용합니다.
--
-- [컬럼 설명]
--   DB         : 논리 DB 명 (PK)        — 예: DAON, DLM, DLMARC, XAUDIT_DB
--   SYSTEM     : 시스템 식별자          — TBL_PIISYSTEM.SYSTEM_ID 와 일치해야 함
--                  CORE / XOne / ARCHIVE_DB / DW / XAUDIT
--   ENV        : 환경 구분              — PRODUCTION / DEVELOPMENT / PRE-PRODUCTION 등
--   DBTYPE     : DB 종류                — ORACLE / MARIADB / MYSQL / MSSQL / TIBERO
--   DBUSER     : DB 접속 계정
--   PWD        : DB 접속 비밀번호 (Jasypt 등으로 암호화된 값)
--   HOSTNAME   : 호스트명 (DNS / 컨테이너명 / IP)
--   PORT       : 포트
--   ID_TYPE    : 식별자 종류            — SERVICENAME (Oracle) / SID / DBNAME 등
--   ID         : 식별자 값
--   COMMENTS   : 설명
--
-- ============================================================
-- 사이트별 배포 시 PWD / HOSTNAME / PORT / ID 등 환경 종속 값을 수정하세요.
-- 본 파일에 들어있는 PWD 는 cipher (암호화) 형태이며, 운영 비밀번호 노출이 우려되는 경우
-- 사이트별로 별도 cipher 값으로 치환 후 적용하시기 바랍니다.
-- ============================================================


delete from COTDL.TBL_PIIDATABASE;

INSERT INTO COTDL.TBL_PIIDATABASE
  (DB, `SYSTEM`, ENV, DBTYPE, DBUSER, PWD, HOSTNAME, PORT, ID_TYPE, ID, COMMENTS, REGDATE, UPDDATE, REGUSERID, UPDUSERID)
VALUES
  ('DAON',      'CORE',       'PRODUCTION',     'ORACLE',  'cotdl', 'WDuaF8IXnahKQlX93JVvMg==', '192.168.0.57', '1521', 'SERVICENAME', 'FREEPDB1', '계정계 운영환경',                                            '2021-01-27 00:00:00', '2026-02-24 21:49:21', 'admin',  'admin'),
  ('DAON-1',    'CORE',       'PRODUCTION-1',   'ORACLE',  'cotdl', 'WDuaF8IXnahKQlX93JVvMg==', '192.168.0.57', '1521', 'SERVICENAME', 'FREEPDB1', '운영계 전일자 DB',                                           '2024-03-10 01:14:36', '2026-02-24 21:50:22', 'admin',  'admin'),
  ('DAOND',     'CORE',       'DEVELOPMENT',    'ORACLE',  'cotdl', 'WDuaF8IXnahKQlX93JVvMg==', '192.168.0.46', '1521', 'SERVICENAME', 'XEPDB1',   '계정계 개발환경',                                            '2024-03-12 08:18:06', '2026-01-29 09:10:36', 'admin',  'admin'),
  ('DAONT',     'CORE',       'PRE-PRODUCTION', 'ORACLE',  'cotdl', 'WDuaF8IXnahKQlX93JVvMg==', '192.168.0.46', '1521', 'SERVICENAME', 'XEPDB1',   '계정계 검증환경',                                            '2024-03-12 08:19:50', '2026-01-29 09:16:32', 'admin',  'admin'),
  ('DLM',       'XOne',       'PRODUCTION',     'MARIADB', 'cotdl', 'VEjc9V+fxHx4S4zA05NqUw==', 'dlm-mariadb',  '3306', 'DBNAME',      'cotdl',    'DLM 자체 내부 DB (HOME_DB)',                                 '2026-04-25 07:41:51', '2026-04-25 11:07:33', 'SYSTEM', 'admin'),
  ('DLMARC',    'ARCHIVE_DB', 'PRODUCTION',     'MARIADB', 'cotdl', 'WDuaF8IXnahKQlX93JVvMg==', 'dlm-mariadb',  '3306', 'DBNAME',      'cotdl',    '개인정보 파기 분리보관 DB',                                  '2026-04-25 09:03:48', '2026-04-25 11:07:16', 'admin',  'admin'),
  ('DW',        'DW',         'PRODUCTION',     'ORACLE',  'cotdl', 'WDuaF8IXnahKQlX93JVvMg==', '192.168.0.46', '1521', 'SERVICENAME', 'XEPDB1',   '',                                                           '2022-11-02 10:20:47', '2026-01-29 09:17:43', 'admin',  'admin'),
  ('XAUDIT_DB', 'XAUDIT',     'PRODUCTION',     'MARIADB', 'cotdl', 'WDuaF8IXnahKQlX93JVvMg==', 'dlm-mariadb',  '3306', '',            'cotdl',    'Auto-registered from Primary DataSource (fallback to DLM internal DB)', '2026-04-25 07:39:33', '2026-04-25 07:39:33', 'SYSTEM', NULL);


COMMIT;
