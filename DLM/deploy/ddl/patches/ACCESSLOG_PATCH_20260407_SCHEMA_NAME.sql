-- ============================================================
-- 접속기록 수집 소스 — schema_name 컬럼 추가
-- 날짜: 2026-04-07
-- PII 메타데이터 매칭에 사용 (BCI/SQL 파싱 방식)
-- ============================================================

ALTER TABLE COTDL.TBL_ACCESS_LOG_SOURCE
    ADD COLUMN schema_name VARCHAR(100) COMMENT '대상 스키마명 (PII 메타데이터 매칭용)'
    AFTER port;

SELECT 'ACCESSLOG_PATCH_20260407 applied: schema_name column added' AS MESSAGE;
