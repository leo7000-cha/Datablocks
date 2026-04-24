-- ============================================================
-- iMCapital INDEX Patch
-- Generated: 2026-04-14
-- 비교: iMCapital 현재 vs 개발환경 (COTDL)
-- ============================================================
-- 실행 전 반드시 백업하세요!
-- ============================================================

-- ============================================================
-- SECTION 1: 구 인덱스 삭제 (이름 변경 또는 불필요)
-- ============================================================

-- tbl_piiextract.TBL_PIIEXTRACT_idx01 (CUSTID) → 새 이름: idx_piiextract_custid
DROP INDEX IF EXISTS `TBL_PIIEXTRACT_idx01` ON `tbl_piiextract`;

-- tbl_piiextract.TBL_PIIEXTRACT_idx02 (CUST_NM) → 새 이름: idx_piiextract_cust_nm
DROP INDEX IF EXISTS `TBL_PIIEXTRACT_idx02` ON `tbl_piiextract`;

-- tbl_piiextract.TBL_PIIEXTRACT_idx03 (VAL1) — 개발환경에 없음
DROP INDEX IF EXISTS `TBL_PIIEXTRACT_idx03` ON `tbl_piiextract`;

-- tbl_piiextract.TBL_PIIEXTRACT_idx04 (VAL2) — 개발환경에 없음
DROP INDEX IF EXISTS `TBL_PIIEXTRACT_idx04` ON `tbl_piiextract`;

-- tbl_piiextract.TBL_PIIEXTRACT_idx05 (CUST_PIN) — 개발환경에 없음
DROP INDEX IF EXISTS `TBL_PIIEXTRACT_idx05` ON `tbl_piiextract`;

-- tbl_piiextract.TBL_PIIEXTRACT_idx06 (BIRTH_DT) → 새 이름: idx_piiextract_birth_dt
DROP INDEX IF EXISTS `TBL_PIIEXTRACT_idx06` ON `tbl_piiextract`;

-- tbl_piiextract.TBL_PIIEXTRACT_idx07 (JOBID) → 새 이름: idx_piiextract_jobid
DROP INDEX IF EXISTS `TBL_PIIEXTRACT_idx07` ON `tbl_piiextract`;

-- tbl_piiextract.TBL_PIIEXTRACT_idx08 (DELETE_DATE) → 새 이름: idx_piiextract_delete_date
DROP INDEX IF EXISTS `TBL_PIIEXTRACT_idx08` ON `tbl_piiextract`;

-- tbl_piiextract.idx_piiextract_02 (ARC_DEL_DATE) → 새 이름: idx_piiextract_arc_del_date
DROP INDEX IF EXISTS `idx_piiextract_02` ON `tbl_piiextract`;

-- tbl_piiorder.TBL_PIIORDER_idx01 (JOBID) — 개발환경에 없음
DROP INDEX IF EXISTS `TBL_PIIORDER_idx01` ON `tbl_piiorder`;

-- tbl_piiorder.TBL_PIIORDER_idx02 (BASEDATE) → 새 이름: idx_piiorder_basedate
DROP INDEX IF EXISTS `TBL_PIIORDER_idx02` ON `tbl_piiorder`;

-- tbl_piiorder.TBL_PIIORDER_idx03 (STATUS) → 새 이름: idx_piiorder_status
DROP INDEX IF EXISTS `TBL_PIIORDER_idx03` ON `tbl_piiorder`;

-- tbl_piiorder.TBL_PIIORDER_idx04 (RUNTYPE) → 새 이름: idx_piiorder_runtype
DROP INDEX IF EXISTS `TBL_PIIORDER_idx04` ON `tbl_piiorder`;

-- tbl_piiorder.TBL_PIIORDER_idx05 (JOB_OWNER_ID2) → 새 이름: idx_piiorder_job_owner_id2
DROP INDEX IF EXISTS `TBL_PIIORDER_idx05` ON `tbl_piiorder`;

-- tbl_piiorder.TBL_PIIORDER_idx06 (JOB_OWNER_ID3) → 새 이름: idx_piiorder_job_owner_id3
DROP INDEX IF EXISTS `TBL_PIIORDER_idx06` ON `tbl_piiorder`;

-- tbl_piiorder.TBL_PIIORDER_idx07 (JOB_OWNER_ID1) → 새 이름: idx_piiorder_job_owner_id1
DROP INDEX IF EXISTS `TBL_PIIORDER_idx07` ON `tbl_piiorder`;


-- ============================================================
-- SECTION 2: 신규 인덱스 생성
-- ============================================================

-- ── tbl_errorhist ──
CREATE INDEX `idx_errorhist_created_at` ON `tbl_errorhist` (`CREATED_AT`);
CREATE INDEX `idx_errorhist_module_name` ON `tbl_errorhist` (`MODULE_NAME`);

