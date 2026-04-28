-- ============================================================
-- X-Audit EXTERNAL 모드 — 고객사 별도 Oracle/Tibero 배포 스키마 (V3)
-- 2026-04-27 INTERVAL 월 파티셔닝 적용
--
-- 용도: XAUDIT_STORAGE_MODE=EXTERNAL 일 때 고객사 감사 DB 에 1회 실행.
-- 구조: Master Fact Table + 1:1 Sidecar (MariaDB 버전과 1:1 동형)
--       + 월별 INTERVAL 파티셔닝 (access_time 기준 자동 생성)
-- 실행 주체: 해당 스키마 소유 유저 (예: XAUDIT / CLICK_AUDIT)
--
-- 지원 버전:
--   · Oracle 19c / 21c / 23c   — INTERVAL + IDENTITY 모두 지원
--   · Oracle 12c+              — INTERVAL + IDENTITY 모두 지원
--   · Oracle 11gR2             — INTERVAL 지원, IDENTITY 미지원 → 파일 하단 [LEGACY SEQ+TRG] 블록 사용
--   · Tibero 7 SP2+            — INTERVAL + IDENTITY 모두 지원
--   · Tibero 6                 — INTERVAL 미지원, IDENTITY 미지원 → 하단 [LEGACY] 블록 + [TIBERO6 수동월파티션] 블록 사용
--
-- ⚠️ Oracle EE 라이선스: Partitioning 은 EE 의 유상 옵션.
--    SE2/XE 미지원. (Oracle Free 23c 는 포함, 19c EE+Partitioning Option 또는 Tibero 7 EE 필요)
--
-- TBL_PIIDATABASE 등록 규약:
--   db='XAUDIT_DB', system='XAUDIT', dbtype='ORACLE'|'TIBERO', …
--   DLM .env: XAUDIT_STORAGE_MODE=EXTERNAL   (db-key default=XAUDIT_DB)
-- ============================================================

-- 1) Master — TBL_ACCESS_LOG (월 INTERVAL 파티션)
CREATE TABLE TBL_ACCESS_LOG (
    log_id             NUMBER(19)     GENERATED AS IDENTITY,
    -- WHO
    source_system_id   VARCHAR2(36),
    user_account       VARCHAR2(100),
    user_name          VARCHAR2(100),
    department         VARCHAR2(100),
    -- WHEN
    access_time        TIMESTAMP(3)   NOT NULL,
    -- WHERE
    client_ip          VARCHAR2(45),
    session_id         VARCHAR2(100),
    -- WHAT
    action_type        VARCHAR2(20)   NOT NULL,
    target_db          VARCHAR2(100),
    target_schema      VARCHAR2(100),
    target_table       VARCHAR2(200),
    affected_rows      NUMBER(10)     DEFAULT 0,
    result_code        VARCHAR2(10)   DEFAULT 'SUCCESS',
    -- PII
    pii_type_codes     VARCHAR2(200),
    pii_grade          CHAR(1),
    pii_detected_flag  CHAR(1)        DEFAULT 'N',
    -- 수집 메타
    collect_type       VARCHAR2(20),
    access_channel     VARCHAR2(20)   DEFAULT 'WAS',
    -- 무결성
    hash_value         VARCHAR2(64),
    prev_hash          VARCHAR2(64),
    collected_at       TIMESTAMP(3)   DEFAULT SYSTIMESTAMP NOT NULL,
    partition_key      VARCHAR2(8),
    -- WAS HTTP 컨텍스트
    req_id             VARCHAR2(36),
    service_name       VARCHAR2(50),
    menu_id            VARCHAR2(100),
    uri                VARCHAR2(500),
    http_method        VARCHAR2(10),
    http_status        NUMBER(10),
    duration_ms        NUMBER(19),
    CONSTRAINT pk_access_log PRIMARY KEY (log_id, access_time) USING INDEX LOCAL
)
PARTITION BY RANGE (access_time)
INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))
(
    PARTITION p_initial VALUES LESS THAN (TIMESTAMP '2026-02-01 00:00:00')
);

COMMENT ON TABLE  TBL_ACCESS_LOG                    IS 'X-Audit 접속기록 Master (월 INTERVAL 파티션)';
COMMENT ON COLUMN TBL_ACCESS_LOG.hash_value         IS 'SHA-256 해시 (위변조 방지, 안전성확보조치 8조 3항)';
COMMENT ON COLUMN TBL_ACCESS_LOG.partition_key      IS 'YYYYMMDD — 월 파티션 키 (보조)';
COMMENT ON COLUMN TBL_ACCESS_LOG.pii_detected_flag  IS 'Y/N — PII 포함 빠른 필터';

-- LOCAL 인덱스 (파티션 단위 관리 → DROP PARTITION 시 자동 정리, 파티션 프루닝 활용)
CREATE INDEX idx_al_access_time  ON TBL_ACCESS_LOG (access_time)                       LOCAL;
CREATE INDEX idx_al_user_account ON TBL_ACCESS_LOG (user_account, access_time)         LOCAL;
CREATE INDEX idx_al_action_type  ON TBL_ACCESS_LOG (action_type, access_time)          LOCAL;
CREATE INDEX idx_al_pii_flag     ON TBL_ACCESS_LOG (pii_detected_flag, access_time)    LOCAL;
CREATE INDEX idx_al_pii_grade    ON TBL_ACCESS_LOG (pii_grade, access_time)            LOCAL;
CREATE INDEX idx_al_target_table ON TBL_ACCESS_LOG (target_table, access_time)         LOCAL;
CREATE INDEX idx_al_collect_type ON TBL_ACCESS_LOG (collect_type, access_time)         LOCAL;
CREATE INDEX idx_al_req_id       ON TBL_ACCESS_LOG (req_id, access_time)               LOCAL;
CREATE INDEX idx_al_service      ON TBL_ACCESS_LOG (service_name, access_time)         LOCAL;
CREATE INDEX idx_al_hash         ON TBL_ACCESS_LOG (hash_value, access_time)           LOCAL;

