-- ============================================================
-- Privacy Monitor — 접속기록관리 DDL (통합본)
-- 대상 DB: MariaDB 10.11+
-- 스키마 : COTDL
-- 날짜   : 2026-04-06
-- ** 반복 실행 가능 (DROP IF EXISTS + CREATE IF NOT EXISTS + INSERT IGNORE) **
--
-- [변경이력]
-- 2026-04-14  TBL_ACCESS_LOG_ALERT_SUPPRESSION, _AUDIT, BCI_TARGET, EXCLUDE_SQL 추가
-- 2026-04-11  TBL_ACCESS_LOG_ALERT 소명 워크플로우 컬럼 추가
--             - notification_sent_at, notification_token, token_expires_at, target_user_email
--             - justification, justified_at, justified_by
--             - approver_id, approval_comment, approved_at
--             - sla_deadline, escalation_level
--             - status 확장: NEW/NOTIFIED/JUSTIFIED/RESOLVED/RE_JUSTIFY/OVERDUE/ESCALATED/DISMISSED
--             - 적용 방법: patches/ALERT_JUSTIFY_PATCH_20260411.sql 실행 (기존 환경)
-- ============================================================

-- ============================================================
-- 1. TBL_ACCESS_LOG_SOURCE — 수집 대상 시스템
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_SOURCE;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_SOURCE (
    source_id         VARCHAR(36)   NOT NULL PRIMARY KEY COMMENT '수집원 ID (UUID)',
    source_name       VARCHAR(100)  NOT NULL COMMENT '시스템명',
    source_type       VARCHAR(20)   DEFAULT 'DB_AUDIT' COMMENT '수집 방식 (DB_AUDIT: DB Audit, DB_DAC: DB 접근제어, WAS_AGENT: Java Agent (BCI))',
    db_name           VARCHAR(50)   COMMENT '연계 DB명 (DLM DB 등록 참조)',
    db_type           VARCHAR(20)   COMMENT 'DB 유형 (ORACLE, MARIADB, MYSQL, MSSQL, TIBERO, DB2)',
    hostname          VARCHAR(200)  COMMENT '호스트명',
    port              VARCHAR(10)   COMMENT '포트',
    schema_name       VARCHAR(100)  COMMENT '대상 스키마명 (PII 메타데이터 매칭용)',
    agent_id          VARCHAR(36)   COMMENT 'BCI Agent ID',
    agent_last_heartbeat DATETIME   COMMENT 'Agent 마지막 heartbeat 시간',
    agent_status      VARCHAR(20)   DEFAULT NULL COMMENT 'Agent 상태 (ACTIVE/INACTIVE)',
    description       VARCHAR(500)  COMMENT '설명',
    collect_interval  INT           DEFAULT 5 COMMENT '수집 주기 (분)',
    table_filter      VARCHAR(2000) COMMENT '수집 대상 테이블 필터 (콤마 구분)',
    exclude_accounts  VARCHAR(1000) COMMENT '제외 계정 (콤마 구분: SYS,SYSTEM,DLM_BATCH)',
    -- DB_DAC(DB접근제어 연동 감사) 전용 컬럼
    dac_select_sql    TEXT          COMMENT 'DB_DAC 사용자 정의 SELECT문 (접근제어 솔루션 로그 조회)',
    is_active         CHAR(1)       DEFAULT 'Y' COMMENT '활성화 여부',
    status            VARCHAR(20)   DEFAULT 'STOPPED' COMMENT '수집 상태 (RUNNING, STOPPED, ERROR)',
    last_collect_time DATETIME      COMMENT '마지막 수집 시간',
    total_collected   BIGINT        DEFAULT 0 COMMENT '누적 수집 건수',
    error_msg         VARCHAR(1000) COMMENT '마지막 에러 메시지',
    reg_user_id       VARCHAR(50)   COMMENT '등록자 ID',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    upd_user_id       VARCHAR(50)   COMMENT '수정자 ID',
    upd_date          DATETIME      ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    INDEX idx_source_active (is_active),
    INDEX idx_source_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='접속기록 수집 대상 시스템';


-- ============================================================
-- 2. TBL_ACCESS_LOG — 접속기록 메인 (파티셔닝 대응 PK)
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG (
    log_id            BIGINT        NOT NULL AUTO_INCREMENT COMMENT '로그 ID',
    source_system_id  VARCHAR(36)   COMMENT '수집원 시스템 ID (FK)',
    user_account      VARCHAR(100)  COMMENT '접속자 계정 (Who)',
    user_name         VARCHAR(100)  COMMENT '접속자 이름',
    department        VARCHAR(100)  COMMENT '소속 부서',
    access_time       DATETIME(3)   NOT NULL COMMENT '접속일시 (When)',
    client_ip         VARCHAR(45)   COMMENT '접속지 IP (Where, IPv6 대응)',
    action_type       VARCHAR(20)   NOT NULL COMMENT '수행업무 (What): SELECT/UPDATE/DELETE/INSERT/DOWNLOAD/EXPORT',
    target_db         VARCHAR(100)  COMMENT '대상 DB명',
    target_schema     VARCHAR(100)  COMMENT '대상 스키마',
    target_table      VARCHAR(200)  COMMENT '대상 테이블',
    target_columns    TEXT          COMMENT '접근한 컬럼 목록',
    pii_type_codes    VARCHAR(500)  COMMENT '관련 PII 유형 코드',
    pii_grade         CHAR(1)       COMMENT '개인정보 등급 (1/2/3)',
    affected_rows     INT           DEFAULT 0 COMMENT '영향받은 행 수',
    search_condition  TEXT          COMMENT '검색 조건문 (Whom)',
    sql_text          TEXT          COMMENT '실행 SQL (선택)',
    collect_type      VARCHAR(20)   COMMENT '수집 방식 (DB_AUDIT: DB Audit, DB_DAC: DB 접근제어, WAS_AGENT: Java Agent (BCI))',
    access_channel    VARCHAR(20)   DEFAULT 'WEB' COMMENT '접근 경로 (WEB/WAS/DB_DIRECT/API/BATCH)',
    session_id        VARCHAR(100)  COMMENT '세션 ID',
    result_code       VARCHAR(10)   DEFAULT 'SUCCESS' COMMENT '수행 결과 (SUCCESS/FAIL/DENIED)',
    hash_value        VARCHAR(64)   COMMENT 'SHA-256 해시 (위변조 방지)',
    prev_hash         VARCHAR(64)   COMMENT '이전 레코드 해시 (해시 체인)',
    collected_at      DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT 'DLM 수집 시간',
    partition_key     VARCHAR(8)    COMMENT '파티셔닝 키 (YYYYMMDD)',
    PRIMARY KEY (log_id, access_time),
    -- 개별 필터 단독 조회 대응: (필터컬럼, access_time) → 단독 사용 + 기간 복합 모두 커버
    INDEX idx_al_access_time (access_time),
    INDEX idx_al_user_account (user_account, access_time),
    INDEX idx_al_action_type (action_type, access_time),
    INDEX idx_al_pii_grade (pii_grade, access_time),
    INDEX idx_al_target_table (target_table, access_time),
    INDEX idx_al_collect_type (collect_type, access_time),
    -- 해시 체인 검증
    INDEX idx_al_hash (hash_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='접속기록 메인'
PARTITION BY RANGE COLUMNS (access_time) (
    PARTITION p202601 VALUES LESS THAN ('2026-02-01'),
    PARTITION p202602 VALUES LESS THAN ('2026-03-01'),
    PARTITION p202603 VALUES LESS THAN ('2026-04-01'),
    PARTITION p202604 VALUES LESS THAN ('2026-05-01'),
    PARTITION p202605 VALUES LESS THAN ('2026-06-01'),
    PARTITION p202606 VALUES LESS THAN ('2026-07-01'),
    PARTITION p202607 VALUES LESS THAN ('2026-08-01'),
    PARTITION p202608 VALUES LESS THAN ('2026-09-01'),
    PARTITION p202609 VALUES LESS THAN ('2026-10-01'),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);


-- ============================================================
-- 3. TBL_ACCESS_LOG_COLLECT_STATUS — 수집 오프셋/상태 추적
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_COLLECT_STATUS;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_COLLECT_STATUS (
    status_id         BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '상태 ID',
    source_id         VARCHAR(36)   NOT NULL COMMENT '수집원 ID (FK)',
    collect_start     DATETIME      COMMENT '수집 시작 시간',
    collect_end       DATETIME      COMMENT '수집 종료 시간',
    last_offset       VARCHAR(200)  COMMENT '마지막 수집 오프셋 (타임스탬프 또는 시퀀스)',
    collected_count   INT           DEFAULT 0 COMMENT '수집 건수',
    status            VARCHAR(20)   DEFAULT 'SUCCESS' COMMENT '수집 결과 (SUCCESS/FAIL/PARTIAL)',
    error_msg         VARCHAR(1000) COMMENT '에러 메시지',
    retry_count       INT           DEFAULT 0 COMMENT '재시도 횟수',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    INDEX idx_cs_source (source_id, collect_start),
    INDEX idx_cs_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='접속기록 수집 상태 추적';


-- ============================================================
-- 4. TBL_ACCESS_LOG_ALERT_RULE — 이상행위 탐지 규칙
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_ALERT_RULE;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_ALERT_RULE (
    rule_id           VARCHAR(36)   NOT NULL PRIMARY KEY COMMENT '규칙 ID (UUID)',
    rule_code         VARCHAR(20)   NOT NULL UNIQUE COMMENT '규칙 코드 (R01, R02, ...)',
    rule_name         VARCHAR(100)  NOT NULL COMMENT '규칙명',
    description       VARCHAR(500)  COMMENT '규칙 설명',
    severity          VARCHAR(10)   DEFAULT 'MEDIUM' COMMENT '심각도 (HIGH/MEDIUM/LOW/INFO)',
    condition_type    VARCHAR(50)   NOT NULL COMMENT '조건 유형 (VOLUME/TIME_RANGE/ACCESS_DENIED/PII_GRADE/REPEAT/NEW_IP/INACTIVE)',
    threshold_value   INT           COMMENT '임계값',
    time_window_min   INT           COMMENT '시간 범위 (분)',
    time_range_start  VARCHAR(5)    COMMENT '시간대 시작 (HH:MM)',
    time_range_end    VARCHAR(5)    COMMENT '시간대 종료 (HH:MM)',
    target_action     VARCHAR(50)   COMMENT '대상 액션 (SELECT/UPDATE/DELETE/DOWNLOAD 등)',
    target_pii_grade  CHAR(1)       COMMENT '대상 PII 등급 (1/2/3)',
    is_active         CHAR(1)       DEFAULT 'Y' COMMENT '활성화 여부',
    sort_order        INT           DEFAULT 0 COMMENT '정렬 순서',
    reg_user_id       VARCHAR(50)   COMMENT '등록자 ID',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    upd_user_id       VARCHAR(50)   COMMENT '수정자 ID',
    upd_date          DATETIME      ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    INDEX idx_ar_active (is_active),
    INDEX idx_ar_severity (severity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이상행위 탐지 규칙';


-- ============================================================
-- 5. TBL_ACCESS_LOG_ALERT — 이상행위 알림
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_ALERT;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_ALERT (
    alert_id          BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '알림 ID',
    rule_id           VARCHAR(36)   COMMENT '탐지 규칙 ID (FK)',
    rule_code         VARCHAR(20)   COMMENT '규칙 코드',
    severity          VARCHAR(10)   COMMENT '심각도',
    alert_title       VARCHAR(200)  NOT NULL COMMENT '알림 제목',
    alert_detail      TEXT          COMMENT '알림 상세',
    target_user_id    VARCHAR(100)  COMMENT '대상 사용자 ID',
    target_user_name  VARCHAR(100)  COMMENT '대상 사용자명',
    related_log_ids   TEXT          COMMENT '관련 접속기록 ID 목록',
    detected_time     DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '탐지 시간',
    status            VARCHAR(20)   DEFAULT 'NEW' COMMENT '상태 (NEW/NOTIFIED/JUSTIFIED/RESOLVED/RE_JUSTIFY/OVERDUE/ESCALATED/DISMISSED)',
    resolved_by       VARCHAR(50)   COMMENT '처리자 ID',
    resolved_time     DATETIME      COMMENT '처리 시간',
    resolve_comment   TEXT          COMMENT '처리 의견',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    upd_date          DATETIME      ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    -- 소명 워크플로우 (2026-04-11 추가)
    notification_sent_at DATETIME   NULL COMMENT '소명요청 이메일 발송 시간',
    notification_token VARCHAR(64)  NULL COMMENT '소명 페이지 접근용 일회성 토큰',
    token_expires_at  DATETIME      NULL COMMENT '토큰 만료시간',
    target_user_email VARCHAR(200)  NULL COMMENT '대상자 이메일',
    justification     TEXT          NULL COMMENT '대상자 소명(사유) 내용',
    justification_summary VARCHAR(500) NULL COMMENT '소명 요약 (리스트 표시용, 자동 생성)',
    justified_at      DATETIME      NULL COMMENT '소명 제출 시간',
    justified_by      VARCHAR(100)  NULL COMMENT '소명 제출자',
    approver_id       VARCHAR(50)   NULL COMMENT '승인자 ID',
    approval_comment  TEXT          NULL COMMENT '승인자 코멘트',
    approved_at       DATETIME      NULL COMMENT '승인 시간',
    sla_deadline      DATETIME      NULL COMMENT 'SLA 마감시간',
    escalation_level  INT           DEFAULT 0 COMMENT '에스컬레이션 단계 (0=없음, 1=OVERDUE, 2=ESCALATED)',
    INDEX idx_alert_status (status, detected_time),
    INDEX idx_alert_severity (severity, detected_time),
    INDEX idx_alert_user (target_user_id),
    INDEX idx_alert_rule (rule_id),
    INDEX idx_alert_token (notification_token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이상행위 알림';


-- ============================================================
-- 6. TBL_ACCESS_LOG_CONFIG — 모듈 설정
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_CONFIG;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_CONFIG (
    config_id         VARCHAR(36)   NOT NULL PRIMARY KEY COMMENT '설정 ID (UUID)',
    config_key        VARCHAR(100)  NOT NULL UNIQUE COMMENT '설정 키',
    config_value      VARCHAR(1000) COMMENT '설정 값',
    config_type       VARCHAR(50)   NOT NULL COMMENT '설정 유형 (GENERAL/RETENTION/COLLECT/ALERT/ARCHIVE)',
    description       VARCHAR(500)  COMMENT '설명',
    is_active         CHAR(1)       DEFAULT 'Y' COMMENT '활성화 여부',
    sort_order        INT           DEFAULT 0 COMMENT '정렬 순서',
    reg_user_id       VARCHAR(50)   COMMENT '등록자 ID',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    upd_user_id       VARCHAR(50)   COMMENT '수정자 ID',
    upd_date          DATETIME      ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    INDEX idx_alc_type (config_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='접속기록관리 설정';


-- ============================================================
-- 7. TBL_ACCESS_LOG_HASH_VERIFY — 해시 무결성 검증 이력
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_HASH_VERIFY;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_HASH_VERIFY (
    verify_id         BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '검증 ID',
    verify_date       DATE          NOT NULL COMMENT '검증 대상 날짜',
    total_records     BIGINT        DEFAULT 0 COMMENT '검증 대상 레코드 수',
    valid_records     BIGINT        DEFAULT 0 COMMENT '무결성 정상 수',
    invalid_records   BIGINT        DEFAULT 0 COMMENT '무결성 위반 수',
    first_invalid_id  BIGINT        COMMENT '첫 위반 레코드 ID',
    status            VARCHAR(20)   DEFAULT 'VALID' COMMENT '결과 (VALID/INVALID/ERROR)',
    error_msg         VARCHAR(1000) COMMENT '에러 메시지',
    started_at        DATETIME      COMMENT '검증 시작',
    completed_at      DATETIME      COMMENT '검증 완료',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    INDEX idx_hv_date (verify_date),
    INDEX idx_hv_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='해시 무결성 검증 이력';


-- ============================================================
-- 8. TBL_ACCESS_LOG_DOWNLOAD — 접속기록 다운로드 감사 이력
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_DOWNLOAD;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_DOWNLOAD (
    download_id       BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '다운로드 ID',
    user_id           VARCHAR(50)   NOT NULL COMMENT '다운로드 사용자 ID',
    user_name         VARCHAR(100)  COMMENT '다운로드 사용자명',
    download_time     DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '다운로드 시간',
    search_criteria   TEXT          COMMENT '검색 조건 (JSON)',
    record_count      INT           DEFAULT 0 COMMENT '다운로드 건수',
    file_format       VARCHAR(10)   DEFAULT 'XLSX' COMMENT '파일 형식 (XLSX/CSV)',
    reason            VARCHAR(500)  COMMENT '다운로드 사유',
    client_ip         VARCHAR(45)   COMMENT '접속 IP',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    INDEX idx_dl_user (user_id, download_time),
    INDEX idx_dl_time (download_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='접속기록 다운로드 감사 이력';


-- ============================================================
-- 9. TBL_ACCESS_LOG_ARCHIVE_HISTORY — 아카이브/파티션 관리 이력
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_ARCHIVE_HISTORY;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_ARCHIVE_HISTORY (
    history_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    action_type  VARCHAR(20) NOT NULL COMMENT 'CREATE_PARTITION / DROP_PARTITION / ARCHIVE',
    partition_name VARCHAR(50),
    target_month VARCHAR(7) COMMENT 'YYYY-MM',
    record_count BIGINT DEFAULT 0,
    status       VARCHAR(20) DEFAULT 'SUCCESS' COMMENT 'SUCCESS / FAILED',
    error_msg    VARCHAR(1000),
    executed_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    executed_by  VARCHAR(100) DEFAULT 'SYSTEM'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='접속기록 아카이브/파티션 관리 이력';


-- ============================================================
-- Default Config (INSERT IGNORE — 이미 있으면 스킵)
-- ============================================================
INSERT IGNORE INTO COTDL.TBL_ACCESS_LOG_CONFIG (config_id, config_key, config_value, config_type, description, is_active, sort_order, reg_user_id) VALUES
-- 일반
(UUID(), 'HASH_VERIFY_ENABLED',      'Y',    'GENERAL',   '해시 무결성 검증 활성화',            'Y',  1, 'system'),
(UUID(), 'HASH_VERIFY_SCHEDULE',     '0 0 3 1 * *', 'GENERAL', '해시 검증 스케줄 (매월 1일 03:00)',   'Y',  2, 'system'),
(UUID(), 'SQL_TEXT_LOGGING',          'N',    'GENERAL',   'SQL 전문 기록 여부',                 'Y',  3, 'system'),
-- 수집
(UUID(), 'SCHEDULER_ENABLED',        'Y',    'COLLECT',   '스케줄 수집 활성화 (Y/N)',            'Y', 10, 'system'),
(UUID(), 'COLLECT_INTERVAL_MIN',     '5',    'COLLECT',   '수집 주기 (분)',                      'Y', 11, 'system'),
(UUID(), 'COLLECT_BATCH_SIZE',       '1000', 'COLLECT',   '수집 배치 크기',                      'Y', 12, 'system'),
(UUID(), 'COLLECT_RETRY_COUNT',      '3',    'COLLECT',   '수집 실패 시 재시도 횟수',             'Y', 13, 'system'),
-- 탐지/알림
(UUID(), 'DETECTION_ENABLED',        'Y',    'ALERT',     '이상행위 탐지 활성화 (Y/N)',           'Y', 20, 'system'),
(UUID(), 'EMAIL_ENABLED',            'Y',    'ALERT',     '이메일 알림 활성화 (Y/N)',             'Y', 21, 'system'),
(UUID(), 'EMAIL_RECIPIENTS',         '',     'ALERT',     '알림 수신 이메일 (쉼표 구분)',          'Y', 22, 'system'),
-- 보관/아카이브
(UUID(), 'RETENTION_PERIOD_YEARS',   '2',    'RETENTION', '접속기록 보관기간 (년)',               'Y', 30, 'system'),
(UUID(), 'RETENTION_FINANCIAL_YEARS','5',    'ARCHIVE',   '금융사 중요원장 보관기간 (년)',         'Y', 31, 'system'),
(UUID(), 'ARCHIVE_ENABLED',         'Y',    'ARCHIVE',   '자동 아카이빙 활성화 (Y/N)',            'Y', 32, 'system');


-- ============================================================
-- Default Alert Rules (INSERT IGNORE — 이미 있으면 스킵)
-- ============================================================
INSERT IGNORE INTO COTDL.TBL_ACCESS_LOG_ALERT_RULE (rule_id, rule_code, rule_name, description, severity, condition_type, threshold_value, time_window_min, time_range_start, time_range_end, target_action, target_pii_grade, is_active, sort_order, reg_user_id) VALUES
(UUID(), 'R01', '대량 접속 탐지',           '시간 윈도우 내 사용자별 접속 건수 초과',     'HIGH',   'VOLUME',        100, 60,   NULL,    NULL,    NULL, NULL, 'Y', 1, 'system'),
(UUID(), 'R02', '야간 시간대 접속',         '비인가 시간대(야간/공휴일) 접속 탐지',       'MEDIUM', 'TIME_RANGE',    NULL, NULL, '22:00', '06:00', NULL, NULL, 'Y', 2, 'system'),
(UUID(), 'R03', '접속 거부 반복',           '접속 거부(DENIED) 반복 발생',              'HIGH',   'ACCESS_DENIED',   5, 30,   NULL,    NULL,    NULL, NULL, 'Y', 3, 'system'),
(UUID(), 'R04', '고등급 PII 대량 접근',     '고등급 개인정보 대량 접근 탐지',            'HIGH',   'PII_GRADE',      50, 60,   NULL,    NULL,    NULL, '1',  'Y', 4, 'system'),
(UUID(), 'R05', '동일 테이블 반복 접근',     '동일 테이블 반복 조회 탐지',              'MEDIUM', 'REPEAT',          30, 30,   NULL,    NULL,    NULL, NULL, 'Y', 5, 'system'),
(UUID(), 'R06', '미등록 IP 접근',           '90일 내 사용 이력 없는 IP에서 접속',       'MEDIUM', 'NEW_IP',         NULL, NULL, NULL,    NULL,    NULL, NULL, 'Y', 6, 'system'),
(UUID(), 'R07', '장기미사용 계정 접근',      '장기 미사용 계정의 접속 탐지',             'HIGH',   'INACTIVE',        90, NULL, NULL,    NULL,    NULL, NULL, 'Y', 7, 'system'),
(UUID(), 'R08', '휴일 접근 탐지',          '주말/공휴일 접속 탐지 (TBL_PIIBIZDAY 연계)', 'MEDIUM', 'HOLIDAY',       NULL, NULL, NULL,    NULL,    NULL, NULL, 'Y', 8, 'system');


-- ============================================================
-- 10. TBL_ACCESS_LOG_ALERT_SUPPRESSION — 알림 예외(억제) 규칙
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_ALERT_SUPPRESSION;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_ALERT_SUPPRESSION (
    suppression_id    BIGINT        NOT NULL AUTO_INCREMENT,
    rule_id           VARCHAR(50)   NOT NULL COMMENT '대상 탐지 규칙 ID',
    rule_code         VARCHAR(50)   COMMENT '규칙 코드 (표시용)',
    target_user_id    VARCHAR(100)  COMMENT '대상 사용자 (NULL=규칙 전체)',
    suppression_type  VARCHAR(20)   NOT NULL DEFAULT 'SUPPRESS' COMMENT 'SUPPRESS/EXCEPTION',
    reason            TEXT          NOT NULL COMMENT '예외 사유 (필수)',
    severity_at_time  VARCHAR(20)   COMMENT '등록 시점 규칙 심각도',
    source_alert_id   BIGINT        COMMENT '원본 알림 ID',
    approved_by       VARCHAR(100)  NOT NULL COMMENT '승인자 ID',
    approved_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '승인일시',
    effective_from    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '유효 시작일',
    effective_until   DATETIME      NOT NULL COMMENT '유효 만료일 (무기한 불가)',
    review_cycle_days INT           NOT NULL DEFAULT 90 COMMENT '정기 검토 주기 (일)',
    last_reviewed_at  DATETIME      COMMENT '마지막 검토일시',
    last_reviewed_by  VARCHAR(100)  COMMENT '마지막 검토자',
    next_review_at    DATETIME      COMMENT '다음 검토 예정일',
    review_comment    TEXT          COMMENT '최근 검토 의견',
    is_active         CHAR(1)       NOT NULL DEFAULT 'Y' COMMENT '활성 여부',
    deactivated_by    VARCHAR(100)  COMMENT '비활성화 처리자',
    deactivated_at    DATETIME      COMMENT '비활성화 일시',
    deactivate_reason VARCHAR(500)  COMMENT '비활성화 사유',
    reg_user_id       VARCHAR(100),
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP,
    upd_user_id       VARCHAR(100),
    upd_date          DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (suppression_id),
    KEY idx_suppression_rule   (rule_id, is_active),
    KEY idx_suppression_user   (target_user_id, is_active),
    KEY idx_suppression_review (next_review_at, is_active),
    KEY idx_suppression_active (is_active, effective_until)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='알림 예외(억제) 규칙';

-- ============================================================
-- 11. TBL_ACCESS_LOG_ALERT_SUPPRESSION_AUDIT — 억제 규칙 감사 로그
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_ALERT_SUPPRESSION_AUDIT;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_ALERT_SUPPRESSION_AUDIT (
    audit_id          BIGINT        NOT NULL AUTO_INCREMENT,
    suppression_id    BIGINT        NOT NULL COMMENT '대상 억제 규칙 ID',
    action_type       VARCHAR(20)   NOT NULL COMMENT 'CREATE/UPDATE/DEACTIVATE/REVIEW/EXTEND',
    action_detail     TEXT          COMMENT '변경 내용 상세',
    action_by         VARCHAR(100)  NOT NULL COMMENT '수행자 ID',
    action_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (audit_id),
    KEY idx_audit_suppression (suppression_id),
    KEY idx_audit_action_at   (action_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='알림 예외 규칙 감사 로그';

-- ============================================================
-- 12. TBL_ACCESS_LOG_BCI_TARGET — BCI Agent 감사 대상 테이블
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_BCI_TARGET;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_BCI_TARGET (
    target_id         VARCHAR(36)   NOT NULL,
    db_name           VARCHAR(100)  NOT NULL,
    owner             VARCHAR(128)  NOT NULL DEFAULT '',
    table_name        VARCHAR(128)  NOT NULL,
    target_type       VARCHAR(20)   NOT NULL DEFAULT 'PII' COMMENT 'PII/BUSINESS',
    description       VARCHAR(200),
    is_active         VARCHAR(1)    NOT NULL DEFAULT 'Y',
    reg_user_id       VARCHAR(10),
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP,
    upd_user_id       VARCHAR(10),
    upd_date          DATETIME,
    PRIMARY KEY (target_id),
    UNIQUE KEY uk_bci_target (db_name, owner, table_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='BCI Agent 감사 대상 테이블';

-- ============================================================
-- 13. TBL_ACCESS_LOG_EXCLUDE_SQL — 수집 제외 SQL 패턴
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_ACCESS_LOG_EXCLUDE_SQL;
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_EXCLUDE_SQL (
    pattern_id        INT           NOT NULL AUTO_INCREMENT,
    source_type       VARCHAR(20)   NOT NULL COMMENT 'DB_AUDIT/DLM_SELF/ALL',
    pattern           VARCHAR(500)  NOT NULL,
    match_type        VARCHAR(20)   NOT NULL DEFAULT 'PREFIX' COMMENT 'PREFIX/CONTAINS/REGEX',
    description       VARCHAR(200),
    is_active         VARCHAR(1)    NOT NULL DEFAULT 'Y',
    reg_user_id       VARCHAR(10),
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (pattern_id),
    UNIQUE KEY uk_exclude_sql (source_type, pattern(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='수집 제외 SQL 패턴';

-- ============================================================
-- Verification
-- ============================================================
SELECT 'AccessLog DDL Deploy Complete!' AS MESSAGE;
SELECT TABLE_NAME, TABLE_ROWS
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'COTDL' AND TABLE_NAME LIKE 'TBL_ACCESS_LOG%'
ORDER BY TABLE_NAME;
