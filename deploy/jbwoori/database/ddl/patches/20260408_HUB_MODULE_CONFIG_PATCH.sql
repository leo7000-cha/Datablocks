-- ============================================================
-- HUB 모듈 표시 설정 키 추가
-- 날짜: 2026-04-08
-- HUB 페이지에서 모듈별 카드 표시/숨김 제어 (Y=표시, N=숨김)
-- ============================================================

INSERT IGNORE INTO COTDL.TBL_PIICONFIG (CFGKEY, VALUE, COMMENTS) VALUES
('MODULE_XPURGE', 'Y', 'HUB 모듈 표시: X-Purge (개인정보 파기). Y=표시, N=숨김'),
('MODULE_XGEN',   'Y', 'HUB 모듈 표시: X-Gen (테스트데이터 생성). Y=표시, N=숨김'),
('MODULE_XSCAN',  'Y', 'HUB 모듈 표시: X-Scan (개인정보 탐지). Y=표시, N=숨김'),
('MODULE_XAUDIT', 'Y', 'HUB 모듈 표시: X-Audit (접속기록·소명). Y=표시, N=숨김');

SELECT CFGKEY, VALUE, COMMENTS FROM COTDL.TBL_PIICONFIG WHERE CFGKEY LIKE 'MODULE_%' ORDER BY CFGKEY;

SELECT 'HUB_MODULE_CONFIG_PATCH_20260408 applied: 4 module config keys added' AS MESSAGE;
