-- ============================================================
-- PATCH: TBL_PIISYSTEM 'DLM' → 'XOne' 시스템 식별자 전환
-- Date: 2026-04-25
-- Description: DLM 자체 시스템 식별자를 'X-One' 브랜드에 맞춰 'XOne' 으로 교체.
--              기존 'DLM' row 삭제 후 'XOne' row 추가.
-- 영향:
--   · TBL_PIISYSTEM.SYSTEM_ID = 'DLM' 행 삭제
--   · TBL_PIISYSTEM 에 ('XOne', 'X-One', 'X-One Home DB server', 'Y') 추가
--   · JSP 4개 파일 (piijob/list, register, modify, piiorder/report) 의 'DLM'
--     하드코딩이 'XOne' 으로 함께 변경되어 있어야 정합성 유지
-- ============================================================


-- ************************************************************
-- [MariaDB / MySQL]
-- ************************************************************

DELETE FROM COTDL.TBL_PIISYSTEM WHERE SYSTEM_ID = 'DLM';

INSERT INTO COTDL.TBL_PIISYSTEM (SYSTEM_ID, SYSTEM_NAME, SYSTEM_INFO, USE_FLAG)
VALUES ('XOne', 'X-One', 'X-One Home DB server', 'Y');

COMMIT;


-- ************************************************************
-- [Oracle] — 원천DB에도 동일 테이블이 있는 경우 수행
-- ************************************************************

-- DELETE FROM COTDL.TBL_PIISYSTEM WHERE SYSTEM_ID = 'DLM';
-- INSERT INTO COTDL.TBL_PIISYSTEM (SYSTEM_ID, SYSTEM_NAME, SYSTEM_INFO, USE_FLAG)
-- VALUES ('XOne', 'X-One', 'X-One Home DB server', 'Y');
-- COMMIT;
