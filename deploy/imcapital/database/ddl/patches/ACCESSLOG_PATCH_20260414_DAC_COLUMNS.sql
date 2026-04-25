-- ============================================================
-- PATCH: DB접근제어 연동 감사 수집 방식 + collect_type 컬럼 추가
-- 날짜: 2026-04-14
-- 설명: 1) GENERAL_LOG/DAC → DB_DAC 마이그레이션
--       2) DLM_SELF → WAS_AGENT 마이그레이션
--       3) TBL_ACCESS_LOG_SOURCE에 접근제어 조회 SQL 컬럼 추가
--       4) TBL_ACCESS_LOG에 수집 방식 구분 컬럼 추가
--          DB_AUDIT : DB 접근 감사 (Audit)
--          DB_DAC   : DB 접근 감사 (접근제어)
--          WAS_AGENT: WAS 접근 감사
-- 적용: 기존 환경에서 실행 (반복 실행 가능)
-- ============================================================

-- 1. SOURCE 테이블: 접근제어 연동 감사 전용 컬럼
ALTER TABLE COTDL.TBL_ACCESS_LOG_SOURCE
  ADD COLUMN IF NOT EXISTS dac_select_sql TEXT COMMENT '접근제어 연동 감사 — 사용자 정의 SELECT문' AFTER exclude_accounts;

-- 2. source_type 코드값 마이그레이션
UPDATE COTDL.TBL_ACCESS_LOG_SOURCE SET source_type = 'DB_DAC' WHERE source_type IN ('GENERAL_LOG', 'DAC');
UPDATE COTDL.TBL_ACCESS_LOG_SOURCE SET source_type = 'WAS_AGENT' WHERE source_type = 'DLM_SELF';

ALTER TABLE COTDL.TBL_ACCESS_LOG_SOURCE
  MODIFY COLUMN source_type VARCHAR(20) DEFAULT 'DB_AUDIT'
  COMMENT '수집 방식 (DB_AUDIT: DB Audit, DB_DAC: DB 접근제어, WAS_AGENT: Java Agent (BCI))';

-- 3. ACCESS_LOG 테이블: collect_type 컬럼 추가
ALTER TABLE COTDL.TBL_ACCESS_LOG
  ADD COLUMN IF NOT EXISTS collect_type VARCHAR(20)
  COMMENT '수집 방식 (DB_AUDIT: DB Audit, DB_DAC: DB 접근제어, WAS_AGENT: Java Agent (BCI))' AFTER sql_text;

-- 4. 기존 collect_type 데이터 마이그레이션
UPDATE COTDL.TBL_ACCESS_LOG SET collect_type = 'DB_DAC' WHERE collect_type = 'DAC';
UPDATE COTDL.TBL_ACCESS_LOG SET collect_type = 'WAS_AGENT' WHERE collect_type = 'DLM_SELF';
