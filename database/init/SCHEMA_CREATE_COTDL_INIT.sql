-- ============================================================
-- SCHEMA_CREATE_COTDL_INIT : MariaDB/MySQL 데이터베이스 및 사용자 초기 설정
-- ============================================================
-- DLM 시스템 신규 배포 시 데이터베이스 생성, 사용자 생성, 권한 부여를
-- 수행하는 스크립트입니다.
--
-- [실행 방법]
--   mysql -u root -p < SCHEMA_CREATE_COTDL_INIT.sql
--   또는 mysql 클라이언트 접속 후 수동 실행
--
-- [생성 대상]
--   데이터베이스 : cotdl (DLM 메인), cotdlbk (백업/분리보관)
--   사용자       : cotdl (DLM 접속 계정), cotdlbk (백업 DB 계정)
--
-- ============================================================
-- 사이트별 배포 시 아래 변수를 해당 사이트 값으로 치환(Replace All)하세요.
--
--   !Dlm1234       -> root 비밀번호         (예: !Dlm1234)
--   cotdl        -> DLM 메인 DB명         (기본값: cotdl)
--   cotdlbk     -> 백업/분리보관 DB명     (기본값: cotdlbk)
--   cotdl      -> DLM 접속 사용자명      (기본값: cotdl)
--   !Dlm1234        -> DLM 사용자 비밀번호    (예: !Dlm1234)
--   piicoownser  -> 분리보관 스키마 1      (예: piicoownser)
--   piicoownorg  -> 분리보관 스키마 2      (예: piicoownorg)
--
-- [비밀번호 정책]
--   대문자, 소문자, 숫자, 특수문자 포함 / 최소 8자 이상
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 1. root 비밀번호 변경
-- ────────────────────────────────────────────────────────────
ALTER USER 'root'@'localhost' IDENTIFIED BY '!Dlm1234';


-- ────────────────────────────────────────────────────────────
-- 2. 데이터베이스 생성
-- ────────────────────────────────────────────────────────────
DROP DATABASE IF EXISTS cotdl;
DROP DATABASE IF EXISTS cotdlbk;

CREATE DATABASE cotdl;
CREATE DATABASE cotdlbk;


-- ────────────────────────────────────────────────────────────
-- 3. root 권한 갱신
-- ────────────────────────────────────────────────────────────
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';
FLUSH PRIVILEGES;


-- ────────────────────────────────────────────────────────────
-- 4. DLM 사용자 생성 (기존 계정 삭제 후 재생성)
-- ────────────────────────────────────────────────────────────

-- 기존 계정 삭제 (없으면 무시)
DROP USER IF EXISTS 'cotdl'@'%';
DROP USER IF EXISTS 'cotdl'@'localhost';
DROP USER IF EXISTS 'cotdl'@'127.0.0.1';

-- 원격 접속용 (%)
CREATE USER 'cotdl'@'%' IDENTIFIED BY '!Dlm1234';
GRANT ALL PRIVILEGES ON *.* TO 'cotdl'@'%';

-- localhost 접속용
CREATE USER 'cotdl'@'localhost' IDENTIFIED BY '!Dlm1234';
GRANT ALL PRIVILEGES ON *.* TO 'cotdl'@'localhost';

-- 127.0.0.1 접속용
CREATE USER 'cotdl'@'127.0.0.1' IDENTIFIED BY '!Dlm1234';
GRANT ALL PRIVILEGES ON *.* TO 'cotdl'@'127.0.0.1';

FLUSH PRIVILEGES;


-- ────────────────────────────────────────────────────────────
-- 5. 백업DB 사용자 생성
-- ────────────────────────────────────────────────────────────

DROP USER IF EXISTS 'cotdlbk'@'%';

CREATE USER 'cotdlbk'@'%' IDENTIFIED BY '!Dlm1234';
GRANT ALL PRIVILEGES ON *.* TO 'cotdlbk'@'%';

FLUSH PRIVILEGES;


-- ────────────────────────────────────────────────────────────
-- 6. 분리보관 스키마 권한 부여 (사이트별 추가)
--    분리보관 대상 스키마가 있는 경우 아래 권한을 추가하세요.
-- ────────────────────────────────────────────────────────────

-- GRANT ALL PRIVILEGES ON piicoownser.* TO 'cotdl'@'%';
-- GRANT ALL PRIVILEGES ON piicoownorg.* TO 'cotdl'@'%';
-- GRANT ALL PRIVILEGES ON piicoownser.* TO 'cotdl'@'localhost';
-- GRANT ALL PRIVILEGES ON piicoownorg.* TO 'cotdl'@'localhost';
-- FLUSH PRIVILEGES;


-- ────────────────────────────────────────────────────────────
-- 확인
-- ────────────────────────────────────────────────────────────
-- SHOW DATABASES;
-- SELECT host, user FROM mysql.user;
