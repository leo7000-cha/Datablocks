-- ============================================================
-- X-One Discovery Module - DDL & Initial Data
-- PII 자동탐지 모듈 테이블 생성 및 초기 데이터
--
-- 대상 DB: MySQL / MariaDB
-- 스키마 : COTDL
-- 날짜   : 2026-03-01
--
-- 실행 전 주의:
--   DROP TABLE IF EXISTS 포함 - 기존 데이터가 삭제됩니다.
--   기존 스캔 결과를 보존하려면 DROP 구문을 주석 처리하세요.
-- ============================================================
--
-- [변경이력]
-- 2026-04-06  pii_type_code VARCHAR(20) → VARCHAR(50) 확장
--             - DLM PIICODE 체계 정렬 (예: 1_2_sexualOrientation=22자)
--             - 대상: TBL_DISCOVERY_PII_TYPE, TBL_DISCOVERY_RULE, TBL_DISCOVERY_SCAN_RESULT
--             - 초기 PII Type/Rule 데이터를 DLM PIICODE 형식으로 변경
--             - 기존 운영 환경: patches/DISCOVERY_PATCH_20260406.sql 적용
-- ============================================================


-- ============================================================
-- 0. 기존 테이블 삭제 (의존성 역순)
-- ============================================================
DROP TABLE IF EXISTS COTDL.TBL_DISCOVERY_TABLE_SCAN_STATUS;
DROP TABLE IF EXISTS COTDL.TBL_DISCOVERY_PII_REGISTRY;
DROP TABLE IF EXISTS COTDL.TBL_DISCOVERY_SCAN_RESULT;
DROP TABLE IF EXISTS COTDL.TBL_DISCOVERY_SCAN_EXECUTION;
DROP TABLE IF EXISTS COTDL.TBL_DISCOVERY_SCAN_JOB_V2;
DROP TABLE IF EXISTS COTDL.TBL_DISCOVERY_RULE;
DROP TABLE IF EXISTS COTDL.TBL_DISCOVERY_PII_TYPE;
DROP TABLE IF EXISTS COTDL.TBL_DISCOVERY_CONFIG;
-- 이전 버전 호환 (V1 테이블이 남아 있을 경우)
DROP TABLE IF EXISTS COTDL.TBL_DISCOVERY_SCAN_JOB;


