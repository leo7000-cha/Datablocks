-- ============================================================
-- PATCH: TBL_MEMBER 계열 TELNO/GRADE NULLABLE 변경
-- Date: 2026-04-25
-- Description: 운영 사용자 관리 화면(PiiMemberMapper.insert)에서 TELNO/GRADE 를 채우지 않으나
--              DDL 이 NOT NULL 이라 사용자 추가 시 NOT NULL 위반 발생.
--              Java VO/Mapper/JSP 어디에도 사용처가 없는 컬럼이므로 NULLABLE 로 변경.
-- 대상: TBL_MEMBER, TBL_MEMBER_TMP, TBL_MEMBER_NEW, TBL_MEMBER_OLD, TBL_MEMBER_SIGNUP
-- ============================================================


-- ************************************************************
-- [MariaDB / MySQL]
-- ************************************************************

-- ========== TBL_MEMBER ==========
ALTER TABLE COTDL.TBL_MEMBER MODIFY COLUMN TELNO VARCHAR(20) NULL COMMENT '연락처 (운영자 화면에서 미입력 — NULL 허용)';
ALTER TABLE COTDL.TBL_MEMBER MODIFY COLUMN GRADE VARCHAR(20) NULL COMMENT '직급 (운영자 화면에서 미입력 — NULL 허용)';

-- ========== TBL_MEMBER_TMP ==========
ALTER TABLE COTDL.TBL_MEMBER_TMP MODIFY COLUMN TELNO VARCHAR(20) NULL COMMENT '연락처 (운영자 화면에서 미입력 — NULL 허용)';
ALTER TABLE COTDL.TBL_MEMBER_TMP MODIFY COLUMN GRADE VARCHAR(20) NULL COMMENT '직급 (운영자 화면에서 미입력 — NULL 허용)';

-- ========== TBL_MEMBER_NEW ==========
ALTER TABLE COTDL.TBL_MEMBER_NEW MODIFY COLUMN TELNO VARCHAR(20) NULL COMMENT '연락처 (운영자 화면에서 미입력 — NULL 허용)';
ALTER TABLE COTDL.TBL_MEMBER_NEW MODIFY COLUMN GRADE VARCHAR(20) NULL COMMENT '직급 (운영자 화면에서 미입력 — NULL 허용)';

-- ========== TBL_MEMBER_OLD ==========
ALTER TABLE COTDL.TBL_MEMBER_OLD MODIFY COLUMN TELNO VARCHAR(20) NULL COMMENT '연락처 (운영자 화면에서 미입력 — NULL 허용)';
ALTER TABLE COTDL.TBL_MEMBER_OLD MODIFY COLUMN GRADE VARCHAR(20) NULL COMMENT '직급 (운영자 화면에서 미입력 — NULL 허용)';

-- ========== TBL_MEMBER_SIGNUP ==========
ALTER TABLE COTDL.TBL_MEMBER_SIGNUP MODIFY COLUMN TELNO VARCHAR(20) NULL COMMENT '연락처 (NULL 허용)';
ALTER TABLE COTDL.TBL_MEMBER_SIGNUP MODIFY COLUMN GRADE VARCHAR(20) NULL COMMENT '직급 (NULL 허용)';


-- ************************************************************
-- [Oracle] — 원천DB에도 동일 테이블이 있는 경우 수행
-- ************************************************************

-- -- ========== TBL_MEMBER ==========
-- ALTER TABLE COTDL.TBL_MEMBER MODIFY (TELNO VARCHAR2(20) NULL);
-- ALTER TABLE COTDL.TBL_MEMBER MODIFY (GRADE VARCHAR2(20) NULL);

-- -- ========== TBL_MEMBER_TMP ==========
-- ALTER TABLE COTDL.TBL_MEMBER_TMP MODIFY (TELNO VARCHAR2(20) NULL);
-- ALTER TABLE COTDL.TBL_MEMBER_TMP MODIFY (GRADE VARCHAR2(20) NULL);

-- -- ========== TBL_MEMBER_NEW ==========
-- ALTER TABLE COTDL.TBL_MEMBER_NEW MODIFY (TELNO VARCHAR2(20) NULL);
-- ALTER TABLE COTDL.TBL_MEMBER_NEW MODIFY (GRADE VARCHAR2(20) NULL);

-- -- ========== TBL_MEMBER_OLD ==========
-- ALTER TABLE COTDL.TBL_MEMBER_OLD MODIFY (TELNO VARCHAR2(20) NULL);
-- ALTER TABLE COTDL.TBL_MEMBER_OLD MODIFY (GRADE VARCHAR2(20) NULL);

-- -- ========== TBL_MEMBER_SIGNUP ==========
-- ALTER TABLE COTDL.TBL_MEMBER_SIGNUP MODIFY (TELNO VARCHAR2(20) NULL);
-- ALTER TABLE COTDL.TBL_MEMBER_SIGNUP MODIFY (GRADE VARCHAR2(20) NULL);
