-- ============================================================
-- DLM_PIISYSTEM_INIT : TBL_PIISYSTEM 초기 시스템 등록
-- ============================================================
-- DLM 에서 관리할 대상 시스템(원천/분리보관/접속기록 등)을 등록하는 스크립트.
-- 신규 사이트 배포 시 또는 시스템 마스터 초기화 시 사용합니다.
--
-- [컬럼 설명]
--   SYSTEM_ID    : 시스템 식별자 (PK)
--   SYSTEM_NAME  : 시스템 표시명 (한글)
--   SYSTEM_INFO  : 시스템 설명
--   USE_FLAG     : 사용 여부 ('Y'=사용, 'N'/'' = 미사용)
--
-- ============================================================
-- 사이트별 배포 시 SYSTEM_NAME / SYSTEM_INFO 를 사이트 정책에 맞게 조정하세요.
-- ============================================================

delete from COTDL.TBL_PIISYSTEM;

INSERT INTO COTDL.TBL_PIISYSTEM (SYSTEM_ID, SYSTEM_NAME, SYSTEM_INFO, USE_FLAG) VALUES
    ('ARCHIVE_DB', '분리보관',         'PII Archive DB server',     'Y'),
    ('CORE',       '계정계',           'Core system',               'Y'),
    ('XOne',        'X-One',           'X-One Home DB server',     'Y'),
    ('DW',         '정보계',           'Data Warehouse DB server',  'Y'),
    ('XAUDIT',     '접속기록저장소명', 'Access Log DB server',      'Y');


COMMIT;
