-- ============================================================
-- TBL_PIICONFTABLE / TBL_PIICONFKEYMAP DROP PATCH
-- Date: 2026-04-30
-- Description: dead 테이블 폐기 — 선행 커밋 16eaa13 에서 관련
--   mapper/service/controller 가 전면 폐기됐고, 후속 커밋 743c3aa 에서
--   마스터/배포 DDL 의 CREATE/DROP 정의도 제거됨. 운영 DB 에 잔존하는
--   실 테이블도 함께 정리하기 위한 패치.
--
--   잔존 소스 참조 확인:
--     - DLM/.../PiiConfKeymapRefVO.java — 도메인 VO 클래스명만 동일,
--       실 SELECT 는 PiiStepTableMapper.xml:101 의 getList_Keymap 인데
--       cotdl.tbl_piisteptable 만 조회하고 PIICONFKEYMAP 의존성 없음.
--     - 그 외 mapper 의 // @Select(...) 는 모두 주석 처리된 dead 참조.
--
-- ⚠️ 사전 백업 필수 (롤백 가능성 보장):
--   mysqldump -h <host> -u <user> -p cotdl TBL_PIICONFTABLE TBL_PIICONFKEYMAP \
--     > backup_piiconf_$(date +%Y%m%d_%H%M%S).sql
--
-- ⚠️ DROP 전 잔존 row 수 확인 권장:
--   SELECT 'TBL_PIICONFTABLE' AS tbl, COUNT(*) AS rowcnt FROM COTDL.TBL_PIICONFTABLE
--   UNION ALL
--   SELECT 'TBL_PIICONFKEYMAP', COUNT(*)            FROM COTDL.TBL_PIICONFKEYMAP;
--
-- 적용 대상: 4개 고객사 운영 DB (jbwoori / hanson_prod / hanson_dev / imcapital)
-- ============================================================

DROP TABLE IF EXISTS `COTDL`.`TBL_PIICONFTABLE`;
DROP TABLE IF EXISTS `COTDL`.`TBL_PIICONFKEYMAP`;
