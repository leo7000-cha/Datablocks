-- ============================================================
-- DISCOVERY_PII_TYPE.status SYNC PATCH
-- Date: 2026-04-26
-- Description: LKPIISCRTYPE.VISIBLE ↔ DISCOVERY_PII_TYPE.status 정합성 보정
--   두 테이블은 1:1 매핑이지만 DB FK 가 없어 운영 중 LKPIISCRTYPE.VISIBLE 만
--   토글되면 DISCOVERY_PII_TYPE.status 가 ACTIVE 로 남아 Discovery 가 계속
--   탐지하고 마스킹 단계에서만 누락되는 데이터 노출 위험이 있음.
--   이 패치는 기존 누적된 불일치를 한 번 보정하고, 코드 레벨 동기화
--   (LkPiiScrTypeServiceImpl.updateVisible) 가 이후 동기화를 책임짐.
--   NOT_PII 는 LKPIISCRTYPE 에 없으므로 보정 대상에서 제외됨.
-- ============================================================

UPDATE COTDL.TBL_DISCOVERY_PII_TYPE d
   JOIN COTDL.TBL_LKPIISCRTYPE l ON d.pii_type_code = l.PIICODE
    SET d.status = CASE WHEN l.VISIBLE = 'Y' THEN 'ACTIVE' ELSE 'INACTIVE' END,
        d.upd_date = NOW()
  WHERE (l.VISIBLE = 'Y' AND d.status <> 'ACTIVE')
     OR (l.VISIBLE = 'N' AND d.status <> 'INACTIVE');
