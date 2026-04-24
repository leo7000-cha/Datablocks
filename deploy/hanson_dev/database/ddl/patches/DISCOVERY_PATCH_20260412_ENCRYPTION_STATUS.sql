-- ============================================================
-- DISCOVERY PATCH: Encryption Status Detection
-- Date: 2026-04-12
-- Description: PII 탐지 결과에 암호화 상태(encryption_status),
--              암호화 방법(encryption_method), 암호화 비율(encryption_ratio) 추가
--              + ENCRYPTED_PII 타입 마스터 추가
-- Purpose: 개인정보 탐지 시 데이터의 암호화/해시 여부를 동시에 식별하여
--          데이터 거버넌스 인벤토리 및 테스트 데이터 생성에 활용
-- ============================================================
-- 적용 방법:
--   mysql -u root -p COTDL < DISCOVERY_PATCH_20260412_ENCRYPTION_STATUS.sql
-- ============================================================

-- 1. TBL_DISCOVERY_SCAN_RESULT: 암호화 상태 컬럼 추가
ALTER TABLE COTDL.TBL_DISCOVERY_SCAN_RESULT
    ADD COLUMN IF NOT EXISTS encryption_status VARCHAR(20) DEFAULT 'NONE' COMMENT '암호화 상태 (NONE, HASHED, ENCRYPTED, UNKNOWN)' AFTER sample_data,
    ADD COLUMN IF NOT EXISTS encryption_method VARCHAR(50) DEFAULT NULL COMMENT '탐지된 암호화 방법 (SHA-256, MD5, BCrypt, AES/Base64 등)' AFTER encryption_status,
    ADD COLUMN IF NOT EXISTS encryption_ratio INT DEFAULT 0 COMMENT '암호화 비율 (0-100%, 샘플 중 암호화된 값의 비율)' AFTER encryption_method;

-- 2. TBL_DISCOVERY_PII_REGISTRY: 암호화 상태 컬럼 추가
ALTER TABLE COTDL.TBL_DISCOVERY_PII_REGISTRY
    ADD COLUMN IF NOT EXISTS encryption_status VARCHAR(20) DEFAULT 'NONE' COMMENT '암호화 상태 (NONE, HASHED, ENCRYPTED, UNKNOWN)' AFTER sample_data,
    ADD COLUMN IF NOT EXISTS encryption_method VARCHAR(50) DEFAULT NULL COMMENT '탐지된 암호화 방법 (SHA-256, MD5, BCrypt, AES/Base64 등)' AFTER encryption_status,
    ADD COLUMN IF NOT EXISTS encryption_ratio INT DEFAULT 0 COMMENT '암호화 비율 (0-100%)' AFTER encryption_method;

-- 3. 인덱스 추가 (암호화 상태 필터링용)
CREATE INDEX IF NOT EXISTS idx_result_encryption_status ON COTDL.TBL_DISCOVERY_SCAN_RESULT (encryption_status);

-- 4. PII 타입 마스터: ENCRYPTED_PII 추가
INSERT IGNORE INTO COTDL.TBL_DISCOVERY_PII_TYPE (
    pii_type_code, pii_type_name, pii_type_name_en, category, description, sort_order, status
) VALUES (
    'ENCRYPTED_PII', '암호화 PII', 'Encrypted PII (Unidentified)',
    'SENSITIVE', '암호화/해시 처리된 개인정보 - 구체적 유형은 암호화로 인해 판별 불가',
    900, 'ACTIVE'
);
