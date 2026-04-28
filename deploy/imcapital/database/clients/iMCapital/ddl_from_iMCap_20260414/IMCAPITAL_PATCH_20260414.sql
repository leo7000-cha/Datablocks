-- ================================================================
-- iMCapital COTDL 스키마 동기화 패치
-- 생성일: 2026-04-14
-- 기준: DEV 개발환경 → CLIENT(iMCapital) 적용
-- ================================================================
-- 비교 방법: 고객사 information_schema vs DEV MariaDB 실제 스키마
-- 참조: 10_DDL_MASTER_CORE.sql + database/ddl/patches/* 전체
-- ================================================================
--
-- 구성:
--   PART 1: 기존 테이블 컬럼 추가 (ADD COLUMN)
--   PART 2: 기존 테이블 컬럼 타입 변경 (MODIFY COLUMN)
--   PART 3: 신규 테이블 생성 (CREATE TABLE)
--
-- 적용 순서: 30_DDL_MASTER_ACCESSLOG.sql → 20_DDL_MASTER_DISCOVERY.sql → 이 파일
-- ================================================================


-- ================================================================
-- PART 1: 기존 테이블에 컬럼 추가 (25건)
-- ================================================================
-- 출처: MEMBER_PATCH_20260411, LKPIISCRTYPE_PATCH_20260412,
--       10_DDL_MASTER_CORE.sql (testdata, metatable)

-- -------------------------------------------------------
-- 1-1. tbl_member: 소명 워크플로우 + 연락처 컬럼 5건
-- 출처: MEMBER_PATCH_20260411_JUSTIFY.sql
-- -------------------------------------------------------
ALTER TABLE tbl_member ADD COLUMN IF NOT EXISTS `TELNO` varchar(20) NULL COMMENT '전화번호';
ALTER TABLE tbl_member ADD COLUMN IF NOT EXISTS `GRADE` varchar(20) NULL COMMENT '등급';
ALTER TABLE tbl_member ADD COLUMN IF NOT EXISTS `EMAIL` varchar(200) NULL COMMENT '이메일';
ALTER TABLE tbl_member ADD COLUMN IF NOT EXISTS `MANAGER_ID` varchar(50) NULL COMMENT '상위결재자 ID';
ALTER TABLE tbl_member ADD COLUMN IF NOT EXISTS `POSITION` varchar(50) NULL COMMENT '직위/직급';

-- -------------------------------------------------------
-- 1-2. tbl_member_tmp: 동일 컬럼 추가 (메타 동기화용)
-- -------------------------------------------------------
ALTER TABLE tbl_member_tmp ADD COLUMN IF NOT EXISTS `TELNO` varchar(20) NULL COMMENT '전화번호';
ALTER TABLE tbl_member_tmp ADD COLUMN IF NOT EXISTS `GRADE` varchar(20) NULL COMMENT '등급';
ALTER TABLE tbl_member_tmp ADD COLUMN IF NOT EXISTS `EMAIL` varchar(200) NULL COMMENT '이메일';
ALTER TABLE tbl_member_tmp ADD COLUMN IF NOT EXISTS `MANAGER_ID` varchar(50) NULL COMMENT '상위결재자 ID';
ALTER TABLE tbl_member_tmp ADD COLUMN IF NOT EXISTS `POSITION` varchar(50) NULL COMMENT '직위/직급';

-- -------------------------------------------------------
-- 1-3. tbl_member_new: 동일 컬럼 추가
-- -------------------------------------------------------
ALTER TABLE tbl_member_new ADD COLUMN IF NOT EXISTS `TELNO` varchar(20) NULL COMMENT '전화번호';
ALTER TABLE tbl_member_new ADD COLUMN IF NOT EXISTS `GRADE` varchar(20) NULL COMMENT '등급';
ALTER TABLE tbl_member_new ADD COLUMN IF NOT EXISTS `EMAIL` varchar(200) NULL COMMENT '이메일';
ALTER TABLE tbl_member_new ADD COLUMN IF NOT EXISTS `MANAGER_ID` varchar(50) NULL COMMENT '상위결재자 ID';
ALTER TABLE tbl_member_new ADD COLUMN IF NOT EXISTS `POSITION` varchar(50) NULL COMMENT '직위/직급';

-- -------------------------------------------------------
-- 1-4. tbl_member_old: 동일 컬럼 추가
-- -------------------------------------------------------
ALTER TABLE tbl_member_old ADD COLUMN IF NOT EXISTS `TELNO` varchar(20) NULL COMMENT '전화번호';
ALTER TABLE tbl_member_old ADD COLUMN IF NOT EXISTS `GRADE` varchar(20) NULL COMMENT '등급';
ALTER TABLE tbl_member_old ADD COLUMN IF NOT EXISTS `EMAIL` varchar(200) NULL COMMENT '이메일';
ALTER TABLE tbl_member_old ADD COLUMN IF NOT EXISTS `MANAGER_ID` varchar(50) NULL COMMENT '상위결재자 ID';
ALTER TABLE tbl_member_old ADD COLUMN IF NOT EXISTS `POSITION` varchar(50) NULL COMMENT '직위/직급';

-- -------------------------------------------------------
-- 1-5. tbl_lkpiiscrtype: 인벤토리 표시 여부
-- 출처: LKPIISCRTYPE_PATCH_20260412_VISIBLE.sql
-- -------------------------------------------------------
ALTER TABLE tbl_lkpiiscrtype ADD COLUMN IF NOT EXISTS `visible` char(1) DEFAULT 'Y' COMMENT '인벤토리 표시 여부 (Y/N)';

-- -------------------------------------------------------
-- 1-6. tbl_metatable: Audit 대상 여부
-- -------------------------------------------------------
ALTER TABLE tbl_metatable ADD COLUMN IF NOT EXISTS `AUDIT_YN` varchar(1) DEFAULT 'N' COMMENT 'Audit 대상 여부 (Y/N)';

-- -------------------------------------------------------
-- 1-7. tbl_testdata: 파기 관련 컬럼 3건
-- 출처: 10_DDL_MASTER_CORE.sql
-- -------------------------------------------------------
ALTER TABLE tbl_testdata ADD COLUMN IF NOT EXISTS `DISPOSAL_STATUS` varchar(30) NULL COMMENT '파기 상태';
ALTER TABLE tbl_testdata ADD COLUMN IF NOT EXISTS `DISPOSAL_SCHE_DATE` datetime NULL COMMENT '파기 예정일';
ALTER TABLE tbl_testdata ADD COLUMN IF NOT EXISTS `DISPOSAL_EXEC_DATE` datetime NULL COMMENT '파기 실행일';


-- ================================================================
-- PART 2: 기존 테이블 컬럼 타입 변경 (8건)
-- ================================================================
-- 주의: 타입 확대만 수행 (축소는 데이터 손실 위험으로 제외)

-- -------------------------------------------------------
-- 2-1. CUST_NM: varchar(200)으로 통일
-- 기존: DEV=varchar(50), CLIENT=varchar(50~100) → 모두 varchar(200)
-- 대상: tbl_piirestore, tbl_piiextract, tbl_piicontract, tbl_testdata
-- -------------------------------------------------------
ALTER TABLE tbl_piirestore MODIFY COLUMN `CUST_NM` varchar(200);
ALTER TABLE tbl_piiextract MODIFY COLUMN `CUST_NM` varchar(200);
ALTER TABLE tbl_piicontract MODIFY COLUMN `CUST_NM` varchar(200);
ALTER TABLE tbl_testdata MODIFY COLUMN `CUST_NM` varchar(200);

-- -------------------------------------------------------
-- 2-2. tbl_piicuststat.MON: date → varchar(50)
-- 기존: DDL=DATETIME, DEV=varchar(50), CLIENT=date
-- 코드 분석: DATE_FORMAT() 결과를 문자열로 저장 → varchar(50)이 정확
-- 주의: 기존 데이터 삭제 후 통계 재생성 필요 (배치 자동 생성)
-- -------------------------------------------------------
TRUNCATE TABLE tbl_piicuststat;
ALTER TABLE tbl_piicuststat MODIFY COLUMN `MON` varchar(50) NOT NULL;

-- -------------------------------------------------------
-- 2-3. tbl_innerstep.RESULT: varchar(300)으로 통일
-- 기존: DEV=varchar(200), CLIENT=varchar(300) → varchar(300)
-- -------------------------------------------------------
ALTER TABLE tbl_innerstep MODIFY COLUMN `RESULT` varchar(300);

-- -------------------------------------------------------
-- 2-3. tbl_piiextract.VAL1/VAL2: varchar(200)으로 통일
-- 기존: DEV=varchar(50), CLIENT=varchar(120) → varchar(200)
-- -------------------------------------------------------
ALTER TABLE tbl_piiextract MODIFY COLUMN `VAL1` varchar(200);
ALTER TABLE tbl_piiextract MODIFY COLUMN `VAL2` varchar(200);

-- -------------------------------------------------------
-- 2-4. EXECNT: int → bigint (대량 처리 시 overflow 방지)
-- DEV 실제값: bigint(20)
-- -------------------------------------------------------
ALTER TABLE tbl_innerstep MODIFY COLUMN `EXECNT` bigint(20) NULL;
ALTER TABLE tbl_piiordersteptable MODIFY COLUMN `EXECNT` bigint(20) NULL;

-- -------------------------------------------------------
-- 2-3. DATA_LENGTH: int → bigint (LONGTEXT/LONGBLOB 4GB 대응)
-- 출처: CATALOG_PATCH_20260411_DATA_LENGTH_BIGINT.sql
-- DEV 실제값: tbl_piitable* = bigint(13), tbl_metatable* = int(아직 미적용)
-- → 고객사에는 모두 bigint로 적용 (패치 기준)
-- -------------------------------------------------------
ALTER TABLE tbl_piitable MODIFY COLUMN `DATA_LENGTH` bigint NULL;
ALTER TABLE tbl_piitable_tmp MODIFY COLUMN `DATA_LENGTH` bigint NULL;
ALTER TABLE tbl_piitable_new MODIFY COLUMN `DATA_LENGTH` bigint NULL;
ALTER TABLE tbl_piitable_old MODIFY COLUMN `DATA_LENGTH` bigint NULL;
ALTER TABLE tbl_metatable MODIFY COLUMN `DATA_LENGTH` bigint NULL;
ALTER TABLE tbl_metatable_tmp MODIFY COLUMN `DATA_LENGTH` bigint NULL;
ALTER TABLE tbl_metatable_new MODIFY COLUMN `DATA_LENGTH` bigint NULL;
ALTER TABLE tbl_metatable_old MODIFY COLUMN `DATA_LENGTH` bigint NULL;


-- ================================================================
-- PART 3: 신규 테이블 생성 (28개)
-- ================================================================

-- -------------------------------------------------------
-- 3-1. 접속기록관리 (AccessLog)
-- → 30_DDL_MASTER_ACCESSLOG.sql 실행으로 대체 (9개 테이블)
--    tbl_access_log, tbl_access_log_source, tbl_access_log_config,
--    tbl_access_log_collect_status, tbl_access_log_alert_rule,
--    tbl_access_log_alert, tbl_access_log_hash_verify,
--    tbl_access_log_download, tbl_access_log_archive_history
-- -------------------------------------------------------

-- AccessLog 추가 테이블 (30_DDL_MASTER_ACCESSLOG에 미포함)

CREATE TABLE IF NOT EXISTS `tbl_access_log_alert_suppression` (
  `suppression_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `rule_id` varchar(50) NOT NULL COMMENT '대상 탐지 규칙 ID',
  `rule_code` varchar(50) DEFAULT NULL COMMENT '규칙 코드',
  `target_user_id` varchar(100) DEFAULT NULL COMMENT '대상 사용자 (NULL=규칙 전체)',
  `suppression_type` varchar(20) NOT NULL DEFAULT 'SUPPRESS' COMMENT 'SUPPRESS/EXCEPTION',
  `reason` text NOT NULL COMMENT '예외 사유 (필수)',
  `severity_at_time` varchar(20) DEFAULT NULL COMMENT '등록 시점 규칙 심각도',
  `source_alert_id` bigint(20) DEFAULT NULL COMMENT '원본 알림 ID',
  `approved_by` varchar(100) NOT NULL COMMENT '승인자 ID',
  `approved_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT '승인일시',
  `effective_from` datetime NOT NULL DEFAULT current_timestamp() COMMENT '유효 시작일',
  `effective_until` datetime NOT NULL COMMENT '유효 만료일 (무기한 불가)',
  `review_cycle_days` int(11) NOT NULL DEFAULT 90 COMMENT '정기 검토 주기 (일)',
  `last_reviewed_at` datetime DEFAULT NULL COMMENT '마지막 검토일시',
  `last_reviewed_by` varchar(100) DEFAULT NULL COMMENT '마지막 검토자',
  `next_review_at` datetime DEFAULT NULL COMMENT '다음 검토 예정일',
  `review_comment` text DEFAULT NULL COMMENT '최근 검토 의견',
  `is_active` char(1) NOT NULL DEFAULT 'Y' COMMENT '활성 여부',
  `deactivated_by` varchar(100) DEFAULT NULL COMMENT '비활성화 처리자',
  `deactivated_at` datetime DEFAULT NULL COMMENT '비활성화 일시',
  `deactivate_reason` varchar(500) DEFAULT NULL COMMENT '비활성화 사유',
  `reg_user_id` varchar(100) DEFAULT NULL,
  `reg_date` datetime DEFAULT current_timestamp(),
  `upd_user_id` varchar(100) DEFAULT NULL,
  `upd_date` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`suppression_id`),
  KEY `idx_suppression_rule` (`rule_id`,`is_active`),
  KEY `idx_suppression_user` (`target_user_id`,`is_active`),
  KEY `idx_suppression_review` (`next_review_at`,`is_active`),
  KEY `idx_suppression_active` (`is_active`,`effective_until`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='알림 예외(억제) 규칙';

CREATE TABLE IF NOT EXISTS `tbl_access_log_alert_suppression_audit` (
  `audit_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `suppression_id` bigint(20) NOT NULL COMMENT '대상 억제 규칙 ID',
  `action_type` varchar(20) NOT NULL COMMENT 'CREATE/UPDATE/DEACTIVATE/REVIEW/EXTEND',
  `action_detail` text DEFAULT NULL COMMENT '변경 내용 상세',
  `action_by` varchar(100) NOT NULL COMMENT '수행자 ID',
  `action_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`audit_id`),
  KEY `idx_audit_suppression` (`suppression_id`),
  KEY `idx_audit_action_at` (`action_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='알림 예외 규칙 감사 로그';

CREATE TABLE IF NOT EXISTS `tbl_access_log_bci_target` (
  `target_id` varchar(36) NOT NULL,
  `db_name` varchar(100) NOT NULL,
  `owner` varchar(128) NOT NULL DEFAULT '',
  `table_name` varchar(128) NOT NULL,
  `target_type` varchar(20) NOT NULL DEFAULT 'PII' COMMENT 'PII/BUSINESS',
  `description` varchar(200) DEFAULT NULL,
  `is_active` varchar(1) NOT NULL DEFAULT 'Y',
  `reg_user_id` varchar(10) DEFAULT NULL,
  `reg_date` datetime DEFAULT current_timestamp(),
  `upd_user_id` varchar(10) DEFAULT NULL,
  `upd_date` datetime DEFAULT NULL,
  PRIMARY KEY (`target_id`),
  UNIQUE KEY `uk_bci_target` (`db_name`,`owner`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='BCI Agent 감사 대상 테이블';

CREATE TABLE IF NOT EXISTS `tbl_access_log_exclude_sql` (
  `pattern_id` int(11) NOT NULL AUTO_INCREMENT,
  `source_type` varchar(20) NOT NULL COMMENT 'DB_AUDIT/DLM_SELF/ALL',
  `pattern` varchar(500) NOT NULL,
  `match_type` varchar(20) NOT NULL DEFAULT 'PREFIX' COMMENT 'PREFIX/CONTAINS/REGEX',
  `description` varchar(200) DEFAULT NULL,
  `is_active` varchar(1) NOT NULL DEFAULT 'Y',
  `reg_user_id` varchar(10) DEFAULT NULL,
  `reg_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`pattern_id`),
  UNIQUE KEY `uk_exclude_sql` (`source_type`,`pattern`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='수집 제외 SQL 패턴';

-- -------------------------------------------------------
-- 3-2. 아카이브 네이밍 설정 — 1개 테이블
-- -------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tbl_archive_naming_config` (
  `config_id` varchar(50) NOT NULL COMMENT '설정 ID (PK)',
  `config_type` varchar(20) NOT NULL COMMENT '설정 타입 (PII/ILM/BACKUP 등)',
  `db` varchar(50) DEFAULT NULL COMMENT '대상 DB (NULL이면 전체 적용)',
  `naming_pattern` varchar(200) NOT NULL COMMENT '네이밍 패턴',
  `prefix_value` varchar(30) DEFAULT NULL COMMENT '프리픽스 값',
  `suffix_value` varchar(30) DEFAULT NULL COMMENT '서픽스 값',
  `SEP_CHAR` varchar(5) DEFAULT '' COMMENT '구분자',
  `case_type` varchar(10) DEFAULT 'UPPER' COMMENT '대소문자 (UPPER/LOWER/AS_IS)',
  `priority` int(11) DEFAULT 100 COMMENT '우선순위 (낮을수록 높음)',
  `use_yn` char(1) DEFAULT 'Y' COMMENT '사용여부',
  `description` varchar(500) DEFAULT NULL COMMENT '설명',
  `regdate` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  `upddate` datetime DEFAULT current_timestamp() COMMENT '수정일시',
  `reguserid` varchar(50) DEFAULT NULL COMMENT '등록자',
  `upduserid` varchar(50) DEFAULT NULL COMMENT '수정자',
  PRIMARY KEY (`config_id`),
  KEY `IDX_ARCHIVE_NAMING_01` (`config_type`,`db`,`priority`),
  KEY `IDX_ARCHIVE_NAMING_02` (`config_type`,`use_yn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='아카이브 스키마 네이밍 설정';

-- -------------------------------------------------------
-- 3-3. PII Discovery (탐지)
-- → 20_DDL_MASTER_DISCOVERY.sql 실행으로 대체 (8개 테이블)
--    tbl_discovery_pii_type, tbl_discovery_rule,
--    tbl_discovery_scan_job_v2, tbl_discovery_scan_execution,
--    tbl_discovery_scan_result, tbl_discovery_config,
--    tbl_discovery_pii_registry, tbl_discovery_table_scan_status
-- -------------------------------------------------------

-- -------------------------------------------------------
-- 3-4. 기타 테이블 — 6개
-- -------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tbl_piiextract_purge_stat` (
  `STAT_DATE` varchar(10) NOT NULL COMMENT 'YYYY/MM/DD 또는 YYYYMM',
  `STAT_TYPE` varchar(20) NOT NULL COMMENT 'ARC_DEL/ARCHIVE/RESTORE_ALL/RESTORE 등',
  `JOBID_PREFIX` varchar(11) NOT NULL COMMENT 'PII_POLICY1/PII_POLICY2/PII_POLICY3/ALL',
  `CNT` int(11) NOT NULL DEFAULT 0,
  `PURGE_DATE` datetime NOT NULL COMMENT '최종 퍼지 실행일',
  PRIMARY KEY (`STAT_DATE`,`STAT_TYPE`,`JOBID_PREFIX`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `tbl_piiextract_purge_log` (
  `CUSTID` varchar(50) NOT NULL COMMENT '고객ID',
  `JOBID` varchar(200) NOT NULL COMMENT '파기 Job ID',
  `BASEDATE` datetime NOT NULL COMMENT '기준일',
  `ORDERID` int(11) NOT NULL COMMENT '오더ID',
  `ARC_DEL_DATE` datetime DEFAULT NULL COMMENT '영구파기일',
  `RESTORE_DATE` datetime DEFAULT NULL COMMENT '복원일',
  `EXCLUDE_REASON` varchar(30) DEFAULT NULL COMMENT 'DELARC 또는 RESTORE',
  `PURGE_DATE` datetime NOT NULL COMMENT '실제 삭제(퍼지) 실행일',
  PRIMARY KEY (`CUSTID`,`JOBID`,`BASEDATE`,`ORDERID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `tbl_progorderhist` (
  `ORDERID` bigint(12) NOT NULL,
  `PROG_JOB_NM` varchar(100) NOT NULL,
  `BGNN_CHNG_DVCD` varchar(10) NOT NULL,
  `PARAM_BASE_DT` varchar(10) NOT NULL,
  `DB` varchar(100) NOT NULL,
  `UPDATE_QUERY` varchar(2000) NOT NULL,
  `INSERT_QUERY` varchar(4000) NOT NULL,
  `CREATED_AT` datetime DEFAULT current_timestamp(),
  `ERROR_MESSAGE` varchar(4000) DEFAULT NULL,
  PRIMARY KEY (`ORDERID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `tbl_faq` (
  `FAQ_ID` int(18) NOT NULL AUTO_INCREMENT,
  `TITLE` varchar(300) NOT NULL,
  `CONTENTS` mediumtext NOT NULL,
  `CATEGORY` varchar(100) DEFAULT NULL,
  `TAGS` varchar(300) DEFAULT NULL,
  `IS_ACTIVE` char(1) NOT NULL DEFAULT 'Y',
  `VIEW_COUNT` int(10) NOT NULL DEFAULT 0,
  `CREATED_BY` varchar(100) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_BY` varchar(100) DEFAULT NULL,
  `UPDATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`FAQ_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `tbl_member_signup` (
  `USERID` varchar(50) NOT NULL,
  `USERPW` varchar(100) DEFAULT NULL,
  `USERNAME` varchar(64) NOT NULL,
  `REGDATE` datetime DEFAULT current_timestamp(),
  `UPDATEDATE` datetime DEFAULT current_timestamp(),
  `ENABLED` char(1) DEFAULT '1',
  `DEPT_CD` varchar(20) NOT NULL,
  `DEPT_NAME` varchar(50) NOT NULL,
  `TELNO` varchar(20) NOT NULL,
  `GRADE` varchar(20) NOT NULL,
  `SOURCE` varchar(50) NOT NULL,
  `APP_VERSION` varchar(20) DEFAULT NULL,
  `CREATED_AT` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`USERID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `tbl_errorhist` (
  `ID` bigint NOT NULL AUTO_INCREMENT,
  `MODULE_NAME` varchar(100) DEFAULT NULL,
  `ERROR_MESSAGE` text DEFAULT NULL,
  `STACK_TRACE` text DEFAULT NULL,
  `CREATED_AT` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- ================================================================
-- END OF PATCH
-- ================================================================
