-- ============================================================
-- X-Audit EXTERNAL 모드 — 고객사 별도 MariaDB/MySQL 배포 스키마 (V2)
-- 2026-04-24 재설계
--
-- 용도: XAUDIT_STORAGE_MODE=EXTERNAL 일 때 고객사 감사 DB 에 1회 실행.
-- 구조: 단일 Master Fact Table + 1:1 Sidecar (업계 Best Practice)
--       - Master: 고정 길이 컬럼 전용 (row ≈ 1KB, 인덱스/파티션 친화)
--       - Sidecar: TEXT/가변 필드 (법규 13조9항 SQL 풀 원문)
--
-- 근거 법규:
--   · 개인정보 안전성 확보조치 기준 제8조 (접속기록 1년/2년, 위변조 방지)
--   · 신용정보업감독규정 별표3 (개인신용정보 3년)
--   · 전자금융감독규정 시행세칙 제13조제1항제9호 (2025.2.3 신설, SQL 원문 의무)
--   · 안전성확보조치 제8조 3항 (SHA-256 해시체인)
--
-- 실행:
--   mariadb -h <host> -u <user> -p <db> < XAUDIT_SCHEMA_MARIADB.sql
-- 또는:
--   docker exec -i <mariadb> mariadb -u <user> -p<pwd> <db> < XAUDIT_SCHEMA_MARIADB.sql
-- ============================================================

-- 1) Master — TBL_ACCESS_LOG
DROP TABLE IF EXISTS TBL_ACCESS_LOG;
CREATE TABLE IF NOT EXISTS TBL_ACCESS_LOG (
    log_id             BIGINT        NOT NULL AUTO_INCREMENT,
    -- WHO
    source_system_id   VARCHAR(36),
    user_account       VARCHAR(100),
    user_name          VARCHAR(100),
    department         VARCHAR(100),
    -- WHEN
    access_time        DATETIME(3)   NOT NULL,
    -- WHERE
    client_ip          VARCHAR(45),
    session_id         VARCHAR(100),
    -- WHAT
    action_type        VARCHAR(20)   NOT NULL,
    target_db          VARCHAR(100),
    target_schema      VARCHAR(100),
    target_table       VARCHAR(200),
    affected_rows      INT           DEFAULT 0,
    result_code        VARCHAR(10)   DEFAULT 'SUCCESS',
    -- PII 플래그
    pii_type_codes     VARCHAR(200),
    pii_grade          CHAR(1),
    pii_detected_flag  CHAR(1)       DEFAULT 'N',
    -- 수집 메타
    collect_type       VARCHAR(20),
    access_channel     VARCHAR(20)   DEFAULT 'WAS',
    -- 무결성 + 시각
    hash_value         VARCHAR(64),
    prev_hash          VARCHAR(64),
    collected_at       DATETIME(3)   DEFAULT CURRENT_TIMESTAMP(3),
    partition_key      VARCHAR(8),
    -- WAS HTTP 컨텍스트
    req_id             VARCHAR(36),
    service_name       VARCHAR(50),
    menu_id            VARCHAR(100),
    uri                VARCHAR(500),
    http_method        VARCHAR(10),
    http_status        INT,
    duration_ms        BIGINT,
    PRIMARY KEY (log_id, access_time),
    INDEX idx_al_access_time  (access_time),
    INDEX idx_al_user_account (user_account, access_time),
    INDEX idx_al_action_type  (action_type, access_time),
    INDEX idx_al_pii_flag     (pii_detected_flag, access_time),
    INDEX idx_al_pii_grade    (pii_grade, access_time),
    INDEX idx_al_target_table (target_table, access_time),
    INDEX idx_al_collect_type (collect_type, access_time),
    INDEX idx_al_req_id       (req_id),
    INDEX idx_al_service      (service_name, access_time),
    INDEX idx_al_hash         (hash_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='X-Audit 접속기록 Master (통합)'
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

-- 2) Sidecar — TBL_ACCESS_LOG_DETAIL
DROP TABLE IF EXISTS TBL_ACCESS_LOG_DETAIL;
CREATE TABLE IF NOT EXISTS TBL_ACCESS_LOG_DETAIL (
    log_id           BIGINT         NOT NULL,
    access_time      DATETIME(3)    NOT NULL,
    req_id           VARCHAR(36),
    sql_id           VARCHAR(255),
    sql_text         MEDIUMTEXT,
    bind_params      TEXT,
    search_condition VARCHAR(4000),
    target_columns   VARCHAR(4000),
    full_uri         VARCHAR(2000),
    user_agent       VARCHAR(500),
    error_message    VARCHAR(500),
    collected_at     DATETIME(3)    DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (log_id, access_time),
    INDEX idx_ald_req  (req_id),
    INDEX idx_ald_time (access_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='X-Audit 접속기록 상세 sidecar'
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

-- 3) 통합 조회 뷰
DROP VIEW IF EXISTS V_ACCESS_LOG_UNIFIED;
CREATE VIEW V_ACCESS_LOG_UNIFIED AS
SELECT
    a.log_id, a.source_system_id, a.user_account, a.user_name, a.department,
    a.access_time, a.client_ip, a.session_id,
    a.action_type, a.target_db, a.target_schema, a.target_table,
    a.affected_rows, a.result_code,
    a.pii_type_codes, a.pii_grade, a.pii_detected_flag,
    a.collect_type, a.access_channel,
    a.hash_value, a.prev_hash, a.collected_at, a.partition_key,
    a.req_id, a.service_name, a.menu_id, a.uri, a.http_method,
    a.http_status, a.duration_ms,
    d.sql_id, d.sql_text, d.bind_params, d.search_condition,
    d.target_columns, d.full_uri, d.user_agent, d.error_message
FROM TBL_ACCESS_LOG a
LEFT JOIN TBL_ACCESS_LOG_DETAIL d
       ON a.log_id = d.log_id AND a.access_time = d.access_time;

-- 4) Verification
SELECT 'XAUDIT External Schema (MariaDB) deployed' AS MESSAGE;
SHOW TABLES LIKE 'TBL_ACCESS_LOG%';
