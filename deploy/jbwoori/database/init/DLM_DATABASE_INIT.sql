-- ============================================================
-- DLM_DATABASE_INIT : MariaDB/MySQL 데이터베이스 및 사용자 초기 설정
-- ============================================================
-- DLM 시스템 신규 배포 시 데이터베이스 생성, 사용자 생성, 권한 부여를
-- 수행하는 스크립트입니다.
--
-- [실행 방법]
--   mysql -u root -p < DLM_DATABASE_INIT.sql
--   또는 mysql 클라이언트 접속 후 수동 실행
--
-- [생성 대상]
--   데이터베이스 : #{DLM_DB} (DLM 메인), #{DLM_DB_BK} (백업/분리보관)
--   사용자       : #{DLM_USER} (DLM 접속 계정), #{DLM_DB_BK} (백업 DB 계정)
--
-- ============================================================
-- 사이트별 배포 시 아래 변수를 해당 사이트 값으로 치환(Replace All)하세요.
--
--   #{ROOT_PW}       -> root 비밀번호         (예: !Dlm1234)
--   #{DLM_DB}        -> DLM 메인 DB명         (기본값: cotdl)
--   #{DLM_DB_BK}     -> 백업/분리보관 DB명     (기본값: cotdlbk)
--   #{DLM_USER}      -> DLM 접속 사용자명      (기본값: cotdl)
--   #{DLM_PW}        -> DLM 사용자 비밀번호    (예: !Dlm1234)
--   #{ARC_SCHEMA_1}  -> 분리보관 스키마 1      (예: piicoownser)
--   #{ARC_SCHEMA_2}  -> 분리보관 스키마 2      (예: piicoownorg)
--
-- [비밀번호 정책]
--   대문자, 소문자, 숫자, 특수문자 포함 / 최소 8자 이상
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 1. root 비밀번호 변경
-- ────────────────────────────────────────────────────────────
ALTER USER 'root'@'localhost' IDENTIFIED BY '#{ROOT_PW}';


-- ────────────────────────────────────────────────────────────
-- 2. 데이터베이스 생성
-- ────────────────────────────────────────────────────────────
DROP DATABASE IF EXISTS #{DLM_DB};
DROP DATABASE IF EXISTS #{DLM_DB_BK};

CREATE DATABASE #{DLM_DB};
CREATE DATABASE #{DLM_DB_BK};


-- ────────────────────────────────────────────────────────────
-- 3. root 권한 갱신
-- ────────────────────────────────────────────────────────────
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';
FLUSH PRIVILEGES;


-- ────────────────────────────────────────────────────────────
-- 4. DLM 사용자 생성 (기존 계정 삭제 후 재생성)
-- ────────────────────────────────────────────────────────────

-- 기존 계정 삭제 (없으면 무시)
DROP USER IF EXISTS '#{DLM_USER}'@'%';
DROP USER IF EXISTS '#{DLM_USER}'@'localhost';
DROP USER IF EXISTS '#{DLM_USER}'@'127.0.0.1';

-- 원격 접속용 (%)
CREATE USER '#{DLM_USER}'@'%' IDENTIFIED BY '#{DLM_PW}';
GRANT ALL PRIVILEGES ON *.* TO '#{DLM_USER}'@'%';

-- localhost 접속용
CREATE USER '#{DLM_USER}'@'localhost' IDENTIFIED BY '#{DLM_PW}';
GRANT ALL PRIVILEGES ON *.* TO '#{DLM_USER}'@'localhost';

-- 127.0.0.1 접속용
CREATE USER '#{DLM_USER}'@'127.0.0.1' IDENTIFIED BY '#{DLM_PW}';
GRANT ALL PRIVILEGES ON *.* TO '#{DLM_USER}'@'127.0.0.1';

FLUSH PRIVILEGES;


-- ────────────────────────────────────────────────────────────
-- 5. 백업DB 사용자 생성
-- ────────────────────────────────────────────────────────────

DROP USER IF EXISTS '#{DLM_DB_BK}'@'%';

CREATE USER '#{DLM_DB_BK}'@'%' IDENTIFIED BY '#{DLM_PW}';
GRANT ALL PRIVILEGES ON *.* TO '#{DLM_DB_BK}'@'%';

FLUSH PRIVILEGES;


-- ────────────────────────────────────────────────────────────
-- 6. 분리보관 스키마 권한 부여 (사이트별 추가)
--    분리보관 대상 스키마가 있는 경우 아래 권한을 추가하세요.
-- ────────────────────────────────────────────────────────────

-- GRANT ALL PRIVILEGES ON #{ARC_SCHEMA_1}.* TO '#{DLM_USER}'@'%';
-- GRANT ALL PRIVILEGES ON #{ARC_SCHEMA_2}.* TO '#{DLM_USER}'@'%';
-- GRANT ALL PRIVILEGES ON #{ARC_SCHEMA_1}.* TO '#{DLM_USER}'@'localhost';
-- GRANT ALL PRIVILEGES ON #{ARC_SCHEMA_2}.* TO '#{DLM_USER}'@'localhost';
-- FLUSH PRIVILEGES;


-- ────────────────────────────────────────────────────────────
-- 확인
-- ────────────────────────────────────────────────────────────
-- SHOW DATABASES;
-- SELECT host, user FROM mysql.user;
