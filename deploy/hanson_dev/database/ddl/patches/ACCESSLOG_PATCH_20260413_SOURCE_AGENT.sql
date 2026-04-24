-- ============================================================
-- PATCH: TBL_ACCESS_LOG_SOURCE Agent 컬럼 추가
-- Date : 2026-04-13
-- Desc : BCI Agent 연동을 위한 agent_id, heartbeat, status 컬럼 추가
-- ============================================================

ALTER TABLE COTDL.TBL_ACCESS_LOG_SOURCE
    ADD COLUMN agent_id VARCHAR(36) NULL COMMENT 'BCI Agent ID' AFTER schema_name,
    ADD COLUMN agent_last_heartbeat DATETIME NULL COMMENT 'Agent 마지막 heartbeat 시간' AFTER agent_id,
    ADD COLUMN agent_status VARCHAR(20) DEFAULT NULL COMMENT 'Agent 상태 (ACTIVE/INACTIVE)' AFTER agent_last_heartbeat;

-- agent_id 인덱스 (heartbeat 업데이트 시 조회용)
CREATE INDEX idx_source_agent_id ON COTDL.TBL_ACCESS_LOG_SOURCE (agent_id);
