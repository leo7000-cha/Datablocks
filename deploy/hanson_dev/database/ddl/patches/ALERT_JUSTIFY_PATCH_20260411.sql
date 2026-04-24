-- ============================================================
-- PATCH: 이상행위 알림 소명 워크플로우 컬럼 추가
-- Date: 2026-04-11
-- Description: 소명 요청/승인 프로세스 지원을 위한 컬럼 확장
-- ============================================================

-- 소명 요청 관련
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN notification_sent_at DATETIME NULL COMMENT '소명요청 이메일 발송 시간';
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN notification_token VARCHAR(64) NULL COMMENT '소명 페이지 접근용 일회성 토큰';
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN token_expires_at DATETIME NULL COMMENT '토큰 만료시간';
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN target_user_email VARCHAR(200) NULL COMMENT '대상자 이메일';

-- 대상자 소명 관련
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN justification TEXT NULL COMMENT '대상자 소명(사유) 내용';
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN justified_at DATETIME NULL COMMENT '소명 제출 시간';
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN justified_by VARCHAR(100) NULL COMMENT '소명 제출자';

-- 관리자 승인 관련
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN approver_id VARCHAR(50) NULL COMMENT '승인자 ID';
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN approval_comment TEXT NULL COMMENT '승인자 코멘트';
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN approved_at DATETIME NULL COMMENT '승인 시간';

-- SLA/에스컬레이션
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN sla_deadline DATETIME NULL COMMENT 'SLA 마감시간';
ALTER TABLE COTDL.TBL_ACCESS_LOG_ALERT ADD COLUMN escalation_level INT DEFAULT 0 COMMENT '에스컬레이션 단계 (0=없음, 1=OVERDUE, 2=ESCALATED)';

-- 토큰 인덱스 (소명 페이지 조회용)
CREATE INDEX IDX_ALERT_TOKEN ON COTDL.TBL_ACCESS_LOG_ALERT (notification_token);
