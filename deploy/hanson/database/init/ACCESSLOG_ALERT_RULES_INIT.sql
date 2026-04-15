-- ============================================================
-- Privacy Monitor — 이상행위 탐지 규칙 초기 데이터
-- 설계서 3.4절 M3.1 기본 제공 탐지 규칙 10개
-- ============================================================

INSERT INTO COTDL.TBL_ACCESS_LOG_ALERT_RULE (rule_id, rule_code, rule_name, description, severity, condition_type, threshold_value, time_window_min, time_range_start, time_range_end, target_action, target_pii_grade, is_active, sort_order) VALUES
(UUID(), 'R01', '대량 조회', '1시간 내 동일 사용자가 N건 이상 조회', 'HIGH', 'VOLUME', 1000, 60, NULL, NULL, 'SELECT', NULL, 'Y', 1),
(UUID(), 'R02', '대량 다운로드', '1일 내 다운로드 건수 N건 초과', 'HIGH', 'VOLUME', 100, 1440, NULL, NULL, 'DOWNLOAD', NULL, 'Y', 2),
(UUID(), 'R03', '업무외 시간 접근', '22:00~06:00 사이 접근', 'MEDIUM', 'TIME_RANGE', NULL, NULL, '22:00', '06:00', NULL, NULL, 'Y', 3),
(UUID(), 'R04', '휴일 접근', '공휴일/주말 접근', 'MEDIUM', 'TIME_RANGE', NULL, NULL, NULL, NULL, NULL, NULL, 'Y', 4),
(UUID(), 'R05', '비인가 접근 시도', 'result_code = DENIED', 'HIGH', 'ACCESS_DENIED', 1, NULL, NULL, NULL, NULL, NULL, 'Y', 5),
(UUID(), 'R06', '고유식별정보 접근', '1급 PII 테이블 접근', 'INFO', 'PII_GRADE', NULL, NULL, NULL, NULL, NULL, '1', 'Y', 6),
(UUID(), 'R07', '반복 조회', '동일 정보주체를 1시간 내 N회 이상 조회', 'MEDIUM', 'REPEAT', 5, 60, NULL, NULL, 'SELECT', NULL, 'Y', 7),
(UUID(), 'R08', '민감정보 다운로드', '1급 민감정보 테이블 다운로드', 'HIGH', 'PII_GRADE', NULL, NULL, NULL, NULL, 'DOWNLOAD', '1', 'Y', 8),
(UUID(), 'R09', '신규 IP 접근', '기존 접속 이력에 없는 IP에서 접근', 'LOW', 'NEW_IP', NULL, NULL, NULL, NULL, NULL, NULL, 'Y', 9),
(UUID(), 'R10', '퇴직/이동자 접근', '비활성 계정으로 접근 시도', 'HIGH', 'INACTIVE', NULL, NULL, NULL, NULL, NULL, NULL, 'Y', 10);

SELECT 'Alert Rules Init Complete!' AS MESSAGE;
SELECT COUNT(*) AS RULE_COUNT FROM COTDL.TBL_ACCESS_LOG_ALERT_RULE;
