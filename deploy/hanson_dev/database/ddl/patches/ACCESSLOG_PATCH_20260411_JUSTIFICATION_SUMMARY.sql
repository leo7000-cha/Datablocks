-- ============================================================
-- PATCH: 소명 요약 컬럼 추가 (리스트 조회 성능 개선)
-- Date: 2026-04-11
-- Description: TEXT justification 대신 VARCHAR(500) 요약 컬럼을 리스트에서 사용
-- ============================================================

-- 소명 요약 컬럼 추가
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT
    ADD COLUMN justification_summary VARCHAR(500) NULL COMMENT '소명 요약 (리스트 표시용, 자동 생성)'
    AFTER justification;

-- 기존 데이터 마이그레이션
UPDATE COTDL.TBL_ACCESS_LOG_ALERT
   SET justification_summary = LEFT(justification, 500)
 WHERE justification IS NOT NULL
   AND justification_summary IS NULL;