-- ============================================================
-- 1. PII Type Master (PII 유형 마스터)
-- ============================================================
CREATE TABLE COTDL.TBL_DISCOVERY_PII_TYPE (
    pii_type_code     VARCHAR(50)   NOT NULL PRIMARY KEY COMMENT 'PII 유형 코드 (DLM PIICODE)',
    pii_type_name     VARCHAR(100)  NOT NULL COMMENT 'PII 유형명 (한글)',
    pii_type_name_en  VARCHAR(100)  COMMENT 'PII 유형명 (영문)',
    category          VARCHAR(50)   NOT NULL COMMENT '카테고리 (PERSONAL, FINANCIAL, CONTACT, etc.)',
    description       VARCHAR(500)  COMMENT '설명',
    scramble_type     VARCHAR(50)   COMMENT '권장 변환 타입',
    sort_order        INT           DEFAULT 0 COMMENT '정렬 순서',
    status            VARCHAR(20)   DEFAULT 'ACTIVE' COMMENT '상태 (ACTIVE, INACTIVE)',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    upd_date          DATETIME      ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='PII 유형 마스터';


-- ============================================================
-- 2. Discovery Rule (탐지 규칙)
-- ============================================================
CREATE TABLE COTDL.TBL_DISCOVERY_RULE (
    rule_id           VARCHAR(36)   NOT NULL PRIMARY KEY COMMENT '규칙 ID (UUID)',
    rule_name         VARCHAR(100)  NOT NULL COMMENT '규칙명',
    rule_type         VARCHAR(20)   NOT NULL COMMENT '규칙 타입 (META, PATTERN, AI)',
    pii_type_code     VARCHAR(50)   COMMENT 'PII 유형 코드 (FK)',
    category          VARCHAR(50)   NOT NULL COMMENT '카테고리 (NAME, SSN, PHONE, EMAIL, etc.)',
    pattern           VARCHAR(1000) NOT NULL COMMENT '패턴 (컬럼명 키워드 또는 정규식)',
    description       VARCHAR(500)  COMMENT '설명',
    weight            DECIMAL(3,2)  DEFAULT 0.5 COMMENT '가중치 (0.0-1.0)',
    priority          INT           DEFAULT 100 COMMENT '우선순위',
    status            VARCHAR(20)   DEFAULT 'ACTIVE' COMMENT '상태 (ACTIVE, INACTIVE)',
    reg_user_id       VARCHAR(50)   COMMENT '등록자 ID',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    upd_user_id       VARCHAR(50)   COMMENT '수정자 ID',
    upd_date          DATETIME      ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    INDEX idx_rule_category (category),
    INDEX idx_rule_type (rule_type),
    INDEX idx_rule_pii_type (pii_type_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='PII 탐지 규칙';


-- ============================================================
-- 3. Scan Job V2 (스캔 작업 정의 - 템플릿)
-- ============================================================
CREATE TABLE COTDL.TBL_DISCOVERY_SCAN_JOB_V2 (
    job_id            VARCHAR(36)   NOT NULL PRIMARY KEY COMMENT '작업 ID (UUID)',
    job_name          VARCHAR(100)  NOT NULL COMMENT '작업명',
    description       VARCHAR(500)  COMMENT '작업 설명',

    -- 대상 설정
    target_db         VARCHAR(50)   NOT NULL COMMENT '대상 데이터베이스',
    target_schema     VARCHAR(200)  COMMENT '대상 스키마 (콤마 구분)',
    target_tables     VARCHAR(2000) COMMENT '대상 테이블 (패턴 또는 목록)',

    -- 스캔 설정
    scan_mode         VARCHAR(20)   DEFAULT 'FULL' COMMENT '스캔 모드 (FULL, INCREMENTAL)',
    sample_size       INT           DEFAULT 1000 COMMENT '패턴 매칭용 샘플 크기',
    thread_count      INT           DEFAULT 5 COMMENT '동시 실행 스레드 수',

    -- 탐지 방법 설정
    enable_meta       CHAR(1)       DEFAULT 'Y' COMMENT '메타데이터 분석 활성화 (Y/N)',
    enable_pattern    CHAR(1)       DEFAULT 'Y' COMMENT '패턴 매칭 활성화 (Y/N)',
    enable_ai         CHAR(1)       DEFAULT 'N' COMMENT 'AI 분류 활성화 (Y/N)',

    -- 제외 설정
    exclude_data_types VARCHAR(500) DEFAULT 'NUMBER,DATE,TIMESTAMP,BLOB,CLOB,RAW,LONG,BFILE' COMMENT '제외할 데이터 타입',
    min_column_length  INT          DEFAULT 2 COMMENT '최소 컬럼 길이',
    exclude_patterns   VARCHAR(500) DEFAULT '*_CD,*_YN,*_FLAG,*_TYPE,*_SEQ,*_IDX,*_CNT,*_AMT' COMMENT '제외할 컬럼명 패턴',
    skip_confirmed_pii CHAR(1)      DEFAULT 'Y' COMMENT '확인된 PII 컬럼 건너뛰기 (Y/N)',

    -- 상태
    is_active         CHAR(1)       DEFAULT 'Y' COMMENT '활성화 여부 (Y/N)',

    -- 마지막 실행 정보
    last_execution_id VARCHAR(36)   COMMENT '마지막 실행 ID',
    execution_count   INT           DEFAULT 0 COMMENT '총 실행 횟수',

    -- 감사 정보
    reg_user_id       VARCHAR(50)   COMMENT '등록자 ID',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    upd_user_id       VARCHAR(50)   COMMENT '수정자 ID',
    upd_date          DATETIME      ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',

    INDEX idx_job_v2_target_db (target_db),
    INDEX idx_job_v2_is_active (is_active),
    INDEX idx_job_v2_reg_date (reg_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='PII 탐지 스캔 작업 정의';


-- ============================================================
-- 4. Scan Execution (스캔 실행 이력)
-- ============================================================
CREATE TABLE COTDL.TBL_DISCOVERY_SCAN_EXECUTION (
    execution_id      VARCHAR(36)   NOT NULL PRIMARY KEY COMMENT '실행 ID (UUID)',
    job_id            VARCHAR(36)   NOT NULL COMMENT '작업 ID (FK)',

    -- 상태
    status            VARCHAR(20)   DEFAULT 'PENDING' COMMENT '상태 (PENDING, RUNNING, COMPLETED, FAILED, CANCELLED)',
    progress          INT           DEFAULT 0 COMMENT '진행률 (0-100)',

    -- 스캔 통계
    total_tables      INT           DEFAULT 0 COMMENT '전체 테이블 수',
    scanned_tables    INT           DEFAULT 0 COMMENT '스캔 완료 테이블 수',
    skipped_tables    INT           DEFAULT 0 COMMENT '건너뛴 테이블 수',
    total_columns     INT           DEFAULT 0 COMMENT '전체 컬럼 수',
    scanned_columns   INT           DEFAULT 0 COMMENT '스캔된 컬럼 수',
    excluded_columns  INT           DEFAULT 0 COMMENT '제외된 컬럼 수',
    pii_count         INT           DEFAULT 0 COMMENT '탐지된 PII 수',

    -- 실행 설정
    thread_count      INT           DEFAULT 5 COMMENT '동시 실행 스레드 수',

    -- 시간 정보
    start_time        DATETIME      COMMENT '시작 시간',
    end_time          DATETIME      COMMENT '종료 시간',
    duration_ms       BIGINT        COMMENT '소요 시간 (밀리초)',

    -- 에러 정보
    error_msg         VARCHAR(2000) COMMENT '에러 메시지',

    -- 감사 정보
    reg_user_id       VARCHAR(50)   COMMENT '실행자 ID',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '실행 요청일시',

    INDEX idx_exec_job_id (job_id),
    INDEX idx_exec_status (status),
    INDEX idx_exec_start_time (start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='PII 탐지 스캔 실행 이력';


-- ============================================================
-- 5. Scan Result (탐지 결과)
-- ============================================================
CREATE TABLE COTDL.TBL_DISCOVERY_SCAN_RESULT (
    result_id         VARCHAR(36)   NOT NULL PRIMARY KEY COMMENT '결과 ID (UUID)',
    job_id            VARCHAR(36)   NOT NULL COMMENT '스캔 작업 ID (FK)',
    execution_id      VARCHAR(36)   COMMENT '실행 ID (FK)',

    -- 컬럼 정보
    db_name           VARCHAR(50)   NOT NULL COMMENT '데이터베이스명',
    schema_name       VARCHAR(50)   COMMENT '스키마명',
    table_name        VARCHAR(100)  NOT NULL COMMENT '테이블명',
    column_name       VARCHAR(100)  NOT NULL COMMENT '컬럼명',
    data_type         VARCHAR(50)   COMMENT '데이터 타입',
    column_comment    VARCHAR(500)  COMMENT '컬럼 코멘트',

    -- PII 탐지 정보
    pii_type_code     VARCHAR(50)   NOT NULL COMMENT 'PII 유형 코드 (NOT_PII 포함)',
    pii_type_name     VARCHAR(100)  COMMENT 'PII 유형명',

    -- 점수
    score             INT           DEFAULT 0 COMMENT '탐지 점수 (0-100)',
    meta_score        INT           DEFAULT 0 COMMENT '메타데이터 점수',
    pattern_score     INT           DEFAULT 0 COMMENT '패턴 점수',
    ai_score          INT           DEFAULT 0 COMMENT 'AI 점수',

    -- 매칭 정보
    meta_match        CHAR(1)       DEFAULT 'N' COMMENT '메타 매칭 여부 (Y/N)',
    pattern_match     CHAR(1)       DEFAULT 'N' COMMENT '패턴 매칭 여부 (Y/N)',
    ai_match          CHAR(1)       DEFAULT 'N' COMMENT 'AI 매칭 여부 (Y/N)',
    matched_rule      VARCHAR(100)  COMMENT '매칭된 규칙명',
    matched_pattern   VARCHAR(500)  COMMENT '매칭된 패턴',

    -- 샘플 데이터 (마스킹된 원본, 최대 5건)
    sample_data       VARCHAR(2000) COMMENT '샘플 데이터',

    -- 확인 상태
    confirm_status    VARCHAR(20)   DEFAULT 'PENDING' COMMENT '확인 상태 (PENDING, NOT_PII, CONFIRMED, EXCLUDED)',
    confirmed_by      VARCHAR(50)   COMMENT '확인자 ID',
    confirmed_date    DATETIME      COMMENT '확인일시',

    -- 감사 정보
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    upd_date          DATETIME      ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',

    INDEX idx_result_job_id (job_id),
    INDEX idx_result_execution_id (execution_id),
    INDEX idx_result_db_table (db_name, schema_name, table_name),
    INDEX idx_result_pii_type (pii_type_code),
    INDEX idx_result_score (score),
    INDEX idx_result_confirm_status (confirm_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='PII 탐지 결과';


-- ============================================================
-- 6. Discovery Config (설정)
-- ============================================================
CREATE TABLE COTDL.TBL_DISCOVERY_CONFIG (
    config_id         VARCHAR(36)   NOT NULL PRIMARY KEY COMMENT '설정 ID (UUID)',
    config_key        VARCHAR(100)  NOT NULL UNIQUE COMMENT '설정 키',
    config_value      VARCHAR(1000) COMMENT '설정 값',
    config_type       VARCHAR(50)   NOT NULL COMMENT '설정 유형',
    description       VARCHAR(500)  COMMENT '설명',
    is_active         CHAR(1)       DEFAULT 'Y' COMMENT '활성화 여부 (Y/N)',
    sort_order        INT           DEFAULT 0 COMMENT '정렬 순서',
    reg_user_id       VARCHAR(50)   COMMENT '등록자 ID',
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    upd_user_id       VARCHAR(50)   COMMENT '수정자 ID',
    upd_date          DATETIME      ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',

    INDEX idx_config_type (config_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='PII 탐지 설정';


-- ============================================================
-- 7. PII Registry (확인된 PII 컬럼 레지스트리)
-- ============================================================
CREATE TABLE COTDL.TBL_DISCOVERY_PII_REGISTRY (
    registry_id                VARCHAR(36)    NOT NULL PRIMARY KEY COMMENT 'Registry UUID',

    -- Column Identification (Unique Key)
    db_name                    VARCHAR(100)   NOT NULL COMMENT 'Database name',
    schema_name                VARCHAR(100)   NOT NULL COMMENT 'Schema name',
    table_name                 VARCHAR(200)   NOT NULL COMMENT 'Table name',
    column_name                VARCHAR(200)   NOT NULL COMMENT 'Column name',

    -- Column Metadata
    data_type                  VARCHAR(100)   COMMENT 'Data type',
    column_comment             VARCHAR(500)   COMMENT 'Column comment',

    -- PII Detection Info
    pii_type_code              VARCHAR(50)    NOT NULL COMMENT 'PII type code',
    pii_type_name              VARCHAR(100)   COMMENT 'PII type name',
    detection_method           VARCHAR(20)    COMMENT 'Detection method: META, PATTERN, META+PATTERN, MANUAL',
    confidence_score           DECIMAL(5,2)   COMMENT 'Detection confidence score',
    sample_data                TEXT           COMMENT 'Sample data at detection time',

    -- First Detection Info
    first_detected_date        DATETIME       COMMENT 'First detected date',
    first_detected_execution_id VARCHAR(36)   COMMENT 'First detection execution ID',
    first_detected_result_id   VARCHAR(36)    COMMENT 'Original scan result ID',

    -- Registry Status
    status                     VARCHAR(20)    NOT NULL DEFAULT 'CONFIRMED' COMMENT 'Status: CONFIRMED, EXCLUDED',

    -- Audit Info
    registered_by              VARCHAR(100)   NOT NULL COMMENT 'User who registered',
    registered_date            DATETIME       NOT NULL COMMENT 'Registration date',
    updated_by                 VARCHAR(100)   COMMENT 'User who last updated',
    updated_date               DATETIME       COMMENT 'Last update date',
    remarks                    VARCHAR(500)   COMMENT 'Additional remarks',

    -- Timestamps
    created_date               DATETIME       DEFAULT CURRENT_TIMESTAMP,

    -- Unique constraint: One entry per column
    UNIQUE KEY uk_registry_column (db_name, schema_name, table_name, column_name),

    -- Indexes
    INDEX idx_registry_status (status),
    INDEX idx_registry_db_schema (db_name, schema_name),
    INDEX idx_registry_pii_type (pii_type_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='PII Column Registry - Confirmed/Excluded PII columns';


-- ============================================================
-- 8. Table Scan Status (테이블 단위 완료 추적 - 재시작 시 스킵용)
-- ============================================================
CREATE TABLE COTDL.TBL_DISCOVERY_TABLE_SCAN_STATUS (
    execution_id      VARCHAR(36)   NOT NULL COMMENT '실행 ID (FK)',
    schema_name       VARCHAR(100)  COMMENT '스키마명',
    table_name        VARCHAR(200)  NOT NULL COMMENT '테이블명',
    column_count      INT           DEFAULT 0 COMMENT '컬럼 수',
    pii_count         INT           DEFAULT 0 COMMENT '탐지된 PII 수',
    scan_time_ms      BIGINT        DEFAULT 0 COMMENT '스캔 소요시간 (ms)',
    completed_time    DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '완료 시간',

    PRIMARY KEY (execution_id, table_name),
    INDEX idx_tss_execution_id (execution_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Discovery 테이블 단위 스캔 완료 추적';


-- ============================================================
-- 초기 데이터: PII Type Master
-- ============================================================
-- 기본 PII Type: DLM PIICODE 체계 (상세 데이터는 DISCOVERY_PII_RULES_FINANCIAL.sql 참조)
INSERT INTO COTDL.TBL_DISCOVERY_PII_TYPE (pii_type_code, pii_type_name, pii_type_name_en, category, description, scramble_type, sort_order) VALUES
('1_1_rrn',           '주민/외국인등록번호', 'Resident Registration Number', 'ID',        '주민등록번호 13자리, 외국인등록번호',       'SCRAMBLE_RRN_AFTER7',     101),
('2_1_name',          '성명(개인/법인)',     'Name',                         'PERSONAL',  '성명 (개인/법인)',                          'SCRAMBLE_NORMAL_ALL',     201),
('2_2_telno',         '전화번호',           'Phone Number',                 'CONTACT',   '휴대폰, 유선전화, FAX 번호',                'SCRAMBLE_NORMAL_LAST7',   211),
('2_2_email',         '이메일',             'Email Address',                'CONTACT',   '이메일 주소',                               'SCRAMBLE_EMAIL_ALL',      212),
('2_2_address2',      '주소 하(상세영역)',   'Address Detail',               'CONTACT',   '주소 (상세영역)',                           'SCRAMBLE_NORMAL_ALL',     214),
('1_4_creditCard',    '신용카드번호',       'Credit Card Number',           'FINANCIAL', '신용카드, 체크카드 번호 16자리',            'SCRAMBLE_NORMAL_LAST8',   132),
('1_4_account',       '계좌번호',           'Account Number',               'FINANCIAL', '은행 계좌번호',                             'SCRAMBLE_NORMAL_LAST8',   131),
('2_1_dob',           '생년월일',           'Date of Birth',                'PERSONAL',  '생년월일 (YYYYMMDD)',                       'SCRAMBLE_YYMMDD_ALL',     202),
('1_1_passport',      '여권번호',           'Passport Number',              'ID',        '여권번호 (영문1+숫자8)',                    'SCRAMBLE_NORMAL_AFTER2',  103),
('1_1_driverLicense', '운전면허번호',       'Driver License Number',        'ID',        '운전면허번호 12자리',                       'SCRAMBLE_NORMAL_AFTER3',  102),
('3_3_corpno',        '법인번호',           'Corporate Number',             'LIMITED_ID','법인번호 13자리',                           'SCRAMBLE_CORPNO_ALL',     321),
('3_1_ipAddress',     'IP 주소',            'IP Address',                   'AUTO',      'IPv4/IPv6 주소',                            'SCRAMBLE_NORMAL_ALL',     301),
('1_3_pwd',           '비밀번호',           'Password',                     'AUTH',      '비밀번호, 인증번호, PIN',                   'FIXED_1111',             122),
('NOT_PII',           'PII 아님',           'Not PII',                      'NONE',      'PII가 아닌 것으로 판단된 컬럼',             NULL,                     999);


-- ============================================================
-- 초기 데이터: Discovery Rules - Metadata (컬럼명 키워드 기반)
-- ============================================================
-- 기본 META Rules: DLM PIICODE 체계 (상세 규칙은 DISCOVERY_PII_RULES_FINANCIAL.sql 참조)
INSERT INTO COTDL.TBL_DISCOVERY_RULE (rule_id, rule_name, rule_type, pii_type_code, category, pattern, description, weight, priority, status) VALUES
(UUID(), '성명 컬럼',           'META', '2_1_name',       'PERSONAL',  'NAME,NM,성명,이름,고객명,사용자명,CUST_NM,USER_NM,EMP_NM', '성명 관련 컬럼',       0.5, 10, 'ACTIVE'),
(UUID(), '주민/외국인등록번호', 'META', '1_1_rrn',        'ID',        'SSN,JUMIN,주민번호,주민등록번호,RESIDENT,RRN',               '주민등록번호 관련 컬럼', 0.6, 10, 'ACTIVE'),
(UUID(), '전화번호 컬럼',       'META', '2_2_telno',      'CONTACT',   'PHONE,TEL,HP,MOBILE,전화,휴대폰,연락처,FAX,CELL',           '전화번호 관련 컬럼',   0.5, 10, 'ACTIVE'),
(UUID(), '이메일 컬럼',         'META', '2_2_email',      'CONTACT',   'EMAIL,MAIL,이메일,메일',                                     '이메일 관련 컬럼',     0.5, 10, 'ACTIVE'),
(UUID(), '주소 컬럼',           'META', '2_2_address2',   'CONTACT',   'ADDR,ADDRESS,주소,거주지',                                   '주소 관련 컬럼',       0.5, 10, 'ACTIVE'),
(UUID(), '카드번호 컬럼',       'META', '1_4_creditCard', 'FINANCIAL', 'CARD,카드번호,신용카드,CREDIT,CARD_NO',                       '카드번호 관련 컬럼',   0.5, 10, 'ACTIVE'),
(UUID(), '계좌번호 컬럼',       'META', '1_4_account',    'FINANCIAL', 'ACCT,ACCOUNT,계좌,통장,BANK,ACCT_NO',                        '계좌번호 관련 컬럼',   0.5, 10, 'ACTIVE'),
(UUID(), '생년월일 컬럼',       'META', '2_1_dob',        'PERSONAL',  'BIRTH,생년월일,생일,DOB,BIRTHDAY',                            '생년월일 관련 컬럼',   0.4, 10, 'ACTIVE');


-- ============================================================
-- 초기 데이터: Discovery Rules - Pattern (정규식 기반)
-- ============================================================
-- 기본 PATTERN Rules: DLM PIICODE 체계 (상세 규칙은 DISCOVERY_PII_RULES_FINANCIAL.sql 참조)
INSERT INTO COTDL.TBL_DISCOVERY_RULE (rule_id, rule_name, rule_type, pii_type_code, category, pattern, description, weight, priority, status) VALUES
(UUID(), '주민등록번호 패턴',    'PATTERN', '1_1_rrn',        'ID',        '^\d{6}-[1-4]\d{6}$',              '주민등록번호 (하이픈 포함)',    0.95, 5, 'ACTIVE'),
(UUID(), '외국인등록번호 패턴',  'PATTERN', '1_1_rrn',        'ID',        '^\d{6}-[5-8]\d{6}$',              '외국인등록번호',                0.90, 5, 'ACTIVE'),
(UUID(), '휴대폰 번호 패턴',    'PATTERN', '2_2_telno',      'CONTACT',   '^01[016789]-?\d{3,4}-?\d{4}$',    '한국 휴대폰 번호',              0.85, 5, 'ACTIVE'),
(UUID(), '유선 전화번호 패턴',  'PATTERN', '2_2_telno',      'CONTACT',   '^0[2-6][1-5]?-?\d{3,4}-?\d{4}$', '유선 전화번호',                  0.80, 6, 'ACTIVE'),
(UUID(), '이메일 패턴',         'PATTERN', '2_2_email',      'CONTACT',   '^[\w.-]+@[\w.-]+\.\w+$',           '이메일 주소',                   0.90, 5, 'ACTIVE'),
(UUID(), '카드번호 패턴',       'PATTERN', '1_4_creditCard', 'FINANCIAL', '^\d{4}-?\d{4}-?\d{4}-?\d{4}$',    '카드번호 16자리',               0.85, 5, 'ACTIVE'),
(UUID(), '계좌번호 패턴',       'PATTERN', '1_4_account',    'FINANCIAL', '^\d{3,4}-\d{2,4}-\d{4,6}$',       '계좌번호 패턴',                 0.75, 6, 'ACTIVE'),
(UUID(), '사업자등록번호 패턴', 'PATTERN', '3_3_corpno',     'LIMITED_ID','^\d{3}-\d{2}-\d{5}$',              '사업자등록번호',                0.85, 5, 'ACTIVE'),
(UUID(), '한글 이름 패턴',      'PATTERN', '2_1_name',       'PERSONAL',  '^[가-힣]{2,5}$',                    '한글 이름 (2~5자)',             0.40, 10, 'ACTIVE');


-- ============================================================
-- 초기 데이터: Default Config
-- ============================================================
INSERT INTO COTDL.TBL_DISCOVERY_CONFIG (config_id, config_key, config_value, config_type, description, sort_order) VALUES
(UUID(), 'DEFAULT_THREAD_COUNT',      '5',  'GENERAL', '기본 동시 실행 스레드 수',   1),
(UUID(), 'DEFAULT_SAMPLE_SIZE',       '100','GENERAL', '기본 샘플 크기',             2),
(UUID(), 'SKIP_CONFIRMED_PII',        'Y',  'GENERAL', '확인된 PII 컬럼 건너뛰기',  3),
(UUID(), 'PATTERN_MATCH_THRESHOLD',   '70', 'GENERAL', '패턴 매칭 최소 점수',        4);


-- ============================================================
-- [선택] 기존 스캔 결과에서 CONFIRMED/EXCLUDED를 Registry로 이관
-- 기존 운영 환경에 스캔 결과가 있는 경우에만 실행하세요.
-- 신규 설치 시에는 이 구문을 실행하지 않아도 됩니다.
-- ============================================================
/*
INSERT INTO COTDL.TBL_DISCOVERY_PII_REGISTRY (
    registry_id, db_name, schema_name, table_name, column_name,
    data_type, column_comment,
    pii_type_code, pii_type_name, detection_method, confidence_score, sample_data,
    first_detected_date, first_detected_execution_id, first_detected_result_id,
    status, registered_by, registered_date, updated_by, updated_date, created_date
)
SELECT
    UUID() AS registry_id,
    r.db_name, r.schema_name, r.table_name, r.column_name,
    r.data_type, r.column_comment,
    r.pii_type_code, r.pii_type_name,
    CASE
        WHEN r.meta_match = 'Y' AND r.pattern_match = 'Y' THEN 'META+PATTERN'
        WHEN r.meta_match = 'Y' THEN 'META'
        WHEN r.pattern_match = 'Y' THEN 'PATTERN'
        ELSE 'UNKNOWN'
    END AS detection_method,
    r.score AS confidence_score,
    r.sample_data,
    r.reg_date AS first_detected_date,
    r.execution_id AS first_detected_execution_id,
    r.result_id AS first_detected_result_id,
    r.confirm_status AS status,
    COALESCE(r.confirmed_by, 'SYSTEM') AS registered_by,
    COALESCE(r.confirmed_date, NOW()) AS registered_date,
    r.confirmed_by AS updated_by,
    r.confirmed_date AS updated_date,
    NOW() AS created_date
FROM COTDL.TBL_DISCOVERY_SCAN_RESULT r
WHERE r.confirm_status IN ('CONFIRMED', 'EXCLUDED')
  AND r.result_id = (
      SELECT r2.result_id
      FROM COTDL.TBL_DISCOVERY_SCAN_RESULT r2
      WHERE r2.db_name = r.db_name
        AND r2.schema_name = r.schema_name
        AND r2.table_name = r.table_name
        AND r2.column_name = r.column_name
        AND r2.confirm_status IN ('CONFIRMED', 'EXCLUDED')
      ORDER BY r2.confirmed_date DESC
      LIMIT 1
  )
ON DUPLICATE KEY UPDATE
    registry_id = registry_id;
*/


-- ============================================================
-- 검증
-- ============================================================
SELECT 'Discovery DDL Deploy Complete!' AS MESSAGE;
SELECT 'PII_TYPE'  AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM COTDL.TBL_DISCOVERY_PII_TYPE
UNION ALL
SELECT 'RULE',                     COUNT(*)              FROM COTDL.TBL_DISCOVERY_RULE
UNION ALL
SELECT 'CONFIG',                   COUNT(*)              FROM COTDL.TBL_DISCOVERY_CONFIG;
