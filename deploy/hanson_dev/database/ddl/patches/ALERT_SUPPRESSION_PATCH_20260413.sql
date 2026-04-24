-- ============================================================
-- 알림 예외(억제) 규칙 테이블 + 감사 로그
-- 개인정보보호법 제29조, 안전성 확보조치 기준 제8조 근거
-- 2026-04-13
-- ============================================================

-- 1. 알림 예외(억제) 규칙 테이블
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_ALERT_SUPPRESSION (
    suppression_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    rule_id           VARCHAR(50)   NOT NULL COMMENT '대상 탐지 규칙 ID',
    rule_code         VARCHAR(50)   NULL     COMMENT '규칙 코드 (표시용)',
    target_user_id    VARCHAR(100)  NULL     COMMENT '대상 사용자 (NULL=규칙 전체)',
    suppression_type  VARCHAR(20)   NOT NULL DEFAULT 'SUPPRESS' COMMENT 'SUPPRESS/EXCEPTION',
    reason            TEXT          NOT NULL COMMENT '예외 사유 (필수)',
    severity_at_time  VARCHAR(20)   NULL     COMMENT '등록 시점 규칙 심각도',
    source_alert_id   BIGINT        NULL     COMMENT '원본 알림 ID (무시 시 자동 생성인 경우)',
    approved_by       VARCHAR(100)  NOT NULL COMMENT '승인자 ID',
    approved_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '승인일시',
    effective_from    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '유효 시작일',
    effective_until   DATETIME      NOT NULL COMMENT '유효 만료일 (무기한 불가)',
    review_cycle_days INT           NOT NULL DEFAULT 90 COMMENT '정기 검토 주기 (일)',
    last_reviewed_at  DATETIME      NULL     COMMENT '마지막 검토일시',
    last_reviewed_by  VARCHAR(100)  NULL     COMMENT '마지막 검토자',
    next_review_at    DATETIME      NULL     COMMENT '다음 검토 예정일',
    review_comment    TEXT          NULL     COMMENT '최근 검토 의견',
    is_active         CHAR(1)       NOT NULL DEFAULT 'Y' COMMENT '활성 여부',
    deactivated_by    VARCHAR(100)  NULL     COMMENT '비활성화 처리자',
    deactivated_at    DATETIME      NULL     COMMENT '비활성화 일시',
    deactivate_reason VARCHAR(500)  NULL     COMMENT '비활성화 사유',
    reg_user_id       VARCHAR(100)  NULL,
    reg_date          DATETIME      DEFAULT CURRENT_TIMESTAMP,
    upd_user_id       VARCHAR(100)  NULL,
    upd_date          DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_suppression_rule    (rule_id, is_active),
    INDEX idx_suppression_user    (target_user_id, is_active),
    INDEX idx_suppression_review  (next_review_at, is_active),
    INDEX idx_suppression_active  (is_active, effective_until)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='알림 예외(억제) 규��';

-- 2. 억제 규칙 변경 감사 로그
CREATE TABLE IF NOT EXISTS COTDL.TBL_ACCESS_LOG_ALERT_SUPPRESSION_AUDIT (
    audit_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    suppression_id    BIGINT        NOT NULL COMMENT '대상 억��� 규칙 ID',
    action_type       VARCHAR(20)   NOT NULL COMMENT 'CREATE/UPDATE/DEACTIVATE/REVIEW/EXTEND',
    action_detail     TEXT          NULL     COMMENT '변경 내용 상세',
    action_by         VARCHAR(100)  NOT NULL COMMENT '수행자 ID',
    action_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_suppression (suppression_id),
    INDEX idx_audit_action_at   (action_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='알림 예외 규칙 감사 로그';
