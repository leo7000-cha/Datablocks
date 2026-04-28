-- ============================================================
-- TBL_METATABLE PATCH: AUDIT_YN 컬럼 추가
-- Date: 2026-04-25
-- Description: AccessLog Collector 가 감사 대상 테이블만 자동 필터링하도록
--              TBL_METATABLE 4종(_, _TMP, _NEW, _OLD)에 AUDIT_YN 컬럼 추가
--              (코드는 이미 사용 중 — AccessLogMapper.xml, AccessLogCollectorImpl.java)
-- ============================================================

ALTER TABLE COTDL.TBL_METATABLE
    ADD COLUMN IF NOT EXISTS `AUDIT_YN` VARCHAR(1) DEFAULT 'N' COMMENT 'Audit 대상 여부 (Y/N) — AccessLog Collector 자동 필터';

ALTER TABLE COTDL.TBL_METATABLE_TMP
    ADD COLUMN IF NOT EXISTS `AUDIT_YN` VARCHAR(1) DEFAULT 'N' COMMENT 'Audit 대상 여부 (Y/N) — AccessLog Collector 자동 필터';

ALTER TABLE COTDL.TBL_METATABLE_NEW
    ADD COLUMN IF NOT EXISTS `AUDIT_YN` VARCHAR(1) DEFAULT 'N' COMMENT 'Audit 대상 여부 (Y/N) — AccessLog Collector 자동 필터';

ALTER TABLE COTDL.TBL_METATABLE_OLD
    ADD COLUMN IF NOT EXISTS `AUDIT_YN` VARCHAR(1) DEFAULT 'N' COMMENT 'Audit 대상 여부 (Y/N) — AccessLog Collector 자동 필터';
