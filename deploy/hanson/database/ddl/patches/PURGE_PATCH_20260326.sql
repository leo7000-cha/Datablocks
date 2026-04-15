-- ============================================================
-- 퍼지 관련 테이블 신규 추가 + 비-파기 Job 이력 퍼지
-- ============================================================
-- 적용 대상: 기존 운영 환경
-- 적용 날짜: 2026-03-26
-- 적용 순서: 이 파일 하나만 실행하면 됩니다.
--
-- [변경 내용]
-- 1. TBL_PIIEXTRACT_PURGE_STAT 신규 추가
--    - tbl_piiextract 영구파기/복원 완료 레코드 퍼지 시 보고서 통계 보존용
--    - 주간 자동 퍼지(매주 일요일 03:00) 도입에 따른 통계 스냅샷 테이블
-- 2. TBL_PIIEXTRACT_PURGE_LOG 신규 추가
--    - 퍼지된 고객별 파기 증적 (개인정보 제외, CUSTID+파기일시만 보존)
--    - 감사/민원 시 "특정 고객이 언제 파기됐는지" 개별 추적용
-- 3. TBL_PIIORDER 비-파기 Job 실행 이력 퍼지 기능 추가
--    - TBL_PIIORDER + 하위 8개 테이블 (ORDERSTEP, ORDERSTEPTABLE, ORDERTHREAD,
--      ORDERJOBWAIT, ORDERSTEPTABLEWAIT, ORDERSTEPTABLEUPDATE, INNERSTEP, ORDERDDL) 대상
--    - jobtype='PII', ARC_DATA_DELETE, RESTORE_CUSTID 제외, 6개월 경과 완료 오더 삭제
--    - DDL 변경 없음 (기존 테이블에서 DELETE만 수행)
-- ============================================================


-- ============================================================
-- 1. TBL_PIIEXTRACT_PURGE_STAT (퍼지된 레코드 통계 보존)
-- ============================================================
DROP TABLE IF EXISTS `COTDL`.`TBL_PIIEXTRACT_PURGE_STAT`;
CREATE TABLE `COTDL`.`TBL_PIIEXTRACT_PURGE_STAT` (
  `STAT_DATE`    VARCHAR(10)  NOT NULL COMMENT 'YYYY/MM/DD 또는 YYYYMM',
  `STAT_TYPE`    VARCHAR(20)  NOT NULL COMMENT 'ARC_DEL, ARCHIVE, RESTORE_ALL, RESTORE, ARC_DEL_DELARC, ARC_DEL_DELARC_P, BASEDATE',
  `JOBID_PREFIX` VARCHAR(11)  NOT NULL COMMENT 'PII_POLICY1, PII_POLICY2, PII_POLICY3, ALL',
  `CNT`          INT          NOT NULL DEFAULT 0,
  `PURGE_DATE`   DATETIME     NOT NULL COMMENT '최종 퍼지 실행일',
  PRIMARY KEY (`STAT_DATE`, `STAT_TYPE`, `JOBID_PREFIX`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- ============================================================
-- 2. TBL_PIIEXTRACT_PURGE_LOG (퍼지된 고객별 파기 증적)
-- ============================================================
DROP TABLE IF EXISTS `COTDL`.`TBL_PIIEXTRACT_PURGE_LOG`;
CREATE TABLE `COTDL`.`TBL_PIIEXTRACT_PURGE_LOG` (
  `CUSTID`       VARCHAR(50)  NOT NULL COMMENT '고객ID',
  `JOBID`        VARCHAR(200) NOT NULL COMMENT '파기 Job ID',
  `BASEDATE`     DATETIME     NOT NULL COMMENT '기준일',
  `ORDERID`      INT          NOT NULL COMMENT '오더ID',
  `ARC_DEL_DATE` DATETIME              COMMENT '영구파기일',
  `RESTORE_DATE` DATETIME              COMMENT '복원일',
  `EXCLUDE_REASON` VARCHAR(30)          COMMENT 'DELARC 또는 RESTORE',
  `PURGE_DATE`   DATETIME     NOT NULL COMMENT '실제 삭제(퍼지) 실행일',
  PRIMARY KEY (`CUSTID`, `JOBID`, `BASEDATE`, `ORDERID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
