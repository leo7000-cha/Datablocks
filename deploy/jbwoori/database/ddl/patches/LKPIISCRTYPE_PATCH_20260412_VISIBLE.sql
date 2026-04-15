-- ============================================================
-- LKPIISCRTYPE PATCH: visible 필드 추가
-- Date: 2026-04-12
-- Description: 데이터 인벤토리 PII Classification 선택 목록에서
--              고객사별로 불필요한 항목을 숨길 수 있도록 visible 필드 추가
-- ============================================================

ALTER TABLE COTDL.TBL_LKPIISCRTYPE
    ADD COLUMN IF NOT EXISTS visible CHAR(1) DEFAULT 'Y' COMMENT '인벤토리 표시 여부 (Y/N)';
