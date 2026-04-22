-- ============================================================
-- X-Audit 접속기록 수집 테이블
-- 고객사 처리계(외부 WAS)가 dlm-aop-sdk 를 통해 송신하는
-- 이벤트를 수신·저장하기 위한 스키마.
--
-- 설계 원칙:
--  1. req_id 로 ACCESS ↔ SQL 을 조인 (한 요청 = 1 ACCESS + N SQL)
--  2. 해시체인(hash_prev → hash_cur)로 위변조 방지 (안전성확보조치 제8조 3항)
--  3. partition_key(YYYYMMDD) 로 월별 파티션 준비
--  4. 기존 TBL_ACCESS_LOG 는 건드리지 않음 (DB 감사/Agent 경로 보존)
--
-- 근거 법규:
--  - 개인정보 안전성 확보조치 기준 제8조 (접속기록 보관 1년/2년)
--  - 신용정보업감독규정 별표3 (개인신용정보 처리내역 3년)
--  - 전자금융감독규정 시행세칙 제13조제1항제9호 (2025.2.3 신설, SQL 원문 의무)
--
-- 2026-04-20
-- ============================================================

-- 1. ACCESS 로그: 한 HTTP 요청 단위
DROP TABLE IF EXISTS COTDL.TBL_XAUDIT_ACCESS_LOG;
CREATE TABLE COTDL.TBL_XAUDIT_ACCESS_LOG (
    log_id            BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'PK',
    req_id            VARCHAR(36)   NOT NULL                            COMMENT '요청 UUID (SQL 로그와 조인키)',
    service_name      VARCHAR(50)   NULL                                COMMENT '처리계 시스템 ID (LOAN/CORE/CARD)',
    user_id           VARCHAR(100)  NULL                                COMMENT '사용자 계정',
    user_name         VARCHAR(100)  NULL                                COMMENT '사용자명',
    department        VARCHAR(100)  NULL                                COMMENT '부서',
    client_ip         VARCHAR(45)   NULL                                COMMENT '접속지 IP (IPv6 대응)',
    session_id        VARCHAR(100)  NULL                                COMMENT '세션 ID',
    menu_id           VARCHAR(100)  NULL                                COMMENT '메뉴 ID/업무 코드',
    uri               VARCHAR(500)  NULL                                COMMENT '요청 URI',
    http_method       VARCHAR(10)   NULL                                COMMENT 'GET/POST/PUT/DELETE',
    user_agent        VARCHAR(500)  NULL                                COMMENT 'User-Agent',
    access_time       DATETIME(3)   NULL                                COMMENT '요청 시각 (ms 정밀도)',
    partition_key     VARCHAR(8)    NULL                                COMMENT 'YYYYMMDD',
    http_status       INT           NULL                                COMMENT 'HTTP 응답 코드',
    total_duration_ms BIGINT        NULL                                COMMENT '요청 총 소요시간(ms)',
    result_code       VARCHAR(20)   NULL                                COMMENT 'SUCCESS/FAIL',
    collected_at      DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT 'DLM 서버 수신 시각',
    hash_prev         VARCHAR(64)   NULL                                COMMENT '이전 레코드 해시',
    hash_cur          VARCHAR(64)   NULL                                COMMENT '현재 레코드 SHA-256 해시',

    INDEX idx_xaudit_acc_req     (req_id),
    INDEX idx_xaudit_acc_user    (user_id, access_time),
    INDEX idx_xaudit_acc_time    (access_time),
    INDEX idx_xaudit_acc_part    (partition_key),
    INDEX idx_xaudit_acc_service (service_name, access_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='X-Audit 접속기록 (HTTP 요청 단위)';


-- 2. SQL 로그: 요청 안에서 실행된 개별 SQL
DROP TABLE IF EXISTS COTDL.TBL_XAUDIT_SQL_LOG;
CREATE TABLE COTDL.TBL_XAUDIT_SQL_LOG (
    log_id         BIGINT       NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'PK',
    req_id         VARCHAR(36)  NOT NULL                            COMMENT '요청 UUID (ACCESS 와 조인)',
    service_name   VARCHAR(50)  NULL                                COMMENT '처리계 시스템 ID',
    user_id        VARCHAR(100) NULL                                COMMENT '사용자 계정',
    user_name      VARCHAR(100) NULL                                COMMENT '사용자명',
    department     VARCHAR(100) NULL                                COMMENT '부서',
    client_ip      VARCHAR(45)  NULL                                COMMENT '접속지 IP',
    session_id     VARCHAR(100) NULL                                COMMENT '세션 ID',
    menu_id        VARCHAR(100) NULL                                COMMENT '메뉴 ID',
    uri            VARCHAR(500) NULL                                COMMENT '요청 URI',
    access_time    DATETIME(3)  NULL                                COMMENT 'SQL 실행 시각',
    partition_key  VARCHAR(8)   NULL                                COMMENT 'YYYYMMDD',

    sql_id         VARCHAR(255) NULL                                COMMENT 'MappedStatement ID 또는 JDBC',
    sql_type       VARCHAR(10)  NULL                                COMMENT 'SELECT/INSERT/UPDATE/DELETE/OTHER',
    sql_text       MEDIUMTEXT   NULL                                COMMENT '실행 SQL 원문 (Plugin 캡처)',
    bind_params    TEXT         NULL                                COMMENT '바인딩 파라미터 JSON',
    affected_rows  INT          NULL                                COMMENT 'DML 영향 행수 또는 SELECT 결과 수',
    duration_ms    BIGINT       NULL                                COMMENT 'SQL 실행 소요시간 (ms)',
    target_db      VARCHAR(100) NULL                                COMMENT '대상 DB (알 수 있으면)',
    target_table   VARCHAR(255) NULL                                COMMENT '대상 테이블',
    pii_detected   VARCHAR(200) NULL                                COMMENT '탐지된 PII CSV (JUMIN,CARD,...)',
    error_message  VARCHAR(500) NULL                                COMMENT '실패 시 예외 요약',
    collected_at   DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT 'DLM 수신 시각',
    hash_prev      VARCHAR(64)  NULL                                COMMENT '이전 해시',
    hash_cur       VARCHAR(64)  NULL                                COMMENT '현재 레코드 SHA-256 해시',

    INDEX idx_xaudit_sql_req     (req_id),
    INDEX idx_xaudit_sql_user    (user_id, access_time),
    INDEX idx_xaudit_sql_time    (access_time),
    INDEX idx_xaudit_sql_part    (partition_key),
    INDEX idx_xaudit_sql_pii     (pii_detected),
    INDEX idx_xaudit_sql_type    (sql_type, access_time),
    INDEX idx_xaudit_sql_service (service_name, access_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='X-Audit SQL 실행기록 (요청 내부 SQL)';


-- 3. 통합 조회 뷰 (JOIN 결과)
DROP VIEW IF EXISTS COTDL.V_XAUDIT_UNIFIED;
CREATE VIEW COTDL.V_XAUDIT_UNIFIED AS
SELECT
    a.req_id,
    a.service_name,
    a.user_id,
    a.user_name,
    a.client_ip,
    a.menu_id,
    a.uri,
    a.http_method,
    a.http_status,
    a.access_time      AS request_time,
    a.total_duration_ms,
    a.result_code,
    s.sql_id,
    s.sql_type,
    s.sql_text,
    s.affected_rows,
    s.duration_ms      AS sql_duration_ms,
    s.pii_detected,
    s.error_message    AS sql_error,
    s.access_time      AS sql_time
FROM COTDL.TBL_XAUDIT_ACCESS_LOG a
LEFT JOIN COTDL.TBL_XAUDIT_SQL_LOG s ON a.req_id = s.req_id;