-- ── tbl_innerstep ──
CREATE INDEX `idx_innerstep_status` ON `tbl_innerstep` (`STATUS`);

-- ── tbl_member ──
CREATE INDEX `idx_member_regdate` ON `tbl_member` (`REGDATE`);

-- ── tbl_metatable ──
CREATE INDEX `idx_metatable_column_name` ON `tbl_metatable` (`COLUMN_NAME`);
CREATE INDEX `idx_metatable_db_owner_table_colid` ON `tbl_metatable` (`DB`, `OWNER`, `TABLE_NAME`, `COLUMN_ID`);
CREATE INDEX `idx_metatable_encript_flag` ON `tbl_metatable` (`ENCRIPT_FLAG`);
CREATE INDEX `idx_metatable_piigrade` ON `tbl_metatable` (`PIIGRADE`);
CREATE INDEX `idx_metatable_piitype` ON `tbl_metatable` (`PIITYPE`);
CREATE INDEX `idx_metatable_regdate` ON `tbl_metatable` (`REGDATE`);
CREATE INDEX `idx_metatable_scramble_type` ON `tbl_metatable` (`SCRAMBLE_TYPE`);
CREATE INDEX `idx_metatable_table_name` ON `tbl_metatable` (`TABLE_NAME`);
CREATE INDEX `idx_metatable_upddate` ON `tbl_metatable` (`UPDDATE`);
CREATE INDEX `idx_metatable_val1` ON `tbl_metatable` (`VAL1`);
CREATE INDEX `idx_metatable_val2` ON `tbl_metatable` (`VAL2`);
CREATE INDEX `idx_metatable_val3` ON `tbl_metatable` (`VAL3`);

-- ── tbl_piiapprovalreq ──
CREATE INDEX `idx_piiapprovalreq_approvalid` ON `tbl_piiapprovalreq` (`APPROVALID`);
CREATE INDEX `idx_piiapprovalreq_jobid` ON `tbl_piiapprovalreq` (`JOBID`);
CREATE INDEX `idx_piiapprovalreq_requesterid` ON `tbl_piiapprovalreq` (`REQUESTERID`);
CREATE INDEX `idx_piiapprovalreq_requestername` ON `tbl_piiapprovalreq` (`REQUESTERNAME`);

-- ── tbl_piicontract ──
CREATE INDEX `idx_piicontract_arc_del_date` ON `tbl_piicontract` (`ARC_DEL_DATE`);
CREATE INDEX `idx_piicontract_delete_date` ON `tbl_piicontract` (`DELETE_DATE`);
CREATE INDEX `idx_piicontract_dept_cd` ON `tbl_piicontract` (`DEPT_CD`);
CREATE INDEX `idx_piicontract_mgmt_dept_status` ON `tbl_piicontract` (`MGMT_DEPT_CD`, `STATUS`);

-- ── tbl_piidatabase ──
CREATE INDEX `idx_piidatabase_system_env` ON `tbl_piidatabase` (`SYSTEM`, `ENV`);

-- ── tbl_piidetect_result ──
CREATE INDEX `idx_piidetect_result_orderid` ON `tbl_piidetect_result` (`ORDERID`);

-- ── tbl_piiextract ──
CREATE INDEX `idx_piiextract_arc_del_date` ON `tbl_piiextract` (`ARC_DEL_DATE`);
CREATE INDEX `idx_piiextract_archive_date` ON `tbl_piiextract` (`ARCHIVE_DATE`);
CREATE INDEX `idx_piiextract_birth_dt` ON `tbl_piiextract` (`BIRTH_DT`);
CREATE INDEX `idx_piiextract_cust_nm` ON `tbl_piiextract` (`CUST_NM`);
CREATE INDEX `idx_piiextract_custid` ON `tbl_piiextract` (`CUSTID`);
CREATE INDEX `idx_piiextract_delete_date` ON `tbl_piiextract` (`DELETE_DATE`);
CREATE INDEX `idx_piiextract_exclude_reason` ON `tbl_piiextract` (`EXCLUDE_REASON`);
CREATE INDEX `idx_piiextract_jobid` ON `tbl_piiextract` (`JOBID`);
CREATE INDEX `idx_piiextract_restore_date` ON `tbl_piiextract` (`RESTORE_DATE`);

-- ── tbl_piijob ──
CREATE INDEX `idx_piijob_policy_id` ON `tbl_piijob` (`POLICY_ID`);
CREATE INDEX `idx_piijob_status_runtype_jobtype` ON `tbl_piijob` (`STATUS`, `RUNTYPE`, `JOBTYPE`);
CREATE INDEX `idx_piijob_system` ON `tbl_piijob` (`SYSTEM`);