-- 2) Sidecar — TBL_ACCESS_LOG_DETAIL (월 INTERVAL 파티션 — Master 와 동일 정책)
CREATE TABLE TBL_ACCESS_LOG_DETAIL (
    log_id           NUMBER(19)     NOT NULL,
    access_time      TIMESTAMP(3)   NOT NULL,
    req_id           VARCHAR2(36),
    sql_id           VARCHAR2(255),
    sql_text         CLOB,
    bind_params      CLOB,
    search_condition VARCHAR2(4000),
    target_columns   VARCHAR2(4000),
    full_uri         VARCHAR2(2000),
    user_agent       VARCHAR2(500),
    error_message    VARCHAR2(500),
    collected_at     TIMESTAMP(3)   DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_access_log_detail PRIMARY KEY (log_id, access_time) USING INDEX LOCAL
)
PARTITION BY RANGE (access_time)
INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))
(
    PARTITION p_initial VALUES LESS THAN (TIMESTAMP '2026-02-01 00:00:00')
);

COMMENT ON TABLE  TBL_ACCESS_LOG_DETAIL          IS 'X-Audit 접속기록 상세 sidecar (월 INTERVAL 파티션)';
COMMENT ON COLUMN TBL_ACCESS_LOG_DETAIL.sql_text IS 'SQL 풀 원문 (전자금융 13조9항 대응)';

CREATE INDEX idx_ald_req  ON TBL_ACCESS_LOG_DETAIL (req_id, access_time)  LOCAL;
CREATE INDEX idx_ald_time ON TBL_ACCESS_LOG_DETAIL (access_time)          LOCAL;

-- 3) 통합 조회 뷰
CREATE OR REPLACE VIEW V_ACCESS_LOG_UNIFIED AS
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


-- ============================================================
-- 운영 가이드 — INTERVAL 파티션
-- ============================================================
-- · 새 월 데이터 INSERT 시 Oracle 이 SYS_Pxxxxx 형태로 자동 파티션 생성
-- · 파티션 이름 조회:
--     SELECT partition_name, high_value FROM user_tab_partitions
--     WHERE table_name = 'TBL_ACCESS_LOG' ORDER BY partition_position;
-- · 보유기간 초과 파티션 삭제 (예: 2년 이전):
--     ALTER TABLE TBL_ACCESS_LOG DROP PARTITION FOR (TIMESTAMP '2024-01-01 00:00:00');
--     ALTER TABLE TBL_ACCESS_LOG_DETAIL DROP PARTITION FOR (TIMESTAMP '2024-01-01 00:00:00');
--   → LOCAL 인덱스도 함께 정리됨 (UPDATE GLOBAL INDEXES 불필요)
-- · DLM AccessLogArchiveScheduler 가 RETENTION_PERIOD_YEARS 설정에 따라 자동 호출
--
-- 파티션 친화적 가독성 이름 부여 (선택):
--   ALTER TABLE TBL_ACCESS_LOG RENAME PARTITION SYS_P12345 TO p202602;


-- ============================================================
-- [LEGACY SEQUENCE+TRIGGER] Oracle 11g / Tibero 6 에서 IDENTITY 미지원 시
-- 위 CREATE TABLE 의 `GENERATED AS IDENTITY` 절을 제거하고 아래 블록 사용:
-- ============================================================
-- CREATE SEQUENCE SEQ_ACCESS_LOG START WITH 1 INCREMENT BY 1 NOCACHE;
-- CREATE OR REPLACE TRIGGER TRG_ACCESS_LOG_BI
-- BEFORE INSERT ON TBL_ACCESS_LOG FOR EACH ROW
-- BEGIN
--     IF :NEW.log_id IS NULL THEN :NEW.log_id := SEQ_ACCESS_LOG.NEXTVAL; END IF;
--     IF :NEW.collected_at IS NULL THEN :NEW.collected_at := SYSTIMESTAMP; END IF;
-- END;
-- /


-- ============================================================
-- [TIBERO6 수동 월파티션] Tibero 6 처럼 INTERVAL 미지원 시
-- 위 PARTITION BY ... INTERVAL ... 절을 아래로 대체:
-- ============================================================
-- PARTITION BY RANGE (access_time) (
--     PARTITION p202601 VALUES LESS THAN (TIMESTAMP '2026-02-01 00:00:00'),
--     PARTITION p202602 VALUES LESS THAN (TIMESTAMP '2026-03-01 00:00:00'),
--     PARTITION p202603 VALUES LESS THAN (TIMESTAMP '2026-04-01 00:00:00'),
--     PARTITION p202604 VALUES LESS THAN (TIMESTAMP '2026-05-01 00:00:00'),
--     PARTITION p202605 VALUES LESS THAN (TIMESTAMP '2026-06-01 00:00:00'),
--     PARTITION p202606 VALUES LESS THAN (TIMESTAMP '2026-07-01 00:00:00'),
--     PARTITION p202607 VALUES LESS THAN (TIMESTAMP '2026-08-01 00:00:00'),
--     PARTITION p202608 VALUES LESS THAN (TIMESTAMP '2026-09-01 00:00:00'),
--     PARTITION p202609 VALUES LESS THAN (TIMESTAMP '2026-10-01 00:00:00'),
--     PARTITION p_future VALUES LESS THAN (MAXVALUE)
-- );
-- → 매월 1일 ALTER TABLE ... SPLIT PARTITION p_future 로 신월 파티션 추가 필요