-- ── tbl_piiorder ──
CREATE INDEX `idx_piiorder_basedate` ON `tbl_piiorder` (`BASEDATE`);
CREATE INDEX `idx_piiorder_eststarttime` ON `tbl_piiorder` (`ESTSTARTTIME`);
CREATE INDEX `idx_piiorder_job_owner_id1` ON `tbl_piiorder` (`JOB_OWNER_ID1`);
CREATE INDEX `idx_piiorder_job_owner_id2` ON `tbl_piiorder` (`JOB_OWNER_ID2`);
CREATE INDEX `idx_piiorder_job_owner_id3` ON `tbl_piiorder` (`JOB_OWNER_ID3`);
CREATE INDEX `idx_piiorder_job_owner_name1` ON `tbl_piiorder` (`JOB_OWNER_NAME1`);
CREATE INDEX `idx_piiorder_jobid_basedate` ON `tbl_piiorder` (`JOBID`, `BASEDATE`);
CREATE INDEX `idx_piiorder_jobtype_status` ON `tbl_piiorder` (`JOBTYPE`, `STATUS`);
CREATE INDEX `idx_piiorder_keymap_basedate` ON `tbl_piiorder` (`KEYMAP_ID`, `BASEDATE`);
CREATE INDEX `idx_piiorder_orderuserid` ON `tbl_piiorder` (`ORDERUSERID`);
CREATE INDEX `idx_piiorder_realendtime` ON `tbl_piiorder` (`REALENDTIME`);
CREATE INDEX `idx_piiorder_runtype` ON `tbl_piiorder` (`RUNTYPE`);
CREATE INDEX `idx_piiorder_status` ON `tbl_piiorder` (`STATUS`);

-- ── tbl_piiorderstep ──
CREATE INDEX `idx_piiorderstep_orderid_stepseq` ON `tbl_piiorderstep` (`ORDERID`, `STEPSEQ`);
CREATE INDEX `idx_piiorderstep_status` ON `tbl_piiorderstep` (`STATUS`);
CREATE INDEX `idx_piiorderstep_steptype` ON `tbl_piiorderstep` (`STEPTYPE`);

-- ── tbl_piiordersteptable ──
CREATE INDEX `idx_piiordersteptable_db_owner_table` ON `tbl_piiordersteptable` (`DB`, `OWNER`, `TABLE_NAME`);
CREATE INDEX `idx_piiordersteptable_exetype` ON `tbl_piiordersteptable` (`EXETYPE`);
CREATE INDEX `idx_piiordersteptable_jobid_steptype` ON `tbl_piiordersteptable` (`JOBID`, `STEPTYPE`);
CREATE INDEX `idx_piiordersteptable_status` ON `tbl_piiordersteptable` (`STATUS`);

-- ── tbl_piirecovery ──
CREATE INDEX `idx_piirecovery_basedate` ON `tbl_piirecovery` (`BASEDATE`);
CREATE INDEX `idx_piirecovery_old_jobid` ON `tbl_piirecovery` (`OLD_JOBID`);

-- ── tbl_piirestore ──
CREATE INDEX `idx_piirestore_custid` ON `tbl_piirestore` (`CUSTID`);
CREATE INDEX `idx_piirestore_keymap_basedate` ON `tbl_piirestore` (`KEYMAP_ID`, `BASEDATE`);
CREATE INDEX `idx_piirestore_old_orderid` ON `tbl_piirestore` (`OLD_ORDERID`);

-- ── tbl_piistep ──
CREATE INDEX `idx_piistep_jobid_version_stepseq` ON `tbl_piistep` (`JOBID`, `VERSION`, `STEPSEQ`);
CREATE INDEX `idx_piistep_steptype` ON `tbl_piistep` (`STEPTYPE`);

-- ── tbl_piisteptable ──
CREATE INDEX `idx_piisteptable_db_owner_table` ON `tbl_piisteptable` (`DB`, `OWNER`, `TABLE_NAME`);
CREATE INDEX `idx_piisteptable_exetype` ON `tbl_piisteptable` (`EXETYPE`);

-- ── tbl_piitable ──
CREATE INDEX `idx_piitable_column_name` ON `tbl_piitable` (`COLUMN_NAME`);
CREATE INDEX `idx_piitable_db_owner_table_colid` ON `tbl_piitable` (`DB`, `OWNER`, `TABLE_NAME`, `COLUMN_ID`);
CREATE INDEX `idx_piitable_owner_table` ON `tbl_piitable` (`OWNER`, `TABLE_NAME`);
CREATE INDEX `idx_piitable_table_name` ON `tbl_piitable` (`TABLE_NAME`);

-- ── tbl_testdata ──
CREATE INDEX `idx_testdata_custid` ON `tbl_testdata` (`CUSTID`);
CREATE INDEX `idx_testdata_disposal_sche_date` ON `tbl_testdata` (`DISPOSAL_SCHE_DATE`);
CREATE INDEX `idx_testdata_status` ON `tbl_testdata` (`STATUS`);

-- ============================================================
-- END OF PATCH
-- ============================================================